'use client';

import { useState } from 'react';
import { Modal } from '@/components/ui/modal';
import { TableWrap, EmptyState } from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import type { CalculatedLoanCharge } from '@/lib/types';

/**
 * A loan's charge total, shown as a click target — the Loan Card's Facility details "Estimated
 * charges" / "Charges recovered" figure. Clicking it opens the itemised Loan Product Charges
 * breakdown (lib/loans.ts's calculateLoanProductCharges) computed for this loan: which charge, how much,
 * and which revenue account it posts (or posted) to — the same list disburse() itself credits
 * line by line, so what's shown here is exactly what happens financially, not just a total.
 */
export function ChargesBreakdownButton({ charges, label, totalOverride }: {
  charges: CalculatedLoanCharge[];
  /** "Estimated charges" pre-disbursement, "Charges recovered" once posted. */
  label: string;
  /** The actually-posted total for an already-disbursed loan, shown as the click target instead
   *  of resumming `charges` — a re-computation from the product's current configuration can
   *  drift from what was posted at the time if that configuration has changed since. */
  totalOverride?: number;
}) {
  const [open, setOpen] = useState(false);
  const total = totalOverride ?? charges.reduce((sum, c) => sum + c.amount, 0);

  if (!charges.length) return <Money cents={total} />;

  return (
    <>
      <button type="button" className="link-btn" onClick={() => setOpen(true)}
        title="Click to see the computed charges">
        <Money cents={total} />
      </button>
      {open ? (
        <Modal title={label} onClose={() => setOpen(false)}>
          {charges.length ? (
            <TableWrap>
              <thead><tr><th>Charge</th><th>Revenue account</th><th className="num">Amount</th></tr></thead>
              <tbody>
                {charges.map((c, i) => (
                  <tr key={i}>
                    <td>{c.chargeDescription || c.chargeCode}{c.prorated ? ' (prorated)' : ''}</td>
                    <td className="mono">{c.glAccountCode || '—'}</td>
                    <td className="num"><Money cents={c.amount} /></td>
                  </tr>
                ))}
              </tbody>
              <tfoot>
                <tr><td colSpan={2}>Total</td><td className="num"><b><Money cents={total} /></b></td></tr>
              </tfoot>
            </TableWrap>
          ) : <EmptyState icon="🧾" title="No charges configured" />}
        </Modal>
      ) : null}
    </>
  );
}
