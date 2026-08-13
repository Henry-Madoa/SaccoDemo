import { notFound } from 'next/navigation';
import { requireUser } from '@/lib/session';
import { can, PERMISSIONS } from '@/lib/auth';
import { getOrg, getTheme, themePresets, TOKEN_GROUPS } from '@/lib/org';
import {
  listUsers, listRoles, listSavingsProducts, listLoanProducts, listAuditLog,
  listActiveSavingsProducts,
} from '@/lib/admin';
import { listPostableAccounts } from '@/lib/gl';
import {
  listMemberCategories, getMemberCategoryDefaultAccounts, listCounties, listSubCounties,
  listDimensionValues,
} from '@/lib/pool';
import {
  listWorkflows, listWorkflowUserGroups, listWorkflowUserGroupMembers, listApprovalUserSetup,
  DOCUMENT_TYPE_LABELS,
} from '@/lib/workflow';
import { getDimensionCaptions } from '@/lib/org';
import { imageSrc, isConfigured } from '@/lib/cloudinary';
import { formatDateTime } from '@/lib/format';
import { Page } from '@/components/layout/page';
import {
  Card, CardHead, EmptyState, Pill, TableWrap, Tabs, Toolbar, Spacer, type TabDefinition,
} from '@/components/ui/primitives';
import { SearchInput } from '@/components/ui/filters';
import { Money } from '@/components/ui/money';
import { CompanyForm } from '../company-form';
import { AppearanceEditor } from '../appearance-editor';
import { UserFormButton } from '../user-form';
import { RoleFormButton } from '../role-form';
import { SavingsProductButton, LoanProductButton } from '../product-forms';
import { MemberCategoryFormButton, MemberCategoryRow } from '../member-category-form';
import { CountyFormButton, CountyRow } from '../county-form';
import { DimensionValueFormButton } from '../dimension-value-form';
import { DimensionCaptionForm } from '../dimension-caption-form';
import { WorkflowFormButton } from '../workflow-form';
import { WorkflowUserGroupFormButton } from '../workflow-user-group-form';
import { ApprovalUserSetupFormButton } from '../approval-user-setup-form';
import type { Permission } from '@/lib/types';

interface AdminTab extends TabDefinition {
  /** A tab shows up once the user holds any one of these — Setup Pool merges the perms of everything nested under it. */
  perm: Permission | Permission[];
}

const hasTabAccess = (user: Parameters<typeof can>[0], t: AdminTab): boolean =>
  (Array.isArray(t.perm) ? t.perm : [t.perm]).some((p) => can(user, p));

const TABS: AdminTab[] = [
  { key: 'company', label: 'Company Information', perm: 'ADMIN:ORG_MANAGE' },
  { key: 'appearance', label: 'Appearance & Theme', perm: 'ADMIN:THEME_MANAGE' },
  { key: 'products', label: 'Sacco Products', perm: 'ADMIN:PRODUCT_MANAGE' },
  { key: 'pool', label: 'Setup Pool', perm: 'ADMIN:POOL_MANAGE' },
  { key: 'workflows', label: 'Workflow Management', perm: 'ADMIN:WORKFLOW_MANAGE' },
  {
    key: 'security', label: 'System Security',
    perm: ['ADMIN:USER_MANAGE', 'ADMIN:ROLE_MANAGE', 'ADMIN:AUDIT_VIEW'],
  },
];

/** Sacco Products' own sub-navigation. */
const PRODUCTS_TABS: AdminTab[] = [
  { key: 'savings', label: 'Savings Products', perm: 'ADMIN:PRODUCT_MANAGE' },
  { key: 'loans', label: 'Loan Products', perm: 'ADMIN:PRODUCT_MANAGE' },
];

/** Setup Pool's own sub-navigation — each entry is its own page rather than one long scroll. */
const POOL_TABS: AdminTab[] = [
  { key: 'categories', label: 'Member Categories', perm: 'ADMIN:POOL_MANAGE' },
  { key: 'counties', label: 'Counties', perm: 'ADMIN:POOL_MANAGE' },
  { key: 'dimensions', label: 'Dimensions', perm: 'ADMIN:POOL_MANAGE' },
];

