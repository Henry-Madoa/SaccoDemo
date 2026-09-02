/*
 * Account Instructions — AL "Account Instructions" (Tab52204129) master list and "Member Account
 * Instructions" (Tab52204009) lines. A line is either PREDEFINED (its text must match an active
 * master instruction — the "dropdown" the admin defines) or USER_DEFINED (free text for a
 * one-off). The same line shape is staged on a member application and a member edit request and
 * copied onto the member when the document is processed.
 */
import { one, all, run, tx, audit } from './db.ts';
import { AppError } from './errors.ts';
import type {
  AccountInstruction, AccountInstructionLine, AccountInstructionType, Actor,
  MemberAccountInstruction, MemberApplicationAccountInstruction, MemberEditAccountInstruction,
} from './types.ts';

/* ------------------------------------------------------------------- master */

export const listAccountInstructions = (): Promise<AccountInstruction[]> =>
  all<AccountInstruction>('SELECT * FROM account_instruction ORDER BY sort, description');

export const listActiveAccountInstructions = (): Promise<AccountInstruction[]> =>
  all<AccountInstruction>('SELECT * FROM account_instruction WHERE active = 1 ORDER BY sort, description');

export interface AccountInstructionInput {
  code: string;
  description: string;
  active: boolean;
  sort: number;
}

export async function saveAccountInstruction(
  input: AccountInstructionInput, id: number | null, user: Actor,
): Promise<void> {
  const code = String(input.code || '').trim().toUpperCase();
  const description = String(input.description || '').trim();
  if (!code) throw new AppError('A code is required');
  if (!description) throw new AppError('A description is required');
  if (!/^[A-Z0-9_]+$/.test(code)) throw new AppError('Code may use letters, digits and underscore only');

  const clash = await one<{ id: number }>(
    'SELECT id FROM account_instruction WHERE code = ? AND id <> ?', code, id ?? 0,
  );
  if (clash) throw new AppError(`Account instruction "${code}" already exists`);

  if (id) {
    await run(
      'UPDATE account_instruction SET code = ?, description = ?, active = ?, sort = ? WHERE id = ?',
      code, description, input.active ? 1 : 0, Math.trunc(input.sort) || 0, id,
    );
  } else {
    await run(
      'INSERT INTO account_instruction (code, description, active, sort) VALUES (?,?,?,?)',
      code, description, input.active ? 1 : 0, Math.trunc(input.sort) || 0,
    );
  }
  await audit(user, id ? 'ACCOUNT_INSTRUCTION_UPDATE' : 'ACCOUNT_INSTRUCTION_CREATE', 'account_instruction', id ?? code, input);
}

export async function deleteAccountInstruction(id: number, user: Actor): Promise<void> {
  const row = await one<AccountInstruction>('SELECT * FROM account_instruction WHERE id = ?', id);
  if (!row) return;
  // Lines keep the free text, so deleting a master row never orphans data — but a still-referenced
  // instruction is better deactivated than deleted.
  const inUse = await one<{ c: number }>(
    `SELECT (SELECT COUNT(*) FROM member_account_instruction WHERE instruction = ?)
          + (SELECT COUNT(*) FROM member_application_account_instruction WHERE instruction = ?)
          + (SELECT COUNT(*) FROM member_edit_account_instruction WHERE instruction = ?) AS c`,
    row.description, row.description, row.description,
  );
  if (Number(inUse?.c ?? 0) > 0) {
    throw new AppError('This instruction is in use — deactivate it instead of deleting');
  }
  await run('DELETE FROM account_instruction WHERE id = ?', id);
  await audit(user, 'ACCOUNT_INSTRUCTION_DELETE', 'account_instruction', id);
}

/* --------------------------------------------------------------------- lines */

export interface AccountInstructionDraft {
  instruction_type: AccountInstructionType;
  instruction: string;
}

/** Normalises a submitted list: trims, drops blanks, and (for user-entered lists) checks every
 *  PREDEFINED line against the active master list. `trusted` skips that check for lists that are
 *  merely being copied between documents — those were validated when first saved, and a master
 *  instruction deactivated in the meantime must not block processing. */
