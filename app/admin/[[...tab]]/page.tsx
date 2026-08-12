import { notFound } from 'next/navigation';
import { requireUser } from '@/lib/session';
import { can, PERMISSIONS } from '@/lib/auth';
import { getOrg, getTheme, themePresets, TOKEN_GROUPS } from '@/lib/org';
import {
  listUsers, listRoles, listBranches, listSavingsProducts, listLoanProducts, listAuditLog,
} from '@/lib/admin';
import { listPostableAccounts } from '@/lib/gl';
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
import { BranchFormButton } from '../branch-form';
import { SavingsProductButton, LoanProductButton } from '../product-forms';
import type { Permission } from '@/lib/types';

interface AdminTab extends TabDefinition {
  perm: Permission;
}

const TABS: AdminTab[] = [
  { key: 'company', label: 'Company Information', perm: 'ADMIN:ORG_MANAGE' },
  { key: 'appearance', label: 'Appearance & Theme', perm: 'ADMIN:THEME_MANAGE' },
  { key: 'users', label: 'Users', perm: 'ADMIN:USER_MANAGE' },
  { key: 'roles', label: 'Roles & Permissions', perm: 'ADMIN:ROLE_MANAGE' },
  { key: 'branches', label: 'Branches', perm: 'ADMIN:BRANCH_MANAGE' },
  { key: 'savings', label: 'Savings Products', perm: 'ADMIN:PRODUCT_MANAGE' },
  { key: 'loans', label: 'Loan Products', perm: 'ADMIN:PRODUCT_MANAGE' },
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
  const allowed = TABS.filter((t) => can(user, t.perm));
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

  return (
    <Page title="Admin Centre" crumb="Configuration, security and appearance" user={user}>
      <Tabs tabs={allowed} active={tab} hrefFor={(k) => `/admin/${k}`} />
      {tab === 'company' ? <CompanyTab /> : null}
      {tab === 'appearance' ? <AppearanceTab /> : null}
      {tab === 'users' ? <UsersTab /> : null}
      {tab === 'roles' ? <RolesTab /> : null}
      {tab === 'branches' ? <BranchesTab /> : null}
      {tab === 'savings' ? <SavingsProductsTab /> : null}
      {tab === 'loans' ? <LoanProductsTab /> : null}
      {tab === 'audit' ? <AuditTab search={q} /> : null}
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
  const [users, roles, branches] = await Promise.all([listUsers(), listRoles(), listBranches()]);

  return (
    <>
      <Toolbar>
        <Spacer />
        <UserFormButton roles={roles} branches={branches}>Add user</UserFormButton>
      </Toolbar>
      <Card>
        <CardHead title={`${users.length} system users`}
          sub="Access is granted through roles, never directly to a person" />
        <TableWrap>
          <thead>
            <tr>
              <th>User</th><th>Username</th><th>Role</th><th>Branch</th>
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
                <td>{u.branch_name || '—'}</td>
                <td>{u.last_login_at ? formatDateTime(u.last_login_at) : 'never'}</td>
                <td><Pill status={u.status} /></td>
                <td className="num">
                  <UserFormButton user={u} roles={roles} branches={branches} className="btn sm ghost">
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

async function BranchesTab() {
  const rows = await listBranches();

  return (
    <>
      <Toolbar>
        <Spacer />
        <BranchFormButton>Add branch</BranchFormButton>
      </Toolbar>
      <Card>
        <TableWrap>
          <thead>
            <tr><th>Code</th><th>Name</th><th>Town</th><th>Phone</th><th>Status</th><th className="num" /></tr>
          </thead>
          <tbody>
            {rows.map((b) => (
              <tr key={b.id}>
                <td className="mono">{b.code}</td>
                <td>{b.name} {b.is_head_office ? <Pill tone="info">HEAD OFFICE</Pill> : null}</td>
                <td>{b.town || '—'}</td>
                <td>{b.phone || '—'}</td>
                <td><Pill status={b.status} /></td>
                <td className="num">
                  <BranchFormButton branch={b} className="btn sm ghost">Edit</BranchFormButton>
                </td>
              </tr>
            ))}
          </tbody>
        </TableWrap>
      </Card>
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
