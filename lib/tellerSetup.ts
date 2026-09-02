/*
 * Teller Setup — AL Tab52204042. Links a user to the cash account they operate: a TELLER to
 * their own till (bank_account.account_type = 'TILL'), or a TREASURY user to the branch vault
 * (account_type = 'TREASURY'). The capacity limits gate fosa_transaction posting
 * (lib/cashManagement.ts); approval_limit gates whether a teller_transaction auto-posts or is
 * routed for approval first (lib/tellerTransactions.ts).
 */
import { one, all, run, audit } from './db.ts';
import { AppError } from './errors.ts';
import type { Actor, BankAccountType, Cents, TellerSetup, TellerSetupWithAccount } from './types.ts';

const SELECT_ROW = `
  SELECT ts.*, b.code AS bank_account_code, b.name AS bank_account_name, b.account_type AS bank_account_type
  FROM teller_setup ts
  JOIN bank_account b ON b.id = ts.bank_account_id`;

export const listTellerSetups = (): Promise<TellerSetupWithAccount[]> =>
  all<TellerSetupWithAccount>(`${SELECT_ROW} ORDER BY ts.setup_type, ts.user_username`);

export const getTellerSetup = (
  username: string, setupType: 'TELLER' | 'TREASURY',
): Promise<TellerSetupWithAccount | undefined> =>
  one<TellerSetupWithAccount>(
    `${SELECT_ROW} WHERE ts.user_username = ? AND ts.setup_type = ?`, username, setupType,
  );

/** The acting user's own till setup — thrown-on-missing so a caller can `TestField`-style
 *  demand it (AL: 'You are not setup as a teller'). */
export async function requireTellerSetup(username: string): Promise<TellerSetupWithAccount> {
  const row = await getTellerSetup(username, 'TELLER');
  if (!row) throw new AppError('You are not set up as a teller — ask an administrator to add a Teller Setup for you', 'NO_TELLER_SETUP');
  return row;
}

export const tellerSetupForUser = (username: string): Promise<TellerSetupWithAccount | undefined> =>
  getTellerSetup(username, 'TELLER');

export const treasurySetupForUser = (username: string): Promise<TellerSetupWithAccount | undefined> =>
  getTellerSetup(username, 'TREASURY');

/** Whichever Teller Setup owns a given bank account (used by the capacity checks to look up the
 *  right max/min limits for a source or destination account). */
export const setupForBankAccount = (bankAccountId: number): Promise<TellerSetup | undefined> =>
  one<TellerSetup>('SELECT * FROM teller_setup WHERE bank_account_id = ? LIMIT 1', bankAccountId);

export const hasAnyTellerSetups = async (): Promise<boolean> =>
  !!(await one('SELECT 1 FROM teller_setup LIMIT 1'));

export interface TellerSetupInput {
  userUsername: string;
  setupType: 'TELLER' | 'TREASURY';
  bankAccountId: number;
  maxCapacity: Cents;
  minCapacity: Cents;
  approvalLimit: Cents;
}

const REQUIRED_ACCOUNT_TYPE: Record<'TELLER' | 'TREASURY', BankAccountType> = {
  TELLER: 'TILL',
  TREASURY: 'TREASURY',
};

async function assertValid(input: TellerSetupInput): Promise<void> {
  if (!input.userUsername?.trim()) throw new AppError('A user is required', 'VALIDATION');
  if (!['TELLER', 'TREASURY'].includes(input.setupType)) throw new AppError('Invalid setup type', 'VALIDATION');
  if (!(await one('SELECT 1 FROM app_user WHERE username = ?', input.userUsername))) {
    throw new AppError('That user does not exist', 'VALIDATION');
  }
  const acct = await one<{ account_type: BankAccountType }>(
    'SELECT account_type FROM bank_account WHERE id = ?', input.bankAccountId,
  );
  if (!acct) throw new AppError('Cash account not found', 'NOT_FOUND');
  const need = REQUIRED_ACCOUNT_TYPE[input.setupType];
  if (acct.account_type !== need) {
    throw new AppError(`A ${input.setupType} must be linked to a ${need} cash account`, 'VALIDATION');
  }
  if (input.minCapacity > input.maxCapacity && input.maxCapacity > 0) {
    throw new AppError('Minimum capacity cannot exceed maximum capacity', 'VALIDATION');
  }
}

export async function upsertTellerSetup(input: TellerSetupInput, user: Actor): Promise<{ id: number }> {
  await assertValid(input);
  const existing = await one<{ id: number }>(
    'SELECT id FROM teller_setup WHERE user_username = ? AND setup_type = ?',
    input.userUsername, input.setupType,
  );
  if (existing) {
    await run(
      `UPDATE teller_setup SET bank_account_id = ?, max_capacity = ?, min_capacity = ?, approval_limit = ?
       WHERE id = ?`,
      input.bankAccountId, Math.round(input.maxCapacity), Math.round(input.minCapacity),
      Math.round(input.approvalLimit), existing.id,
    );
    await audit(user, 'TELLER_SETUP_UPDATE', 'teller_setup', existing.id, { user: input.userUsername });
    return { id: existing.id };
  }
  const info = await run(
    `INSERT INTO teller_setup (user_username, setup_type, bank_account_id, max_capacity, min_capacity, approval_limit, created_at, created_by)
     VALUES (?,?,?,?,?,?,?,?)`,
    input.userUsername, input.setupType, input.bankAccountId, Math.round(input.maxCapacity),
    Math.round(input.minCapacity), Math.round(input.approvalLimit), new Date().toISOString(), user.username,
  );
  await audit(user, 'TELLER_SETUP_CREATE', 'teller_setup', info.lastInsertRowid, { user: input.userUsername });
  return { id: Number(info.lastInsertRowid) };
}

export async function deleteTellerSetup(id: number, user: Actor): Promise<void> {
  const before = await one<{ user_username: string }>('SELECT user_username FROM teller_setup WHERE id = ?', id);
  if (!before) throw new AppError('Teller Setup not found', 'NOT_FOUND');
  await run('DELETE FROM teller_setup WHERE id = ?', id);
  await audit(user, 'TELLER_SETUP_DELETE', 'teller_setup', id, { user: before.user_username });
}
