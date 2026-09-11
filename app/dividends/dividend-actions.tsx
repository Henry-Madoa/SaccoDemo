'use client';

import { useState } from 'react';
import Link from 'next/link';
import { FormModal } from '@/components/ui/form-modal';
import { Field, MoneyInput } from '@/components/ui/field';
import { SearchableSelect } from '@/components/ui/searchable-select';
import { useRunAction } from '@/components/ui/run-action';
import { useFormat } from '@/components/ui/format-provider';
import {
  createDividendRequest, saveDividend, deleteDividendRequest, saveDividendParams,
  runDividendCalculation, submitDividendRequest, cancelDividendApprovalRequest,
  approveDividendRequest, rejectDividendRequest, reopenDividendRequest, postDividendRequest,
  saveDividendLine,
} from '@/app/actions/dividends';
import { DIVIDEND_RATE_TYPES, defaultDividendRateType } from '@/lib/constants';
import type { DividendParamInput } from '@/lib/dividends';
import type {
  DividendDetail, DividendLineView, DividendParamView, DividendPostTo, DividendRateType,
} from '@/lib/types';

type ProductOption = { id: number; code: string; name: string; category: string; min_balance: number };
type AccountOption = { id: number; code: string; name: string };
type ChargeOption = { id: number; code: string; description: string };

export interface DividendFormOptions {
  products: ProductOption[];
  accounts: AccountOption[];
  charges: ChargeOption[];
}

const yearOf = (d: string | null | undefined): number =>
  Number(String(d ?? '').slice(0, 4)) || new Date().getFullYear();

/* ------------------------------------------------------------------ the header */

