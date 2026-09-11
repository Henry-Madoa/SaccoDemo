'use client';

import { useEffect, useState, type ReactNode } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { AppliesToPicker } from '@/components/ui/applies-to-picker';
import { MemberSelect } from '@/components/ui/member-select';
import { useFormat } from '@/components/ui/format-provider';
import { today } from '@/lib/format';
import {
  createReceiptRequest, updateReceiptRequest, memberReceiptOptions, type ReceiptLineDraft,
} from '@/app/actions/cashMgmt';
import type {
  MemberReceiptAccount, MemberReceiptLoan, Member, ReceiptDetail, ReceiptLineType,
} from '@/lib/types';

/**
 * AL Enum-Ext52204000: the header's Receipt Type is what a line's Account No relates to, so the
 * type is chosen once and every line follows it. There is no per-line type.
 */
const RECEIPT_TYPES: ReceiptLineType[] = ['Member', 'G/L Account', 'Customer', 'Vendor', 'Bank Account'];

type Opt = { code: string; name: string };
type EligibleMember = Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>;

export interface ReceiptFormProps {
  banks: { id: number; code: string; name: string; currency_code: string }[];
  accounts: Opt[];
  customers: { no: string; name: string }[];
  vendors: { no: string; name: string }[];
  currencies: { code: string }[];
  payMethods: { code: string }[];
  members: EligibleMember[];
}

const emptyLine = (): ReceiptLineDraft => ({
  lineType: '', accountNo: '', description: '', amount: '', appliesToDocNo: '',
  savingsAccountId: '', loanId: '',
});

const sumLines = (lines: ReceiptLineDraft[]): number =>
  lines.reduce((s, l) => s + Math.round((Number(l.amount) || 0) * 100), 0);

