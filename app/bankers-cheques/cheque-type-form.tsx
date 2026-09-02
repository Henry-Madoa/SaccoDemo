'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { GlAccountSelect, type GlAccountSelectOption } from '@/components/ui/gl-account-select';
import { SearchableSelect } from '@/components/ui/searchable-select';
import { saveChequeType } from '@/app/actions/chequeTypes';
import type { ChequeTypeWithDetail, TransactionCharge } from '@/lib/types';

export function ChequeTypeFormButton({
  glAccounts, charges, row, className = 'btn', children,
}: {
  glAccounts: GlAccountSelectOption[];
  charges: Pick<TransactionCharge, 'id' | 'code' | 'description'>[];
  row?: ChequeTypeWithDetail | null;
  className?: string;
  children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const [clearingGlAccountId, setClearingGlAccountId] = useState(String(row?.clearing_gl_account_id ?? ''));
  const [clearingChargeId, setClearingChargeId] = useState(String(row?.clearing_charge_id ?? ''));

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          title={row ? `Edit cheque type — ${row.code}` : 'Add banker’s cheque type'}
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveChequeType(row?.id ?? null, values)}
          submitLabel="Save"
          successTitle="Cheque type saved"
        >
          <input type="hidden" name="type" value="BANKERS" />
          <div className="grid g2">
            <Field name="code" label="Code" defaultValue={row?.code} required disabled={!!row} uppercase />
            <Field name="status" label="Status" type="select" defaultValue={row?.status ?? 'ACTIVE'}
              options={['ACTIVE', 'INACTIVE']} />
          </div>
          <Field name="description" label="Description" defaultValue={row?.description} required />
          <Field name="maximumAmount" label="Maximum amount per cheque" type="currency" min={0}
            defaultValue={row ? row.maximum_amount / 100 : 0}
            hint="0 = no ceiling" />
          <GlAccountSelect name="clearingGlAccountId" label="Clearing account"
            accounts={glAccounts} value={clearingGlAccountId} onChange={setClearingGlAccountId} required
            hint="The G/L account an issued cheque is credited to (e.g. Bankers Cheques Payable)" />
          <SearchableSelect name="clearingChargeId" label="Clearing charge (optional)"
            items={charges} getValue={(c) => String(c.id)} getLabel={(c) => `${c.code} — ${c.description}`}
            value={clearingChargeId} onChange={setClearingChargeId}
            placeholder="Search charge code or description…" emptyText="No matching charges"
            hint="Deducted from the member's account on posting, on top of the cheque amount" />
          <Field name="inHouse" label="In-house cheque" type="checkbox"
            defaultValue={row ? (row.in_house ? 1 : 0) : 0} />
        </FormModal>
      ) : null}
    </>
  );
}
