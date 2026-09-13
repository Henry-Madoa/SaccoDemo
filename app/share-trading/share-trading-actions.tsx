'use client';

import { useEffect, useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { useEditableCard } from '@/components/ui/editable-card';
import { Field, MoneyInput, toTwoDp } from '@/components/ui/field';
import { MemberSelect } from '@/components/ui/member-select';
import { SearchableSelect } from '@/components/ui/searchable-select';
import { GlAccountSelect, type GlAccountSelectOption } from '@/components/ui/gl-account-select';
import { useRunAction } from '@/components/ui/run-action';
import { useFormat } from '@/components/ui/format-provider';
import { formatDate, today } from '@/lib/format';
import {
  createShareWindowRequest, saveShareWindow, deleteShareWindowRequest, publishShareWindowRequest, retireShareWindowRequest,
  requestShareFloating, saveShareFloating, deleteShareFloatingRequest, submitShareFloatingRequest,
  cancelShareFloatingApprovalRequest, approveShareFloatingRequest, rejectShareFloatingRequest, reopenShareFloatingRequest,
  publishShareFloatingRequest, placeShareBidRequest, withdrawShareBidRequest, analyseShareBidsRequest,
  notifyShareAwardRequest, postSharePurchaseRequest, allocateSharePaymentRequest, removeSharePaymentRequest,
  transferSharesRequest, takeDownShareFloatingRequest, applyShareNoBidRuleRequest, processExpiredShareFloatingsRequest,
  shareMemberPositionRequest, shareProceedsAccountsRequest, sharePaymentAccountsRequest,
} from '@/app/actions/shareTrading';
import type { ShareMemberPosition, ShareProceedsAccount, SharePaymentAccount } from '@/lib/shareTrading';
import type {
  Member, ShareFloatType, ShareFloatingView, ShareProceedsType, ShareTradingWindowView,
} from '@/lib/types';

type EligibleMember = Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>;
type ChargeOption = { id: number; code: string; description: string };
type WindowOption = Pick<ShareTradingWindowView, 'no' | 'description' | 'base_price' | 'reserve_price' | 'published'>;

/* ================================================================== windows */

export interface WindowLookups { accounts: GlAccountSelectOption[]; charges: ChargeOption[] }

function WindowFields({ lookups, initial }: { lookups: WindowLookups; initial?: ShareTradingWindowView | null }) {
  const [clearing, setClearing] = useState(String(initial?.clearing_account_id ?? lookups.accounts.find((a) => a.code === '1255')?.id ?? ''));
  const [holding, setHolding] = useState(String(initial?.holding_account_id ?? lookups.accounts.find((a) => a.code === '2135')?.id ?? ''));
  const [charge, setCharge] = useState(String(initial?.transaction_charge_id ?? ''));
  const [basePrice, setBasePrice] = useState(initial ? toTwoDp(String(initial.base_price / 100)) : '');
  const [reserve, setReserve] = useState(initial ? toTwoDp(String(initial.reserve_price / 100)) : '');
  const year = new Date().getFullYear();
  return (
    <>
      <Field name="description" label="Description" required defaultValue={initial?.description ?? ''}
        placeholder={`Share trading window ${year}`} />
      <div className="grid g2">
        <Field name="startDate" label="Trading from" type="date" required defaultValue={initial?.start_date ?? today()} />
        <Field name="endDate" label="Trading to" type="date" required defaultValue={initial?.end_date ?? `${year}-12-31`} />
      </div>
      <div className="grid g2">
        <div className="field">
          <label htmlFor="f_basePrice">Base (par) price per share <span className="req">*</span></label>
          <MoneyInput id="f_basePrice" value={basePrice} onChange={setBasePrice} min={0} />
          <input type="hidden" name="basePrice" value={basePrice} />
          <div className="hint">What a share is worth on the books, and the most any bid may offer</div>
        </div>
        <div className="field">
          <label htmlFor="f_reservePrice">Reserve price per share</label>
          <MoneyInput id="f_reservePrice" value={reserve} onChange={setReserve} min={0} />
          <input type="hidden" name="reservePrice" value={reserve} />
          <div className="hint">The least a seller may ask</div>
        </div>
      </div>
      <div className="grid g2">
        <GlAccountSelect id="f_holdingAccountId" name="holdingAccountId" label="Holding account" required
          accounts={lookups.accounts} value={holding} onChange={setHolding}
          hint="Shares in transit between seller and buyer — nets to zero on a completed trade" />
        <GlAccountSelect id="f_clearingAccountId" name="clearingAccountId" label="Clearing account" required
          accounts={lookups.accounts} value={clearing} onChange={setClearing}
          hint="What the awarded buyer owes until they pay" />
      </div>
      <SearchableSelect id="f_transactionChargeId" name="transactionChargeId" label="Trading charge"
        items={lookups.charges} getValue={(c) => String(c.id)} getLabel={(c) => `${c.code} — ${c.description}`}
        value={charge} onChange={setCharge} placeholder="No charge" emptyText="No transaction charges configured"
        hint="Charged to the buyer on the floated value, and to the seller on any premium over par" />
      <div className="grid g3">
        <Field name="shareLife" label="Share life" defaultValue={initial?.share_life ?? '30D'} placeholder="30D"
          hint="How long a published floating takes bids (30D, 2W, 1M)" />
        <Field name="tolerancePeriod" label="Payment tolerance" defaultValue={initial?.tolerance_period ?? '14D'} placeholder="14D"
          hint="How long an awarded buyer has to pay" />
        <Field name="minimumSharesToFloat" label="Minimum shares per floating" type="number" min={0}
          defaultValue={String(initial?.minimum_shares_to_float ?? 0)} />
      </div>
      <div className="field">
        <label htmlFor="f_onNoBid">When a floating expires with no bid</label>
        <select id="f_onNoBid" name="onNoBid" defaultValue={initial?.on_no_bid ?? 'Extend'}>
          <option value="Extend">Extend — keep it on the market for another share life</option>
          <option value="Reverse">Reverse — take it down and return the shares</option>
        </select>
      </div>
    </>
  );
}

export function NewWindowButton({ lookups }: { lookups: WindowLookups }) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className="btn" onClick={() => setOpen(true)}>New trading window</button>
      {open ? (
        <FormModal title="New share trading window" wide onClose={() => setOpen(false)} onSubmit={createShareWindowRequest}
          submitLabel="Save" successTitle="Trading window created" successDetail={(d) => `${d.no} saved — publish it to open the market`}>
          <WindowFields lookups={lookups} />
        </FormModal>
      ) : null}
    </>
  );
}

