'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Card, CardHead, EmptyState, Pill, TableWrap } from '@/components/ui/primitives';
import type { AccountInstruction, AccountInstructionLine, AccountInstructionType, ActionResult } from '@/lib/types';

export interface InstructionDraft {
  instruction_type: AccountInstructionType;
  instruction: string;
}

interface Row extends InstructionDraft { key: number }
let seq = 0;
const emptyRow = (): Row => ({ key: ++seq, instruction_type: 'PREDEFINED', instruction: '' });

/** The add/remove-rows editor. `onSave` is the module's own server action bound to its document. */
export function AccountInstructionsFormButton({
  lines, predefined, onSave, className = 'btn sm ghost', children,
}: {
  lines: AccountInstructionLine[];
  predefined: Pick<AccountInstruction, 'description'>[];
  onSave: (rows: InstructionDraft[]) => Promise<ActionResult<unknown>>;
  className?: string;
  children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const [rows, setRows] = useState<Row[]>(() =>
    lines.length
      ? lines.map((l) => ({ key: ++seq, instruction_type: l.instruction_type, instruction: l.instruction }))
      : []);

  const update = (i: number, patch: Partial<Row>) =>
    setRows((cur) => cur.map((r, k) => (k === i ? { ...r, ...patch } : r)));
  const remove = (i: number) => setRows((cur) => cur.filter((_, k) => k !== i));

  const options = predefined.map((p) => p.description);

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          wide
          title="Account instructions"
          onClose={() => setOpen(false)}
          onSubmit={() => onSave(
            rows
              .filter((r) => r.instruction.trim())
              .map((r) => ({ instruction_type: r.instruction_type, instruction: r.instruction.trim() })),
          )}
          submitLabel="Save instructions"
          successTitle="Account instructions saved"
        >
          <p className="tiny muted-cell" style={{ marginBottom: 8 }}>
            Pick a standard instruction from the list, or choose <b>User defined</b> for a one-off.
            These guide the teller at the counter — they do not block a transaction.
          </p>
          <table>
            <thead>
              <tr>
                <th style={{ width: 150 }}>Type</th><th>Instruction</th><th style={{ width: 40 }} />
              </tr>
            </thead>
            <tbody>
              {rows.map((row, i) => (
                <tr key={row.key}>
                  <td>
                    <select
                      value={row.instruction_type} aria-label="Instruction type"
                      onChange={(e) => update(i, { instruction_type: e.target.value as AccountInstructionType, instruction: '' })}
                    >
                      <option value="PREDEFINED">Predefined</option>
                      <option value="USER_DEFINED">User defined</option>
                    </select>
                  </td>
                  <td>
                    {row.instruction_type === 'PREDEFINED' ? (
                      <select
                        value={row.instruction} aria-label="Instruction" required
                        onChange={(e) => update(i, { instruction: e.target.value })}
                      >
                        <option value="">— select —</option>
                        {options.map((o) => <option key={o} value={o}>{o}</option>)}
                        {row.instruction && !options.includes(row.instruction)
                          ? <option value={row.instruction}>{row.instruction} (inactive)</option>
                          : null}
                      </select>
                    ) : (
                      <input
                        type="text" value={row.instruction} aria-label="Instruction" required
                        placeholder="e.g. Do not pay any withdrawal without a call to the chairman"
                        onChange={(e) => update(i, { instruction: e.target.value })}
                      />
                    )}
                  </td>
                  <td>
                    <button type="button" className="btn sm ghost" aria-label="Remove row" onClick={() => remove(i)}>×</button>
                  </td>
                </tr>
              ))}
              {!rows.length ? <tr><td colSpan={3} className="tiny">No account instructions yet.</td></tr> : null}
            </tbody>
          </table>
          <div className="inline" style={{ marginTop: 10 }}>
            <button type="button" className="btn ghost sm" onClick={() => setRows((cur) => [...cur, emptyRow()])}>
              Add instruction
            </button>
          </div>
        </FormModal>
      ) : null}
    </>
  );
}

/** Read-only list of instructions with a colour-coded type chip. Used everywhere the instructions
 *  are only shown (member card, teller transaction card). */
export function AccountInstructionsList({ lines, dense }: { lines: AccountInstructionLine[]; dense?: boolean }) {
  if (!lines.length) {
    return <EmptyState icon="📋" title="No account instructions on file"
      sub={dense ? undefined : 'The member gave no special operating instructions'} />;
  }
  return (
    <TableWrap>
      <tbody>
        {lines.map((l) => (
          <tr key={l.id}>
            <td style={{ width: 120 }}>
              <Pill tone={l.instruction_type === 'PREDEFINED' ? 'info' : 'accent'}>
                {l.instruction_type === 'PREDEFINED' ? 'Standard' : 'Special'}
              </Pill>
            </td>
            <td>{l.instruction}</td>
          </tr>
        ))}
      </tbody>
    </TableWrap>
  );
}

/** Card wrapper — the tab content on the application / edit / member pages. */
export function AccountInstructionsPanel({
  lines, predefined, onSave, canManage, sub,
}: {
  lines: AccountInstructionLine[];
  predefined?: Pick<AccountInstruction, 'description'>[];
  onSave?: (rows: InstructionDraft[]) => Promise<ActionResult<unknown>>;
  canManage: boolean;
  sub?: string;
}) {
  return (
    <Card>
      <CardHead title="Account instructions" sub={sub ?? 'Standing operating instructions for this account'}>
        {canManage && onSave && predefined ? (
          <AccountInstructionsFormButton lines={lines} predefined={predefined} onSave={onSave}>
            Manage
          </AccountInstructionsFormButton>
        ) : null}
      </CardHead>
      <AccountInstructionsList lines={lines} />
    </Card>
  );
}
