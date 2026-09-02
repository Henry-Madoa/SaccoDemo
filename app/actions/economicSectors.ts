'use server';

import { revalidatePath } from 'next/cache';
import { requireAction } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  listSectors, listSubsectors, listSubsubsectors, saveSector, saveSubsector, saveSubsubsector,
  deleteSubsector, deleteSubsubsector,
} from '@/lib/economicSectors';
import type { ActionResult, EconomicSector, EconomicSubsector, EconomicSubsubsector, FormValues } from '@/lib/types';

const revalidate = () => {
  revalidatePath('/admin/pool/credit/sectors');
  revalidatePath('/loans');
  revalidatePath('/reports');
};

// Reference lookups for the loan card's cascading sector picker — available to anyone who can
// see loans at all, not just whoever manages the Economic Sectors master.
export async function sectorsForLoanForm(): Promise<ActionResult<EconomicSector[]>> {
  return actionResult(async () => {
    await requireAction('LOAN_READ');
    return listSectors();
  });
}

export async function subsectorsForSector(sectorCode: string): Promise<ActionResult<EconomicSubsector[]>> {
  return actionResult(async () => {
    await requireAction('LOAN_READ');
    return sectorCode ? listSubsectors(sectorCode) : [];
  });
}

export async function subsubsectorsForSubsector(sectorCode: string, subsectorCode: string): Promise<ActionResult<EconomicSubsubsector[]>> {
  return actionResult(async () => {
    await requireAction('LOAN_READ');
    return sectorCode && subsectorCode ? listSubsubsectors(sectorCode, subsectorCode) : [];
  });
}

export async function saveSectorRequest(values: FormValues): Promise<ActionResult<{ saved: true }>> {
  return actionResult(async () => {
    const user = await requireAction('ADMIN_POOL_SECTORS_MANAGE');
    await saveSector(String(values.code || ''), String(values.name || ''), values.originalCode ? String(values.originalCode) : null, user);
    revalidate();
    return { saved: true };
  });
}

export async function saveSubsectorRequest(values: FormValues): Promise<ActionResult<{ saved: true }>> {
  return actionResult(async () => {
    const user = await requireAction('ADMIN_POOL_SECTORS_MANAGE');
    await saveSubsector(
      String(values.sectorCode || ''), String(values.code || ''), String(values.name || ''),
      values.id ? Number(values.id) : null, user,
    );
    revalidate();
    return { saved: true };
  });
}

export async function saveSubsubsectorRequest(values: FormValues): Promise<ActionResult<{ saved: true }>> {
  return actionResult(async () => {
    const user = await requireAction('ADMIN_POOL_SECTORS_MANAGE');
    await saveSubsubsector(
      String(values.sectorCode || ''), String(values.subsectorCode || ''), String(values.code || ''),
      String(values.description || ''), values.id ? Number(values.id) : null, user,
    );
    revalidate();
    return { saved: true };
  });
}

export async function deleteSubsectorRequest(id: number): Promise<ActionResult<{ deleted: true }>> {
  return actionResult(async () => {
    const user = await requireAction('ADMIN_POOL_SECTORS_MANAGE');
    await deleteSubsector(id, user);
    revalidate();
    return { deleted: true };
  });
}

export async function deleteSubsubsectorRequest(id: number): Promise<ActionResult<{ deleted: true }>> {
  return actionResult(async () => {
    const user = await requireAction('ADMIN_POOL_SECTORS_MANAGE');
    await deleteSubsubsector(id, user);
    revalidate();
    return { deleted: true };
  });
}
