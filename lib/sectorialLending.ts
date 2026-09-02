/*
 * SASRA Sectorial Lending Return — AL Rep52204034 "Sectorial Lending". One line per economic
 * sector / sub-sector / sub-subsector a loan is classified against (lib/economicSectors.ts),
 * with the DT-SACCO's own outstanding portfolio and the net principal movement for the chosen
 * period — SASRA's own "Sectoral Analysis of Loans" format (outstanding balance per sector, plus
 * the period's disbursements and recoveries so the movement reconciles).
 *
 * "Net Change-Principal" is AL's own field: `SUM(Detailed Vendor Ledg. Entry.Amount where
 * "Sacco Transaction Type" in ["Loan Disbursal","Principal Paid"])` for the period — the net
 * movement on the loan's own receivable ledger. Here that is exactly the journal lines posted to
 * the loan's receivable G/L account (a disbursement debits it, a principal repayment credits it;
 * interest/penalty never touch it), traced back to the loan via `journal.reference = loan.loan_no`.
 */
import { all } from './db.ts';
import type { Cents, IsoDate, SectorialLendingRow } from './types.ts';

export interface SectorialLendingOptions {
  from?: IsoDate;
  to?: IsoDate;
}

const UNCLASSIFIED = 'Unclassified';

export async function sectorialLendingReport(
  { from, to }: SectorialLendingOptions = {},
): Promise<SectorialLendingRow[]> {
  const movementConds: string[] = [];
  const movementParams: Record<string, unknown> = {};
  if (from) { movementConds.push('j.value_date >= @from'); movementParams.from = from; }
  if (to) { movementConds.push('j.value_date <= @to'); movementParams.to = to; }

  const [movement, outstanding] = await Promise.all([
    all<{
      sector_code: string | null; sub_sector_code: string | null; sub_subsector_code: string | null;
      disbursed: Cents; repaid: Cents;
    }>(
      `SELECT l.sector_code, l.sub_sector_code, l.sub_subsector_code,
              COALESCE(SUM(CASE WHEN jl.debit > 0 THEN jl.debit ELSE 0 END), 0) AS disbursed,
              COALESCE(SUM(CASE WHEN jl.credit > 0 THEN jl.credit ELSE 0 END), 0) AS repaid
       FROM journal j
       JOIN journal_line jl ON jl.journal_id = j.id
       JOIN loan l ON l.loan_no = j.reference
       JOIN loan_product lp ON lp.id = l.product_id
       WHERE j.source_module = 'LOAN' AND jl.gl_account_id = lp.gl_receivable_id
         ${movementConds.length ? `AND ${movementConds.join(' AND ')}` : ''}
       GROUP BY l.sector_code, l.sub_sector_code, l.sub_subsector_code`,
      movementParams,
    ),
    all<{ sector_code: string | null; sub_sector_code: string | null; sub_subsector_code: string | null; loans: number; outstanding: Cents }>(
      `SELECT sector_code, sub_sector_code, sub_subsector_code, COUNT(*) AS loans, COALESCE(SUM(principal_balance), 0) AS outstanding
       FROM loan WHERE status = 'DISBURSED'
       GROUP BY sector_code, sub_sector_code, sub_subsector_code`,
    ),
  ]);

  const names = await all<{ sector_code: string; sector_name: string; sub_sector_code: string | null; sub_sector_name: string | null; sub_subsector_code: string | null; sub_subsector_name: string | null }>(
    `SELECT es.code AS sector_code, es.name AS sector_name,
            ess.code AS sub_sector_code, ess.name AS sub_sector_name,
            esss.code AS sub_subsector_code, esss.description AS sub_subsector_name
     FROM economic_sector es
     LEFT JOIN economic_subsector ess ON ess.sector_code = es.code
     LEFT JOIN economic_subsubsector esss ON esss.sector_code = es.code AND esss.subsector_code = ess.code`,
  );
  const nameFor = (sector: string | null, sub: string | null, subSub: string | null) => {
    if (!sector) return { sector: UNCLASSIFIED, sub: '—', subSub: '—' };
    const sectorRow = names.find((n) => n.sector_code === sector);
    const subRow = sub ? names.find((n) => n.sector_code === sector && n.sub_sector_code === sub) : undefined;
    const subSubRow = subSub ? names.find((n) => n.sector_code === sector && n.sub_sector_code === sub && n.sub_subsector_code === subSub) : undefined;
    return {
      sector: sectorRow?.sector_name ?? sector,
      sub: sub ? (subRow?.sub_sector_name ?? sub) : '—',
      subSub: subSub ? (subSubRow?.sub_subsector_name ?? subSub) : '—',
    };
  };

  const key = (r: { sector_code: string | null; sub_sector_code: string | null; sub_subsector_code: string | null }) =>
    `${r.sector_code ?? ''}|${r.sub_sector_code ?? ''}|${r.sub_subsector_code ?? ''}`;

  const rows = new Map<string, SectorialLendingRow>();
  for (const o of outstanding) {
    const n = nameFor(o.sector_code, o.sub_sector_code, o.sub_subsector_code);
    rows.set(key(o), {
      sector_code: o.sector_code, sector_name: n.sector,
      sub_sector_code: o.sub_sector_code, sub_sector_name: n.sub,
      sub_subsector_code: o.sub_subsector_code, sub_subsector_name: n.subSub,
      loans: Number(o.loans), disbursed: 0, repaid: 0, net_change: 0, outstanding: Number(o.outstanding),
    });
  }
  for (const m of movement) {
    const k = key(m);
    const disbursed = Number(m.disbursed);
    const repaid = Number(m.repaid);
    const existing = rows.get(k);
    if (existing) {
      existing.disbursed += disbursed;
      existing.repaid += repaid;
      existing.net_change += disbursed - repaid;
    } else {
      const n = nameFor(m.sector_code, m.sub_sector_code, m.sub_subsector_code);
      rows.set(k, {
        sector_code: m.sector_code, sector_name: n.sector,
        sub_sector_code: m.sub_sector_code, sub_sector_name: n.sub,
        sub_subsector_code: m.sub_subsector_code, sub_subsector_name: n.subSub,
        loans: 0, disbursed, repaid, net_change: disbursed - repaid, outstanding: 0,
      });
    }
  }

  return [...rows.values()].sort((a, b) => (
    a.sector_name === b.sector_name
      ? a.sub_sector_name.localeCompare(b.sub_sector_name) || a.sub_subsector_name.localeCompare(b.sub_subsector_name)
      : a.sector_name.localeCompare(b.sector_name)
  ));
}
