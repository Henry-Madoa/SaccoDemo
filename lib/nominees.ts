import { one, all, run, tx, audit } from './db.ts';
import { AppError } from './errors.ts';
import type { Actor, MemberNextOfKin, MemberNominee } from './types.ts';

/* ------------------------------------------------------------------- next of kin */
export const listNextOfKin = (memberId: number): Promise<MemberNextOfKin[]> =>
  all<MemberNextOfKin>('SELECT * FROM member_next_of_kin WHERE member_id = ? ORDER BY id', memberId);

export interface NextOfKinDraft {
  name: string;
  relationship?: string | null;
  phone?: string | null;
}

/** Replaces a member's full next-of-kin list with the submitted rows — nothing else references these rows. */
export async function replaceNextOfKin(memberId: number, rows: NextOfKinDraft[], user: Actor): Promise<void> {
  const clean = rows.map((r) => ({ ...r, name: String(r.name || '').trim() })).filter((r) => r.name);

  await tx(async () => {
    await run('DELETE FROM member_next_of_kin WHERE member_id = ?', memberId);
    for (const r of clean) {
      await run(
        'INSERT INTO member_next_of_kin (member_id, name, relationship, phone) VALUES (?,?,?,?)',
        memberId, r.name, r.relationship || null, r.phone || null,
      );
    }
    await audit(user, 'MEMBER_NOK_UPDATE', 'member', memberId, { count: clean.length });
  });
}

/* --------------------------------------------------------------------- nominees */
export const listNominees = (memberId: number): Promise<MemberNominee[]> =>
  all<MemberNominee>('SELECT * FROM member_nominee WHERE member_id = ? ORDER BY id', memberId);

export interface NomineeDraft {
  name: string;
  relationship?: string | null;
  phone?: string | null;
  percentage: number | string;
  /** When set, the nominee is also added as a next-of-kin entry on save. */
  is_next_of_kin?: boolean | number;
}

/**
 * Replaces a member's full nominee list with the submitted rows.
 *
 * A non-empty set must add up to 100% — an empty set is fine, since nominating
 * beneficiaries is optional. A row with its "also next of kin" box checked adds
 * a next-of-kin entry too, skipping it if one with the same name already exists
 * so re-saving the form doesn't pile up duplicates.
 */
export async function replaceNominees(memberId: number, rows: NomineeDraft[], user: Actor): Promise<void> {
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
    await run('DELETE FROM member_nominee WHERE member_id = ?', memberId);
    for (const r of clean) {
      const isNok = !!r.is_next_of_kin;
      await run(
        `INSERT INTO member_nominee (member_id, name, relationship, phone, percentage, is_next_of_kin)
         VALUES (?,?,?,?,?,?)`,
        memberId, r.name, r.relationship || null, r.phone || null, r.percentage, isNok ? 1 : 0,
      );
      if (isNok) {
        const exists = await one(
          'SELECT 1 FROM member_next_of_kin WHERE member_id = ? AND name = ?', memberId, r.name,
        );
        if (!exists) {
          await run(
            'INSERT INTO member_next_of_kin (member_id, name, relationship, phone) VALUES (?,?,?,?)',
            memberId, r.name, r.relationship || null, r.phone || null,
          );
        }
      }
    }
    await audit(user, 'MEMBER_NOMINEES_UPDATE', 'member', memberId, { count: clean.length });
  });
}