function DividendFields({ options, initial }: { options: DividendFormOptions; initial?: DividendDetail | null }) {
  const lastYear = new Date().getFullYear() - 1;
  const [year, setYear] = useState(String(initial?.dividend_year ?? lastYear));
  const [book, setBook] = useState(initial?.document_type ?? 'BOSA');
  const [computation, setComputation] = useState(initial?.computation_type ?? 'Automatic');
  const [postingType, setPostingType] = useState(initial?.posting_type ?? 'Provisioning');
  const [expenseId, setExpenseId] = useState(String(initial?.expense_account_id ?? ''));
  const [payableId, setPayableId] = useState(String(initial?.payable_account_id ?? ''));
  const [chargeId, setChargeId] = useState(String(initial?.transaction_charge_id ?? ''));
  const [boost, setBoost] = useState(Boolean(Number(initial?.boost_to_minimum ?? 0)));
  const [maxBoost, setMaxBoost] = useState(
    initial?.maximum_boost_amount ? (initial.maximum_boost_amount / 100).toFixed(2) : '',
  );

  // The dividend year drives the period, so an officer only types the year for the usual case.
  const start = initial?.start_date ?? `${year}-01-01`;
  const end = initial?.end_date ?? `${year}-12-31`;

  return (
    <>
      <div className="grid g2">
        <div className="field">
          <label htmlFor="f_documentType">Book <span className="req">*</span></label>
          <select id="f_documentType" name="documentType" value={book}
            onChange={(e) => setBook(e.target.value as 'BOSA' | 'FOSA')} disabled={!!initial}>
            <option value="BOSA">BOSA — dividend on deposits and share capital</option>
            <option value="FOSA">FOSA — interest on savings</option>
          </select>
          <div className="hint">
            {book === 'BOSA'
              ? 'Each month earns on how much the account grew that month, pro-rated for the rest of the year.'
              : 'Each month earns on the lowest balance the account held that month, at one twelfth of the rate.'}
          </div>
        </div>
        <Field name="dividendYear" label="Dividend year" type="number" required
          defaultValue={year} onChange={(e) => setYear(e.target.value)} min={2000} max={2100} />
      </div>

      <Field name="description" label="Description" required defaultValue={initial?.description ?? ''}
        placeholder={`${book} dividend for the year ${year}`} />
      <Field name="postingDescription" label="Posting description" defaultValue={initial?.posting_description ?? ''}
        hint="What members see on their statement — defaults to the description above" />

      <div className="grid g3">
        <Field name="startDate" label="Period from" type="date" required defaultValue={start} />
        <Field name="endDate" label="Period to" type="date" required defaultValue={end} />
        <Field name="postingDate" label="Posting date" type="date" required
          defaultValue={initial?.posting_date ?? `${year}-12-31`} />
      </div>

      <div className="grid g2">
        <div className="field">
          <label htmlFor="f_postingType">Posting type <span className="req">*</span></label>
          <select id="f_postingType" name="postingType" value={postingType}
            onChange={(e) => setPostingType(e.target.value as 'Provisioning' | 'Payout')}>
            <option value="Provisioning">Provisioning — raise the expense and the payable</option>
            <option value="Payout">Payout — settle the payable to the members</option>
          </select>
        </div>
        <div className="field">
          <label htmlFor="f_computationType">Computation <span className="req">*</span></label>
          <select id="f_computationType" name="computationType" value={computation}
            onChange={(e) => setComputation(e.target.value as 'Automatic' | 'Manual Upload')}>
            <option value="Automatic">Automatic — walk each member’s ledger</option>
            <option value="Manual Upload">Manual Upload — take the amounts as given</option>
          </select>
        </div>
      </div>

      <div className="grid g2">
        <SearchableSelect id="f_expenseAccountId" name="expenseAccountId" label="Dividend expense account"
          required={postingType === 'Provisioning'}
          items={options.accounts} getValue={(a) => String(a.id)} getLabel={(a) => `${a.code} — ${a.name}`}
          value={expenseId} onChange={setExpenseId} placeholder="Search account…" emptyText="No matching accounts"
          hint="Debited when the dividend is provided for" />
        <SearchableSelect id="f_payableAccountId" name="payableAccountId" label="Dividend payable account" required
          items={options.accounts} getValue={(a) => String(a.id)} getLabel={(a) => `${a.code} — ${a.name}`}
          value={payableId} onChange={setPayableId} placeholder="Search account…" emptyText="No matching accounts"
          hint="Credited on provisioning, debited on payout" />
      </div>

      <SearchableSelect id="f_transactionChargeId" name="transactionChargeId" label="Charge code"
        items={options.charges} getValue={(c) => String(c.id)} getLabel={(c) => `${c.code} — ${c.description}`}
        value={chargeId} onChange={setChargeId} placeholder="No charge" emptyText="No transaction charges configured"
        hint="Optional — deducted from each member’s earning before it is paid" />

      <div className="grid g2">
        <Field name="recoverLoans" label="Recover outstanding loans" type="checkbox"
          defaultValue={Number(initial?.recover_loans ?? 0)}
          hint="Apply each member’s dividend against what they owe before paying the balance" />
        <Field name="preferentialBoost" label="Allow preferential share boost" type="checkbox"
          defaultValue={Number(initial?.preferential_boost ?? 0)}
          hint="Lets a member plough a chosen percentage back into share capital" />
      </div>

      <div className="grid g2">
        <Field name="boostToMinimum" label="Boost share capital to the minimum" type="checkbox"
          defaultValue={Number(initial?.boost_to_minimum ?? 0)} onChange={(e) => setBoost((e.target as HTMLInputElement).checked)}
          hint="Top a member up to the statutory minimum share capital out of their dividend" />
        <div className="field">
          <label htmlFor="f_maximumBoostAmount">Maximum boost amount</label>
          <MoneyInput id="f_maximumBoostAmount" value={maxBoost} onChange={setMaxBoost} min={0} disabled={!boost} />
          <input type="hidden" name="maximumBoostAmount" value={maxBoost} />
          <div className="hint">Leave empty for no ceiling</div>
        </div>
      </div>
    </>
  );
}

export function NewDividendButton({ options }: { options: DividendFormOptions }) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className="btn" onClick={() => setOpen(true)}>New dividend</button>
      {open ? (
        <FormModal
          title="New dividend declaration" wide
          onClose={() => setOpen(false)}
          onSubmit={createDividendRequest}
          submitLabel="Save"
          successTitle="Dividend created"
          successDetail={(d) => `${d.no} saved — set the rates, then calculate`}
        >
          <DividendFields options={options} />
        </FormModal>
      ) : null}
    </>
  );
}

export function EditDividendButton({ dividend, options, className = 'btn ghost' }: {
  dividend: DividendDetail; options: DividendFormOptions; className?: string;
}) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Edit</button>
      {open ? (
        <FormModal
          title={`Edit ${dividend.no}`} wide
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveDividend(dividend.no, values)}
          submitLabel="Save changes"
          successTitle="Dividend updated"
        >
          <DividendFields options={options} initial={dividend} />
        </FormModal>
      ) : null}
    </>
  );
}