export function WindowEditForm({ window, lookups }: { window: ShareTradingWindowView; lookups: WindowLookups }) {
  const { close } = useEditableCard();
  return (
    <FormModal inline title={`Edit ${window.no}`} onClose={close} onSubmit={(v) => saveShareWindow(window.no, v)}
      submitLabel="Save changes" successTitle="Trading window updated">
      <WindowFields lookups={lookups} initial={window} />
    </FormModal>
  );
}

export function PublishWindowButton({ no, className = 'btn sm' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => publishShareWindowRequest(no), {
        confirm: { title: `Publish trading window ${no}?`, message: 'It becomes the market every new floating is sold in. Any other published window is retired.', confirmLabel: 'Publish' },
        successTitle: 'Trading window published',
      })}>
      {busy ? 'Working…' : 'Publish'}
    </button>
  );
}

export function RetireWindowButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => retireShareWindowRequest(no), {
        confirm: { title: `Take down trading window ${no}?`, message: 'No new floatings can be raised in it. Floatings already on the market stay up on their own terms.', confirmLabel: 'Take down' },
        successTitle: 'Trading window retired',
      })}>
      {busy ? 'Working…' : 'Take down'}
    </button>
  );
}

export function DeleteWindowButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => deleteShareWindowRequest(no), {
        confirm: { title: 'Delete this trading window?', message: 'Only a window with no floatings can be deleted.', confirmLabel: 'Delete', danger: true },
        successTitle: 'Deleted', redirectTo: '/share-trading/windows',
      })}>
      {busy ? 'Working…' : 'Delete'}
    </button>
  );
}

