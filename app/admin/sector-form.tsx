'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { useRunAction } from '@/components/ui/run-action';
import {
  saveSectorRequest, saveSubsectorRequest, saveSubsubsectorRequest,
  deleteSubsectorRequest, deleteSubsubsectorRequest,
} from '@/app/actions/economicSectors';
import type { EconomicSector, EconomicSubsector, EconomicSubsubsector } from '@/lib/types';

export function SectorFormButton({ row, className = 'btn', children }: {
  row?: EconomicSector | null; className?: string; children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          title={row ? `Edit sector — ${row.code}` : 'Add economic sector'}
          onClose={() => setOpen(false)}
          onSubmit={saveSectorRequest}
          submitLabel="Save"
          successTitle="Sector saved"
        >
          {row ? <input type="hidden" name="originalCode" value={row.code} /> : null}
          <Field name="code" label="Code" defaultValue={row?.code} required disabled={!!row} uppercase />
          <Field name="name" label="Name" defaultValue={row?.name} required />
        </FormModal>
      ) : null}
    </>
  );
}

export function SubsectorFormButton({ sectorCode, row, className = 'btn sm ghost', children }: {
  sectorCode: string; row?: EconomicSubsector | null; className?: string; children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          title={row ? `Edit sub-sector — ${row.code}` : 'Add sub-sector'}
          onClose={() => setOpen(false)}
          onSubmit={saveSubsectorRequest}
          submitLabel="Save"
          successTitle="Sub-sector saved"
        >
          <input type="hidden" name="sectorCode" value={sectorCode} />
          {row ? <input type="hidden" name="id" value={row.id} /> : null}
          <Field name="code" label="Code" defaultValue={row?.code} required uppercase />
          <Field name="name" label="Name" defaultValue={row?.name} required />
        </FormModal>
      ) : null}
    </>
  );
}

export function SubsubsectorFormButton({ sectorCode, subsectorCode, row, className = 'btn sm ghost', children }: {
  sectorCode: string; subsectorCode: string; row?: EconomicSubsubsector | null; className?: string; children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          title={row ? `Edit sub-subsector — ${row.code}` : 'Add sub-subsector'}
          onClose={() => setOpen(false)}
          onSubmit={saveSubsubsectorRequest}
          submitLabel="Save"
          successTitle="Sub-subsector saved"
        >
          <input type="hidden" name="sectorCode" value={sectorCode} />
          <input type="hidden" name="subsectorCode" value={subsectorCode} />
          {row ? <input type="hidden" name="id" value={row.id} /> : null}
          <Field name="code" label="Code" defaultValue={row?.code} required uppercase />
          <Field name="description" label="Description" defaultValue={row?.description} required />
        </FormModal>
      ) : null}
    </>
  );
}

/** A sub-subsector rendered as a removable chip: click the label to edit, the × to delete. */
export function SubsubsectorChip({ sectorCode, subsectorCode, row }: {
  sectorCode: string; subsectorCode: string; row: EconomicSubsubsector;
}) {
  const [open, setOpen] = useState(false);
  const { run, busy } = useRunAction();
  return (
    <>
      <span className="pill chip" title={row.description}>
        <button type="button" onClick={() => setOpen(true)} style={{ maxWidth: 320, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
          <span className="mono">{row.code}</span> {row.description}
        </button>
        <button type="button" aria-label={`Remove ${row.code}`} disabled={busy}
          onClick={() => run(() => deleteSubsubsectorRequest(row.id), {
            confirm: { title: `Remove ${row.code}?`, message: `"${row.description}" — refused if any loan is classified against it.`, confirmLabel: 'Remove' },
            successTitle: 'Removed',
          })}>
          ×
        </button>
      </span>
      {open ? (
        <FormModal
          title={`Edit sub-subsector — ${row.code}`}
          onClose={() => setOpen(false)}
          onSubmit={saveSubsubsectorRequest}
          submitLabel="Save"
          successTitle="Sub-subsector saved"
        >
          <input type="hidden" name="sectorCode" value={sectorCode} />
          <input type="hidden" name="subsectorCode" value={subsectorCode} />
          <input type="hidden" name="id" value={row.id} />
          <Field name="code" label="Code" defaultValue={row.code} required uppercase />
          <Field name="description" label="Description" defaultValue={row.description} required />
        </FormModal>
      ) : null}
    </>
  );
}

export function DeleteSubsectorButton({ id, className = 'btn sm ghost' }: { id: number; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => deleteSubsectorRequest(id), {
        confirm: { title: 'Remove this sub-sector?', message: 'Its sub-subsectors are removed too. Refused if any loan is classified against it.', confirmLabel: 'Remove' },
        successTitle: 'Removed',
      })}>
      {busy ? 'Working…' : 'Remove'}
    </button>
  );
}

export function DeleteSubsubsectorButton({ id, className = 'btn sm ghost' }: { id: number; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => deleteSubsubsectorRequest(id), {
        confirm: { title: 'Remove this sub-subsector?', message: 'Refused if any loan is classified against it.', confirmLabel: 'Remove' },
        successTitle: 'Removed',
      })}>
      {busy ? 'Working…' : 'Remove'}
    </button>
  );
}
