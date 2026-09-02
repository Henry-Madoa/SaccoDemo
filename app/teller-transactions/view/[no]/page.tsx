import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  getTellerTransaction, getAdjacentTellerTransactionNos, listTellerTransactionHistory, type TellerTxnView,
} from '@/lib/tellerTransactions';
import { getDenominationLines } from '@/lib/denominations';
import { listActiveMembers } from '@/lib/members';
import { listMemberAccountInstructions } from '@/lib/accountInstructions';
import { imageSrc } from '@/lib/cloudinary';
import { AccountInstructionsList } from '@/components/members/account-instructions';
import { findPendingRoutedTask, isEligibleApprover, listWorkflowTasksForDocument } from '@/lib/workflow';
import { formatDateTime } from '@/lib/format';
import { Page } from '@/components/layout/page';
import {
  DefinitionList, EmptyState, Pill, TableWrap, Toolbar, Spacer,
} from '@/components/ui/primitives';
import { CollapsibleCard } from '@/components/ui/collapsible-card';
import { Money } from '@/components/ui/money';
import { DocumentActionsMenu } from '@/components/ui/document-actions';
import { CardNav } from '@/components/ui/card-nav';
import { DenominationGrid } from '@/components/ui/denomination-grid';
import {
  EditButton, SubmitButton, CancelApprovalButton, ApproveButton, RejectButton, DelegateButton,
  PostButton, DeleteButton, ResendSlipButton,
} from '../../teller-transaction-actions';

const VIEWS: TellerTxnView[] = ['open', 'pending', 'approved', 'posted'];

