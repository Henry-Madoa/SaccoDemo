/*
 * Deposit / Withdrawal slip — AL Rep52204068 "Cash Deposit Receipt" / Rep52204069
 * "Cash Withdrawal". Built from a posted teller_transaction and rendered through the shared
 * document chrome in lib/documentPrint.ts, so the slip a member carries away matches the
 * receipt, the voucher and the statement.
 *
 * Used by BOTH the print-friendly page (/teller-slip/[no]) and the email sent to the member
 * after posting (lib/tellerTransactions.ts's emailSlip()).
 */
import { getTellerTransaction } from './tellerTransactions.ts';
import { formatDate } from './format.ts';
import { amountInWords } from './numberToWords.ts';
import { signatureFor } from './userSignatures.ts';
import { imageSrc } from './cloudinary.ts';
import {
  printBrand, documentMoney, currencyLabel, renderDocument,
} from './documentPrint.ts';
import type { PrintDocument } from './documentPrint.ts';
import type { TellerTransactionView } from './types.ts';

export { renderDocument };

export const slipSubject = (doc: TellerTransactionView): string =>
  `${doc.transaction_type === 'CASH_DEPOSIT' ? 'Cash Deposit Receipt' : 'Cash Withdrawal Advice'} — ${doc.no}`;

/** The posted transaction as a printable document, or null if it is not posted yet. */
export async function buildTellerSlipDocument(no: string): Promise<PrintDocument | null> {
  const doc = await getTellerTransaction(no);
  if (!doc || !doc.posted) return null;
  const brand = await printBrand();
  if (!brand) return null;
  const money = documentMoney(brand, brand.currency_code);

  // The slip is issued after posting, so account_balance already reflects this transaction.
  const isDeposit = doc.transaction_type === 'CASH_DEPOSIT';
  const balanceAfter = doc.account_balance;
  const balanceBefore = isDeposit
    ? balanceAfter - doc.amount + doc.charge_amount
    : balanceAfter + doc.amount + doc.charge_amount;
  const availableAfter = Math.max(balanceAfter - doc.account_hold_amount - doc.account_min_balance, 0);

  const tellerSignature = await signatureFor(doc.teller_username);

  return {
    brand,
    title: isDeposit ? 'Cash Deposit Receipt' : 'Cash Withdrawal Advice',
    status: { label: 'Posted', tone: 'ok' },
    parties: [{
      heading: isDeposit ? 'Deposited by' : 'Paid to',
      name: `${doc.member_first_name} ${doc.member_last_name}`,
      lines: [
        `Member No. ${doc.member_no}`,
        `Account ${doc.account_no} — ${doc.account_product_name}`,
        doc.transacted_by_name
          ? `Transacted by ${doc.transacted_by_name}${doc.transacted_by_id_no ? ` (ID ${doc.transacted_by_id_no})` : ''}`
          : '',
        isDeposit && doc.source_of_funds ? `Source of funds: ${doc.source_of_funds}` : '',
      ].filter(Boolean),
    }],
    meta: [
      { label: 'Document No.', value: doc.no },
      { label: 'Date', value: formatDate(doc.posted_at ? doc.posted_at.slice(0, 10) : null) },
      { label: 'Teller / Till', value: `${doc.teller_username} — ${doc.till_name}` },
      { label: isDeposit ? 'Amount Deposited' : 'Amount Withdrawn', value: money(doc.amount), strong: true },
    ],
    columns: [
      { key: 'item', label: 'Particulars' },
      { key: 'amount', label: 'Amount', align: 'right', width: '30%' },
    ],
    rows: [
      { cells: { item: isDeposit ? 'Cash deposited' : 'Cash withdrawn', amount: money(doc.amount) } },
      ...(doc.charge_amount
        ? [{ cells: { item: 'Transaction charge', amount: money(doc.charge_amount) } }]
        : []),
      { cells: { item: 'Book balance before', amount: money(balanceBefore) } },
      { strong: true, cells: { item: 'Book balance after', amount: money(balanceAfter) } },
      { cells: { item: 'Available balance', amount: money(availableAfter) } },
    ],
    totals: [
      { label: isDeposit ? 'Amount deposited' : 'Amount withdrawn', value: money(doc.amount), grand: true },
    ],
    amount_words: amountInWords(doc.amount, currencyLabel(brand.currency_code)),
    signatures: [
      {
        label: 'Member',
        block: {
          username: doc.member_no,
          full_name: `${doc.member_first_name} ${doc.member_last_name}`,
          src: imageSrc(doc.member_signature_image, { width: 180, height: 70, crop: 'fit' }),
        },
      },
      { label: 'Teller', block: tellerSignature },
    ],
    footnote: brand.footer || 'This slip is computer generated.',
  };
}