/* ================================================================ floatings */

export interface FloatingLookups {
  members: EligibleMember[];
  windows: WindowOption[];
  payMethods: { code: string; description: string }[];
}

function FloatingFields({ lookups, initial }: { lookups: FloatingLookups; initial?: ShareFloatingView | null }) {
  const { cur } = useFormat();
  const editing = !!initial;
  const published = lookups.windows.find((w) => w.published);
  const [windowNo, setWindowNo] = useState(initial?.window_no ?? published?.no ?? '');
  const [memberId, setMemberId] = useState(String(initial?.member_id ?? ''));
  const [floatType, setFloatType] = useState<ShareFloatType>(initial?.float_type ?? 'Partial');
  const [shares, setShares] = useState(String(initial?.shares_to_float ?? ''));
  const [price, setPrice] = useState(initial ? toTwoDp(String(initial.minimum_acceptable_price / 100)) : '');
  const [proceedsType, setProceedsType] = useState<ShareProceedsType>(initial?.proceeds_type ?? 'FOSA Account');
  const [proceedsAccountId, setProceedsAccountId] = useState(String(initial?.proceeds_account_id ?? ''));
  const [position, setPosition] = useState<ShareMemberPosition | null>(null);
  const [proceedsAccounts, setProceedsAccounts] = useState<ShareProceedsAccount[]>([]);

  const window = lookups.windows.find((w) => w.no === windowNo) ?? null;

  // The member's holding in the chosen window: Total Shares, and how many a partial float may take.
  useEffect(() => {
    let cancelled = false;
    if (!memberId) { setPosition(null); return; }
    shareMemberPositionRequest(Number(memberId), windowNo || null).then((res) => {
      if (!cancelled && res.ok) setPosition(res.data);
    });
    return () => { cancelled = true; };
  }, [memberId, windowNo]);

  useEffect(() => {
    let cancelled = false;
    if (!memberId) { setProceedsAccounts([]); return; }
    shareProceedsAccountsRequest(Number(memberId), proceedsType).then((res) => {
      if (!cancelled && res.ok) setProceedsAccounts(res.data);
    });
    return () => { cancelled = true; };
  }, [memberId, proceedsType]);

  useEffect(() => {
    if (floatType === 'Full' && position) setShares(String(position.totalShares));
  }, [floatType, position]);

  const par = window ? window.base_price : position?.parValue ?? 0;
  const n = Number(shares) || 0;
  const floatedValue = n * par;

  return (
    <>
      <div className="grid g2">
        <SearchableSelect id="f_windowNo" name="windowNo" label="Trading window" required disabled={editing}
          items={lookups.windows.filter((w) => w.published || w.no === windowNo)}
          getValue={(w) => w.no} getLabel={(w) => `${w.no} — ${w.description}${w.published ? '' : ' (not published)'}`}
          value={windowNo} onChange={setWindowNo} placeholder="Published window…" emptyText="No published trading window" />
        <MemberSelect id="f_memberId" name="memberId" label="Seller (member)" members={lookups.members}
          value={memberId} onChange={(id) => { setMemberId(id); setProceedsAccountId(''); }} required disabled={editing} />
      </div>

      {position ? (
        <div className="note">
          {position.account
            ? <>Share capital account <b className="mono">{position.account.account_no}</b> holds <b>{cur(position.account.balance)}</b> — <b>{position.totalShares}</b> shares at par {cur(par)}. A partial float may take up to <b>{position.partialCeiling}</b>.</>
            : <>This member has no active share capital account.</>}
        </div>
      ) : null}

      <div className="grid g3">
        <div className="field">
          <label htmlFor="f_floatType">Float type <span className="req">*</span></label>
          <select id="f_floatType" name="floatType" value={floatType} onChange={(e) => setFloatType(e.target.value as ShareFloatType)}>
            <option value="Partial">Partial — keep the minimum share capital</option>
            <option value="Full">Full — float every share held</option>
          </select>
        </div>
        <Field name="sharesToFloat" label="Shares to float" type="number" required min={1}
          defaultValue={shares} onChange={(e) => setShares(e.target.value)} disabled={floatType === 'Full'}
          hint={floatedValue ? `Floated value ${cur(floatedValue)} at par` : undefined} />
        <div className="field">
          <label htmlFor="f_minimumAcceptablePrice">Minimum acceptable price per share <span className="req">*</span></label>
          <MoneyInput id="f_minimumAcceptablePrice" value={price} onChange={setPrice} min={0} />
          <input type="hidden" name="minimumAcceptablePrice" value={price} />
          <div className="hint">{window ? `Between the reserve ${cur(window.reserve_price)} and par ${cur(window.base_price)}` : 'Between the window’s reserve and par'}</div>
        </div>
      </div>

      <div className="grid g2">
        <div className="field">
          <label htmlFor="f_proceedsType">Proceeds paid to</label>
          <select id="f_proceedsType" name="proceedsType" value={proceedsType}
            onChange={(e) => { setProceedsType(e.target.value as ShareProceedsType); setProceedsAccountId(''); }}>
            <option value="FOSA Account">FOSA account — withdrawable deposit</option>
            <option value="NWD Account">NWD account — non-withdrawable deposit</option>
          </select>
        </div>
        <SearchableSelect id="f_proceedsAccountId" name="proceedsAccountId" label="Proceeds account"
          items={proceedsAccounts} getValue={(a) => String(a.id)} getLabel={(a) => `${a.account_no} — ${a.product_name}`}
          value={proceedsAccountId} onChange={setProceedsAccountId} disabled={!memberId}
          placeholder={memberId ? (proceedsAccounts.length ? 'Search account…' : 'No account of this type') : 'Pick the seller first'}
          emptyText="No matching accounts" hint="Defaults to the seller’s first account of the type on transfer" />
      </div>

      <div className="grid g3">
        <Field name="paymentMethodCode" label="Payment method" type="select" defaultValue={initial?.payment_method_code ?? ''}
          options={[{ value: '', label: '(none)' }, ...lookups.payMethods.map((m) => ({ value: m.code, label: `${m.code} — ${m.description}` }))]} />
        <Field name="externalReferenceNo" label="External reference" defaultValue={initial?.external_reference_no ?? ''} />
        <Field name="source" label="Source" type="select" defaultValue={initial?.source ?? 'Walking'}
          options={['Walking', 'App', 'USSD', 'Portal'].map((s) => ({ value: s, label: s }))} />
      </div>
      <Field name="narration" label="Narration" type="textarea" defaultValue={initial?.narration ?? ''} />

      <div className="note">
        Once approved and published, the shares leave the seller’s account into the Holding account and
        other members may bid. The highest bid wins; the buyer pays from their deposit accounts and the
        shares transfer at par, with the proceeds at the bid price going to the seller.
      </div>
    </>
  );
}

