'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { useFormat } from '@/components/ui/format-provider';
import { openSavingsAccount } from '@/app/actions/savings';
import { DEPOSIT_CHANNELS } from '@/lib/constants';
import type { MemberWithDimensions, SavingsProduct } from '@/lib/types';

export function OpenAccountButton({ member, products }: {
  member: MemberWithDimensions;
  products: SavingsProduct[];
}) {
  const [open, setOpen] = useState(false);
  const [productId, setProductId] = useState(String(products[0]?.id ?? ''));
  const { cur } = useFormat();

  const product = products.find((p) => String(p.id) === productId);

  return (
    <>
      <button type="button" className="btn ghost" onClick={() => setOpen(true)}>Open savings account</button>
      {open ? (
        <FormModal
          title={`Open a savings account — ${member.first_name} ${member.last_name}`}
          onClose={() => setOpen(false)}
          onSubmit={(values) => openSavingsAccount({ ...values, memberId: member.id })}
          submitLabel="Open account"
          successTitle="Account opened"
          successDetail={(a) => a.account_no}
        >
          <div className="field">
            <label htmlFor="f_productId">Product <span className="req">*</span></label>
            <select id="f_productId" name="productId" required value={productId}
              onChange={(e) => setProductId(e.target.value)}>
              {products.map((p) => (
                <option key={p.id} value={p.id}>{p.name} ({p.code})</option>
              ))}
            </select>
          </div>
          <Field name="openingBalance" label="Opening deposit" type="number" step="0.01"
            hint="Must meet the product minimum" />
          <Field name="channel" label="Channel" type="select" options={DEPOSIT_CHANNELS} />
          {product ? (
            <div className="note">
              Minimum opening {cur(product.min_opening)} · minimum balance {cur(product.min_balance)} ·{' '}
              {product.allow_withdrawal ? 'withdrawals permitted' : 'no withdrawals'} ·{' '}
              interest {product.interest_rate}% p.a.
              {product.is_loanable_base ? ' · counts toward the loan multiplier' : ''}
            </div>
          ) : null}
        </FormModal>
      ) : null}
    </>
  );
}
