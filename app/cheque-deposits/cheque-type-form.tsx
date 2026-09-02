'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { GlAccountSelect, type GlAccountSelectOption } from '@/components/ui/gl-account-select';
import { SearchableSelect } from '@/components/ui/searchable-select';
import { saveChequeType } from '@/app/actions/chequeTypes';
import type { ChequeTypeWithDetail, TransactionCharge } from '@/lib/types';

type ChargeOpt = Pick<TransactionCharge, 'id' | 'code' | 'description'>;

export function ExternalChequeTypeFormButton({
  glAccounts, charges, row, className = 'btn', children,
}: {
  glAccounts: GlAccountSelectOption[];
  charges: ChargeOpt[];
  row?: ChequeTypeWithDetail | null;
  className?: string;
  children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const [clearingGlAccountId, setClearingGlAccountId] = useState(String(row?.clearing_gl_account_id ?? ''));
  const [clearingChargeId, setClearingChargeId] = useState(String(row?.clearing_charge_id ?? ''));
  const [bouncingChargeId, setBouncingChargeId] = useState(String(row?.bouncing_charge_id ?? ''));
  const [expressChargeId, setExpressChargeId] = useState(String(row?.express_charge_id ?? ''));
  const [inHouse, setInHouse] = useState(!!row?.in_house);

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          title={row ? `Edit cheque type — ${row.code}` : 'Add external cheque type'}
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveChequeType(row?.id ?? null, values)}
          submitLabel="Save"
          successTitle="Cheque type saved"
        >
          <input type="hidden" name="type" value="EXTERNAL" />
          <div className="grid g2">
            <Field name="code" label="Code" defaultValue={row?.code} required disabled={!!row} uppercase />
            <Field name="status" label="Status" type="select" defaultValue={row?.status ?? 'ACTIVE'}
              options={['ACTIVE', 'INACTIVE']} />
          </div>
          <Field name="description" label="Description" defaultValue={row?.description} required />
          <Field name="maximumAmount" label="Maximum amount per cheque" type="currency" min={0}
            defaultValue={row ? row.maximum_amount / 100 : 0} hint="0 = no ceiling" />

          <GlAccountSelect name="clearingGlAccountId" label="Clearing account"
            accounts={glAccounts} value={clearingGlAccountId} onChange={setClearingGlAccountId} required
            hint="The G/L account debited while the cheque is in clearing (e.g. Cheques in Clearing)" />

          <div className="grid g2">
            <Field name="inHouse" label="In-house (drawn on this SACCO — clears same day)" type="checkbox"
              defaultValue={inHouse ? 1 : 0} onChange={(e) => setInHouse((e.target as HTMLInputElement).checked)} />
            {!inHouse ? (
              <Field name="maturityDays" label="Maturity period (days)" type="number" step="1" min={1}
                defaultValue={row?.maturity_days ?? 3}
                hint="Business days added to the deposit date (weekends skipped, AL Tab52204124)" />
            ) : <input type="hidden" name="maturityDays" value="0" />}
          </div>

          <SearchableSelect name="clearingChargeId" label="Clearing charge (optional)"
            items={charges} getValue={(c) => String(c.id)} getLabel={(c) => `${c.code} — ${c.description}`}
            value={clearingChargeId} onChange={setClearingChargeId}
            placeholder="Search charge code or description…" emptyText="No matching charges"
            hint="Deducted from the member on normal clearing" />
          <SearchableSelect name="expressChargeId" label="Express clearing charge (optional)"
            items={charges} getValue={(c) => String(c.id)} getLabel={(c) => `${c.code} — ${c.description}`}
            value={expressChargeId} onChange={setExpressChargeId}
            placeholder="Search charge code or description…" emptyText="No matching charges"
            hint="Enables express clearing — funds released early for this charge, with a hold until maturity" />
          <SearchableSelect name="bouncingChargeId" label="Bouncing charge (optional)"
            items={charges} getValue={(c) => String(c.id)} getLabel={(c) => `${c.code} — ${c.description}`}
            value={bouncingChargeId} onChange={setBouncingChargeId}
            placeholder="Search charge code or description…" emptyText="No matching charges"
            hint="Deducted from the member if the cheque bounces" />
        </FormModal>
      ) : null}
    </>
  );
}
