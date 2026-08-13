/*
 * The workflow engine — Business-Central-style approval routing shared by
 * every document type (member applications, loans, journals).
 *
 * A document's own service module (lib/memberApplications.ts, lib/loanService.ts,
 * lib/gl.ts) asks findMatchingWorkflow() whether an admin-defined workflow
 * applies; if so it calls startWorkflow() instead of doing its own permission-
 * gated approval. Nothing here imports those modules at the top level — the
 * finalize step (a task's last step is approved / any step is rejected) reaches
 * back into them with a dynamic import, so the two directions of the reference
 * never form a real circular dependency at module-evaluation time.
 */
import { one, all, run, tx, audit } from './db.ts';
import { AppError } from './errors.ts';
import { sendMail, approvalRequestedEmail, approvalDecidedEmail } from './mailer.ts';
import { notify } from './notifications.ts';
import { DOCUMENT_LINK, documentLabel } from './workflowConstants.ts';
import type {
  Actor, ApprovalUserSetupRow, Cents, Workflow, WorkflowApproverType, WorkflowCondition,
  WorkflowConditionOperator, WorkflowDocumentType, WorkflowStep, WorkflowTask, WorkflowTaskRow,
  WorkflowUserGroupWithUsage, WorkflowWithDetail,
} from './types.ts';

export * from './workflowConstants.ts';

/* ----------------------------------------------------------- condition match */

function evalCondition(fieldValue: number | string | null, c: WorkflowCondition): boolean {
  if (fieldValue === null || fieldValue === undefined || fieldValue === '') return false;
  const num = Number(fieldValue);
  const numeric = !Number.isNaN(num) && !Number.isNaN(Number(c.value));
  switch (c.operator) {
    case '=': return numeric ? num === Number(c.value) : String(fieldValue) === c.value;
    case '!=': return numeric ? num !== Number(c.value) : String(fieldValue) !== c.value;
    case '>': return numeric && num > Number(c.value);
    case '>=': return numeric && num >= Number(c.value);
    case '<': return numeric && num < Number(c.value);
    case '<=': return numeric && num <= Number(c.value);
    case 'BETWEEN': return numeric && num >= Number(c.value) && num <= Number(c.value2 ?? c.value);
    default: return false;
  }
}

/** The first ACTIVE workflow (with at least one step) whose conditions all match. */
export async function findMatchingWorkflow(
  documentType: WorkflowDocumentType,
  fields: Record<string, number | string | null>,
): Promise<{ workflow: Workflow; steps: WorkflowStep[] } | null> {
  const workflows = await all<Workflow>(
    "SELECT * FROM workflow WHERE document_type = ? AND status = 'ACTIVE' ORDER BY id", documentType,
  );
  for (const wf of workflows) {
    const conditions = await all<WorkflowCondition>(
      'SELECT * FROM workflow_condition WHERE workflow_id = ?', wf.id,
    );
    if (!conditions.every((c) => evalCondition(fields[c.field] ?? null, c))) continue;
    const steps = await all<WorkflowStep>(
      'SELECT * FROM workflow_step WHERE workflow_id = ? ORDER BY step_no', wf.id,
    );
    if (!steps.length) continue;
    return { workflow: wf, steps };
  }
  return null;
}

/* -------------------------------------------------------------- routing */

async function resolveApprover(
  step: WorkflowStep, requestedByUsername: string,
): Promise<{ userIds: number[]; groupId: number | null }> {
  if (step.approver_type === 'USER') {
    return { userIds: step.approver_user_id ? [step.approver_user_id] : [], groupId: null };
  }
  if (step.approver_type === 'USER_GROUP') {
    return { userIds: [], groupId: step.approver_group_id };
  }

  // DIRECT_APPROVER: the requester's configured approver, falling back to
  // whoever is flagged as an Approval Administrator if none is set up.
  const requester = await one<{ id: number }>(
    'SELECT id FROM app_user WHERE username = ?', requestedByUsername,
  );
  if (!requester) throw new AppError('Requesting user not found', 'USER_NOT_FOUND');

  const setup = await one<{ approver_id: number | null }>(
    'SELECT approver_id FROM approval_user_setup WHERE user_id = ?', requester.id,
  );
  if (setup?.approver_id) return { userIds: [setup.approver_id], groupId: null };

  const admins = await all<{ user_id: number }>(
    'SELECT user_id FROM approval_user_setup WHERE is_approval_administrator = 1',
  );
  if (admins.length) return { userIds: admins.map((a) => a.user_id), groupId: null };

  throw new AppError(
    'No approver is configured for this request. Ask an administrator to set up an Approver in '
    + 'Approval User Setup, or flag someone as an Approval Administrator.',
    'NO_APPROVER',
  );
}

