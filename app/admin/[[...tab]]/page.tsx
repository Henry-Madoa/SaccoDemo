import { notFound } from 'next/navigation';
import { requireUser } from '@/lib/session';
import { canPage, PAGES } from '@/lib/permissions';
import { getOrg, getTheme, themePresets, TOKEN_GROUPS } from '@/lib/org';
import {
  listUsers, listRoles, listSavingsProducts, listLoanProducts, listAuditLog, AUDIT_FILTER_FIELDS,
  listActiveSavingsProducts, listActiveLoanProducts,
} from '@/lib/admin';
import {
  listChangeLogSetup, listChangeLogEntries, listAvailableChangeLogTables, CHANGE_LOG_FILTER_FIELDS,
} from '@/lib/changeLog';
import { parseFilters } from '@/lib/listFilters';
import { parseSort } from '@/lib/listSort';
import { listConfigPackages, listConfigPackageTables } from '@/lib/configPackages';
import { listPostableAccounts } from '@/lib/gl';
import {
  listMemberCategories, getMemberCategoryDefaultAccounts, listCounties, listSubCounties,
  listDimensionValues, listActiveMemberCategories, listActiveCounties, listActiveDimensionValues,
} from '@/lib/pool';
import {
  listWorkflows, listWorkflowUserGroups, listWorkflowUserGroupMembers, listApprovalUserSetup,
  listWorkflowTableRelations, listDocumentTypeOptions, listWorkflowDocumentTypes, documentTypeLabel,
} from '@/lib/workflow';
import { getDimensionCaptions } from '@/lib/org';
import { imageSrc, isConfigured } from '@/lib/cloudinary';
import { formatDateTime } from '@/lib/format';
import { Page } from '@/components/layout/page';
import {
  Card, CardHead, EmptyState, Pill, TableWrap, Tabs, Toolbar, Spacer, type TabDefinition,
} from '@/components/ui/primitives';
import { SearchInput } from '@/components/ui/filters';
import { DynamicFilterBar } from '@/components/ui/dynamic-filter';
import { SortLink } from '@/components/ui/sort-link';
import { Money } from '@/components/ui/money';
import { ExportButton } from '@/components/ui/export-button';
import { CompanyForm } from '../company-form';
import { AppearanceEditor } from '../appearance-editor';
import { UserFormButton } from '../user-form';
import { RoleFormButton, RoleRow } from '../role-form';
import { SavingsProductButton, LoanProductButton } from '../product-forms';
import { MemberCategoryFormButton, MemberCategoryRow } from '../member-category-form';
import { CountyFormButton, CountyRow } from '../county-form';
import { DimensionValueFormButton } from '../dimension-value-form';
import { DimensionCaptionForm } from '../dimension-caption-form';
import { WorkflowFormButton } from '../workflow-form';
import { WorkflowUserGroupFormButton } from '../workflow-user-group-form';
import { WorkflowTableRelationFormButton } from '../workflow-table-relation-form';
import { ApprovalUserSetupFormButton } from '../approval-user-setup-form';
import { ChangeLogSetupTable } from '../change-log-setup-table';
import { ConfigPackageFormButton } from '../config-package-form';
import { ConfigPackageIo, DeleteConfigPackageButton } from '../config-package-io';
interface AdminTab extends TabDefinition {
  /** A tab shows up once the user can execute any one of these pages — Setup Pool
   *  merges the pages of everything nested under it. */
  page: string | string[];
}

const hasTabAccess = (user: Parameters<typeof canPage>[0], t: AdminTab): boolean =>
  (Array.isArray(t.page) ? t.page : [t.page]).some((p) => canPage(user, p));

const TABS: AdminTab[] = [
  { key: 'company', label: 'Company Information', page: 'ADMIN_COMPANY' },
  { key: 'appearance', label: 'Appearance & Theme', page: 'ADMIN_APPEARANCE' },
  { key: 'products', label: 'Sacco Products', page: ['ADMIN_PRODUCTS_SAVINGS', 'ADMIN_PRODUCTS_LOANS'] },
  { key: 'pool', label: 'Setup Pool', page: ['ADMIN_POOL_CATEGORIES', 'ADMIN_POOL_COUNTIES', 'ADMIN_POOL_DIMENSIONS'] },
  {
    key: 'workflows', label: 'Workflow Management',
    page: ['ADMIN_WORKFLOWS_DEFINITIONS', 'ADMIN_WORKFLOWS_GROUPS', 'ADMIN_WORKFLOWS_SETUP', 'ADMIN_WORKFLOWS_TABLES'],
  },
  {
    key: 'security', label: 'System Security',
    page: ['ADMIN_USERS', 'ADMIN_ROLES', 'ADMIN_AUDIT', 'ADMIN_CHANGELOG'],
  },
  { key: 'data', label: 'Data Management', page: 'ADMIN_DATA' },
];

