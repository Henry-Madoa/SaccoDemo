'use client';

import { useEffect, useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { MoneyInput } from '@/components/ui/field';
import { SearchableSelect } from '@/components/ui/searchable-select';
import { useRunAction } from '@/components/ui/run-action';
import { useFormat } from '@/components/ui/format-provider';
import { TableWrap, EmptyState } from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import {
  addChequeInstructionRequest, deleteChequeInstructionRequest, targetsForChequeInstruction,
} from '@/app/actions/chequeDeposits';
import type { ChequeInstructionView } from '@/lib/types';

type Target = { target_type: 'ACCOUNT' | 'LOAN'; id: number; label: string; balance: number };

function AddInstructionForm({ no, memberId, depositAccountId, remaining }: {
  no: string; memberId: number; depositAccountId: number; remaining: number;
}) {
  const { cur } = useFormat();
  const [targets, setTargets] = useState<Target[]>([]);
  const [key, setKey] = useState('');
  const [amount, setAmount] = useState('');

  useEffect(() => {
    let cancelled = false;
    targetsForChequeInstruction(memberId, depositAccountId).then((res) => {
      if (!cancelled && res.ok) setTargets(res.data);
    });
    return () => { cancelled = true; };
  }, [memberId, depositAccountId]);

  const sel = targets.find((t) => `${t.target_type}:${t.id}` === key);

  return (
    <>
      <SearchableSelect id="f_target" name="target" label="Credit / repay" required
        items={targets} getValue={(t) => `${t.target_type}:${t.id}`}
        getLabel={(t) => `${t.target_type === 'LOAN' ? 'Loan ' : 'Account '}${t.label}`}
        value={key} onChange={setKey}
        placeholder={targets.length ? 'Search the member’s accounts and loans…' : 'This member has no other account or open loan'}
        emptyText="No matching targets"
        hint={sel ? (sel.target_type === 'LOAN' ? `Loan balance ${cur(sel.balance)}` : `Account balance ${cur(sel.balance)}`) : undefined} />
      {/* Hidden fields the action reads */}
      <input type="hidden" name="targetType" value={sel?.target_type ?? ''} />
      <input type="hidden" name="targetId" value={sel?.id ?? ''} />

      <div className="field">
        <label htmlFor="f_amount">Amount <span className="req">*</span></label>
        <MoneyInput id="f_amount" value={amount} onChange={setAmount} required min={0}
          max={(remaining / 100).toFixed(2)} />
        <input type="hidden" name="amount" value={amount} />
        <div className="hint">Up to {cur(remaining)} may still be instructed</div>
      </div>
    </>
  );
}

export function ChequeInstructions({
  no, memberId, depositAccountId, instructions, cap, editable,
}: {
  no: string;
  memberId: number;
  depositAccountId: number;
  instructions: ChequeInstructionView[];
  cap: number;
  editable: boolean;
}) {
  const { cur } = useFormat();
  const { run, busy } = useRunAction();
  const [open, setOpen] = useState(false);
  const total = instructions.reduce((s, i) => s + i.amount, 0);
  const remaining = Math.max(cap - total, 0);

  return (
    <>
      {instructions.length ? (
        <TableWrap>
          <thead>
            <tr><th>#</th><th>Type</th><th>Target</th><th className="num">Amount</th><th className="num">Target balance</th>{editable ? <th className="num" /> : null}</tr>
          </thead>
          <tbody>
            {instructions.map((i, idx) => (
              <tr key={i.id}>
                <td>{idx + 1}</td>
                <td>{i.target_type === 'LOAN' ? 'Loan repayment' : 'Account credit'}</td>
                <td className="mono">{i.target_label}</td>
                <td className="num"><Money cents={i.amount} /></td>
                <td className="num"><Money cents={i.target_balance} /></td>
                {editable ? (
                  <td className="num">
                    <button type="button" className="btn sm ghost" disabled={busy}
                      onClick={() => run(() => deleteChequeInstructionRequest(no, i.id), {
                        confirm: { title: 'Remove this instruction?', message: 'It will not be applied when the cheque clears.', confirmLabel: 'Remove' },
                        successTitle: 'Instruction removed',
                      })}>Remove</button>
                  </td>
                ) : null}
              </tr>
            ))}
            <tr className="total">
              <td colSpan={3}><b>Total instructed</b></td>
              <td className="num"><b><Money cents={total} /></b></td>
              <td className="num muted-cell">of {cur(cap)}</td>
              {editable ? <td /> : null}
            </tr>
          </tbody>
        </TableWrap>
      ) : (
        <EmptyState icon="🧭" title="No instructions"
          sub={`When the cheque clears, the full ${cur(cap)} stays in the deposit account.`} />
      )}

      {editable ? (
        <div style={{ marginTop: 10 }}>
          <button type="button" className="btn sm" disabled={remaining <= 0} onClick={() => setOpen(true)}>
            Add instruction
          </button>
          {remaining <= 0 ? <span className="tiny muted-cell" style={{ marginLeft: 8 }}>Fully instructed</span> : null}
        </div>
      ) : null}

      {open ? (
        <FormModal
          title="Add cheque instruction"
          onClose={() => setOpen(false)}
          onSubmit={(values) => addChequeInstructionRequest(no, values)}
          submitLabel="Add"
          successTitle="Instruction added"
        >
          <AddInstructionForm no={no} memberId={memberId} depositAccountId={depositAccountId} remaining={remaining} />
        </FormModal>
      ) : null}
    </>
  );
}