/** Every user who may currently act on a task: the assignee, their substitute, or a group's members. */
async function eligibleUserIds(
  task: Pick<WorkflowTask, 'assigned_to_user_id' | 'assigned_to_group_id'>,
): Promise<number[]> {
  const ids: number[] = [];
  if (task.assigned_to_user_id) {
    ids.push(task.assigned_to_user_id);
    const setup = await one<{ substitute_id: number | null }>(
      'SELECT substitute_id FROM approval_user_setup WHERE user_id = ?', task.assigned_to_user_id,
    );
    if (setup?.substitute_id) ids.push(setup.substitute_id);
  }
  if (task.assigned_to_group_id) {
    const members = await all<{ user_id: number }>(
      'SELECT user_id FROM workflow_user_group_member WHERE group_id = ?', task.assigned_to_group_id,
    );
    ids.push(...members.map((m) => m.user_id));
  }
  return ids;
}

export interface StartWorkflowInput {
  documentType: WorkflowDocumentType;
  /** The document's own key — loan.id, member_application.no, or a minted journal-draft reference. */
  entityId: string;
  requestedBy: string;
  amount: Cents;
  /** Serialized document data a JOURNAL task needs to actually post once approved. */
  payload?: string | null;
}

async function createTaskForStep(workflowId: number, step: WorkflowStep, input: StartWorkflowInput): Promise<number> {
  const { userIds, groupId } = await resolveApprover(step, input.requestedBy);
  const primaryUserId = userIds[0] ?? null;

  const info = await run(
    `INSERT INTO workflow_task
       (workflow_id, workflow_step_id, step_no, document_type, entity_id, assigned_to_user_id,
        assigned_to_group_id, status, requested_by, requested_at, amount, payload)
     VALUES (?,?,?,?,?,?,?,'PENDING',?,?,?,?)`,
    workflowId, step.id, step.step_no, input.documentType, input.entityId, primaryUserId,
    groupId, input.requestedBy, new Date().toISOString(), input.amount, input.payload ?? null,
  );
  const taskId = Number(info.lastInsertRowid);

  const recipients = await eligibleUserIds({ assigned_to_user_id: primaryUserId, assigned_to_group_id: groupId });
  const label = documentLabel(input.documentType, input.entityId);
  const link = DOCUMENT_LINK[input.documentType](input.entityId);
  for (const uid of recipients) {
    await notify(uid, 'WORKFLOW_PENDING', `Approval needed: ${label}`, `Requested by ${input.requestedBy}`, link);
  }
  if (step.notify_email && recipients.length) {
    const rows = await all<{ email: string | null }>(
      `SELECT email FROM app_user WHERE id IN (${recipients.map(() => '?').join(',')})`, ...recipients,
    );
    for (const r of rows) {
      if (!r.email) continue;
      await sendMail({
        to: r.email,
        subject: `Approval needed: ${label}`,
        html: approvalRequestedEmail(label, input.requestedBy, link),
      });
    }
  }
  return taskId;
}

/** Kick off the first step of a matched workflow against a freshly-submitted document. */
export async function startWorkflow(
  workflow: Workflow, steps: WorkflowStep[], input: StartWorkflowInput,
): Promise<number> {
  return createTaskForStep(workflow.id, steps[0], input);
}

/**
 * A document type with no matching workflow keeps its old, static-permission
 * behavior — but loans have always kept a task row for the dashboard/queue
 * count, so this preserves that bookkeeping without routing to anyone specific.
 */
