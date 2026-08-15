import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  getMemberCharging, getAdjacentMemberChargingNos, getMemberChargingJournal, type MemberChargingView,
} from '@/lib/memberCharging';
import { formatDateTime } from '@/lib/format';
import { Page } from '@/components/layout/page';
import {
  Card, CardHead, DefinitionList, EmptyState, Pill, TableWrap, Toolbar, Spacer,
} from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import { CardNav } from '@/components/ui/card-nav';
import { EditButton, DeleteButton, PostButton } from '../../member-charging-actions';

const MEMBER_CHARGING_VIEWS: MemberChargingView[] = ['open', 'posted'];

export default async function MemberChargingDetailPage({ params, searchParams }: {
  params: Promise<{ no: string }>;
  searchParams: Promise<{ view?: string }>;
}) {
  const user = await requireAction('MEMBER_CHARGING_READ');
  const { no } = await params;
  const { view: viewRaw } = await searchParams;
  const view = MEMBER_CHARGING_VIEWS.includes(viewRaw as MemberChargingView) ? (viewRaw as MemberChargingView) : undefined;
  const request = await getMemberCharging(no);
  if (!request) notFound();

  const [canCreate, canPost, { prevNo, nextNo }, journal] = await Promise.all([
    currentCanAction('MEMBER_CHARGING_CREATE'), currentCanAction('MEMBER_CHARGING_POST'),
    getAdjacentMemberChargingNos(no, view),
    request.status === 'Posted' ? getMemberChargingJournal(no) : Promise.resolve(null),
  ]);

  const isOpen = request.status === 'Open';
  const isOwn = request.created_by === user.username;
  const canEditThis = canCreate && (!canPost || isOwn);
  const posted = request.status === 'Posted';

  return (
    <>
      <CardNav
        prevHref={prevNo ? `/member-chargings/view/${prevNo}${view ? `?view=${view}` : ''}` : null}
        nextHref={nextNo ? `/member-chargings/view/${nextNo}${view ? `?view=${view}` : ''}` : null}
      />
      <Page
        title={`${request.source_account_no} — ${request.member_first_name} ${request.member_last_name}`}
        crumb={`${request.no} · ${request.status} · ${request.member_no}`}
        user={user}
      >
      <Toolbar>
        <Link href="/member-chargings" className="btn ghost sm">← All member charging documents</Link>
        <Link href={`/savings/${request.source_account_id}`} className="btn ghost sm">View account</Link>
        <Link href={`/members/${request.member_id}`} className="btn ghost sm">View member</Link>
        <Spacer />
        {isOpen && canEditThis ? <EditButton request={request} className="btn ghost" /> : null}
        {isOpen && canEditThis ? <DeleteButton no={request.no} className="btn ghost" /> : null}
        {isOpen && canPost ? <PostButton no={request.no} amount={request.amount_charged} /> : null}
      </Toolbar>

      <Card>
        <CardHead title="Document details" sub="Status" />
        <DefinitionList items={[
          ['Document no.', <span className="mono" key="no">{request.no}</span>],
          ['Member', <>{request.member_first_name} {request.member_last_name} <span className="mono">({request.member_no})</span></>],
          ['Source account', <><span className="mono">{request.source_account_no}</span></>],
          ['Source balance', <Money cents={request.source_balance} key="source-balance" />],
          ['Description', request.description || '—'],
          ['Charge code', `${request.transaction_charge_code} — ${request.transaction_charge_description}`],
          ['Posting transaction type', request.posting_transaction_type],
          request.posting_transaction_type === 'Statement Charge' ? ['No. of pages', request.no_of_pages ?? '—'] : null,
          ['Amount charged', <Money cents={request.amount_charged} key="amount-charged" />],
          ['Status', <Pill status={request.status} key="status" />],
        ]} />
      </Card>

      <Card>
        <CardHead title="Document trail" sub="Who created and posted this document, and when" />
        <DefinitionList items={[
          ['Created by', request.created_by || '—'],
          ['Created on', formatDateTime(request.created_at)],
          ['Posted', posted
            ? <Pill tone="ok" key="posted">YES — charge posted</Pill>
            : <Pill tone="warn" key="posted">NOT YET</Pill>],
          posted ? ['Posted by', request.posted_by || '—'] : null,
          posted ? ['Posted on', formatDateTime(request.posted_at)] : null,
        ]} />
      </Card>

      {posted ? (
        <Card>
          <CardHead
            title="Related ledger entries"
            sub={journal ? `Journal ${journal.journal.journal_no}` : 'Navigate'}
          />
          {journal ? (
            <TableWrap>
              <thead>
                <tr><th>Account</th><th>Narration</th><th className="num">Debit</th><th className="num">Credit</th></tr>
              </thead>
              <tbody>
                {journal.lines.map((l) => (
                  <tr key={l.id}>
                    <td><span className="mono">{l.code}</span> — {l.name}</td>
                    <td>{l.narration || '—'}</td>
                    <td className="num">{l.debit ? <Money cents={l.debit} /> : '—'}</td>
                    <td className="num">{l.credit ? <Money cents={l.credit} /> : '—'}</td>
                  </tr>
                ))}
              </tbody>
            </TableWrap>
          ) : <EmptyState icon="⚖" title="No ledger entries found" />}
        </Card>
      ) : null}
      </Page>
    </>
  );
}