/** Workflow Management's own sub-navigation. */
const WORKFLOW_TABS: AdminTab[] = [
  { key: 'definitions', label: 'Workflows', perm: 'ADMIN:WORKFLOW_MANAGE' },
  { key: 'groups', label: 'Approval User Groups', perm: 'ADMIN:WORKFLOW_MANAGE' },
  { key: 'setup', label: 'Approval User Setup', perm: 'ADMIN:WORKFLOW_MANAGE' },
];

/** System Security's own sub-navigation. */
const SECURITY_TABS: AdminTab[] = [
  { key: 'users', label: 'Users', perm: 'ADMIN:USER_MANAGE' },
  { key: 'roles', label: 'Roles & Permissions', perm: 'ADMIN:ROLE_MANAGE' },
  { key: 'audit', label: 'Audit Trail', perm: 'ADMIN:AUDIT_VIEW' },
];

export default async function AdminPage({ params, searchParams }: {
  params: Promise<{ tab?: string[] }>;
  searchParams: Promise<{ q?: string }>;
}) {
  const user = await requireUser();
  const { tab: segments } = await params;
  const { q = '' } = await searchParams;

  // The Admin Centre is reachable by anyone holding at least one admin
  // permission, so the visible tabs — and the default — depend on the role.
  const allowed = TABS.filter((t) => hasTabAccess(user, t));
  if (!allowed.length) {
    return (
      <Page title="Admin Centre" crumb="Configuration, security and appearance" user={user}>
        <Card>
          <EmptyState icon="🔒" title="No administration rights"
            sub="Your role does not include any Admin Centre permissions" />
        </Card>
      </Page>
    );
  }

  const requested = segments?.[0];
  if (requested && !TABS.some((t) => t.key === requested)) notFound();
  const tab = allowed.some((t) => t.key === requested) ? requested! : allowed[0].key;

  const productsAllowed = PRODUCTS_TABS.filter((t) => hasTabAccess(user, t));
  const productsSub = segments?.[1];
  if (tab === 'products' && productsSub && !PRODUCTS_TABS.some((t) => t.key === productsSub)) notFound();
  const productsTab = tab === 'products' && productsAllowed.some((t) => t.key === productsSub)
    ? productsSub! : productsAllowed[0]?.key;

  const poolAllowed = POOL_TABS.filter((t) => hasTabAccess(user, t));
  const poolSub = segments?.[1];
  if (tab === 'pool' && poolSub && !POOL_TABS.some((t) => t.key === poolSub)) notFound();
  const poolTab = tab === 'pool' && poolAllowed.some((t) => t.key === poolSub) ? poolSub! : poolAllowed[0]?.key;

  const workflowAllowed = WORKFLOW_TABS.filter((t) => hasTabAccess(user, t));
  const workflowSub = segments?.[1];
  if (tab === 'workflows' && workflowSub && !WORKFLOW_TABS.some((t) => t.key === workflowSub)) notFound();
  const workflowTab = tab === 'workflows' && workflowAllowed.some((t) => t.key === workflowSub)
    ? workflowSub! : workflowAllowed[0]?.key;

  const securityAllowed = SECURITY_TABS.filter((t) => hasTabAccess(user, t));
  const securitySub = segments?.[1];
  if (tab === 'security' && securitySub && !SECURITY_TABS.some((t) => t.key === securitySub)) notFound();
  const securityTab = tab === 'security' && securityAllowed.some((t) => t.key === securitySub)
    ? securitySub! : securityAllowed[0]?.key;

  return (
    <Page title="Admin Centre" crumb="Configuration, security and appearance" user={user}>
      <Tabs tabs={allowed} active={tab} hrefFor={(k) => `/admin/${k}`} />
      {tab === 'company' ? <CompanyTab /> : null}
      {tab === 'appearance' ? <AppearanceTab /> : null}
      {tab === 'products' ? (
        <>
          <Tabs tabs={productsAllowed} active={productsTab} hrefFor={(k) => `/admin/products/${k}`} />
          {productsTab === 'savings' ? <SavingsProductsTab /> : null}
          {productsTab === 'loans' ? <LoanProductsTab /> : null}
        </>
      ) : null}
      {tab === 'pool' ? (
        <>
          <Tabs tabs={poolAllowed} active={poolTab} hrefFor={(k) => `/admin/pool/${k}`} />
          {poolTab === 'categories' ? <MemberCategoriesTab /> : null}
          {poolTab === 'counties' ? <CountiesTab /> : null}
          {poolTab === 'dimensions' ? <DimensionsTab /> : null}
        </>
      ) : null}
      {tab === 'workflows' ? (
        <>
          <Tabs tabs={workflowAllowed} active={workflowTab} hrefFor={(k) => `/admin/workflows/${k}`} />
          {workflowTab === 'definitions' ? <WorkflowsTab /> : null}
          {workflowTab === 'groups' ? <WorkflowGroupsTab /> : null}
          {workflowTab === 'setup' ? <ApprovalUserSetupTab /> : null}
        </>
      ) : null}
      {tab === 'security' ? (
        <>
          <Tabs tabs={securityAllowed} active={securityTab} hrefFor={(k) => `/admin/security/${k}`} />
          {securityTab === 'users' ? <UsersTab /> : null}
          {securityTab === 'roles' ? <RolesTab /> : null}
          {securityTab === 'audit' ? <AuditTab search={q} /> : null}
        </>
      ) : null}
    </Page>
  );
}