export default async function TellerTransactionDetailPage({ params, searchParams }: {
  params: Promise<{ no: string }>;
  searchParams: Promise<{ view?: string }>;
}) {
  const user = await requireAction('TELLER_TRANSACTIONS_READ');
  const { no } = await params;
  const { view: viewRaw } = await searchParams;
  const view = VIEWS.includes(viewRaw as TellerTxnView) ? (viewRaw as TellerTxnView) : undefined;

  const doc = await getTellerTransaction(no);
  if (!doc) notFound();
  const isDeposit = doc.transaction_type === 'CASH_DEPOSIT';

  const [canCreate, canApprove, canPost, tasks, { prevNo, nextNo }, denomLines, history, accountInstructions] = await Promise.all([
    currentCanAction('TELLER_TRANSACTIONS_CREATE'),
    currentCanAction('TELLER_TRANSACTIONS_APPROVE'),
    currentCanAction('TELLER_TRANSACTIONS_POST'),
    listWorkflowTasksForDocument('TELLER_TRANSACTION', no),
    getAdjacentTellerTransactionNos(no, view),
    getDenominationLines('TELLER', no),
    doc.status === 'Processed' ? listTellerTransactionHistory(no) : Promise.resolve([]),
    listMemberAccountInstructions(doc.member_id),
  ]);
  const photoSrc = imageSrc(doc.member_photo, { width: 150, height: 190, crop: 'fill' });
  const signatureSrc = imageSrc(doc.member_signature_image, { width: 240, height: 90, crop: 'fit' });

  const isOwn = doc.created_by === user.username;
  const isOpen = doc.status === 'Open';
  const editMembers = isOpen && canCreate && isOwn ? await listActiveMembers() : [];

  const routedTask = doc.status === 'Pending Approval' ? await findPendingRoutedTask('TELLER_TRANSACTION', no) : null;
  const canDecideThis = routedTask ? await isEligibleApprover(routedTask, user.id) : canApprove;
  const requestedBy = routedTask?.requested_by ?? doc.created_by;
  const canCancelThis = canCreate && requestedBy === user.username;
  const pendingWith = tasks.find((t) => t.status === 'PENDING')?.pending_with;
  const q = view ? `?view=${view}` : '';

  return (
    <>
      <CardNav
        prevHref={prevNo ? `/teller-transactions/view/${prevNo}${q}` : null}
        nextHref={nextNo ? `/teller-transactions/view/${nextNo}${q}` : null}
      />
      <Page
        title={`${doc.no} — ${isDeposit ? 'Cash Deposit' : 'Cash Withdrawal'}`}
        crumb={`${doc.status} · ${doc.member_first_name} ${doc.member_last_name} (${doc.member_no})${pendingWith ? ` · pending with ${pendingWith}` : ''}`}
        user={user}
      >
        <Toolbar>
          <Link href="/teller-transactions" className="btn ghost sm">← All transactions</Link>
          <Link href={`/members/${doc.member_id}`} className="btn ghost sm">View member</Link>
          <Spacer />
          {isOpen && canCreate && isOwn ? (
            <EditButton doc={doc} members={editMembers} className="btn ghost"
              verification={{ instructions: accountInstructions, photoSrc, signatureSrc }} />
          ) : null}
          {isOpen && canCreate && isOwn ? <DeleteButton no={doc.no} className="btn ghost" /> : null}
          {isOpen && doc.approval_required && canCreate && isOwn ? <SubmitButton no={doc.no} className="btn ghost" /> : null}
          {isOpen && !doc.approval_required && canPost ? <PostButton no={doc.no} /> : null}
          {doc.status === 'Pending Approval' && canCancelThis ? <CancelApprovalButton no={doc.no} className="btn ghost" /> : null}
          {doc.status === 'Pending Approval' && canDecideThis ? (
            <>
              {routedTask ? <DelegateButton taskId={routedTask.id} className="btn ghost" /> : null}
              <ApproveButton no={doc.no} />
              <RejectButton no={doc.no} className="btn ghost" />
            </>
          ) : null}
          {doc.status === 'Approved' && canPost ? <PostButton no={doc.no} /> : null}
          {doc.posted ? (
            <>
              <a className="btn ghost" href={`/teller-slip/${doc.no}`} target="_blank" rel="noreferrer">Print slip</a>
              <ResendSlipButton no={doc.no} className="btn ghost" />
            </>
          ) : null}
          <DocumentActionsMenu />
        </Toolbar>

        <CollapsibleCard title="Transaction details" sub={isDeposit ? 'Over-the-counter cash deposit' : 'Over-the-counter cash withdrawal'}>
          <div className="grid g2">
            <DefinitionList items={[
              ['Document no.', <span className="mono" key="no">{doc.no}</span>],
              ['Member', <>{doc.member_first_name} {doc.member_last_name} <span className="mono">({doc.member_no})</span></>],
              ['Account', <><span className="mono">{doc.account_no}</span> — {doc.account_product_name}</>],
              ['Amount', <Money cents={doc.amount} key="amt" />],
              doc.charge_amount ? ['Transaction charge', <><Money cents={doc.charge_amount} /> {doc.transaction_charge_code ? <span className="tiny mono">({doc.transaction_charge_code})</span> : null}</>] : null,
              isDeposit && doc.source_of_funds ? ['Source of funds', doc.source_of_funds] : null,
              doc.transacted_by_name ? ['Transacted by', `${doc.transacted_by_name}${doc.transacted_by_id_no ? ` — ID ${doc.transacted_by_id_no}` : ''}`] : null,
            ]} />
            <DefinitionList items={[
              ['Till', `${doc.till_code} — ${doc.till_name}`],
              ['Teller', doc.teller_username],
              ['Book balance (snapshot)', <Money cents={doc.book_balance} key="bb" />],
              ['Available (snapshot)', <Money cents={doc.available_balance} key="ab" />],
              ['Approval', doc.approval_required ? <Pill tone="warn" key="ar">Required (above limit)</Pill> : <Pill tone="ok" key="ar">Within limit</Pill>],
              ['Status', <Pill status={doc.status} key="st" />],
              doc.decision_reason ? ['Decision reason', doc.decision_reason] : null,
              doc.journal_no ? ['Journal', <span className="mono" key="j">{doc.journal_no}</span>] : null,
              doc.slip_emailed_at ? ['Slip emailed', formatDateTime(doc.slip_emailed_at)] : null,
            ]} />
          </div>
        </CollapsibleCard>

        <CollapsibleCard
          title="Member verification & account instructions"
          sub={isDeposit
            ? 'Confirm you are transacting with the right member'
            : 'Authenticate the person before paying out — check the photo and signature'}
        >
          {!isDeposit && accountInstructions.length ? (
            <div className="note" style={{ marginBottom: 12 }}>
              ⚠ This account carries {accountInstructions.length} operating instruction{accountInstructions.length === 1 ? '' : 's'} — read them before paying.
            </div>
          ) : null}
          <div className="grid split-side-sm">
            <div className="stack-2">
              <div>
                <div className="metric-label" style={{ marginBottom: 4 }}>Passport photo</div>
                {photoSrc
                  ? <img src={photoSrc} alt="Member" style={{ width: 150, borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)' }} />
                  : <div className="tiny muted-cell">No photo on file</div>}
              </div>
              <div>
                <div className="metric-label" style={{ marginBottom: 4 }}>Specimen signature</div>
                {signatureSrc
                  ? <img src={signatureSrc} alt="Signature" style={{ maxWidth: 240, border: '1px solid var(--border)', borderRadius: 'var(--radius-sm)', background: '#fff' }} />
                  : <div className="tiny muted-cell">No signature on file</div>}
              </div>
              <DefinitionList items={[
                ['Member', <>{doc.member_first_name} {doc.member_last_name} <span className="mono">({doc.member_no})</span></>],
                ['ID / Passport no.', <span className="mono" key="id">{doc.member_identification_no || '—'}</span>],
                doc.transacted_by_name
                  ? ['Presented by', `${doc.transacted_by_name}${doc.transacted_by_id_no ? ` — ID ${doc.transacted_by_id_no}` : ''}`]
                  : null,
              ]} />
            </div>
            <div>
              <div className="metric-label" style={{ marginBottom: 6 }}>Account instructions</div>
              <AccountInstructionsList lines={accountInstructions} dense />
            </div>
          </div>
        </CollapsibleCard>

        <CollapsibleCard title="Denomination breakdown" sub="Note & coin count for this transaction">
          <DenominationGrid
            kind="TELLER"
            docNo={no}
            lines={denomLines}
            amount={doc.amount}
            editable={isOpen && canCreate && isOwn}
          />
        </CollapsibleCard>

        <CollapsibleCard title="Document trail" sub="Who raised this, and when">
          <DefinitionList items={[
            ['Created by', doc.created_by || '—'],
            ['Created on', formatDateTime(doc.created_at)],
            ['Posted by', doc.posted_by || '—'],
            ['Posted on', formatDateTime(doc.posted_at)],
          ]} />
        </CollapsibleCard>

        {doc.status === 'Processed' ? (
          <CollapsibleCard title="Posted entries" sub={`${history.length} journal${history.length === 1 ? '' : 's'}`}>
            {history.length ? (
              <TableWrap>
                <thead><tr><th>Date</th><th>Journal</th><th>Description</th><th className="num">Amount</th></tr></thead>
                <tbody>
                  {history.map((h) => (
                    <tr key={h.journal_no}>
                      <td>{h.value_date}</td>
                      <td className="mono">{h.journal_no}</td>
                      <td>{h.description || '—'}</td>
                      <td className="num"><Money cents={h.amount} /></td>
                    </tr>
                  ))}
                </tbody>
              </TableWrap>
            ) : <EmptyState icon="🕓" title="Nothing posted yet" />}
          </CollapsibleCard>
        ) : null}

        <CollapsibleCard title="Approval details" sub={`${tasks.length} approval step${tasks.length === 1 ? '' : 's'} routed`}>
          {tasks.length ? (
            <TableWrap>
              <thead><tr><th>Sent by</th><th>Sent date</th><th>Approver</th><th>Approved on</th><th /></tr></thead>
              <tbody>
                {tasks.map((t) => (
                  <tr key={t.id}>
                    <td>{t.requested_by || '—'}</td>
                    <td>{formatDateTime(t.requested_at)}</td>
                    <td className="muted-cell">{t.decided_by || t.pending_with || '—'}</td>
                    <td>{t.decided_at ? formatDateTime(t.decided_at) : '—'}</td>
                    <td><Pill status={t.status} /></td>
                  </tr>
                ))}
              </tbody>
            </TableWrap>
          ) : <EmptyState icon="🕓" title="Not routed for approval (within limit)" />}
        </CollapsibleCard>
      </Page>
    </>
  );
}