export function DeleteDividendButton({ no, className = 'btn ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => deleteDividendRequest(no), {
        confirm: {
          title: 'Delete this dividend?',
          message: 'The declaration and everything calculated under it are removed. This cannot be undone.',
          confirmLabel: 'Delete', danger: true,
        },
        successTitle: 'Dividend deleted',
        redirectTo: '/dividends',
      })}>
      {busy ? 'Working…' : 'Delete'}
    </button>
  );
}

/* ------------------------------------------------------------- the rate grid */

interface ParamDraft {
  key: number;
  productId: string;
  postingDescription: string;
  rate: string;
  rateType: DividendRateType;
  postTo: DividendPostTo;
  minimumBalance: string;
  qualifiedMinimumBalance: string;
  maximumBoostAmount: string;
}

let draftKey = 0;
const blankDraft = (): ParamDraft => ({
  key: (draftKey += 1),
  productId: '', postingDescription: '', rate: '', rateType: 'Pro Rated', postTo: 'Savings',
  minimumBalance: '', qualifiedMinimumBalance: '', maximumBoostAmount: '',
});

/** The AL "Dividend Calculation Params" subpage: one row per participating savings product,
 *  edited and saved as a block. */
export function EditParamsButton({ no, params, products, className = 'btn ghost' }: {
  no: string; params: DividendParamView[]; products: ProductOption[]; className?: string;
}) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>
        {params.length ? 'Edit rates' : 'Set rates'}
      </button>
      {open ? <ParamsModal no={no} params={params} products={products} onClose={() => setOpen(false)} /> : null}
    </>
  );
}

