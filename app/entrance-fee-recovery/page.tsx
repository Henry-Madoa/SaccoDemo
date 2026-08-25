import Link from 'next/link';
import { requireAction, currentCanAction } from '@/lib/session';
import { listEntranceFeeRecoveryCandidates } from '@/lib/entranceFeeRecovery';
import { Page } from '@/components/layout/page';
import {
  Card, CardHead, EmptyState, TableWrap, Toolbar, Spacer,
} from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import { RunRecoveryButton } from './entrance-fee-recovery-actions';

export default async function EntranceFeeRecoveryPage() {
  const user = await requireAction('ENTRANCE_FEE_RECOVERY_READ');
  const [candidates, canRun] = await Promise.all([
    listEntranceFeeRecoveryCandidates(),
    currentCanAction('ENTRANCE_FEE_RECOVERY_RUN'),
  ]);
  const dueNow = candidates.filter((c) => c.posting_amount > 0);

  return (
    <Page title="Entrance Fee Recovery"
      crumb="Sweeps a Not Paid Up member's Registration Fee from their Non-Withdrawable Deposit account, and activates them once it's fully recovered"
      user={user}>
      <Toolbar>
        <Spacer />
        {canRun ? <RunRecoveryButton disabled={!dueNow.length} /> : null}
      </Toolbar>

      <Card>
        <CardHead
          title={`${candidates.length} Not Paid Up member(s) with a registration fee configured`}
          sub={`${dueNow.length} currently have an available balance to sweep — this can also run unattended from Admin Centre → System Automation`}
        />
        {candidates.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th>Member</th><th>Category</th>
                <th className="num">Registration fee</th><th className="num">Paid so far</th>
                <th className="num">Outstanding</th><th>Deposit account</th>
                <th className="num">Available balance</th><th className="num">Would recover</th>
              </tr>
            </thead>
            <tbody>
              {candidates.map((c) => (
                <tr key={c.member_id}>
                  <td>
                    <Link href={`/members/${c.member_id}`}><b>{c.first_name} {c.last_name}</b></Link>
                    <div className="tiny mono">{c.member_no}</div>
                  </td>
                  <td className="mono">{c.category_code}</td>
                  <td className="num"><Money cents={c.registration_fee} /></td>
                  <td className="num"><Money cents={c.paid_registration} /></td>
                  <td className="num"><Money cents={c.outstanding} /></td>
                  <td className="mono">{c.deposit_account_no ?? '—'}</td>
                  <td className="num"><Money cents={c.available_balance} /></td>
                  <td className="num">
                    <b className={c.posting_amount > 0 ? 'pos' : undefined}><Money cents={c.posting_amount} /></b>
                  </td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : (
          <EmptyState icon="🎟" title="Nothing to recover"
            sub="No Not Paid Up member currently has a Member Category with a Registration Fee and Registration Fee Account configured" />
        )}
      </Card>
    </Page>
  );
}
