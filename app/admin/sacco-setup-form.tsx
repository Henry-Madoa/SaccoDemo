'use client';

import { useRef, useState } from 'react';
import { useRouter } from 'next/navigation';
import { Card } from '@/components/ui/primitives';
import { Field, readForm } from '@/components/ui/field';
import { SearchableSelect } from '@/components/ui/searchable-select';
import { useToast } from '@/components/ui/toast';
import { saveOrganisation } from '@/app/actions/admin';
import type { Organisation, TransactionCharge } from '@/lib/types';

/**
 * Sacco Setup — the society's own operating rules, as opposed to who the society IS (that is
 * Company Information) or how the ledger behaves (General Ledger Setup).
 *
 * Membership, guarantorship and cash handling all live on the same `organisation` singleton, so
 * this saves through the same action Company Information does; splitting them is a matter of
 * which screen an administrator goes to, not of where the values are kept.
 */
export function SaccoSetupForm({ org, charges }: { org: Organisation; charges: TransactionCharge[] }) {
  const formRef = useRef<HTMLFormElement>(null);
  const router = useRouter();
  const toast = useToast();
  const [busy, setBusy] = useState(false);
  const [instantWithdrawalChargeId, setInstantWithdrawalChargeId] = useState(String(org.instant_withdrawal_charge_id ?? ''));
  const [interAccountTransferChargeId, setInterAccountTransferChargeId] = useState(String(org.inter_account_transfer_charge_id ?? ''));

  const save = async () => {
    const form = formRef.current;
    if (!form || !form.reportValidity()) return;
    setBusy(true);
    try {
      const res = await saveOrganisation(readForm(form));
      if (!res.ok) { toast('Could not save', res.error, 'err'); return; }
      toast('Sacco Setup saved', 'The change is live across the system', 'ok');
      router.refresh();
    } finally {
      setBusy(false);
    }
  };

  return (
    <form ref={formRef} onSubmit={(e) => { e.preventDefault(); save(); }}>
      <Card>
        <h3>Membership</h3>
        <div className="card-sub">Member Exit&apos;s notice period, and when an inactive member is marked Dormant.</div>
        <div className="grid g2">
          <Field name="member_exit_notice_days" label="Exit notice period (days)" type="number" step="1"
            defaultValue={org.member_exit_notice_days ?? 30}
            hint="A member exit cannot be processed before this many days after it was opened" />
          <Field name="dormancy_days" label="Dormancy period (days)" type="number" step="1"
            defaultValue={org.dormancy_days ?? 90}
            hint="No money in a member's Non-Withdrawable Deposit account for this many days flips them Active → Dormant (Setup Pool → General → System Automation)" />
        </div>
        <SearchableSelect name="instant_withdrawal_charge_id" label="Instant withdrawal charge"
          items={charges} getValue={(c) => String(c.id)} getLabel={(c) => `${c.code} — ${c.description}`}
          value={instantWithdrawalChargeId} onChange={setInstantWithdrawalChargeId}
          placeholder="Search charge code or description…" emptyText="No matching charges"
          hint="Auto-applied on Member Exit when Instant Withdrawal is checked" />
        <SearchableSelect name="inter_account_transfer_charge_id" label="Inter-account transfer charge"
          items={charges} getValue={(c) => String(c.id)} getLabel={(c) => `${c.code} — ${c.description}`}
          value={interAccountTransferChargeId} onChange={setInterAccountTransferChargeId}
          placeholder="Search charge code or description…" emptyText="No matching charges"
          hint="Auto-applied to every inter-account transfer, deducted from the source account. Leave blank to fall back to the charge configured for type ‘Acc. Transfer’." />
      </Card>

      <Card>
        <h3>Guarantorship</h3>
        <div className="card-sub">
          How much of their own deposits a member can put up as security — for other
          members&apos; loans, and for their own.
        </div>
        <div className="grid g2">
          <Field name="guarantor_multiplier" label="Guarantor multiplier" type="number" step="0.1"
            defaultValue={org.guarantor_multiplier ?? 1}
            hint="Deposits × this = how much of OTHER members' loans a member qualifies to guarantee" />
          <Field name="self_guarantor_multiplier" label="Self guarantor multiplier" type="number" step="0.1"
            defaultValue={org.self_guarantor_multiplier ?? 1}
            hint="Deposits × this = how much of a member's OWN loan their own deposits can secure" />
        </div>
      </Card>

      <Card>
        <h3>Cash &amp; Tellering</h3>
        <div className="card-sub">
          The General Ledger Setup &ldquo;Validate Cash Denomination&rdquo; rule, applied to the
          FOSA counter.
        </div>
        <Field name="validate_cash_denomination" label="Validate cash denomination" type="checkbox"
          defaultValue={org.validate_cash_denomination ? 1 : 0}
          hint="When on, a Cash Management movement or a teller deposit/withdrawal cannot be submitted or posted unless its denomination breakdown totals exactly the amount" />
      </Card>

      <div className="inline" style={{ justifyContent: 'flex-end' }}>
        <button type="submit" className="btn" disabled={busy}>{busy ? 'Saving…' : 'Save Sacco Setup'}</button>
      </div>
    </form>
  );
}