export async function startLegacyTask(input: StartWorkflowInput): Promise<number> {
  const info = await run(
    `INSERT INTO workflow_task
       (workflow_id, workflow_step_id, step_no, document_type, entity_id, status, requested_by, requested_at, amount, payload)
     VALUES (NULL,NULL,1,?,?,'PENDING',?,?,?,?)`,
    input.documentType, input.entityId, input.requestedBy, new Date().toISOString(), input.amount, input.payload ?? null,
  );
  return Number(info.lastInsertRowid);
}

/** Record a decision made through the old static-permission path (no assignee to check). */
export async function recordLegacyDecision(
  documentType: WorkflowDocumentType, entityId: string, approved: boolean, reason: string | null, user: Actor,
): Promise<void> {
  await run(
    `UPDATE workflow_task SET status=?, decided_by=?, decided_at=?, comment=?
     WHERE document_type=? AND entity_id=? AND workflow_id IS NULL AND status='PENDING'`,
    approved ? 'APPROVED' : 'REJECTED', user.username, new Date().toISOString(), reason, documentType, entityId,
  );
}

async function finalizeDocument(task: WorkflowTask, approved: boolean, decidedBy: Actor, reason: string | null): Promise<void> {
  switch (task.document_type) {
    case 'MEMBER_APPLICATION': {
      const svc = await import('./memberApplications.ts');
      if (approved) await svc.approveMemberApplication(task.entity_id, decidedBy);
      else await svc.rejectMemberApplication(task.entity_id, reason, decidedBy);
      break;
    }
    case 'LOAN': {
      const svc = await import('./loanService.ts');
      await svc.approve({ loanId: Number(task.entity_id), user: decidedBy, approve: approved, reason });
      break;
    }
    case 'JOURNAL': {
      if (approved && task.payload) {
        const svc = await import('./gl.ts');
        await svc.postManualJournal(JSON.parse(task.payload), decidedBy);
      }
      break;
    }
  }
}

async function notifyRequester(task: WorkflowTask, approved: boolean, decidedByUsername: string, comment: string | null): Promise<void> {
  const requester = await one<{ id: number; email: string | null }>(
    'SELECT id, email FROM app_user WHERE username = ?', task.requested_by,
  );
  if (!requester) return;
  const label = documentLabel(task.document_type, task.entity_id);
  const link = DOCUMENT_LINK[task.document_type](task.entity_id);
  await notify(
    requester.id, approved ? 'WORKFLOW_APPROVED' : 'WORKFLOW_REJECTED',
    `${label} ${approved ? 'approved' : 'rejected'}`, comment || null, link,
  );
  if (requester.email) {
    await sendMail({
      to: requester.email,
      subject: `${label} ${approved ? 'approved' : 'rejected'}`,
      html: approvalDecidedEmail(label, approved, decidedByUsername, comment, link),
    });
  }
}

/** Whether a document is currently routed through a workflow — the action layer uses this to
 *  decide between the assignment-based decideWorkflowTask() path and the legacy permission-gated one. */
export async function findPendingRoutedTask(
  documentType: WorkflowDocumentType, entityId: string,
): Promise<WorkflowTask | null> {
  const task = await one<WorkflowTask>(
    "SELECT * FROM workflow_task WHERE document_type=? AND entity_id=? AND workflow_id IS NOT NULL AND status='PENDING'",
    documentType, String(entityId),
  );
  return task || null;
}

export interface DecideResult { finalized: boolean; approved: boolean }

