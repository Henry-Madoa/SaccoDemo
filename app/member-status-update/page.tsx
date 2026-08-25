import Link from 'next/link';
import { requireAction, currentCanAction } from '@/lib/session';
import { listMemberStatusUpdateCandidates } from '@/lib/memberStatusUpdate';
import { Page } from '@/components/layout/page';
import {
  Card, CardHead, EmptyState, Pill, TableWrap, Toolbar, Spacer,
} from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import { RunStatusUpdateButton } from './member-status-update-actions';
import type { MemberStatusUpdateAction } from '@/lib/types';

const ACTION_LABEL: Record<MemberStatusUpdateAction, string> = {
  NONE: '—',
  MARK_DORMANT: 'Will mark Dormant',
  REACTIVATE: 'Will reactivate',
  REACTIVATION_BLOCKED: 'Reactivation blocked',
};

const ACTION_TONE: Record<MemberStatusUpdateAction, '' | 'ok' | 'warn' | 'bad'> = {
  NONE: '',
  MARK_DORMANT: 'warn',
  REACTIVATE: 'ok',
  REACTIVATION_BLOCKED: 'bad',
};

export default async function MemberStatusUpdatePage() {
  const user = await requireAction('MEMBER_STATUS_UPDATE_READ');
  const [candidates, canRun] = await Promise.all([
    listMemberStatusUpdateCandidates(),
    currentCanAction('MEMBER_STATUS_UPDATE_RUN'),
  ]);
  const pending = candidates.filter((c) => c.action !== 'NONE');

  return (
    <Page title="Member Status Update"
      crumb="Marks a member Dormant when their Non-Withdrawable Deposit account has carried no money long enough, and reactivates a Dormant member the moment it does again"
      user={user}>
      <Toolbar>
        <Spacer />
        {canRun ? <RunStatusUpdateButton disabled={!pending.length} /> : null}
      </Toolbar>

      <Card>
        <CardHead
          title={`${candidates.length} Active/Dormant member(s) evaluated`}
          sub={`${pending.length} would change on the next run — this can also run unattended from Admin Centre → System Automation`}
        />
        {candidates.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th>Member</th><th>Status</th><th>Deposit account</th>
                <th className="num">Balance</th><th className="num">Days idle</th>
                <th className="num">Reactivation charge</th><th>Next run</th>
              </tr>
            </thead>
            <tbody>
              {candidates.map((c) => (
                <tr key={c.member_id}>
                  <td>
                    <Link href={`/members/${c.member_id}`}><b>{c.first_name} {c.last_name}</b></Link>
                    <div className="tiny mono">{c.member_no}</div>
                  </td>
                  <td><Pill status={c.status} /></td>
                  <td className="mono">{c.deposit_account_no ?? '—'}</td>
                  <td className="num"><Money cents={c.balance} /></td>
                  <td className="num">{c.days_since_activity ?? '—'}</td>
                  <td className="num">{c.reactivation_charge != null ? <Money cents={c.reactivation_charge} /> : '—'}</td>
                  <td><Pill tone={ACTION_TONE[c.action]}>{ACTION_LABEL[c.action]}</Pill></td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : (
          <EmptyState icon="🕰" title="Nothing to evaluate"
            sub="No member is currently Active or Dormant with a Non-Withdrawable Deposit account" />
        )}
      </Card>
    </Page>
  );
}
