/*
 * Economic Sectors — AL Tab52204077 "Economic Sectors" / Tab52204078 "Economic Subsectors" /
 * Tab52204079 "Economic Sub-subsector". The three-level SASRA classification a loan carries
 * (loan.sector_code / sub_sector_code / sub_subsector_code) so the Sectorial Lending Return
 * (lib/sectorialLending.ts) can be produced.
 */
import { one, all, run, audit } from './db.ts';
import { AppError } from './errors.ts';
import type {
  Actor, EconomicSector, EconomicSubsector, EconomicSubsubsector, EconomicSectorTree,
} from './types.ts';

export const listSectors = (): Promise<EconomicSector[]> =>
  all<EconomicSector>('SELECT * FROM economic_sector ORDER BY code');

export const listSubsectors = (sectorCode: string): Promise<EconomicSubsector[]> =>
  all<EconomicSubsector>('SELECT * FROM economic_subsector WHERE sector_code = ? ORDER BY code', sectorCode);

export const listSubsubsectors = (sectorCode: string, subsectorCode: string): Promise<EconomicSubsubsector[]> =>
  all<EconomicSubsubsector>(
    'SELECT * FROM economic_subsubsector WHERE sector_code = ? AND subsector_code = ? ORDER BY code',
    sectorCode, subsectorCode,
  );

/** The whole classification tree, with a per-sector loan count — for the admin setup screen. */
export async function sectorTree(): Promise<EconomicSectorTree[]> {
  const [sectors, subs, subsubs, counts] = await Promise.all([
    listSectors(),
    all<EconomicSubsector>('SELECT * FROM economic_subsector ORDER BY sector_code, code'),
    all<EconomicSubsubsector>('SELECT * FROM economic_subsubsector ORDER BY sector_code, subsector_code, code'),
    all<{ sector_code: string; n: number }>(
      "SELECT sector_code, COUNT(*) AS n FROM loan WHERE sector_code IS NOT NULL GROUP BY sector_code",
    ),
  ]);
  const countBy = new Map(counts.map((c) => [c.sector_code, Number(c.n)]));
  return sectors.map((s) => ({
    ...s,
    loans: countBy.get(s.code) ?? 0,
    subsectors: subs.filter((ss) => ss.sector_code === s.code).map((ss) => ({
      ...ss,
      subsubsectors: subsubs.filter((sss) => sss.sector_code === s.code && sss.subsector_code === ss.code),
    })),
  }));
}

/** Resolve the three codes on a loan to their names — for the loan card / report. */
export async function resolveSectorNames(
  sectorCode: string | null, subSectorCode: string | null, subSubsectorCode: string | null,
): Promise<{ sector: string | null; subSector: string | null; subSubsector: string | null }> {
  if (!sectorCode) return { sector: null, subSector: null, subSubsector: null };
  const [s, ss, sss] = await Promise.all([
    one<{ name: string }>('SELECT name FROM economic_sector WHERE code = ?', sectorCode),
    subSectorCode
      ? one<{ name: string }>('SELECT name FROM economic_subsector WHERE sector_code = ? AND code = ?', sectorCode, subSectorCode)
      : Promise.resolve(undefined),
    subSectorCode && subSubsectorCode
      ? one<{ description: string }>(
          'SELECT description FROM economic_subsubsector WHERE sector_code = ? AND subsector_code = ? AND code = ?',
          sectorCode, subSectorCode, subSubsectorCode,
        )
      : Promise.resolve(undefined),
  ]);
  return { sector: s?.name ?? null, subSector: ss?.name ?? null, subSubsector: sss?.description ?? null };
}

/** Validates a (sector, sub-sector?, sub-subsector?) selection against the masters. */
export async function assertSectorSelection(
  sectorCode: string | null, subSectorCode: string | null, subSubsectorCode: string | null,
): Promise<void> {
  if (!sectorCode) {
    if (subSectorCode || subSubsectorCode) throw new AppError('Pick a sector before a sub-sector', 'VALIDATION');
    return;
  }
  if (!(await one('SELECT 1 FROM economic_sector WHERE code = ?', sectorCode))) {
    throw new AppError('Unknown economic sector', 'VALIDATION');
  }
  if (subSectorCode
    && !(await one('SELECT 1 FROM economic_subsector WHERE sector_code = ? AND code = ?', sectorCode, subSectorCode))) {
    throw new AppError('That sub-sector does not belong to the chosen sector', 'VALIDATION');
  }
  if (subSubsectorCode) {
    if (!subSectorCode) throw new AppError('Pick a sub-sector before a sub-subsector', 'VALIDATION');
    if (!(await one(
      'SELECT 1 FROM economic_subsubsector WHERE sector_code = ? AND subsector_code = ? AND code = ?',
      sectorCode, subSectorCode, subSubsectorCode,
    ))) {
      throw new AppError('That sub-subsector does not belong to the chosen sub-sector', 'VALIDATION');
    }
  }
}

/* --------------------------------------------------------------- setup CRUD */