export function NewFloatingButton({ lookups }: { lookups: FloatingLookups }) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className="btn" onClick={() => setOpen(true)}>Float shares</button>
      {open ? (
        <FormModal title="Float shares for sale" wide onClose={() => setOpen(false)} onSubmit={requestShareFloating}
          submitLabel="Save" successTitle="Floating captured" successDetail={(d) => `${d.no} saved — send it for approval when ready`}>
          <FloatingFields lookups={lookups} />
        </FormModal>
      ) : null}
    </>
  );
}

export function EditForm({ floating, lookups }: { floating: ShareFloatingView; lookups: FloatingLookups }) {
  const { close } = useEditableCard();
  return (
    <FormModal inline title={`Edit ${floating.no}`} wide onClose={close} onSubmit={(v) => saveShareFloating(floating.no, v)}
      submitLabel="Save changes" successTitle="Floating updated">
      <FloatingFields lookups={lookups} initial={floating} />
    </FormModal>
  );
}

/* ---------------------------------------------------------- maker-checker */

const simple = (
  label: string, busyLabel: string,
  action: (no: string) => Promise<{ ok: boolean; error?: string; data?: unknown }>,
  confirm: { title: string; message: string; confirmLabel: string; danger?: boolean },
  successTitle: string | ((d: never) => string), defaultClass = 'btn sm ghost',
) => function Button({ no, className = defaultClass }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => action(no) as never, { confirm, successTitle: successTitle as never })}>
      {busy ? busyLabel : label}
    </button>
  );
};