function ParamsModal({ no, params, products, onClose }: {
  no: string; params: DividendParamView[]; products: ProductOption[]; onClose: () => void;
}) {
  const [rows, setRows] = useState<ParamDraft[]>(() => (
    params.length
      ? params.map((p) => ({
        key: (draftKey += 1),
        productId: String(p.product_id),
        postingDescription: p.posting_description,
        rate: String(p.rate),
        rateType: p.rate_type,
        postTo: p.post_to,
        minimumBalance: (p.minimum_balance / 100).toFixed(2),
        qualifiedMinimumBalance: (p.qualified_minimum_balance / 100).toFixed(2),
        maximumBoostAmount: p.maximum_boost_amount ? (p.maximum_boost_amount / 100).toFixed(2) : '',
      }))
      : [blankDraft()]
  ));

  const set = (key: number, patch: Partial<ParamDraft>) =>
    setRows((rs) => rs.map((r) => (r.key === key ? { ...r, ...patch } : r)));

  const submit = () => saveDividendParams(no, rows
    .filter((r) => r.productId)
    .map((r): DividendParamInput => ({
      productId: Number(r.productId),
      postingDescription: r.postingDescription.trim()
        || products.find((p) => String(p.id) === r.productId)?.name
        || 'Dividend',
      rate: Number(r.rate || 0),
      rateType: r.rateType,
      postTo: r.postTo,
      minimumBalance: r.minimumBalance === '' ? undefined : Math.round(Number(r.minimumBalance) * 100),
      qualifiedMinimumBalance: r.qualifiedMinimumBalance === '' ? undefined : Math.round(Number(r.qualifiedMinimumBalance) * 100),
      maximumBoostAmount: r.maximumBoostAmount === '' ? undefined : Math.round(Number(r.maximumBoostAmount) * 100),
    })));

  return (
    <FormModal
      title="Dividend rates" wide
      onClose={onClose}
      onSubmit={submit}
      submitLabel="Save rates"
      successTitle="Rates saved"
      successDetail={() => 'Recalculate the dividend to apply them'}
    >
      <div className="note">
        One row per savings product the dividend is declared on. Recalculating after a change
        rewrites every member line, so rates can be adjusted as often as needed until they are right.
      </div>
      <div className="note">
        <b>Pro Rated</b> suits non-withdrawable deposits and share capital: the balance standing at
        the end of the first month earns the full year, and each later month earns on its own
        increase for the months remaining. <b>Minimum Balance</b> is the bank model for withdrawable
        accounts: each month earns on the lowest balance the account held that month. Picking a
        product sets the usual one for its category — change it here if this declaration differs.
      </div>
      <div className="table-wrap">
        <table>
          <thead>
            <tr>
              <th style={{ minWidth: 180 }}>Product</th>
              <th style={{ minWidth: 160 }}>Posting description</th>
              <th className="num">Rate %</th>
              <th>Rate type</th>
              <th>Post to</th>
              <th className="num">Min. balance</th>
              <th className="num">Max. boost</th>
              <th />
            </tr>
          </thead>
          <tbody>
            {rows.map((r) => (
              <tr key={r.key}>
                <td>
                  <select value={r.productId} onChange={(e) => {
                    const product = products.find((p) => String(p.id) === e.target.value);
                    set(r.key, {
                      productId: e.target.value,
                      postingDescription: r.postingDescription || (product ? `${product.name} dividend` : ''),
                      // Non-withdrawable stake and share capital are pro-rated; anything the
                      // member can draw on earns the bank way. Still editable afterwards.
                      rateType: product ? defaultDividendRateType(product.category) : r.rateType,
                      minimumBalance: r.minimumBalance || (product ? (product.min_balance / 100).toFixed(2) : ''),
                      qualifiedMinimumBalance: r.qualifiedMinimumBalance || (product ? (product.min_balance / 100).toFixed(2) : ''),
                    });
                  }}>
                    <option value="">Select…</option>
                    {products.map((p) => <option key={p.id} value={p.id}>{p.code} — {p.name}</option>)}
                  </select>
                </td>
                <td>
                  <input value={r.postingDescription} onChange={(e) => set(r.key, { postingDescription: e.target.value })} />
                </td>
                <td className="num">
                  <input type="number" step="0.01" min="0" style={{ width: 80, textAlign: 'right' }}
                    value={r.rate} onChange={(e) => set(r.key, { rate: e.target.value })} />
                </td>
                <td>
                  <select value={r.rateType}
                    title={DIVIDEND_RATE_TYPES.find((t) => t.value === r.rateType)?.help}
                    onChange={(e) => set(r.key, { rateType: e.target.value as DividendRateType })}>
                    {DIVIDEND_RATE_TYPES.map((t) => <option key={t.value} value={t.value}>{t.label}</option>)}
                  </select>
                </td>
                <td>
                  <select value={r.postTo} onChange={(e) => set(r.key, { postTo: e.target.value as ParamDraft['postTo'] })}>
                    <option value="Savings">Member savings</option>
                    <option value="Same Account">Same account</option>
                    <option value="Accrue">Accrue</option>
                  </select>
                </td>
                <td className="num">
                  <input type="number" step="0.01" min="0" style={{ width: 110, textAlign: 'right' }}
                    value={r.minimumBalance} onChange={(e) => set(r.key, { minimumBalance: e.target.value })} />
                </td>
                <td className="num">
                  <input type="number" step="0.01" min="0" style={{ width: 110, textAlign: 'right' }}
                    value={r.maximumBoostAmount} onChange={(e) => set(r.key, { maximumBoostAmount: e.target.value })} />
                </td>
                <td>
                  <button type="button" className="btn sm ghost"
                    onClick={() => setRows((rs) => (rs.length > 1 ? rs.filter((x) => x.key !== r.key) : rs))}>
                    Remove
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <button type="button" className="btn sm ghost" onClick={() => setRows((rs) => [...rs, blankDraft()])}>
        Add product
      </button>
    </FormModal>
  );
}

/* --------------------------------------------------------------- run & lifecycle */

export function CalculateButton({ no, recalculating, className = 'btn' }: {
  no: string; recalculating?: boolean; className?: string;
}) {
  const { run, busy } = useRunAction();
  const { cur } = useFormat();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => runDividendCalculation(no), {
        confirm: recalculating
          ? {
            title: 'Recalculate this dividend?',
            message: 'Everything calculated so far is discarded and worked out again from the current rates.',
            confirmLabel: 'Recalculate',
          }
          : undefined,
        successTitle: 'Dividend calculated',
        successDetail: (d) =>
          `${d.lines.toLocaleString()} accounts · ${d.members.toLocaleString()} members · `
          + `earned ${cur(d.totalEarned)} · net ${cur(d.totalNet)}`,
      })}>
      {busy ? 'Calculating…' : recalculating ? 'Recalculate' : 'Calculate'}
    </button>
  );
}

export function SubmitButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => submitDividendRequest(no), {
        confirm: {
          title: 'Send this dividend for approval?',
          message: 'It can no longer be edited or recalculated while pending.',
          confirmLabel: 'Send for approval',
        },
        successTitle: (d) => (d.autoApproved ? 'Approved — ready to post' : 'Sent for approval'),
      })}>
      {busy ? 'Working…' : 'Send for approval'}
    </button>
  );
}

