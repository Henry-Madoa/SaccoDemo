import { Card, CardHead, DefinitionList, Pill, TableWrap } from '@/components/ui/primitives';
import { CollapsibleCard } from '@/components/ui/collapsible-card';
import { Money } from '@/components/ui/money';
import { formatDateTime } from '@/lib/format';
import type { Appraisal, LoanAppraisalRow } from '@/lib/types';

/** Adapts a persisted loan_appraisal row back into the plain Appraisal shape appraise()
 *  returns, so AppraisalCard below has one rendering path whether the decision is still
 *  ephemeral (New Application modal, no loan_id yet) or on file (a loan's Appraisal tab). */
export function toAppraisal(row: LoanAppraisalRow): Appraisal {
  return {
    decision: row.decision,
    score: row.score,
    factors: row.factors.map((f) => ({ ...f, detail: f.detail ?? '' })),
    installment: row.installment,
    deposits: row.deposits,
    exposure: row.exposure,
    maxByMultiplier: row.max_by_multiplier,
    dsr: row.dsr,
    monthlyObligations: row.monthly_obligations,
  };
}

/** Explainable credit-appraisal breakdown — every policy factor shown pass/fail, plus the
 *  headline affordability figures. Shared between the New Application modal's live preview
 *  (an ephemeral, unsaved Appraisal) and a loan's Appraisal tab (the same shape read back off a
 *  saved loan_appraisal row via toAppraisal() above) — one rendering, two sources. */
export function AppraisalCard({ appraisal: a }: { appraisal: Appraisal }) {
  return (
    <Card className="inset">
      <CardHead
        title={<>Credit appraisal — <Pill status={a.decision} /></>}
        sub={`Policy score ${a.score}/100 · every factor is shown so the decision is explainable`}
      />
      <TableWrap>
        <thead><tr><th /><th>Factor</th><th>Assessment</th></tr></thead>
        <tbody>
          {a.factors.map((f) => (
            <tr key={f.code}>
              <td style={{ width: 26 }}>
                <span className={f.pass ? 'factor-ok' : 'factor-no'}>{f.pass ? '✔' : '✖'}</span>
              </td>
              <td>{f.label}</td>
              <td className="muted-cell">{f.detail}</td>
            </tr>
          ))}
        </tbody>
      </TableWrap>
      <div className="grid g4" style={{ marginTop: 'calc(var(--sp)*2)' }}>
        <div><div className="metric-label">Monthly instalment</div><b><Money cents={a.installment} /></b></div>
        <div><div className="metric-label">Deposit ceiling</div><b><Money cents={a.maxByMultiplier} decimals={0} /></b></div>
        <div><div className="metric-label">Existing exposure</div><b><Money cents={a.exposure} decimals={0} /></b></div>
        <div><div className="metric-label">Deduction ratio</div><b>{a.dsr}%</b></div>
      </div>
    </Card>
  );
}

/** Prior appraisal runs on file for a loan, newest-first with the very latest omitted — that
 *  one is already shown in full by AppraisalCard above; this is just the "who ran it, when, and
 *  to what decision" trail underneath. */
export function AppraisalHistoryTable({ appraisals }: { appraisals: LoanAppraisalRow[] }) {
  if (appraisals.length <= 1) return null;
  const previous = appraisals.slice(1);
  return (
    <CollapsibleCard title="Appraisal history" sub={`${previous.length} earlier run${previous.length === 1 ? '' : 's'}`}>
      <TableWrap>
        <thead><tr><th>Appraised</th><th>By</th><th>Decision</th><th className="num">Score</th></tr></thead>
        <tbody>
          {previous.map((r) => (
            <tr key={r.id}>
              <td>{formatDateTime(r.appraised_at)}</td>
              <td>{r.appraised_by || '—'}</td>
              <td><Pill status={r.decision} /></td>
              <td className="num">{r.score}/100</td>
            </tr>
          ))}
        </tbody>
      </TableWrap>
    </CollapsibleCard>
  );
}

/** The latest appraisal's who/when, shown above its factor table so the Appraisal tab (and the
 *  printed Appraisal Report) reads standalone — it names its own author without requiring the
 *  rest of the loan workspace for context. */
export function AppraisalMeta({ appraisal }: { appraisal: LoanAppraisalRow }) {
  return (
    <DefinitionList items={[
      ['Appraised by', appraisal.appraised_by || '—'],
      ['Appraised on', formatDateTime(appraisal.appraised_at)],
    ]} />
  );
}
