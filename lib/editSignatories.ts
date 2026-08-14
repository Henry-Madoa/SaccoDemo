import { all, run, tx } from './db.ts';
import type { MemberEditSignatory } from './types.ts';

export const listEditSignatories = (editNo: string): Promise<MemberEditSignatory[]> =>
  all<MemberEditSignatory>('SELECT * FROM member_edit_signatory WHERE edit_no = ? ORDER BY id', editNo);

export interface SignatoryDraft {
  identification_no?: string | null;
  name: string;
  designation?: string | null;
  date_of_birth?: string | null;
  email?: string | null;
  phone?: string | null;
}

/** Replaces an edit request's full signatory list with the submitted rows — nothing else references these rows. */
export async function replaceEditSignatories(editNo: string, rows: SignatoryDraft[]): Promise<void> {
  const clean = rows.map((r) => ({ ...r, name: String(r.name || '').trim() })).filter((r) => r.name);

  await tx(async () => {
    await run('DELETE FROM member_edit_signatory WHERE edit_no = ?', editNo);
    for (const r of clean) {
      await run(
        `INSERT INTO member_edit_signatory
           (edit_no, identification_no, name, designation, date_of_birth, email, phone)
         VALUES (?,?,?,?,?,?,?)`,
        editNo, r.identification_no || null, r.name, r.designation || null,
        r.date_of_birth || null, r.email || null, r.phone || null,
      );
    }
  });
}
