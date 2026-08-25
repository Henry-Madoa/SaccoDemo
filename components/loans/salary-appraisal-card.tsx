'use client';

import { useMemo, useState } from 'react';
import { useRouter } from 'next/navigation';
import { TableWrap } from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import { useToast } from '@/components/ui/toast';
import { saveSalaryAppraisalLines } from '@/app/actions/salaryAppraisal';
import { computeSalaryTotals } from '@/lib/salaryAppraisalCalc';
import { toCents, toUnits } from '@/lib/format';
import type { LoanSalaryAppraisalLine } from '@/lib/types';

/** The loan card's Salary Appraisal section — auto-seeded predefined earning/deduction lines
 *  (Admin Centre → Sacco Products → Salary Appraisal Parameters) the officer fills in to mimic
 *  the member's actual payslip, plus a live one-third affordability cap computed the instant a
 *  Basic Salary amount is typed. Editable only while the loan is still OPEN — the same window
 *  Guarantors/Collateral stay open in. */
export function SalaryAppraisalCard({ loanId, lines, editable }: {
  loanId: number;
  lines: LoanSalaryAppraisalLine[];
  editable: boolean;
}) {
  const router = useRouter();
  const toast = useToast();
  const [amounts, setAmounts] = useState<Record<string, string>>(() =>
    Object.fromEntries(lines.filter((l) => l.editable).map((l) => [l.code, l.amount ? toUnits(l.amount) : ''])));
  const [busy, setBusy] = useState(false);

  const draftLines = useMemo(
    () => lines.map((l) => (l.editable ? { ...l, amount: toCents(amounts[l.code]) } : l)),
    [lines, amounts],
  );
  const totals = computeSalaryTotals(draftLines);

  const earnings = draftLines.filter((l) => l.type === 'EARNING');
  const deductions = draftLines.filter((l) => l.type === 'DEDUCTION');

  const save = async () => {
    setBusy(true);
    try {
      const res = await saveSalaryAppraisalLines(
        loanId,
        lines.filter((l) => l.editable).map((l) => ({ code: l.code, amount: toCents(amounts[l.code]) })),
      );
      if (!res.ok) { toast('Could not save', res.error, 'err'); return; }
      toast('Salary details saved', undefined, 'ok');
      router.refresh();
    } finally {
      setBusy(false);
    }
  };

  const renderRow = (l: LoanSalaryAppraisalLine) => (
    <tr key={l.code}>
      <td>{l.name}</td>
      <td className="num">
        {l.editable && editable ? (
          <input type="number" step="0.01" min={0} style={{ width: 120, textAlign: 'right' }}
            aria-label={l.name} value={amounts[l.code] ?? ''}
            onChange={(e) => setAmounts((cur) => ({ ...cur, [l.code]: e.target.value }))} />
        ) : (
          <Money cents={l.amount} />
        )}
      </td>
    </tr>
  );

  if (!lines.length) return null;

  return (
    <>
      <div>
        <h4 className="section-title">Earnings</h4>
        <TableWrap>
          <thead><tr><th>Line</th><th className="num">Amount</th></tr></thead>
          <tbody>{earnings.map(renderRow)}</tbody>
        </TableWrap>
      </div>
      <div style={{ marginTop: 'calc(var(--sp)*2)' }}>
        <h4 className="section-title">Deductions</h4>
        <TableWrap>
          <thead><tr><th>Line</th><th className="num">Amount</th></tr></thead>
          <tbody>{deductions.map(renderRow)}</tbody>
        </TableWrap>
      </div>

      <div className="grid auto-fit" style={{ marginTop: 'calc(var(--sp)*2)' }}>
        <div><div className="metric-label">Gross earnings</div><b><Money cents={totals.gross} decimals={0} /></b></div>
        <div><div className="metric-label">Total deductions</div><b><Money cents={totals.totalDeductions} decimals={0} /></b></div>
        <div><div className="metric-label">1/3 of Basic Salary (cap)</div><b><Money cents={totals.oneThirdCap} decimals={0} /></b></div>
        <div>
          <div className="metric-label">Headroom left</div>
          <b className={totals.headroom < 0 ? 'neg' : undefined}><Money cents={totals.headroom} decimals={0} /></b>
        </div>
      </div>

      {editable ? (
        <div className="inline" style={{ marginTop: 'calc(var(--sp)*2)' }}>
          <button type="button" className="btn" disabled={busy} onClick={save}>
            {busy ? 'Saving…' : 'Save salary details'}
          </button>
        </div>
      ) : null}
    </>
  );
}
