'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { DefinitionList } from '@/components/ui/primitives';
import { useFormat } from '@/components/ui/format-provider';
import { postDeposit, postWithdrawal } from '@/app/actions/savings';
import { DEPOSIT_CHANNELS, WITHDRAWAL_CHANNELS } from '@/lib/constants';
import { today } from '@/lib/format';
import type { Cents } from '@/lib/types';

/** The account fields the teller needs to see before posting. */
export interface TxnAccount {
  id: number;
  account_no: string;
  product_name: string;
  balance: Cents;
  hold_amount: Cents;
  min_balance: Cents;
  withdrawal_fee?: Cents;
  member_no: string;
  first_name: string;
  last_name: string;
}

export type TxnKind = 'DEPOSIT' | 'WITHDRAWAL';

function TxnForm({ kind, account, onClose }: {
  kind: TxnKind;
  account: TxnAccount;
  onClose: () => void;
}) {
  const { cur } = useFormat();
  const isDeposit = kind === 'DEPOSIT';
  const available = account.balance - account.hold_amount - account.min_balance;

  return (
    <FormModal
      title={`${isDeposit ? 'Deposit to' : 'Withdrawal from'} ${account.account_no}`}
      onClose={onClose}
      onSubmit={(values) => (isDeposit ? postDeposit : postWithdrawal)({ ...values, accountId: account.id })}
      submitLabel={`Post ${isDeposit ? 'deposit' : 'withdrawal'}`}
      successTitle="Posted"
      successDetail={(r) => `${r.txn.txn_ref} · new balance ${cur(r.balance)}`}
      resultStyle="popup"
    >
      <div className="card inset">
        <DefinitionList items={[
          ['Member', <>{account.first_name} {account.last_name}{' '}
            <span className="mono">({account.member_no})</span></>],
          ['Product', account.product_name],
          ['Current balance', <b key="bal">{cur(account.balance)}</b>],
          !isDeposit && ['Available to withdraw', (
            <>
              <b>{cur(Math.max(available, 0))}</b>
              {account.withdrawal_fee
                ? <span className="muted-cell"> (charge {cur(account.withdrawal_fee)})</span>
                : null}
            </>
          )],
        ]} />
      </div>

      <Field name="amount" label="Amount" type="currency" min={0} required />
      <Field name="channel" label="Channel" type="select"
        options={isDeposit ? DEPOSIT_CHANNELS : WITHDRAWAL_CHANNELS} />
      <Field name="valueDate" label="Value date" type="date" defaultValue={today()} />
      <Field name="description" label="Narration"
        defaultValue={isDeposit ? 'Cash deposit' : 'Counter withdrawal'} />

      <div className="note">
        Posts a balanced double-entry journal through the central posting engine.
      </div>
    </FormModal>
  );
}

/** Button pair used on the account list and the statement header. */
export function TxnButton({ kind, account, className = 'btn sm ghost' }: {
  kind: TxnKind;
  account: TxnAccount;
  className?: string;
}) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>
        {kind === 'DEPOSIT' ? 'Deposit' : 'Withdraw'}
      </button>
      {open ? <TxnForm kind={kind} account={account} onClose={() => setOpen(false)} /> : null}
    </>
  );
}