/** Sacco Products' own sub-navigation. */
const PRODUCTS_TABS: AdminTab[] = [
  { key: 'savings', label: 'Savings Products', page: 'ADMIN_PRODUCTS_SAVINGS' },
  { key: 'loans', label: 'Loan Products', page: 'ADMIN_PRODUCTS_LOANS' },
];

/** Setup Pool's own sub-navigation — each entry is its own page rather than one long scroll. */
const POOL_TABS: AdminTab[] = [
  { key: 'categories', label: 'Member Categories', page: 'ADMIN_POOL_CATEGORIES' },
  { key: 'counties', label: 'Counties', page: 'ADMIN_POOL_COUNTIES' },
  { key: 'dimensions', label: 'Dimensions', page: 'ADMIN_POOL_DIMENSIONS' },
];

/** Workflow Management's own sub-navigation. */
const WORKFLOW_TABS: AdminTab[] = [
  { key: 'definitions', label: 'Workflows', page: 'ADMIN_WORKFLOWS_DEFINITIONS' },
  { key: 'groups', label: 'Approval User Groups', page: 'ADMIN_WORKFLOWS_GROUPS' },
  { key: 'setup', label: 'Approval User Setup', page: 'ADMIN_WORKFLOWS_SETUP' },
  { key: 'tables', label: 'Table Relations', page: 'ADMIN_WORKFLOWS_TABLES' },
];

/** System Security's own sub-navigation. */
const SECURITY_TABS: AdminTab[] = [
  { key: 'users', label: 'Users', page: 'ADMIN_USERS' },
  { key: 'roles', label: 'Permission Sets', page: 'ADMIN_ROLES' },
  { key: 'audit', label: 'Audit Trail', page: 'ADMIN_AUDIT' },
  { key: 'changelog', label: 'Change Log Management', page: 'ADMIN_CHANGELOG' },
];