function Body({ p, initial, lines, setLines }: {
  p: ReceiptFormProps; initial?: ReceiptDetail | null;
  lines: ReceiptLineDraft[]; setLines: (l: ReceiptLineDraft[]) => void;
}) {
  const { cur } = useFormat();
  const [receiptType, setReceiptType] = useState<ReceiptLineType>(initial?.receipt_type ?? 'G/L Account');
  const [memberId, setMemberId] = useState(String(initial?.member_id ?? ''));
  const [received, setReceived] = useState(initial?.received_amount ? String(initial.received_amount / 100) : '');
  const [accounts, setAccounts] = useState<MemberReceiptAccount[]>([]);
  const [loans, setLoans] = useState<MemberReceiptLoan[]>([]);

  const isMember = receiptType === 'Member';

  // The member's own accounts and loans, loaded when a member is chosen — AL's Member No. lookup
  // on the line is filtered to that member's Sacco and Loan accounts.
  useEffect(() => {
    let cancelled = false;
    if (!isMember || !memberId) { setAccounts([]); setLoans([]); return; }
    memberReceiptOptions(Number(memberId)).then((res) => {
      if (cancelled || !res.ok) return;
      setAccounts(res.data.accounts);
      setLoans(res.data.loans);
    });
    return () => { cancelled = true; };
  }, [isMember, memberId]);

  const set = (i: number, k: keyof ReceiptLineDraft, v: string) =>
    setLines(lines.map((l, idx) => (idx === i ? { ...l, [k]: v } : l)));

  /**
   * A member line pays into one of two things, so the picker offers both and the value says
   * which: "acct:<id>" deposits into a savings account, "loan:<id>" repays a loan.
   */
  const pickTarget = (i: number, value: string) => {
    const [kind, rawId] = value.split(':');
    const acc = kind === 'acct' ? accounts.find((a) => String(a.id) === rawId) : undefined;
    setLines(lines.map((l, idx) => (idx === i
      ? {
        ...l,
        savingsAccountId: kind === 'acct' ? rawId : '',
        loanId: kind === 'loan' ? rawId : '',
        accountNo: acc?.account_no ?? '',
      }
      : l)));
  };

  const targetOf = (l: ReceiptLineDraft): string =>
    (l.loanId ? `loan:${l.loanId}` : l.savingsAccountId ? `acct:${l.savingsAccountId}` : '');

  const accountPicker = (l: ReceiptLineDraft, i: number): ReactNode => {
    if (isMember) {
      return (
        <select value={targetOf(l)} onChange={(e) => pickTarget(i, e.target.value)}
          aria-label="Pay into" disabled={!memberId}>
          <option value="">{memberId ? '…' : 'Pick the member first'}</option>
          {accounts.length ? (
            <optgroup label="Deposit into">
              {accounts.map((a) => (
                <option key={`a${a.id}`} value={`acct:${a.id}`}>{a.account_no} — {a.product_name}</option>
              ))}
            </optgroup>
          ) : null}
          {loans.length ? (
            <optgroup label="Repay loan">
              {loans.map((x) => (
                <option key={`l${x.id}`} value={`loan:${x.id}`}>{x.loan_no} — {x.product_name}</option>
              ))}
            </optgroup>
          ) : null}
        </select>
      );
    }
    const rows = receiptType === 'Customer' ? p.customers.map((c) => ({ v: c.no, t: `${c.no} — ${c.name}` }))
      : receiptType === 'Vendor' ? p.vendors.map((c) => ({ v: c.no, t: `${c.no} — ${c.name}` }))
        : receiptType === 'Bank Account' ? p.banks.map((c) => ({ v: c.code, t: `${c.code} — ${c.name}` }))
          : p.accounts.map((c) => ({ v: c.code, t: `${c.code} — ${c.name}` }));
    return (
      <select value={l.accountNo} onChange={(e) => set(i, 'accountNo', e.target.value)} aria-label="Account">
        <option value="">…</option>
        {rows.map((r) => <option key={r.v} value={r.v}>{r.t}</option>)}
      </select>
    );
  };

  const lineTotal = sumLines(lines);
  const receivedCents = Math.round((Number(received) || 0) * 100);
  const outOfBalance = receivedCents > 0 && receivedCents !== lineTotal;

  return (
    <>
      <div className="grid g3">
        <div className="field">
          <label htmlFor="f_receiptType">Receipt type <span className="req">*</span></label>
          <select id="f_receiptType" name="receiptType" value={receiptType}
            onChange={(e) => {
              // Changing the type invalidates every account already picked, so the lines reset.
              setReceiptType(e.target.value as ReceiptLineType);
              setLines([emptyLine()]);
            }}>
            {RECEIPT_TYPES.map((t) => <option key={t} value={t}>{t}</option>)}
          </select>
          <div className="hint">Every line on this receipt is posted to a {receiptType}.</div>
        </div>
        <Field name="bankAccountId" label="Bank account (money in)" type="select" required defaultValue={String(initial?.bank_account_id ?? '')}
          options={[{ value: '', label: '…' }, ...p.banks.map((b) => ({ value: String(b.id), label: `${b.code} — ${b.name} (${b.currency_code})` }))]} />
        <Field name="postingDate" label="Posting date" type="date" required defaultValue={initial?.posting_date ?? today()} />
      </div>

      {isMember ? (
        <div className="grid g2">
          <MemberSelect id="f_memberId" name="memberId" label="Member" members={p.members}
            value={memberId} onChange={(id) => { setMemberId(id); setLines([emptyLine()]); }} required />
          <Field name="receivedAmount" label="Amount received" type="currency" required
            defaultValue={received} onChange={(e) => setReceived(e.target.value)}
            hint="What was counted at the counter — it must equal the lines below" />
        </div>
      ) : (
        <input type="hidden" name="memberId" value="" />
      )}

      <div className="grid g3">
        <Field name="currencyCode" label="Currency" type="select" defaultValue={initial?.currency_code ?? ''} options={[{ value: '', label: '(bank currency)' }, ...p.currencies.map((c) => ({ value: c.code, label: c.code }))]} />
        <Field name="payModeCode" label="Payment mode" type="select" defaultValue={initial?.pay_mode_code ?? ''} options={[{ value: '', label: '(none)' }, ...p.payMethods.map((m) => ({ value: m.code, label: m.code }))]} />
        <Field name="externalDocumentNo" label="Cheque / M-Pesa ref." defaultValue={initial?.external_document_no ?? ''} />
      </div>
      <div className="grid g2">
        <Field name="manualReceiptNo" label="Manual receipt no." defaultValue={initial?.manual_receipt_no ?? ''} placeholder="Optional" />
        <Field name="description" label="Received from / narration" required defaultValue={initial?.description ?? ''} />
      </div>
      {isMember ? null : <input type="hidden" name="receivedAmount" value="" />}

      <div className="hint" style={{ marginTop: 8 }}>Lines</div>
      <table>
        <thead>
          <tr>
            <th>{isMember ? 'Pay into' : receiptType}</th>
            <th>Description</th>
            <th style={{ width: 130 }}>Amount</th>
            {isMember ? <th style={{ width: 150 }}>Owing</th> : <th>Applies to</th>}
            <th style={{ width: 32 }} />
          </tr>
        </thead>
        <tbody>
          {lines.map((l, i) => {
            const acc = accounts.find((a) => String(a.id) === l.savingsAccountId);
            const loan = loans.find((x) => String(x.id) === l.loanId);
            return (
              <tr key={i}>
                <td>{accountPicker(l, i)}</td>
                <td><input value={l.description} onChange={(e) => set(i, 'description', e.target.value)} aria-label="Description" /></td>
                <td><input type="number" step="0.01" min={0} value={l.amount} onChange={(e) => set(i, 'amount', e.target.value)} aria-label="Amount" /></td>
                {isMember ? (
                  <td className="tiny muted-cell">
                    {loan ? (
                      <>
                        <div>Owing {cur(loan.loan_balance)}</div>
                        <div>Int. {cur(loan.interest_balance)} · Pen. {cur(loan.penalty_balance)}</div>
                      </>
                    ) : acc ? `Balance ${cur(acc.balance)}` : '—'}
                  </td>
                ) : (
                  <td>
                    <AppliesToPicker
                      partyType={receiptType === 'Customer' ? 'Customer' : receiptType === 'Vendor' ? 'Vendor' : null}
                      partyNo={l.accountNo} value={l.appliesToDocNo ?? ''}
                      onChange={(v) => set(i, 'appliesToDocNo', v)}
                      onPickAmount={(amt) => set(i, 'amount', amt)}
                    />
                  </td>
                )}
                <td><button type="button" className="btn sm ghost" onClick={() => setLines(lines.filter((_, idx) => idx !== i))} aria-label="Remove">×</button></td>
              </tr>
            );
          })}
        </tbody>
      </table>
      <div className="inline" style={{ marginTop: 8, justifyContent: 'space-between' }}>
        <button type="button" className="btn ghost sm" onClick={() => setLines([...lines, emptyLine()])}>Add line</button>
        <span className={outOfBalance ? 'tiny danger-text' : 'tiny muted-cell'}>
          Lines total {cur(lineTotal)}
          {receivedCents > 0 ? ` · received ${cur(receivedCents)}` : ''}
          {outOfBalance ? ` · out by ${cur(Math.abs(receivedCents - lineTotal))}` : ''}
        </span>
      </div>
      {isMember ? (
        <div className="note">
          A line against a loan repays it — penalties first, then interest, then principal — and the
          loan repayment charge on Cash Management Setup comes off before the rest reaches the
          loan. A line against an account is a deposit into it.
        </div>
      ) : null}
    </>
  );
}

