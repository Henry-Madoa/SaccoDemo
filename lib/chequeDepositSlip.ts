/*
 * Cheque Deposit Slip — AL Rep52204082. The acknowledgement a member gets for a cheque banked
 * over the counter, rendered through the shared document chrome in lib/documentPrint.ts.
 *
 * Used by /cheque-deposits/view/[no]/slip.
 */
import { getChequeDeposit } from './chequeDeposits.ts';
import { formatDate } from './format.ts';
import { amountInWords } from './numberToWords.ts';
import { signatureFor } from './userSignatures.ts';
import { printBrand, documentMoney, currencyLabel, renderDocument } from './documentPrint.ts';
import type { PrintDocument } from './documentPrint.ts';

export { renderDocument };

export async function buildChequeDepositSlipDocument(no: string): Promise<PrintDocument | null> {
  const doc = await getChequeDeposit(no);
  if (!doc) return null;
  const brand = await printBrand();
  if (!brand) return null;
  const money = documentMoney(brand, brand.currency_code);
  const receivedBy = await signatureFor(doc.created_by);

  return {
    brand,
    title: 'Cheque Deposit Slip',
    subtitle: doc.express_cheque ? 'Express clearing' : null,
    status: {
      label: doc.status,
      tone: doc.status === 'Cleared' ? 'ok' : doc.status === 'Bounced' ? 'bad' : 'warn',
    },
    parties: [{
      heading: 'Deposited by',
      name: `${doc.member_first_name} ${doc.member_last_name}`,
      lines: [
        `Member No. ${doc.member_no}`,
        `Account ${doc.account_no} — ${doc.account_product_name}`,
      ],
    }, {
      heading: 'Drawer',
      name: doc.drawer_account_name || '—',
      lines: [
        [doc.drawer_bank, doc.drawer_branch].filter(Boolean).join(' — '),
        doc.drawer_account_no ? `A/C No. ${doc.drawer_account_no}` : '',
      ].filter(Boolean),
    }],
    meta: [
      { label: 'Document No.', value: doc.no },
      { label: 'Cheque Type', value: `${doc.cheque_type_code} — ${doc.description}` },
      { label: 'Cheque No.', value: doc.cheque_no || '—' },
      { label: 'Cheque Date', value: doc.cheque_date ? formatDate(doc.cheque_date) : '—' },
      { label: 'Deposit Date', value: formatDate(doc.deposit_date) },
      { label: 'Maturity Date', value: formatDate(doc.maturity_date) },
      { label: 'Express Clearing', value: doc.express_cheque ? 'Yes' : 'No' },
      { label: 'Amount', value: money(doc.amount), strong: true },
    ],
    columns: [
      { key: 'item', label: 'Particulars' },
      { key: 'amount', label: 'Amount', align: 'right', width: '30%' },
    ],
    rows: [{ cells: { item: `Cheque ${doc.cheque_no || ''} banked for collection`.trim(), amount: money(doc.amount) } }],
    totals: [{ label: 'Amount banked', value: money(doc.amount), grand: true }],
    amount_words: amountInWords(doc.amount, currencyLabel(brand.currency_code)),
    signatures: [
      { label: 'Depositor', block: null },
      { label: 'Received by', block: receivedBy },
    ],
    footnote: 'This is an acknowledgement of receipt only. Funds are available after the cheque '
      + 'clears on its maturity date.',
  };
}