/** Act on a routed (workflow_id set) task — authorization is by assignment, not a raw permission. */
export async function decideWorkflowTask(
  taskId: number, decision: boolean, comment: string | null, actingUser: Actor,
): Promise<DecideResult> {
  const task = await one<WorkflowTask>('SELECT * FROM workflow_task WHERE id = ?', taskId);
  if (!task) throw new AppError('Approval task not found', 'NOT_FOUND');
  if (task.status !== 'PENDING') throw new AppError('This item has already been decided', 'BAD_STATUS');
  if (!task.workflow_id) throw new AppError('This item is not routed through a workflow', 'NOT_ROUTED');
  if (!(await eligibleUserIds(task)).includes(actingUser.id)) {
    throw new AppError('You are not the assigned approver for this item', 'NOT_ASSIGNED');
  }

  return tx(async () => {
    await run(
      'UPDATE workflow_task SET status=?, decided_by=?, decided_at=?, comment=? WHERE id=?',
      decision ? 'APPROVED' : 'REJECTED', actingUser.username, new Date().toISOString(), comment, taskId,
    );
    await audit(actingUser, decision ? 'WORKFLOW_TASK_APPROVE' : 'WORKFLOW_TASK_REJECT', task.document_type, task.entity_id, { comment });

    if (!decision) {
      await finalizeDocument(task, false, actingUser, comment);
      await notifyRequester(task, false, actingUser.username, comment);
      return { finalized: true, approved: false };
    }

    const nextStep = await one<WorkflowStep>(
      'SELECT * FROM workflow_step WHERE workflow_id = ? AND step_no = ?', task.workflow_id, task.step_no + 1,
    );
    if (nextStep) {
      await createTaskForStep(task.workflow_id!, nextStep, {
        documentType: task.document_type, entityId: task.entity_id, requestedBy: task.requested_by,
        amount: task.amount, payload: task.payload,
      });
      return { finalized: false, approved: true };
    }

    await finalizeDocument(task, true, actingUser, comment);
    await notifyRequester(task, true, actingUser.username, comment);
    return { finalized: true, approved: true };
  });
}

/* --------------------------------------------------------------- worklists */

async function decorateTasks(rows: WorkflowTask[]): Promise<WorkflowTaskRow[]> {
  const workflowIds = [...new Set(rows.map((r) => r.workflow_id).filter((x): x is number => x != null))];
  const workflows = workflowIds.length
    ? await all<{ id: number; name: string }>(
      `SELECT id, name FROM workflow WHERE id IN (${workflowIds.map(() => '?').join(',')})`, ...workflowIds,
    )
    : [];
  const nameById = new Map(workflows.map((w) => [w.id, w.name]));
  return rows.map((r) => ({
    ...r,
    workflow_name: r.workflow_id ? nameById.get(r.workflow_id) ?? null : null,
    document_label: documentLabel(r.document_type, r.entity_id),
    link: DOCUMENT_LINK[r.document_type](r.entity_id),
  }));
}

/** Pending tasks I may act on: assigned to me directly, as someone's substitute, or via a group. */
export async function listMyWorkflowTasks(userId: number): Promise<WorkflowTaskRow[]> {
  const rows = await all<WorkflowTask>(
    `SELECT DISTINCT t.* FROM workflow_task t
     LEFT JOIN approval_user_setup su ON su.user_id = t.assigned_to_user_id AND su.substitute_id = ?
     LEFT JOIN workflow_user_group_member gm ON gm.group_id = t.assigned_to_group_id AND gm.user_id = ?
     WHERE t.status = 'PENDING' AND t.workflow_id IS NOT NULL
       AND (t.assigned_to_user_id = ? OR su.user_id IS NOT NULL OR gm.user_id IS NOT NULL)
     ORDER BY t.requested_at`,
    userId, userId, userId,
  );
  return decorateTasks(rows);
}

/** Pending legacy (unrouted) tasks for a document type — anyone with the static permission may act. */
export async function listLegacyPendingTasks(documentType: WorkflowDocumentType): Promise<WorkflowTaskRow[]> {
  const rows = await all<WorkflowTask>(
    "SELECT * FROM workflow_task WHERE workflow_id IS NULL AND document_type = ? AND status = 'PENDING' ORDER BY requested_at",
    documentType,
  );
  return decorateTasks(rows);
}

/** Recent decision history across everyone — the org-wide maker-checker audit view. */
export async function listWorkflowTaskHistory(limit = 200): Promise<WorkflowTaskRow[]> {
  const rows = await all<WorkflowTask>(
    "SELECT * FROM workflow_task WHERE status != 'PENDING' ORDER BY decided_at DESC NULLS LAST, id DESC LIMIT ?", limit,
  );
  return decorateTasks(rows);
}

