import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import { listFixedDeposits, hasAnyFixedDeposits, type FixedDepositView } from '@/lib/fixedDeposits';
import { listActiveMembers } from '@/lib/members';
import { Page } from '@/components/layout/page';
import {
  Card, EmptyState, Pill, TableWrap, Tabs, Toolbar, Spacer, type TabDefinition,
} from '@/components/ui/primitives';
import { SearchInput } from '@/components/ui/filters';
import { Money } from '@/components/ui/money';
import {
  NewFixedDepositButton, SubmitButton, CancelApprovalButton, ActivateButton, MatureButton,
} from '../fixed-deposit-actions';

const TABS: TabDefinition[] = [
  { key: 'open', label: 'Open', tone: 'info' },
  { key: 'pending', label: 'Pending Approval', tone: 'warn' },
  { key: 'approved', label: 'Approved', tone: 'ok' },
  { key: 'active', label: 'Active', tone: 'accent' },
  { key: 'matured', label: 'Matured' },
  { key: 'terminated', label: 'Terminated' },
];

export default async function FixedDepositsPage({ params, searchParams }: {
  params: Promise<{ tab?: string[] }>;
  searchParams: Promise<{ q?: string }>;
}) {
  const user = await requireAction('FIXED_DEPOSITS_READ');
  const { tab: segments } = await params;
  const { q = '' } = await searchParams;

  const requested = segments?.[0];
  if (requested && !TABS.some((t) => t.key === requested)) notFound();
  const tab = (requested ?? 'open') as FixedDepositView;

  const [deposits, empty, canCreate, canApprove, members] = await Promise.all([
    listFixedDeposits({ view: tab, search: q }),
    hasAnyFixedDeposits(tab).then((any) => !any),
    currentCanAction('FIXED_DEPOSITS_CREATE'), currentCanAction('FIXED_DEPOSITS_APPROVE'),
    listActiveMembers(),
  ]);

  return (
    <Page title="Fixed Deposits" crumb="Member term deposits — funded from and paid back to their own savings" user={user}>
      <Tabs tabs={TABS} active={tab} hrefFor={(k) => `/fixed-deposits/${k}`} />
      <Toolbar>
        <SearchInput placeholder="Search member name, no. or document no.…" disabled={empty} />
        <Spacer />
        {canCreate ? <NewFixedDepositButton members={members} /> : null}
      </Toolbar>

      <Card>
        {deposits.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th>No.</th><th>Member</th><th>Type</th><th className="num">Amount</th>
                <th className="num">Rate</th><th>End date</th><th>Status</th><th className="num" />
              </tr>
            </thead>
            <tbody>
              {deposits.map((d) => {
                const isOwnRequest = d.created_by === user.username;
                const canEditThis = canCreate && (!canApprove || isOwnRequest);
                return (
                <tr key={d.no}>
                  <td className="mono"><Link href={`/fixed-deposits/view/${d.no}?view=${tab}`}>{d.no}</Link></td>
                  <td>
                    <b>{d.member_first_name} {d.member_last_name}</b>
                    <div className="tiny mono">{d.member_no}</div>
                  </td>
                  <td>{d.fd_type_code}</td>
                  <td className="num"><Money cents={d.amount} decimals={0} /></td>
                  <td className="num">{d.rate}%</td>
                  <td>{d.end_date}</td>
                  <td><Pill status={d.status} /></td>
                  <td className="num">
                    <div className="inline" style={{ justifyContent: 'flex-end' }}>
                      {d.status === 'Open' && canEditThis ? <SubmitButton no={d.no} /> : null}
                      {d.status === 'Pending Approval' && canCreate && isOwnRequest ? (
                        <CancelApprovalButton no={d.no} />
                      ) : null}
                      {d.status === 'Approved' && canApprove ? <ActivateButton no={d.no} /> : null}
                      {d.status === 'Active' && canApprove && d.end_date <= new Date().toISOString().slice(0, 10) ? (
                        <MatureButton no={d.no} />
                      ) : null}
                    </div>
                  </td>
                </tr>
                );
              })}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🏛" title="No fixed deposits here" sub="Try a different tab or clear the search" />}
      </Card>
    </Page>
  );
}