export default async function AdminPage({ params, searchParams }: {
  params: Promise<{ tab?: string[] }>;
  searchParams: Promise<{ q?: string; filters?: string; sort?: string }>;
}) {
  const user = await requireUser();
  const { tab: segments } = await params;
  const { q = '', filters: filtersRaw, sort: sortRaw } = await searchParams;

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
          {workflowTab === 'tables' ? <TableRelationsTab /> : null}
        </>
      ) : null}
      {tab === 'security' ? (
        <>
          <Tabs tabs={securityAllowed} active={securityTab} hrefFor={(k) => `/admin/security/${k}`} />
          {securityTab === 'users' ? <UsersTab /> : null}
          {securityTab === 'roles' ? <RolesTab /> : null}
          {securityTab === 'audit' ? <AuditTab search={q} filtersRaw={filtersRaw} sortRaw={sortRaw} /> : null}
          {securityTab === 'changelog' ? <ChangeLogTab search={q} filtersRaw={filtersRaw} sortRaw={sortRaw} /> : null}
        </>
      ) : null}
      {tab === 'data' ? <DataManagementTab /> : null}
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
        <RoleFormButton pages={PAGES}>Add permission set</RoleFormButton>
      </Toolbar>
      <Card>
        <CardHead title={`${roles.length} permission sets`}
          sub="Click a permission code to see its full line-by-line grant" />
        <TableWrap>
          <thead>
            <tr>
              <th>Permission code</th><th>Description</th>
              <th className="num">Lines</th><th className="num">Assigned users</th>
              <th>Type</th><th className="num" />
            </tr>
          </thead>
          <tbody>
            {roles.map((r) => <RoleRow key={r.id} role={r} pages={PAGES} />)}
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
  const [
    workflows, users, groups, memberCategory, county, globalDimension1, globalDimension2, loanProduct,
    captions, documentTypes,
  ] = await Promise.all([
    listWorkflows(), listUsers(), listWorkflowUserGroups(),
    listActiveMemberCategories(), listActiveCounties(), listActiveDimensionValues(1), listActiveDimensionValues(2),
    listActiveLoanProducts(), getDimensionCaptions(), listWorkflowDocumentTypes(),
  ]);
  const relationProps = {
    memberCategory, county, globalDimension1, globalDimension2, loanProduct,
    dimensionCaption1: captions.caption1, dimensionCaption2: captions.caption2,
  };
  const wiredByType = new Map(documentTypes.map((d) => [d.documentType, d.wired]));

  return (
    <>
      <Toolbar>
        <Spacer />
        <WorkflowFormButton documentTypes={documentTypes} users={users} groups={groups} {...relationProps}>
          Add workflow
        </WorkflowFormButton>
      </Toolbar>
      <Card>
        <CardHead title="Workflows" sub="Route approvals by document field values instead of a flat permission" />
        {workflows.length ? (
          <TableWrap>
            <thead>
              <tr><th>Name</th><th>Document type</th><th className="num">Steps</th><th>Enabled</th><th className="num" /></tr>
            </thead>
            <tbody>
              {workflows.map((w) => (
                <tr key={w.id}>
                  <td><b>{w.name}</b></td>
                  <td>
                    {documentTypeLabel(w.document_type)}
                    {wiredByType.get(w.document_type) === false ? <> <Pill tone="warn">NOT YET ENFORCED</Pill></> : null}
                  </td>
                  <td className="num">{w.steps.length}</td>
                  <td>{w.enabled ? <Pill tone="ok">ENABLED</Pill> : <Pill tone="bad">DISABLED</Pill>}</td>
                  <td className="num">
                    <WorkflowFormButton
                      workflow={w} documentTypes={documentTypes} users={users} groups={groups}
                      {...relationProps} className="btn sm ghost"
                    >
                      Edit
                    </WorkflowFormButton>
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
                    <WorkflowUserGroupFormButton group={g} members={membersByGroup[g.id]} users={users} className="btn sm ghost">
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

async function TableRelationsTab() {
  const [documentTypes, relations, dimensionCaptions] = await Promise.all([
    listDocumentTypeOptions(), listWorkflowTableRelations(), getDimensionCaptions(),
  ]);
  const relationByType = new Map(relations.map((r) => [r.document_type, r]));

  return (
    <Card>
      <CardHead
        title="Table relations"
        sub="Which table backs each document type, and which of its fields a workflow's conditions may route approvals on"
      />
      <TableWrap>
        <thead>
          <tr><th>Document type</th><th>Table</th><th>Enforced</th><th className="num">Fields enabled</th><th className="num" /></tr>
        </thead>
        <tbody>
          {documentTypes.map((d) => {
            const relation = relationByType.get(d.documentType) ?? null;
            return (
              <tr key={d.documentType}>
                <td><b>{d.label}</b></td>
                <td className="mono">{d.table}</td>
                <td>{d.wired ? <Pill tone="ok">YES</Pill> : <Pill tone="warn">NOT YET</Pill>}</td>
                <td className="num">{relation?.fields.length ?? 0}</td>
                <td className="num">
                  <WorkflowTableRelationFormButton
                    documentType={d.documentType} documentTypeLabel={d.label} tableName={d.table}
                    relation={relation} className="btn sm ghost"
                    dimensionCaption1={dimensionCaptions.caption1} dimensionCaption2={dimensionCaptions.caption2}
                  >
                    Configure fields
                  </WorkflowTableRelationFormButton>
                </td>
              </tr>
            );
          })}
        </tbody>
      </TableWrap>
    </Card>
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

async function AuditTab({ search, filtersRaw, sortRaw }: { search: string; filtersRaw?: string; sortRaw?: string }) {
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);
  const rows = await listAuditLog({ search, filters, sort });

  return (
    <>
      <Toolbar>
        <SearchInput placeholder="Filter by user, action or entity…" />
        <DynamicFilterBar fields={AUDIT_FILTER_FIELDS} />
        <Spacer />
        <ExportButton href="/api/export/audit" params={{ q: search, filters: filtersRaw, sort: sortRaw }} />
      </Toolbar>
      <Card>
        <CardHead title="Audit trail" sub="Append-only record of every privileged and financial action" />
        {rows.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th><SortLink sortKey="at">When</SortLink></th>
                <th><SortLink sortKey="username">User</SortLink></th>
                <th><SortLink sortKey="action">Action</SortLink></th>
                <th><SortLink sortKey="entity">Entity</SortLink></th>
                <th><SortLink sortKey="detail">Detail</SortLink></th>
              </tr>
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

/**
 * Field-level change tracking, modelled on Business Central's Change Log Management —
 * nothing is recorded for a table until it's checked in below, unlike the always-on
 * Audit Trail tab.
 */
async function ChangeLogTab({ search, filtersRaw, sortRaw }: { search: string; filtersRaw?: string; sortRaw?: string }) {
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);
  const [setup, entries, available] = await Promise.all([
    listChangeLogSetup(), listChangeLogEntries({ search, filters, sort }), listAvailableChangeLogTables(),
  ]);
  const fields = CHANGE_LOG_FILTER_FIELDS.map((f) => (
    f.key === 'table_name' ? { ...f, options: setup.map((s) => ({ value: s.table_name, label: s.table_caption })) } : f
  ));

  return (
    <>
      <Card>
        <CardHead title="Change Log Setup" sub="Only the tables checked here get field-level change tracking" />
        <ChangeLogSetupTable setup={setup} available={available} />
      </Card>

      <Toolbar>
        <SearchInput placeholder="Filter by record, field or user…" />
        <DynamicFilterBar fields={fields} />
        <Spacer />
        <ExportButton href="/api/export/change-log" params={{ q: search, filters: filtersRaw, sort: sortRaw }} />
      </Toolbar>
      <Card>
        <CardHead title="Change Log Entries" sub="Every logged field change, newest first" />
        {entries.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th><SortLink sortKey="changed_at">When</SortLink></th>
                <th><SortLink sortKey="username">User</SortLink></th>
                <th><SortLink sortKey="table_caption">Table</SortLink></th>
                <th><SortLink sortKey="record_id">Record</SortLink></th>
                <th><SortLink sortKey="field_name">Field</SortLink></th>
                <th><SortLink sortKey="old_value">Old value</SortLink></th>
                <th><SortLink sortKey="new_value">New value</SortLink></th>
                <th><SortLink sortKey="type">Type</SortLink></th>
              </tr>
            </thead>
            <tbody>
              {entries.map((e) => (
                <tr key={e.id}>
                  <td style={{ whiteSpace: 'nowrap' }}>{formatDateTime(e.changed_at)}</td>
                  <td>{e.username}</td>
                  <td>{e.table_caption}</td>
                  <td className="mono tiny">{e.record_id}</td>
                  <td>{e.field_name}</td>
                  <td className="mono tiny">{e.old_value ?? '—'}</td>
                  <td className="mono tiny">{e.new_value ?? '—'}</td>
                  <td><Pill status={e.type} /></td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="📜" title="No change log entries yet" />}
      </Card>
    </>
  );
}

/**
 * Configuration Packages — modeled on Business Central's Configuration Packages/RapidStart:
 * an admin picks a table and a set of its columns, then exports that data to CSV and
 * re-imports a CSV to bulk insert/update rows, straight into the base table for data
 * migration, bypassing whatever approval workflow that entity normally goes through.
 */
async function DataManagementTab() {
  const [packages, tables] = await Promise.all([listConfigPackages(), listConfigPackageTables()]);

  return (
    <>
      <Toolbar>
        <Spacer />
        <ConfigPackageFormButton tables={tables}>New package</ConfigPackageFormButton>
      </Toolbar>
      <Card>
        <CardHead
          title="Configuration packages"
          sub="Export a table's data to CSV, edit it, and re-import to bulk create or update records — for data migration, not day-to-day entry"
        />
        {packages.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th>Code</th><th>Name</th><th>Table</th><th className="num">Fields</th>
                <th>Key field</th><th /><th className="num" />
              </tr>
            </thead>
            <tbody>
              {packages.map((p) => (
                <tr key={p.id}>
                  <td className="mono">{p.code}</td>
                  <td><b>{p.name}</b></td>
                  <td className="mono tiny">{p.table_name}</td>
                  <td className="num">{p.fields.length}</td>
                  <td className="tiny">{p.key_field || '—'}</td>
                  <td><ConfigPackageIo code={p.code} /></td>
                  <td className="num">
                    <div className="inline" style={{ gap: 4 }}>
                      <ConfigPackageFormButton pkg={p} tables={tables} className="btn sm ghost">Edit</ConfigPackageFormButton>
                      <DeleteConfigPackageButton code={p.code} />
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="📦" title="No configuration packages yet" sub="Create one to bulk export or import a table's data" />}
      </Card>
    </>
  );
}