export const pendingWorkflowTaskCount = async (): Promise<number> =>
  (await one<{ c: number }>("SELECT COUNT(*) c FROM workflow_task WHERE status = 'PENDING'"))!.c;

/* ------------------------------------------------------------- admin: workflows */

export interface WorkflowInput {
  name?: string;
  document_type?: WorkflowDocumentType;
  status?: string | null;
}

export interface ConditionDraft {
  field: string;
  operator: WorkflowConditionOperator;
  value: string;
  value2?: string | null;
}

export interface StepDraft {
  approver_type: WorkflowApproverType;
  approver_user_id?: number | null;
  approver_group_id?: number | null;
  notify_email?: number;
}

export const listWorkflows = (): Promise<WorkflowWithDetail[]> => withDetail(
  all<Workflow>('SELECT * FROM workflow ORDER BY id'),
);

async function withDetail(promise: Promise<Workflow[]>): Promise<WorkflowWithDetail[]> {
  const workflows = await promise;
  return Promise.all(workflows.map(async (w) => ({
    ...w,
    conditions: await all<WorkflowCondition>('SELECT * FROM workflow_condition WHERE workflow_id = ?', w.id),
    steps: await all<WorkflowStep>('SELECT * FROM workflow_step WHERE workflow_id = ? ORDER BY step_no', w.id),
  })));
}

async function replaceConditionsAndSteps(
  workflowId: number, conditions: ConditionDraft[], steps: StepDraft[],
): Promise<void> {
  await run('DELETE FROM workflow_condition WHERE workflow_id = ?', workflowId);
  await run('DELETE FROM workflow_step WHERE workflow_id = ?', workflowId);
  for (const c of conditions) {
    if (!c.field || !c.operator || c.value === undefined || c.value === '') continue;
    await run(
      'INSERT INTO workflow_condition (workflow_id, field, operator, value, value2) VALUES (?,?,?,?,?)',
      workflowId, c.field, c.operator, c.value, c.value2 || null,
    );
  }
  let stepNo = 1;
  for (const s of steps) {
    if (!s.approver_type) continue;
    if (s.approver_type === 'USER' && !s.approver_user_id) continue;
    if (s.approver_type === 'USER_GROUP' && !s.approver_group_id) continue;
    await run(
      `INSERT INTO workflow_step (workflow_id, step_no, approver_type, approver_user_id, approver_group_id, notify_email)
       VALUES (?,?,?,?,?,?)`,
      workflowId, stepNo++, s.approver_type, s.approver_user_id || null, s.approver_group_id || null,
      s.notify_email ? 1 : 0,
    );
  }
}

export async function createWorkflow(
  body: WorkflowInput, conditions: ConditionDraft[], steps: StepDraft[], user: Actor,
): Promise<{ id: number }> {
  if (!body.name || !body.document_type) throw new AppError('Name and document type are required', 'VALIDATION');
  return tx(async () => {
    const info = await run(
      'INSERT INTO workflow (name, document_type, status, created_at, created_by) VALUES (?,?,?,?,?)',
      body.name, body.document_type, body.status || 'ACTIVE', new Date().toISOString(), user.username,
    );
    const id = Number(info.lastInsertRowid);
    await replaceConditionsAndSteps(id, conditions, steps);
    await audit(user, 'WORKFLOW_CREATE', 'workflow', id, { name: body.name });
    return { id };
  });
}

export async function updateWorkflow(
  id: number, body: WorkflowInput, conditions: ConditionDraft[], steps: StepDraft[], user: Actor,
): Promise<{ id: number }> {
  return tx(async () => {
    await run(
      'UPDATE workflow SET name=COALESCE(?,name), document_type=COALESCE(?,document_type), status=COALESCE(?,status) WHERE id=?',
      body.name ?? null, body.document_type ?? null, body.status ?? null, id,
    );
    await replaceConditionsAndSteps(id, conditions, steps);
    await audit(user, 'WORKFLOW_UPDATE', 'workflow', id, { name: body.name });
    return { id };
  });
}

/* ------------------------------------------------------- admin: user groups */