async function cleanLines(rows: AccountInstructionDraft[], trusted = false): Promise<AccountInstructionDraft[]> {
  const clean = rows
    .map((r) => ({
      instruction_type: (r.instruction_type === 'PREDEFINED' ? 'PREDEFINED' : 'USER_DEFINED') as AccountInstructionType,
      instruction: String(r.instruction || '').trim(),
    }))
    .filter((r) => r.instruction);

  const predefined = clean.filter((r) => r.instruction_type === 'PREDEFINED');
  if (!trusted && predefined.length) {
    const active = await listActiveAccountInstructions();
    const known = new Set(active.map((a) => a.description));
    for (const r of predefined) {
      if (!known.has(r.instruction)) {
        throw new AppError(`"${r.instruction}" is not an active predefined account instruction`, 'VALIDATION');
      }
    }
  }
  return clean;
}

const TABLE = {
  member: { table: 'member_account_instruction', key: 'member_id' },
  application: { table: 'member_application_account_instruction', key: 'application_no' },
  edit: { table: 'member_edit_account_instruction', key: 'edit_no' },
} as const;

async function listLines(scope: keyof typeof TABLE, owner: string | number) {
  const { table, key } = TABLE[scope];
  return all<{ id: number; line_no: number; instruction_type: AccountInstructionType; instruction: string }>(
    `SELECT id, line_no, instruction_type, instruction FROM ${table} WHERE ${key} = ? ORDER BY line_no, id`,
    owner,
  );
}

async function replaceLines(
  scope: keyof typeof TABLE, owner: string | number, rows: AccountInstructionDraft[], trusted = false,
) {
  const { table, key } = TABLE[scope];
  const clean = await cleanLines(rows, trusted);
  await tx(async () => {
    await run(`DELETE FROM ${table} WHERE ${key} = ?`, owner);
    let lineNo = 10000;
    for (const r of clean) {
      await run(
        `INSERT INTO ${table} (${key}, line_no, instruction_type, instruction) VALUES (?,?,?,?)`,
        owner, lineNo, r.instruction_type, r.instruction,
      );
      lineNo += 10000;
    }
  });
}

export const listMemberAccountInstructions = (memberId: number): Promise<MemberAccountInstruction[]> =>
  listLines('member', memberId) as Promise<MemberAccountInstruction[]>;
export const listApplicationAccountInstructions = (no: string): Promise<MemberApplicationAccountInstruction[]> =>
  listLines('application', no) as Promise<MemberApplicationAccountInstruction[]>;
export const listEditAccountInstructions = (no: string): Promise<MemberEditAccountInstruction[]> =>
  listLines('edit', no) as Promise<MemberEditAccountInstruction[]>;

export const replaceApplicationAccountInstructions = (no: string, rows: AccountInstructionDraft[]): Promise<void> =>
  replaceLines('application', no, rows);
export const replaceEditAccountInstructions = (no: string, rows: AccountInstructionDraft[]): Promise<void> =>
  replaceLines('edit', no, rows);

const toDrafts = (lines: AccountInstructionLine[]): AccountInstructionDraft[] =>
  lines.map((l) => ({ instruction_type: l.instruction_type, instruction: l.instruction }));

/** Member Editing: seed the edit request's instruction lines from the live member's own list. */
export async function seedEditAccountInstructions(memberId: number, editNo: string): Promise<void> {
  await replaceLines('edit', editNo, toDrafts(await listLines('member', memberId)), true);
}

/** Member Editing: apply the (approved) edit request's instruction lines onto the member. */
export async function applyEditAccountInstructions(editNo: string, memberId: number, user: Actor): Promise<void> {
  await replaceLines('member', memberId, toDrafts(await listLines('edit', editNo)), true);
  await audit(user, 'MEMBER_ACCOUNT_INSTRUCTIONS_SET', 'member', memberId, { via: editNo });
}
