/*
 * Collateral Register — the read-only ledger of accepted collateral. Written only by
 * postCollateralApplication() (lib/collateralApplications.ts) and postCollateralRelease()
 * (lib/collateralReleases.ts); every screen here is read-only, matching page 52204032's
 * InsertAllowed/ModifyAllowed/DeleteAllowed = false in the source specification.
 *
 * `status` is deliberately never a stored column (see DEF-04 in the source spec: the AL
 * implementation left it on the enum's unset default because nothing ever assigned it). It is
 * derived here, in one place, from whether a live loan_collateral row still consumes cover and
 * whether the item has been collected — so an invalid combination can never be persisted, and
 * every reader (the list, the detail page, the release picker, the loan attach picker) agrees.
 */
import { one, all, hasAnyRow } from './db.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import type { AvailableCollateralRow, CollateralRegisterRow } from './types.ts';

/** Cover consumed per item = SUM of MIN(this loan's pledged guarantee, that loan's outstanding
 *  balance) over every ACTIVE loan_collateral row whose loan is DISBURSED with a balance still
 *  owing — the same cap the source specification's UpdateCollateralRegister() applies (BR-14):
 *  a collateral item pledged for 500,000 against a loan amortised down to 120,000 only ever
 *  consumes 120,000 of cover, and a fully settled loan frees its collateral automatically. */
const SELECT_REGISTER = `
  SELECT r.*, m.member_no AS member_no, m.first_name AS member_first_name, m.last_name AS member_last_name,
         t.code AS collateral_type_code, c.name AS county_name,
         COALESCE(x.linked_loan_balance, 0) AS linked_loan_balance,
         r.guarantee - COALESCE(x.linked_loan_balance, 0) AS collateral_balance,
         CASE
           WHEN r.collected_at IS NOT NULL THEN 'COLLECTED'
           WHEN COALESCE(x.linked_loan_balance, 0) > 0 THEN 'LINKED_TO_LOAN'
           ELSE 'AVAILABLE'
         END AS status
  FROM collateral_register r
  JOIN member m ON m.id = r.member_id
  LEFT JOIN collateral_type t ON t.id = r.collateral_type_id
  LEFT JOIN county c ON c.id = r.county_id
  LEFT JOIN (
    SELECT lc.collateral_no, SUM(LEAST(lc.guarantee, l.principal_balance + l.interest_balance + l.penalty_balance)) AS linked_loan_balance
    FROM loan_collateral lc
    JOIN loan l ON l.id = lc.loan_id
    WHERE lc.status = 'ACTIVE' AND l.status = 'DISBURSED'
      AND (l.principal_balance + l.interest_balance + l.penalty_balance) > 0
    GROUP BY lc.collateral_no
  ) x ON x.collateral_no = r.no`;

/** Collateral Register's dynamic-filter registry — every meaningful column. member_id and
 *  collateral_type_id ship without `options`; the page fills them in from lookups it already
 *  fetches. `status` is computed, not a real column, so it is deliberately left out of the
 *  filterable set (matching how AL's page never let it be filtered either). */
export const COLLATERAL_REGISTER_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'no', label: 'No.', type: 'text', column: 'r.no' },
  { key: 'member_id', label: 'Member', type: 'select', column: 'r.member_id' },
  { key: 'category', label: 'Category', type: 'select', column: 'r.category' },
  { key: 'collateral_type_id', label: 'Collateral Type', type: 'select', column: 'r.collateral_type_id' },
  { key: 'serial_reg_no', label: 'Serial / Reg. No.', type: 'text', column: 'r.serial_reg_no' },
  { key: 'collateral_value', label: 'Collateral Value', type: 'number', column: 'r.collateral_value' },
  { key: 'guarantee', label: 'Guarantee (LTV)', type: 'number', column: 'r.guarantee' },
  { key: 'owner_name', label: 'Owner Name', type: 'text', column: 'r.owner_name' },
  { key: 'posting_date', label: 'Posting Date', type: 'date', column: 'r.posting_date' },
];

const SORT_COLUMNS: Record<string, string> = {
  no: 'r.no',
  member: 'm.first_name',
  member_no: 'm.member_no',
  category: 'r.category',
  collateral_type: 't.code',
  collateral_value: 'r.collateral_value',
  guarantee: 'r.guarantee',
  linked_loan_balance: 'linked_loan_balance',
  collateral_balance: 'collateral_balance',
  status: 'status',
};