export const listWorkflowUserGroups = (): Promise<WorkflowUserGroupWithUsage[]> =>
  all<WorkflowUserGroupWithUsage>(
    `SELECT g.*, COUNT(m.id) AS members FROM workflow_user_group g
     LEFT JOIN workflow_user_group_member m ON m.group_id = g.id
     GROUP BY g.id ORDER BY g.name`,
  );

export const listWorkflowUserGroupMembers = (groupId: number): Promise<number[]> =>
  all<{ user_id: number }>('SELECT user_id FROM workflow_user_group_member WHERE group_id = ?', groupId)
    .then((rows) => rows.map((r) => r.user_id));

export interface WorkflowUserGroupInput {
  name?: string;
  status?: string | null;
}

async function replaceGroupMembers(groupId: number, userIds: number[]): Promise<void> {
  await run('DELETE FROM workflow_user_group_member WHERE group_id = ?', groupId);
  for (const userId of [...new Set(userIds)]) {
    await run('INSERT INTO workflow_user_group_member (group_id, user_id) VALUES (?,?)', groupId, userId);
  }
}

export async function createWorkflowUserGroup(
  body: WorkflowUserGroupInput, memberUserIds: number[], user: Actor,
): Promise<{ id: number }> {
  if (!body.name) throw new AppError('Group name is required', 'VALIDATION');
  return tx(async () => {
    if (await one('SELECT 1 FROM workflow_user_group WHERE name = ?', body.name)) {
      throw new AppError('That group already exists', 'DUPLICATE');
    }
    const info = await run(
      'INSERT INTO workflow_user_group (name, status) VALUES (?,?)', body.name, body.status || 'ACTIVE',
    );
    const id = Number(info.lastInsertRowid);
    await replaceGroupMembers(id, memberUserIds);
    await audit(user, 'WORKFLOW_GROUP_CREATE', 'workflow_user_group', id, { name: body.name });
    return { id };
  });
}

export async function updateWorkflowUserGroup(
  id: number, body: WorkflowUserGroupInput, memberUserIds: number[], user: Actor,
): Promise<{ id: number }> {
  return tx(async () => {
    await run(
      'UPDATE workflow_user_group SET name=COALESCE(?,name), status=COALESCE(?,status) WHERE id=?',
      body.name ?? null, body.status ?? null, id,
    );
    await replaceGroupMembers(id, memberUserIds);
    await audit(user, 'WORKFLOW_GROUP_UPDATE', 'workflow_user_group', id, { name: body.name });
    return { id };
  });
}

/* ------------------------------------------------------ admin: approval user setup */

export const listApprovalUserSetup = (): Promise<ApprovalUserSetupRow[]> =>
  all<ApprovalUserSetupRow>(
    `SELECT u.id AS user_id, u.username, u.full_name,
            s.approver_id, a.full_name AS approver_name,
            s.substitute_id, sub.full_name AS substitute_name,
            COALESCE(s.is_approval_administrator, 0) AS is_approval_administrator
     FROM app_user u
     LEFT JOIN approval_user_setup s ON s.user_id = u.id
     LEFT JOIN app_user a ON a.id = s.approver_id
     LEFT JOIN app_user sub ON sub.id = s.substitute_id
     ORDER BY u.full_name`,
  );

export interface ApprovalUserSetupInput {
  approver_id?: number | null;
  substitute_id?: number | null;
  is_approval_administrator?: number;
}

export async function saveApprovalUserSetup(
  userId: number, body: ApprovalUserSetupInput, user: Actor,
): Promise<void> {
  await run(
    `INSERT INTO approval_user_setup (user_id, approver_id, substitute_id, is_approval_administrator)
     VALUES (?,?,?,?)
     ON CONFLICT (user_id) DO UPDATE SET
       approver_id = EXCLUDED.approver_id,
       substitute_id = EXCLUDED.substitute_id,
       is_approval_administrator = EXCLUDED.is_approval_administrator`,
    userId, body.approver_id || null, body.substitute_id || null, body.is_approval_administrator ? 1 : 0,
  );
  await audit(user, 'APPROVAL_USER_SETUP_SAVE', 'approval_user_setup', userId, body);
}