export const SubmitButton = simple('Send for approval', 'Working…', submitShareFloatingRequest,
  { title: 'Send this floating for approval?', message: 'It can no longer be edited while pending.', confirmLabel: 'Send for approval' },
  ((d: { autoApproved: boolean }) => (d.autoApproved ? 'Approved — ready to publish' : 'Sent for approval')) as never);

export const CancelApprovalButton = simple('Cancel approval request', 'Working…', cancelShareFloatingApprovalRequest,
  { title: 'Recall this floating?', message: 'It goes back to Open so you can amend and resubmit it.', confirmLabel: 'Recall' },
  'Recalled — back to Open');

export const ApproveButton = simple('Approve', 'Working…', approveShareFloatingRequest,
  { title: 'Approve this floating?', message: 'It becomes ready to publish. Nothing moves until it is published.', confirmLabel: 'Approve' },
  'Approved — ready to publish', 'btn sm');

export const ReopenButton = simple('Reopen', 'Working…', reopenShareFloatingRequest,
  { title: 'Reopen this floating?', message: 'It goes back to Open for amendment and must be approved again.', confirmLabel: 'Reopen' },
  'Reopened — back to Open');

export const DeleteButton = simple('Delete', 'Working…', deleteShareFloatingRequest,
  { title: 'Delete this floating?', message: 'It is removed permanently. Only an open floating can be deleted.', confirmLabel: 'Delete', danger: true },
  'Deleted');

export { DelegateButton } from '@/components/ui/delegate-button';

export function RejectButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Reject</button>
      {open ? (
        <FormModal title="Reject floating" onClose={() => setOpen(false)}
          onSubmit={(values) => rejectShareFloatingRequest(no, String(values.reason || ''))}
          submitLabel="Reject" submitClass="btn danger" successTitle="Rejected — back to Open" resultStyle="popup">
          <Field name="reason" label="Reason" type="textarea" required />
        </FormModal>
      ) : null}
    </>
  );
}

/* ------------------------------------------------------------------ market */

export function PublishSaleButton({ no, className = 'btn sm' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => publishShareFloatingRequest(no), {
        confirm: { title: 'Publish this sale?', message: 'The shares leave the seller’s share capital account into the Holding account and members may bid until the expiry date.', confirmLabel: 'Publish sale' },
        successTitle: 'Sale published', successDetail: (d) => `Journal ${d.journalNo} · bidding closes ${formatDate(d.expiryDate)}`,
      })}>
      {busy ? 'Working…' : 'Publish sale'}
    </button>
  );
}