export function listCollateralRegister(
  { search = '', filters = [], sort = null }: { search?: string; filters?: FilterCondition[]; sort?: SortState | null } = {},
): Promise<CollateralRegisterRow[]> {
  const { clause, params } = buildFilterClause(COLLATERAL_REGISTER_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(SORT_COLUMNS, sort, 'r.no DESC');
  return all<CollateralRegisterRow>(
    `${SELECT_REGISTER}
     WHERE (r.no LIKE @like OR r.serial_reg_no LIKE @like OR m.member_no LIKE @like
            OR m.first_name LIKE @like OR m.last_name LIKE @like)
       ${clause}
     ${orderBy}`,
    { like: `%${String(search).trim()}%`, ...params },
  );
}

export const hasAnyCollateralRegister = (): Promise<boolean> => hasAnyRow('collateral_register');

export const getCollateralRegisterRow = (no: string): Promise<CollateralRegisterRow | undefined> =>
  one<CollateralRegisterRow>(`${SELECT_REGISTER} WHERE r.no = ?`, no);

export async function getAdjacentCollateralRegisterNos(
  no: string,
): Promise<{ prevNo: string | null; nextNo: string | null }> {
  const [prev, next] = await Promise.all([
    one<{ no: string }>('SELECT no FROM collateral_register WHERE no < ? ORDER BY no DESC LIMIT 1', no),
    one<{ no: string }>('SELECT no FROM collateral_register WHERE no > ? ORDER BY no ASC LIMIT 1', no),
  ]);
  return { prevNo: prev?.no ?? null, nextNo: next?.no ?? null };
}

/** Every loan currently drawing cover from this collateral item — the "Collateral Linked
 *  Loans" list part in the source specification (3.3.3), computed on read rather than
 *  materialised and rebuilt on every page render (see DEF-22: the AL version's per-row
 *  DeleteAll+Insert write storm is deliberately not reproduced). */
export const listLinkedLoansForCollateral = (collateralNo: string) => all<{
  loan_id: number; loan_no: string; product_name: string; member_no: string;
  member_first_name: string; member_last_name: string; current_balance: number;
}>(
  `SELECT l.id AS loan_id, l.loan_no, p.name AS product_name, m.member_no,
          m.first_name AS member_first_name, m.last_name AS member_last_name,
          LEAST(lc.guarantee, l.principal_balance + l.interest_balance + l.penalty_balance) AS current_balance
   FROM loan_collateral lc
   JOIN loan l ON l.id = lc.loan_id
   JOIN loan_product p ON p.id = l.product_id
   JOIN member m ON m.id = l.member_id
   WHERE lc.collateral_no = ? AND lc.status = 'ACTIVE' AND l.status = 'DISBURSED'
     AND (l.principal_balance + l.interest_balance + l.penalty_balance) > 0
   ORDER BY l.id`,
  collateralNo,
);

/** How much loan balance a collateral item still secures — the figure BR-10 requires to be
 *  zero before a release can be submitted or posted, re-fetched (not trusted from a stale
 *  read) at both points. */
export async function getCollateralLinkedBalance(collateralNo: string): Promise<number> {
  const row = await one<{ balance: number }>(
    `SELECT COALESCE(SUM(LEAST(lc.guarantee, l.principal_balance + l.interest_balance + l.penalty_balance)), 0) AS balance
     FROM loan_collateral lc JOIN loan l ON l.id = lc.loan_id
     WHERE lc.collateral_no = ? AND lc.status = 'ACTIVE' AND l.status = 'DISBURSED'
       AND (l.principal_balance + l.interest_balance + l.penalty_balance) > 0`,
    collateralNo,
  );
  return row?.balance ?? 0;
}

/** Collateral a loan officer could still pledge against a loan for this member: registered,
 *  not collected, with cover left over — the picker behind "Attach collateral" on a loan. */
export function listAvailableCollateralForMember(memberId: number): Promise<AvailableCollateralRow[]> {
  return all<AvailableCollateralRow>(
    `SELECT r.no, r.collateral_description, r.serial_reg_no, r.guarantee,
            r.guarantee - COALESCE(x.linked_loan_balance, 0) AS collateral_balance
     FROM collateral_register r
     LEFT JOIN (
       SELECT lc.collateral_no, SUM(LEAST(lc.guarantee, l.principal_balance + l.interest_balance + l.penalty_balance)) AS linked_loan_balance
       FROM loan_collateral lc JOIN loan l ON l.id = lc.loan_id
       WHERE lc.status = 'ACTIVE' AND l.status = 'DISBURSED'
         AND (l.principal_balance + l.interest_balance + l.penalty_balance) > 0
       GROUP BY lc.collateral_no
     ) x ON x.collateral_no = r.no
     WHERE r.member_id = ? AND r.collected_at IS NULL
       AND r.guarantee - COALESCE(x.linked_loan_balance, 0) > 0
     ORDER BY r.no`,
    memberId,
  );
}