export function NewReceiptButton(p: ReceiptFormProps) {
  const [open, setOpen] = useState(false);
  const [lines, setLines] = useState<ReceiptLineDraft[]>([emptyLine()]);
  return (
    <>
      <button type="button" className="btn" onClick={() => { setLines([emptyLine()]); setOpen(true); }}>New receipt</button>
      {open ? (
        <FormModal title="New receipt" wide onClose={() => setOpen(false)} onSubmit={(v) => createReceiptRequest(v, lines)}
          submitLabel="Create" successTitle="Receipt created" successDetail={(d) => `${d.no} created — submit it for approval`}>
          <Body p={p} lines={lines} setLines={setLines} />
        </FormModal>
      ) : null}
    </>
  );
}

export function EditReceiptButton({ receipt, className = 'btn sm ghost', p }: { receipt: ReceiptDetail; className?: string; p: ReceiptFormProps }) {
  const [open, setOpen] = useState(false);
  const [lines, setLines] = useState<ReceiptLineDraft[]>(() => (receipt.lines.length
    ? receipt.lines.map((l) => ({
      lineType: l.line_type,
      accountNo: l.account_no ?? '',
      description: l.description ?? '',
      amount: String(l.amount / 100),
      appliesToDocNo: l.applies_to_doc_no ?? '',
      savingsAccountId: l.savings_account_id ? String(l.savings_account_id) : '',
      loanId: l.loan_id ? String(l.loan_id) : '',
    }))
    : [emptyLine()]));
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Edit</button>
      {open ? (
        <FormModal title={`Edit ${receipt.no}`} wide onClose={() => setOpen(false)} onSubmit={(v) => updateReceiptRequest(receipt.no, v, lines)}
          submitLabel="Save changes" successTitle="Receipt updated">
          <Body p={p} initial={receipt} lines={lines} setLines={setLines} />
        </FormModal>
      ) : null}
    </>
  );
}
