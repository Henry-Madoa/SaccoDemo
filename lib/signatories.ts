import { all, run, tx, audit } from './db.ts';
import type { Actor, MemberSignatory } from './types.ts';

export const listSignatories = (memberId: number): Promise<MemberSignatory[]> =>
  all<MemberSignatory>('SELECT * FROM member_signatory WHERE member_id = ? ORDER BY id', memberId);

export interface SignatoryDraft {
  identification_no?: string | null;
  name: string;
  designation?: string | null;
  date_of_birth?: string | null;
  email?: string | null;
  phone?: string | null;
}

/** Replaces a member's full signatory list with the submitted rows — nothing else references these rows. */
export async function replaceSignatories(memberId: number, rows: SignatoryDraft[], user: Actor): Promise<void> {
  const clean = rows.map((r) => ({ ...r, name: String(r.name || '').trim() })).filter((r) => r.name);

  await tx(async () => {
    await run('DELETE FROM member_signatory WHERE member_id = ?', memberId);
    for (const r of clean) {
      await run(
        `INSERT INTO member_signatory (member_id, identification_no, name, designation, date_of_birth, email, phone)
         VALUES (?,?,?,?,?,?,?)`,
        memberId, r.identification_no || null, r.name, r.designation || null,
        r.date_of_birth || null, r.email || null, r.phone || null,
      );
    }
    await audit(user, 'MEMBER_SIGNATORIES_UPDATE', 'member', memberId, { count: clean.length });
  });
}