async function CompanyTab() {
  const org = (await getOrg())!;
  // The delivery URL is built server-side so the browser never needs the
  // Cloudinary cloud name, and legacy data-URL logos still resolve.
  return (
    <CompanyForm
      org={org}
      logoSrc={imageSrc(org.logo, { width: 128, height: 128, crop: 'fit' })}
      mediaEnabled={isConfigured()}
    />
  );
}

async function AppearanceTab() {
  return <AppearanceEditor theme={await getTheme()} presets={themePresets()} groups={TOKEN_GROUPS} />;
}

async function UsersTab() {
  const [users, roles] = await Promise.all([listUsers(), listRoles()]);

  return (
    <>
      <Toolbar>
        <Spacer />
        <UserFormButton roles={roles}>Add user</UserFormButton>
      </Toolbar>
      <Card>
        <CardHead title={`${users.length} system users`}
          sub="Access is granted through roles, never directly to a person" />
        <TableWrap>
          <thead>
            <tr>
              <th>User</th><th>Username</th><th>Role</th>
              <th>Last sign-in</th><th>Status</th><th className="num" />
            </tr>
          </thead>
          <tbody>
            {users.map((u) => (
              <tr key={u.id}>
                <td>
                  <b>{u.full_name}</b>
                  <div className="tiny">{u.email || ''}</div>
                </td>
                <td className="mono">{u.username}</td>
                <td>{u.role_name}</td>
                <td>{u.last_login_at ? formatDateTime(u.last_login_at) : 'never'}</td>
                <td><Pill status={u.status} /></td>
                <td className="num">
                  <UserFormButton user={u} roles={roles} className="btn sm ghost">
                    Edit
                  </UserFormButton>
                </td>
              </tr>
            ))}
          </tbody>
        </TableWrap>
      </Card>
    </>
  );
}

async function RolesTab() {
  const roles = await listRoles();

  return (
    <>
      <Toolbar>
        <Spacer />
        <RoleFormButton catalogue={PERMISSIONS}>Add role</RoleFormButton>
      </Toolbar>
      <div className="grid g2">
        {roles.map((r) => (
          <Card key={r.id}>
            <CardHead title={r.name} sub={r.description || ''}>
              {r.is_system
                ? <Pill>SYSTEM</Pill>
                : <RoleFormButton role={r} catalogue={PERMISSIONS} className="btn sm ghost">Edit</RoleFormButton>}
            </CardHead>
            <div className="tiny" style={{ marginBottom: 8 }}>
              {r.userCount} user(s) · {r.permissions.includes('*') ? 'all' : r.permissions.length} permission(s)
            </div>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 4 }}>
              {(r.permissions.includes('*') ? ['Full access'] : r.permissions).map((p) => (
                <Pill key={p}>{p}</Pill>
              ))}
            </div>
          </Card>
        ))}
      </div>
    </>
  );
}