export function CancelApprovalButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => cancelDividendApprovalRequest(no), {
        confirm: { title: 'Recall this dividend?', message: 'It goes back to Open so you can amend and resubmit it.', confirmLabel: 'Recall' },
        successTitle: 'Recalled — back to Open',
      })}>
      {busy ? 'Working…' : 'Cancel approval request'}
    </button>
  );
}

export { DelegateButton } from '@/components/ui/delegate-button';

export function ApproveButton({ no, className = 'btn sm' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => approveDividendRequest(no), {
        confirm: { title: 'Approve this dividend?', message: 'It becomes ready to post. Nothing moves until it is posted.', confirmLabel: 'Approve' },
        successTitle: 'Approved — ready to post',
      })}>
      {busy ? 'Working…' : 'Approve'}
    </button>
  );
}

export function RejectButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Reject</button>
      {open ? (
        <FormModal
          title="Reject dividend"
          onClose={() => setOpen(false)}
          onSubmit={(values) => rejectDividendRequest(no, String(values.reason || ''))}
          submitLabel="Reject" submitClass="btn danger"
          successTitle="Rejected — back to Open" resultStyle="popup"
        >
          <Field name="reason" label="Reason" type="textarea" required />
        </FormModal>
      ) : null}
    </>
  );
}

export function ReopenButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => reopenDividendRequest(no), {
        confirm: { title: 'Reopen this dividend?', message: 'It goes back to Open for amendment. It must be approved again before posting.', confirmLabel: 'Reopen' },
        successTitle: 'Reopened — back to Open',
      })}>
      {busy ? 'Working…' : 'Reopen'}
    </button>
  );
}

export function PostButton({ no, postingType, className = 'btn sm' }: {
  no: string; postingType: string; className?: string;
}) {
  const { run, busy } = useRunAction();
  const { cur } = useFormat();
  const payout = postingType === 'Payout';
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => postDividendRequest(no), {
        confirm: {
          title: `Post this ${payout ? 'payout' : 'provision'}?`,
          message: payout
            ? 'Every member is credited their earning, then the charges, share boosts and loan recoveries are taken back out. This cannot be undone from here.'
            : 'The dividend expense and the payable are raised in the G/L. This cannot be undone from here.',
          confirmLabel: 'Post',
        },
        successTitle: 'Dividend posted',
        successDetail: (d) => (payout
          ? `${d.lines.toLocaleString()} lines · paid ${cur(d.gross)} · charges ${cur(d.charged)} · boosts ${cur(d.boosted)} · loans ${cur(d.recovered)}`
          : `Journal ${d.journalNo} · ${cur(d.gross)} provided for`),
      })}>
      {busy ? 'Posting…' : 'Post'}
    </button>
  );
}

/* ------------------------------------------------------------------- line edit */

/** The per-line override — a manual amount, and the member's preferential boost election. */
export function EditLineButton({ no, line, className = 'btn sm ghost' }: {
  no: string; line: DividendLineView; className?: string;
}) {
  const [open, setOpen] = useState(false);
  const [boost, setBoost] = useState(Boolean(Number(line.preferential_boost)));
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Adjust</button>
      {open ? (
        <FormModal
          title={`${line.member_name} — ${line.account_no}`}
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveDividendLine(no, line.id, values)}
          submitLabel="Save"
          successTitle="Line updated" resultStyle="popup"
        >
          <Field name="amountEarned" label="Amount earned" type="currency"
            defaultValue={(line.amount_earned / 100).toFixed(2)}
            hint="Overrides what the calculation worked out. Recalculating replaces it again." />
          <Field name="preferentialBoost" label="Preferential share boost" type="checkbox"
            defaultValue={Number(line.preferential_boost)}
            onChange={(e) => setBoost((e.target as HTMLInputElement).checked)} />
          <Field name="preferentialBoostPct" label="Boost percentage" type="number"
            defaultValue={String(line.preferential_boost_pct || 0)} disabled={!boost}
            hint="Share of this member’s earning ploughed back into share capital" />
        </FormModal>
      ) : null}
    </>
  );
}

/** Print every member's slip off one URL — the batch the officer runs once and hands out. */
export function PrintSlipsLink({ no, className = 'btn ghost sm' }: { no: string; className?: string }) {
  return (
    <Link href={`/print/dividend-slips/${encodeURIComponent(no)}`} target="_blank" className={className}>
      Print dividend slips
    </Link>
  );
}