export async function saveSector(code: string, name: string, originalCode: string | null, user: Actor): Promise<void> {
  const c = code.trim().toUpperCase();
  if (!c) throw new AppError('A sector code is required', 'VALIDATION');
  if (!name.trim()) throw new AppError('A sector name is required', 'VALIDATION');
  if (originalCode) {
    if (originalCode !== c) throw new AppError('A sector code cannot be changed', 'VALIDATION');
    await run('UPDATE economic_sector SET name = ? WHERE code = ?', name.trim(), c);
    await audit(user, 'ECONOMIC_SECTOR_UPDATE', 'economic_sector', c, {});
  } else {
    if (await one('SELECT 1 FROM economic_sector WHERE code = ?', c)) throw new AppError('That sector code already exists', 'DUPLICATE');
    await run(
      'INSERT INTO economic_sector (code, name, created_at, created_by) VALUES (?,?,?,?)',
      c, name.trim(), new Date().toISOString(), user.username,
    );
    await audit(user, 'ECONOMIC_SECTOR_CREATE', 'economic_sector', c, {});
  }
}

export async function saveSubsector(
  sectorCode: string, code: string, name: string, id: number | null, user: Actor,
): Promise<void> {
  const c = code.trim().toUpperCase();
  if (!sectorCode) throw new AppError('A sector is required', 'VALIDATION');
  if (!c) throw new AppError('A sub-sector code is required', 'VALIDATION');
  if (!name.trim()) throw new AppError('A sub-sector name is required', 'VALIDATION');
  const dup = await one<{ id: number }>(
    'SELECT id FROM economic_subsector WHERE sector_code = ? AND code = ?', sectorCode, c,
  );
  if (dup && dup.id !== id) throw new AppError('That sub-sector code already exists for this sector', 'DUPLICATE');
  if (id) {
    await run('UPDATE economic_subsector SET code = ?, name = ? WHERE id = ?', c, name.trim(), id);
  } else {
    await run('INSERT INTO economic_subsector (sector_code, code, name) VALUES (?,?,?)', sectorCode, c, name.trim());
  }
  await audit(user, id ? 'ECONOMIC_SUBSECTOR_UPDATE' : 'ECONOMIC_SUBSECTOR_CREATE', 'economic_subsector', id ?? c, { sectorCode });
}

export async function saveSubsubsector(
  sectorCode: string, subsectorCode: string, code: string, description: string, id: number | null, user: Actor,
): Promise<void> {
  const c = code.trim().toUpperCase();
  if (!sectorCode || !subsectorCode) throw new AppError('A sector and sub-sector are required', 'VALIDATION');
  if (!c) throw new AppError('A sub-subsector code is required', 'VALIDATION');
  if (!description.trim()) throw new AppError('A description is required', 'VALIDATION');
  const dup = await one<{ id: number }>(
    'SELECT id FROM economic_subsubsector WHERE sector_code = ? AND subsector_code = ? AND code = ?',
    sectorCode, subsectorCode, c,
  );
  if (dup && dup.id !== id) throw new AppError('That sub-subsector code already exists', 'DUPLICATE');
  if (id) {
    await run('UPDATE economic_subsubsector SET code = ?, description = ? WHERE id = ?', c, description.trim(), id);
  } else {
    await run(
      'INSERT INTO economic_subsubsector (sector_code, subsector_code, code, description) VALUES (?,?,?,?)',
      sectorCode, subsectorCode, c, description.trim(),
    );
  }
  await audit(user, id ? 'ECONOMIC_SUBSUBSECTOR_UPDATE' : 'ECONOMIC_SUBSUBSECTOR_CREATE', 'economic_subsubsector', id ?? c, { sectorCode, subsectorCode });
}

export async function deleteSubsector(id: number, user: Actor): Promise<void> {
  const row = await one<{ sector_code: string; code: string }>('SELECT sector_code, code FROM economic_subsector WHERE id = ?', id);
  if (!row) throw new AppError('Sub-sector not found', 'NOT_FOUND');
  const inUse = await one('SELECT 1 FROM loan WHERE sector_code = ? AND sub_sector_code = ? LIMIT 1', row.sector_code, row.code);
  if (inUse) throw new AppError('This sub-sector is used by a loan and cannot be removed', 'IN_USE');
  await run('DELETE FROM economic_subsubsector WHERE sector_code = ? AND subsector_code = ?', row.sector_code, row.code);
  await run('DELETE FROM economic_subsector WHERE id = ?', id);
  await audit(user, 'ECONOMIC_SUBSECTOR_DELETE', 'economic_subsector', id, {});
}

export async function deleteSubsubsector(id: number, user: Actor): Promise<void> {
  const row = await one<{ sector_code: string; subsector_code: string; code: string }>(
    'SELECT sector_code, subsector_code, code FROM economic_subsubsector WHERE id = ?', id,
  );
  if (!row) throw new AppError('Sub-subsector not found', 'NOT_FOUND');
  const inUse = await one(
    'SELECT 1 FROM loan WHERE sector_code = ? AND sub_sector_code = ? AND sub_subsector_code = ? LIMIT 1',
    row.sector_code, row.subsector_code, row.code,
  );
  if (inUse) throw new AppError('This sub-subsector is used by a loan and cannot be removed', 'IN_USE');
  await run('DELETE FROM economic_subsubsector WHERE id = ?', id);
  await audit(user, 'ECONOMIC_SUBSUBSECTOR_DELETE', 'economic_subsubsector', id, {});
}
