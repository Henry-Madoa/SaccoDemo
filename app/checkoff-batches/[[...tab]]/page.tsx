import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  listCheckoffBatches, hasAnyCheckoffBatches, type CheckoffBatchView,
} from '@/lib/checkoffBatches';
import { listActiveEmployers } from '@/lib/employers';
import { Page } from '@/components/layout/page';
import {
  Card, EmptyState, Pill, TableWrap, Tabs, Toolbar, Spacer, type TabDefinition,
} from '@/components/ui/primitives';
import { SearchInput } from '@/components/ui/filters';
import { Money } from '@/components/ui/money';
import { formatDate, humanise } from '@/lib/format';
import { NewCheckoffBatchButton, SubmitButton, CancelApprovalButton, ProcessButton } from '../checkoff-batch-actions';

const TABS: TabDefinition[] = [
  { key: 'open', label: 'Open', tone: 'info' },
  { key: 'pending', label: 'Pending Approval', tone: 'warn' },
  { key: 'approved', label: 'Approved', tone: 'ok' },
  { key: 'processed', label: 'Processed', tone: 'accent' },
];

export default async function CheckoffBatchesPage({ params, searchParams }: {
  params: Promise<{ tab?: string[] }>;
  searchParams: Promise<{ q?: string }>;
}) {
  const user = await requireAction('CHECKOFF_BATCHES_READ');
  const { tab: segments } = await params;
  const { q = '' } = await searchParams;

  const requested = segments?.[0];
  if (requested && !TABS.some((t) => t.key === requested)) notFound();
  const tab = (requested ?? 'open') as CheckoffBatchView;

  const [batches, empty, canCreate, canApprove, employers] = await Promise.all([
    listCheckoffBatches({ view: tab, search: q }),
    hasAnyCheckoffBatches(tab).then((any) => !any),
    currentCanAction('CHECKOFF_BATCHES_CREATE'), currentCanAction('CHECKOFF_BATCHES_APPROVE'),
    listActiveEmployers(),
  ]);

  return (
    <Page title="Checkoff & Salary Processing" crumb="Employer payroll deduction and salary batches — reconcile remitted vs. expected, then post" user={user}>
      <Tabs tabs={TABS} active={tab} hrefFor={(k) => `/checkoff-batches/${k}`} />
      <Toolbar>
        <SearchInput placeholder="Search employer or document no.…" disabled={empty} />
        <Spacer />
        {canCreate ? <NewCheckoffBatchButton employers={employers} /> : null}
      </Toolbar>

      <Card>
        {batches.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th>No.</th><th>Employer</th><th>Type</th><th>Period</th>
                <th className="num">Remitted</th><th className="num">Variance</th><th>Status</th><th className="num" />
              </tr>
            </thead>
            <tbody>
              {batches.map((b) => {
                const isOwnRequest = b.created_by === user.username;
                const canEditThis = canCreate && (!canApprove || isOwnRequest);
                return (
                <tr key={b.no}>
                  <td className="mono"><Link href={`/checkoff-batches/view/${b.no}?view=${tab}`}>{b.no}</Link></td>
                  <td>
                    <b>{b.employer_name}</b>
                    <div className="tiny mono">{b.employer_code}</div>
                  </td>
                  <td>{humanise(b.batch_type)}</td>
                  <td>{formatDate(b.period)}</td>
                  <td className="num"><Money cents={b.total_remitted} decimals={0} /></td>
                  <td className="num">
                    <span className={b.total_variance ? 'neg' : undefined}><Money cents={b.total_variance} decimals={0} /></span>
                  </td>
                  <td><Pill status={b.status} /></td>
                  <td className="num">
                    <div className="inline" style={{ justifyContent: 'flex-end' }}>
                      {b.status === 'Open' && canEditThis ? <SubmitButton no={b.no} /> : null}
                      {b.status === 'Pending Approval' && canCreate && isOwnRequest ? (
                        <CancelApprovalButton no={b.no} />
                      ) : null}
                      {b.status === 'Approved' && canApprove ? <ProcessButton no={b.no} /> : null}
                    </div>
                  </td>
                </tr>
                );
              })}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="💼" title="No batches here" sub="Try a different tab or clear the search" />}
      </Card>
    </Page>
  );
}
