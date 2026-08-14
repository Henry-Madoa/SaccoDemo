import { all, run, tx } from './db.ts';
import type { MemberApplicationSignatory } from './types.ts';

export const listApplicationSignatories = (applicationNo: string): Promise<MemberApplicationSignatory[]> =>
  all<MemberApplicationSignatory>(
    'SELECT * FROM member_application_signatory WHERE application_no = ? ORDER BY id', applicationNo,
  );

export interface SignatoryDraft {
  identification_no?: string | null;
  name: string;
  designation?: string | null;
  date_of_birth?: string | null;
  email?: string | null;
  phone?: string | null;
}

/** Replaces an application's full signatory list with the submitted rows — nothing else references these rows. */
export async function replaceApplicationSignatories(applicationNo: string, rows: SignatoryDraft[]): Promise<void> {
  const clean = rows.map((r) => ({ ...r, name: String(r.name || '').trim() })).filter((r) => r.name);

  await tx(async () => {
    await run('DELETE FROM member_application_signatory WHERE application_no = ?', applicationNo);
    for (const r of clean) {
      await run(
        `INSERT INTO member_application_signatory
           (application_no, identification_no, name, designation, date_of_birth, email, phone)
         VALUES (?,?,?,?,?,?,?)`,
        applicationNo, r.identification_no || null, r.name, r.designation || null,
        r.date_of_birth || null, r.email || null, r.phone || null,
      );
    }
  });
}
