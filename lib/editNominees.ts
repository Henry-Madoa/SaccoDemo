import { one, all, run, tx } from './db.ts';
import { AppError } from './errors.ts';
import type { MemberEditNextOfKin, MemberEditNominee } from './types.ts';

/* ------------------------------------------------------------------- next of kin */
export const listEditNextOfKin = (editNo: string): Promise<MemberEditNextOfKin[]> =>
  all<MemberEditNextOfKin>('SELECT * FROM member_edit_next_of_kin WHERE edit_no = ? ORDER BY id', editNo);

export interface NextOfKinDraft {
  name: string;
  relationship?: string | null;
  phone?: string | null;
  identification_no?: string | null;
}

/** Throws if the same (non-blank) Identification No. appears more than once in a submitted
 *  list — scoped to this one edit request's own next-of-kin/nominee list, not global: the same
 *  person can perfectly reasonably be listed for several different members. */
function assertNoDuplicateId(rows: { identification_no?: string | null }[], what: string): void {
  const seen = new Set<string>();
  for (const r of rows) {
    if (!r.identification_no) continue;
    if (seen.has(r.identification_no)) {
      throw new AppError(`Identification No. "${r.identification_no}" is listed more than once among ${what}`, 'VALIDATION');
    }
    seen.add(r.identification_no);
  }
}

/** Replaces an edit request's full next-of-kin list with the submitted rows — nothing else references these rows. */
export async function replaceEditNextOfKin(editNo: string, rows: NextOfKinDraft[]): Promise<void> {
  const clean = rows
    .map((r) => ({ ...r, name: String(r.name || '').trim(), identification_no: r.identification_no?.trim() || null }))
    .filter((r) => r.name);
  assertNoDuplicateId(clean, 'this member\'s next of kin');

  await tx(async () => {
    await run('DELETE FROM member_edit_next_of_kin WHERE edit_no = ?', editNo);
    for (const r of clean) {
      await run(
        'INSERT INTO member_edit_next_of_kin (edit_no, name, relationship, phone, identification_no) VALUES (?,?,?,?,?)',
        editNo, r.name, r.relationship || null, r.phone || null, r.identification_no,
      );
    }
  });
}

/* --------------------------------------------------------------------- nominees */
export const listEditNominees = (editNo: string): Promise<MemberEditNominee[]> =>
  all<MemberEditNominee>('SELECT * FROM member_edit_nominee WHERE edit_no = ? ORDER BY id', editNo);

export interface NomineeDraft {
  name: string;
  relationship?: string | null;
  phone?: string | null;
  identification_no?: string | null;
  percentage: number | string;
  /** When set, the nominee is also added as a next-of-kin entry on save. */
  is_next_of_kin?: boolean | number;
}

/**
 * Replaces an edit request's full nominee list with the submitted rows.
 *
 * A non-empty set must add up to 100% — an empty set is fine, since nominating
 * beneficiaries is optional. A row with its "also next of kin" box checked adds
 * a next-of-kin entry too, skipping it if one with the same name already exists
 * so re-saving the form doesn't pile up duplicates.
 */
export async function replaceEditNominees(editNo: string, rows: NomineeDraft[]): Promise<void> {
  const clean = rows
    .map((r) => ({
      ...r, name: String(r.name || '').trim(), percentage: Number(r.percentage) || 0,
      identification_no: r.identification_no?.trim() || null,
    }))
    .filter((r) => r.name);
  assertNoDuplicateId(clean, 'this member\'s nominees');

  if (clean.length) {
    const total = Math.round(clean.reduce((sum, r) => sum + r.percentage, 0) * 100) / 100;
    if (Math.abs(total - 100) > 0.01) {
      throw new AppError(`Nominee percentages must add up to 100% (currently ${total}%)`, 'VALIDATION');
    }
  }

  await tx(async () => {
    await run('DELETE FROM member_edit_nominee WHERE edit_no = ?', editNo);
    for (const r of clean) {
      const isNok = !!r.is_next_of_kin;
      await run(
        `INSERT INTO member_edit_nominee (edit_no, name, relationship, phone, identification_no, percentage, is_next_of_kin)
         VALUES (?,?,?,?,?,?,?)`,
        editNo, r.name, r.relationship || null, r.phone || null, r.identification_no, r.percentage, isNok ? 1 : 0,
      );
      if (isNok) {
        const exists = await one(
          'SELECT 1 FROM member_edit_next_of_kin WHERE edit_no = ? AND name = ?', editNo, r.name,
        );
        if (!exists) {
          await run(
            'INSERT INTO member_edit_next_of_kin (edit_no, name, relationship, phone, identification_no) VALUES (?,?,?,?,?)',
            editNo, r.name, r.relationship || null, r.phone || null, r.identification_no,
          );
        }
      }
    }
  });
}