export function PlaceBidButton({ floating, members, className = 'btn sm' }: {
  floating: ShareFloatingView; members: EligibleMember[]; className?: string;
}) {
  const { cur } = useFormat();
  const [open, setOpen] = useState(false);
  const [memberId, setMemberId] = useState('');
  const [price, setPrice] = useState('');
  const n = Number(price) || 0;
  const total = n > 0 ? Math.round(n * 100) * floating.shares_to_float + floating.charge_amount : 0;
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Place bid</button>
      {open ? (
        <FormModal title={`Bid on ${floating.no}`} onClose={() => setOpen(false)}
          onSubmit={(v) => placeShareBidRequest(floating.no, v)} submitLabel="Place bid"
          successTitle="Bid placed" successDetail={(d) => `Total payable if awarded ${cur(d.total)}`} resultStyle="popup">
          <div className="note">
            {floating.shares_to_float} shares · bids from <b>{cur(floating.minimum_acceptable_price)}</b> to par <b>{cur(floating.par_value)}</b> per share
            {floating.charge_amount ? <> · trading charge {cur(floating.charge_amount)} added to the total</> : null}.
            A member may bid once; a second bid replaces the first.
          </div>
          <MemberSelect id="f_bidMemberId" name="memberId" label="Bidder (member)" members={members.filter((m) => m.id !== floating.member_id)}
            value={memberId} onChange={setMemberId} required />
          <div className="field">
            <label htmlFor="f_bidPrice">Bid price per share <span className="req">*</span></label>
            <MoneyInput id="f_bidPrice" value={price} onChange={setPrice} min={0} />
            <input type="hidden" name="bidPrice" value={price} />
            <div className="hint">{total ? `Total payable if awarded ${cur(total)}` : 'Shares × price + charge'}</div>
          </div>
          <Field name="source" label="Source" type="select" defaultValue="Walking"
            options={['Walking', 'App', 'USSD', 'Portal'].map((s) => ({ value: s, label: s }))} />
        </FormModal>
      ) : null}
    </>
  );
}

export function WithdrawBidButton({ no, bidId, className = 'btn sm ghost' }: { no: string; bidId: number; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => withdrawShareBidRequest(no, bidId), {
        confirm: { title: 'Withdraw this bid?', message: 'It is removed from the floating.', confirmLabel: 'Withdraw' },
        successTitle: 'Bid withdrawn',
      })}>
      {busy ? 'Working…' : 'Withdraw'}
    </button>
  );
}

export function AnalyseBidsButton({ no, className = 'btn sm' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => analyseShareBidsRequest(no), {
        successTitle: (d) => (d.winner ? `Awarded to ${d.winner.first_name} ${d.winner.last_name}` : 'No bids to award'),
        successDetail: (d) => (d.winner ? `${d.winner.member_no} — highest bid, earliest on a tie` : undefined),
      })}>
      {busy ? 'Working…' : 'Analyse bids'}
    </button>
  );
}

export const NotifyAwardButton = simple('Notify winner', 'Sending…', notifyShareAwardRequest,
  { title: 'Notify the winning bidder?', message: 'An SMS and email tell them what to pay and by when.', confirmLabel: 'Send' },
  'Winner notified');

export function PostPurchaseButton({ no, className = 'btn sm' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => postSharePurchaseRequest(no), {
        confirm: { title: 'Post the purchase?', message: 'The winning bid becomes the buyer’s debt on the Clearing account and the payment clock starts. Bids close.', confirmLabel: 'Post purchase' },
        successTitle: 'Purchase posted', successDetail: (d) => `Journal ${d.journalNo}${d.dueDate ? ` · payment due ${formatDate(d.dueDate)}` : ''}`,
      })}>
      {busy ? 'Working…' : 'Post purchase'}
    </button>
  );
}

