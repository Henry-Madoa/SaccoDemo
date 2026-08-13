import { one, all, run, tx, audit } from './db.ts';
import { AppError } from './errors.ts';
import type { Actor, MemberApplicationNextOfKin, MemberApplicationNominee } from './types.ts';

/* ------------------------------------------------------------------- next of kin */
export const listApplicationNextOfKin = (applicationNo: string): Promise<MemberApplicationNextOfKin[]> =>
  all<MemberApplicationNextOfKin>(
    'SELECT * FROM member_application_next_of_kin WHERE application_no = ? ORDER BY id', applicationNo,
  );

export interface NextOfKinDraft {
  name: string;
  relationship?: string | null;
  phone?: string | null;
}

/** Replaces an application's full next-of-kin list with the submitted rows — nothing else references these rows. */
export async function replaceApplicationNextOfKin(
  applicationNo: string, rows: NextOfKinDraft[], user: Actor,
): Promise<void> {
  const clean = rows.map((r) => ({ ...r, name: String(r.name || '').trim() })).filter((r) => r.name);

  await tx(async () => {
    await run('DELETE FROM member_application_next_of_kin WHERE application_no = ?', applicationNo);
    for (const r of clean) {
      await run(
        'INSERT INTO member_application_next_of_kin (application_no, name, relationship, phone) VALUES (?,?,?,?)',
        applicationNo, r.name, r.relationship || null, r.phone || null,
      );
    }
    await audit(user, 'APPLICATION_NOK_UPDATE', 'member_application', applicationNo, { count: clean.length });
  });
}

/* --------------------------------------------------------------------- nominees */
export const listApplicationNominees = (applicationNo: string): Promise<MemberApplicationNominee[]> =>
  all<MemberApplicationNominee>(
    'SELECT * FROM member_application_nominee WHERE application_no = ? ORDER BY id', applicationNo,
  );

export interface NomineeDraft {
  name: string;
  relationship?: string | null;
  phone?: string | null;
  percentage: number | string;
  /** When set, the nominee is also added as a next-of-kin entry on save. */
  is_next_of_kin?: boolean | number;
}

/**
 * Replaces an application's full nominee list with the submitted rows.
 *
 * A non-empty set must add up to 100% — an empty set is fine, since nominating
 * beneficiaries is optional. A row with its "also next of kin" box checked adds
 * a next-of-kin entry too, skipping it if one with the same name already exists
 * so re-saving the form doesn't pile up duplicates.
 */
export async function replaceApplicationNominees(
  applicationNo: string, rows: NomineeDraft[], user: Actor,
): Promise<void> {
  const clean = rows
    .map((r) => ({ ...r, name: String(r.name || '').trim(), percentage: Number(r.percentage) || 0 }))
    .filter((r) => r.name);

  if (clean.length) {
    const total = Math.round(clean.reduce((sum, r) => sum + r.percentage, 0) * 100) / 100;
    if (Math.abs(total - 100) > 0.01) {
      throw new AppError(`Nominee percentages must add up to 100% (currently ${total}%)`, 'VALIDATION');
    }
  }

  await tx(async () => {
    await run('DELETE FROM member_application_nominee WHERE application_no = ?', applicationNo);
    for (const r of clean) {
      const isNok = !!r.is_next_of_kin;
      await run(
        `INSERT INTO member_application_nominee (application_no, name, relationship, phone, percentage, is_next_of_kin)
         VALUES (?,?,?,?,?,?)`,
        applicationNo, r.name, r.relationship || null, r.phone || null, r.percentage, isNok ? 1 : 0,
      );
      if (isNok) {
        const exists = await one(
          'SELECT 1 FROM member_application_next_of_kin WHERE application_no = ? AND name = ?', applicationNo, r.name,
        );
        if (!exists) {
          await run(
            'INSERT INTO member_application_next_of_kin (application_no, name, relationship, phone) VALUES (?,?,?,?)',
            applicationNo, r.name, r.relationship || null, r.phone || null,
          );
        }
      }
    }
    await audit(user, 'APPLICATION_NOMINEES_UPDATE', 'member_application', applicationNo, { count: clean.length });
  });
}