async function SavingsProductsTab() {
  const [rows, accounts] = await Promise.all([listSavingsProducts(), listPostableAccounts()]);

  return (
    <>
      <Toolbar>
        <Spacer />
        <SavingsProductButton accounts={accounts}>Add product</SavingsProductButton>
      </Toolbar>
      <Card>
        <CardHead
          title="Savings and deposit products"
          sub="Every product maps to a GL control account, so the subsidiary ledger always reconciles"
        />
        <TableWrap>
          <thead>
            <tr>
              <th>Code</th><th>Product</th><th>Category</th><th className="num">Interest</th>
              <th className="num">Min. balance</th><th>Withdrawals</th><th>Loan base</th>
              <th>GL control</th><th className="num">Accounts</th><th className="num">Portfolio</th>
              <th className="num" />
            </tr>
          </thead>
          <tbody>
            {rows.map((p) => (
              <tr key={p.id}>
                <td className="mono">{p.code}</td>
                <td><b>{p.name}</b></td>
                <td>{p.category}</td>
                <td className="num">{p.interest_rate}%</td>
                <td className="num"><Money cents={p.min_balance} decimals={0} /></td>
                <td>{p.allow_withdrawal ? <Pill tone="ok">ALLOWED</Pill> : <Pill>RESTRICTED</Pill>}</td>
                <td>{p.is_loanable_base ? <Pill tone="info">YES</Pill> : '—'}</td>
                <td className="mono tiny">{p.gl_control_code || ''}</td>
                <td className="num">{p.accounts}</td>
                <td className="num"><Money cents={p.portfolio} decimals={0} /></td>
                <td className="num">
                  <SavingsProductButton product={p} accounts={accounts} className="btn sm ghost">
                    Edit
                  </SavingsProductButton>
                </td>
              </tr>
            ))}
          </tbody>
        </TableWrap>
      </Card>
    </>
  );
}

async function LoanProductsTab() {
  const [rows, accounts] = await Promise.all([listLoanProducts(), listPostableAccounts()]);

  return (
    <>
      <Toolbar>
        <Spacer />
        <LoanProductButton accounts={accounts}>Add product</LoanProductButton>
      </Toolbar>
      <Card>
        <CardHead
          title="Loan products"
          sub="Product parameters drive eligibility, pricing, schedules and posting"
        />
        <TableWrap>
          <thead>
            <tr>
              <th>Code</th><th>Product</th><th className="num">Rate</th><th>Method</th>
              <th className="num">Max term</th><th className="num">Multiplier</th><th className="num">Fees</th>
              <th className="num">Live loans</th><th className="num">Portfolio</th><th className="num" />
            </tr>
          </thead>
          <tbody>
            {rows.map((p) => (
              <tr key={p.id}>
                <td className="mono">{p.code}</td>
                <td><b>{p.name}</b></td>
                <td className="num">{p.interest_rate}%</td>
                <td>{p.interest_method}</td>
                <td className="num">{p.max_term_months}m</td>
                <td className="num">{p.deposit_multiplier}×</td>
                <td className="num">{p.processing_fee_pct}% + {p.insurance_pct}%</td>
                <td className="num">{p.active_loans}</td>
                <td className="num"><Money cents={p.portfolio} decimals={0} /></td>
                <td className="num">
                  <LoanProductButton product={p} accounts={accounts} className="btn sm ghost">
                    Edit
                  </LoanProductButton>
                </td>
              </tr>
            ))}
          </tbody>
        </TableWrap>
      </Card>
    </>
  );
}