export function AllocatePaymentButton({ floating, buyerMemberId, className = 'btn sm' }: {
  floating: ShareFloatingView; buyerMemberId: number; className?: string;
}) {
  const { cur } = useFormat();
  const [open, setOpen] = useState(false);
  const [accounts, setAccounts] = useState<SharePaymentAccount[]>([]);
  const [accountId, setAccountId] = useState('');
  const [amount, setAmount] = useState('');
  const remaining = floating.payment_amount - floating.allocated_amount;
  useEffect(() => {
    if (!open) return;
    let cancelled = false;
    sharePaymentAccountsRequest(buyerMemberId).then((res) => { if (!cancelled && res.ok) setAccounts(res.data); });
    return () => { cancelled = true; };
  }, [open, buyerMemberId]);
  const acct = accounts.find((a) => String(a.id) === accountId);
  return (
    <>
      <button type="button" className={className} onClick={() => { setAmount(toTwoDp(String(Math.max(remaining, 0) / 100))); setOpen(true); }}>Allocate payment</button>
      {open ? (
        <FormModal title="Allocate the buyer’s payment" onClose={() => setOpen(false)}
          onSubmit={(v) => allocateSharePaymentRequest(floating.no, v)} submitLabel="Allocate" successTitle="Payment allocated">
          <div className="note">Due <b>{cur(floating.payment_amount)}</b> · allocated so far {cur(floating.allocated_amount)} · <b>{cur(Math.max(remaining, 0))}</b> remaining. The money is taken from the account on transfer.</div>
          <SearchableSelect id="f_paySavingsAccountId" name="savingsAccountId" label="Buyer’s deposit account" required
            items={accounts} getValue={(a) => String(a.id)} getLabel={(a) => `${a.account_no} — ${a.product_name} (available ${cur(a.available)})`}
            value={accountId} onChange={setAccountId} placeholder="Search account…" emptyText="No withdrawable accounts" />
          <div className="field">
            <label htmlFor="f_payAmount">Amount <span className="req">*</span></label>
            <MoneyInput id="f_payAmount" value={amount} onChange={setAmount} min={0} />
            <input type="hidden" name="amount" value={amount} />
            <div className="hint">{acct ? `Up to ${cur(Math.min(acct.available, Math.max(remaining, 0)))} from this account` : 'Up to the remaining amount and the account’s available balance'}</div>
          </div>
        </FormModal>
      ) : null}
    </>
  );
}

export function RemoveAllocationButton({ no, id, className = 'btn sm ghost' }: { no: string; id: number; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => removeSharePaymentRequest(no, id), { successTitle: 'Allocation removed' })}>
      {busy ? 'Working…' : 'Remove'}
    </button>
  );
}

export function TransferSharesButton({ no, className = 'btn sm' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  const { cur } = useFormat();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => transferSharesRequest(no), {
        confirm: { title: 'Transfer the shares?', message: 'The buyer’s allocated payments are taken, the shares move to the buyer at par, and the seller is paid at the bid price. This cannot be undone from here.', confirmLabel: 'Transfer shares' },
        successTitle: 'Shares transferred', successDetail: (d) => `Journal ${d.journalNo} · seller paid ${cur(d.proceeds)}${d.sellerCharge ? ` less charge ${cur(d.sellerCharge)}` : ''}`,
      })}>
      {busy ? 'Working…' : 'Transfer shares'}
    </button>
  );
}

export function TakeDownButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => takeDownShareFloatingRequest(no), {
        confirm: { title: 'Take down this floating?', message: 'It comes off the market and the shares return to the seller’s share capital account.', confirmLabel: 'Take down', danger: true },
        successTitle: 'Floating taken down', successDetail: (d) => `Reversal journal ${d.journalNo}`,
      })}>
      {busy ? 'Working…' : 'Take down'}
    </button>
  );
}

export function NoBidRuleButton({ no, rule, className = 'btn sm ghost' }: { no: string; rule: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => applyShareNoBidRuleRequest(no), {
        confirm: { title: 'Apply the no-bid rule?', message: `This floating has expired. The window's rule is "${rule}".`, confirmLabel: 'Apply' },
        successTitle: (d) => d.action, successDetail: (d) => (d.expiryDate ? `Bidding now closes ${formatDate(d.expiryDate)}` : undefined),
      })}>
      {busy ? 'Working…' : 'Apply no-bid rule'}
    </button>
  );
}

export function ProcessExpiredButton({ className = 'btn sm ghost' }: { className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => processExpiredShareFloatingsRequest(), {
        confirm: { title: 'Process expired floatings?', message: 'Every floating past its expiry with no bids is extended or reversed per its window’s rule. Those with bids are left for you to analyse.', confirmLabel: 'Process' },
        successTitle: 'Expired floatings processed', successDetail: (d) => `${d.extended} extended · ${d.reversed} reversed · ${d.withBids} with bids left to analyse`,
      })}>
      {busy ? 'Working…' : 'Process expired'}
    </button>
  );
}