async function MemberCategoriesTab() {
  const [categories, accounts, products] = await Promise.all([
    listMemberCategories(), listPostableAccounts(), listActiveSavingsProducts(),
  ]);
  const defaultAccountsByCategory = Object.fromEntries(
    await Promise.all(categories.map(async (c) => [c.id, await getMemberCategoryDefaultAccounts(c.id)] as const)),
  );

  return (
    <>
      <Toolbar>
        <Spacer />
        <MemberCategoryFormButton accounts={accounts} savingsProducts={products}>
          Add category
        </MemberCategoryFormButton>
      </Toolbar>
      <Card>
        <CardHead
          title="Member categories"
          sub="Classifies members and drives their registration fee and default savings accounts"
        />
        {categories.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th>Code</th><th>Description</th><th>Type</th><th className="num">Registration fee</th>
                <th>Fee account</th><th className="num">Default accounts</th><th className="num">Members</th>
                <th>Status</th><th className="num" />
              </tr>
            </thead>
            <tbody>
              {categories.map((c) => (
                <MemberCategoryRow
                  key={c.id}
                  category={c}
                  defaultAccounts={defaultAccountsByCategory[c.id]}
                  accounts={accounts}
                  savingsProducts={products}
                />
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🏷" title="No member categories yet" />}
      </Card>
    </>
  );
}

async function CountiesTab() {
  const [counties, subCounties] = await Promise.all([listCounties(), listSubCounties()]);

  return (
    <>
      <Toolbar>
        <Spacer />
        <CountyFormButton>Add county</CountyFormButton>
      </Toolbar>
      <Card>
        <CardHead title="Counties" sub="Feeds the County and Sub-county fields on the member application form" />
        {counties.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th>Name</th><th className="num">Sub-counties</th><th className="num">Members</th>
                <th>Status</th><th className="num" />
              </tr>
            </thead>
            <tbody>
              {counties.map((c) => (
                <CountyRow key={c.id} county={c} subCounties={subCounties} />
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🗺" title="No counties yet" />}
      </Card>
    </>
  );
}

async function DimensionsTab() {
  const [{ caption1, caption2 }, values1, values2] = await Promise.all([
    getDimensionCaptions(), listDimensionValues(1), listDimensionValues(2),
  ]);

  return (
    <>
      <DimensionCaptionForm caption1={caption1} caption2={caption2} />
      <DimensionValuesCard slot={1} caption={caption1} values={values1} />
      <DimensionValuesCard slot={2} caption={caption2} values={values2} />
    </>
  );
}

function DimensionValuesCard({ slot, caption, values }: {
  slot: 1 | 2;
  caption: string;
  values: Awaited<ReturnType<typeof listDimensionValues>>;
}) {
  return (
    <>
      <Toolbar>
        <Spacer />
        <DimensionValueFormButton slot={slot} caption={caption}>Add value</DimensionValueFormButton>
      </Toolbar>
      <Card>
        <CardHead title={caption} sub={`Values available for the ${caption} field on members and GL postings`} />
        {values.length ? (
          <TableWrap>
            <thead>
              <tr><th>Code</th><th>Name</th><th>Status</th><th className="num" /></tr>
            </thead>
            <tbody>
              {values.map((v) => (
                <tr key={v.id}>
                  <td className="mono">{v.code}</td>
                  <td><b>{v.name}</b></td>
                  <td><Pill status={v.status} /></td>
                  <td className="num">
                    <DimensionValueFormButton slot={slot} caption={caption} value={v} className="btn sm ghost">
                      Edit
                    </DimensionValueFormButton>
                  </td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🏷" title={`No ${caption.toLowerCase()} values yet`} />}
      </Card>
    </>
  );
}

async function WorkflowsTab() {
  const [workflows, users, groups] = await Promise.all([listWorkflows(), listUsers(), listWorkflowUserGroups()]);

  return (
    <>
      <Toolbar>
        <Spacer />
        <WorkflowFormButton users={users} groups={groups}>Add workflow</WorkflowFormButton>
      </Toolbar>
      <Card>
        <CardHead title="Workflows" sub="Route approvals by document field values instead of a flat permission" />
        {workflows.length ? (
          <TableWrap>
            <thead>
              <tr><th>Name</th><th>Document type</th><th className="num">Steps</th><th>Status</th><th className="num" /></tr>
            </thead>
            <tbody>
              {workflows.map((w) => (
                <tr key={w.id}>
                  <td><b>{w.name}</b></td>
                  <td>{DOCUMENT_TYPE_LABELS[w.document_type]}</td>
                  <td className="num">{w.steps.length}</td>
                  <td><Pill status={w.status} /></td>
                  <td className="num">
                    <WorkflowFormButton workflow={w} users={users} groups={groups} className="btn sm ghost">Edit</WorkflowFormButton>
                  </td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🔀" title="No workflows yet" sub="Documents fall back to a plain permission check until one is defined" />}
      </Card>
    </>
  );
}

async function WorkflowGroupsTab() {
  const [groups, users] = await Promise.all([listWorkflowUserGroups(), listUsers()]);
  const membersByGroup = Object.fromEntries(
    await Promise.all(groups.map(async (g) => [g.id, await listWorkflowUserGroupMembers(g.id)] as const)),
  );

  return (
    <>
      <Toolbar>
        <Spacer />
        <WorkflowUserGroupFormButton users={users}>Add group</WorkflowUserGroupFormButton>
      </Toolbar>
      <Card>
        <CardHead title="Approval user groups" sub="A step routed to a group can be actioned by any of its members" />
        {groups.length ? (
          <TableWrap>
            <thead>
              <tr><th>Name</th><th className="num">Members</th><th>Status</th><th className="num" /></tr>
            </thead>
            <tbody>
              {groups.map((g) => (
                <tr key={g.id}>
                  <td><b>{g.name}</b></td>
                  <td className="num">{g.members}</td>
                  <td><Pill status={g.status} /></td>
                  <td className="num">
                    <WorkflowUserGroupFormButton group={g} memberUserIds={membersByGroup[g.id]} users={users} className="btn sm ghost">
                      Edit
                    </WorkflowUserGroupFormButton>
                  </td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="👥" title="No approval user groups yet" />}
      </Card>
    </>
  );
}

async function ApprovalUserSetupTab() {
  const rows = await listApprovalUserSetup();

  return (
    <Card>
      <CardHead title="Approval user setup" sub="Who approves each user's requests, their substitute, and fallback approval administrators" />
      <TableWrap>
        <thead>
          <tr><th>User</th><th>Approver</th><th>Substitute</th><th>Approval admin</th><th className="num" /></tr>
        </thead>
        <tbody>
          {rows.map((r) => (
            <tr key={r.user_id}>
              <td><b>{r.full_name}</b> <span className="tiny">({r.username})</span></td>
              <td>{r.approver_name || '—'}</td>
              <td>{r.substitute_name || '—'}</td>
              <td>{r.is_approval_administrator ? <Pill tone="info">YES</Pill> : '—'}</td>
              <td className="num">
                <ApprovalUserSetupFormButton row={r} users={rows} className="btn sm ghost">Edit</ApprovalUserSetupFormButton>
              </td>
            </tr>
          ))}
        </tbody>
      </TableWrap>
    </Card>
  );
}

async function AuditTab({ search }: { search: string }) {
  const rows = await listAuditLog({ search });

  return (
    <>
      <Toolbar>
        <SearchInput placeholder="Filter by user, action or entity…" />
        <Spacer />
      </Toolbar>
      <Card>
        <CardHead title="Audit trail" sub="Append-only record of every privileged and financial action" />
        {rows.length ? (
          <TableWrap>
            <thead>
              <tr><th>When</th><th>User</th><th>Action</th><th>Entity</th><th>Detail</th></tr>
            </thead>
            <tbody>
              {rows.map((a) => (
                <tr key={a.id}>
                  <td style={{ whiteSpace: 'nowrap' }}>{formatDateTime(a.at)}</td>
                  <td>{a.username || 'system'}</td>
                  <td><Pill status={a.action} /></td>
                  <td className="mono tiny">{a.entity || ''}{a.entity_id ? `#${a.entity_id}` : ''}</td>
                  <td className="mono tiny" style={{ maxWidth: 420, overflow: 'hidden', textOverflow: 'ellipsis' }}>
                    {a.detail || ''}
                  </td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="📋" title="No audit entries match" />}
      </Card>
    </>
  );
}
