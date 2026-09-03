/*
 * Withholding Tax Certificate printout — AL Rep52203485. Split from lib/whtCertificate.ts so the
 * certificate creation / query logic stays free of the org.ts → cloudinary.ts ('server-only')
 * import chain (the fixture suite imports whtCertificate.ts directly).
 */
import { getOrg } from './org.ts';
import { amountInWords } from './numberToWords.ts';
import { formatDate, formatMoney } from './format.ts';
import { getWhtCertificate } from './whtCertificate.ts';
import type { WhtCertificateSlip } from './types.ts';

const esc = (s: unknown): string => String(s ?? '')
  .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

export async function buildWhtCertificateSlip(no: string): Promise<WhtCertificateSlip | null> {
  const cert = await getWhtCertificate(no);
  if (!cert) return null;
  const org = await getOrg();
  if (!org) return null;
  return {
    org_name: org.name,
    org_address: [org.physical_address, org.postal_address, org.city].filter(Boolean).join(' · '),
    org_pin: org.kra_pin,
    certificate_no: cert.no,
    certificate_date: cert.certificate_date,
    vendor_name: cert.vendor_name ?? '',
    vendor_pin: cert.vendor_pin,
    payment_voucher_no: cert.payment_voucher_no,
    gross_amount: cert.gross_amount,
    total_wht: cert.total_wht,
    total_wht_words: amountInWords(cert.total_wht, 'Kenya Shillings'),
    lines: cert.lines.map((l) => ({
      wht_code: l.wht_code, description: l.description ?? l.wht_code, rate: l.rate, base: l.base, wht_amount: l.wht_amount,
    })),
  };
}

export function renderWhtCertificateHtml(slip: WhtCertificateSlip): string {
  const money = (c: number): string => formatMoney(c, { symbol: 'KSh', code: 'KES' });
  const rows = slip.lines.map((l) => `
    <tr>
      <td>${esc(l.description)}</td>
      <td class="r">${l.rate}%</td>
      <td class="r">${money(l.base)}</td>
      <td class="r">${money(l.wht_amount)}</td>
    </tr>`).join('');
  return `
<style>
  .cert { font-family: Arial, Helvetica, sans-serif; max-width: 700px; margin: 0 auto; color: #111; }
  .cert .org { text-align: center; border-bottom: 2px solid #111; padding-bottom: 12px; margin-bottom: 6px; }
  .cert .org .name { font-size: 20px; font-weight: 700; }
  .cert .org .meta { font-size: 11px; color: #444; margin-top: 3px; }
  .cert .title { text-align: center; font-size: 16px; font-weight: 700; text-transform: uppercase;
    letter-spacing: .12em; margin: 14px 0; }
  .cert .info { display: flex; justify-content: space-between; font-size: 12px; margin-bottom: 12px; }
  .cert table { width: 100%; border-collapse: collapse; margin-top: 8px; }
  .cert th, .cert td { border: 1px solid #ccc; padding: 7px 9px; font-size: 12px; text-align: left; }
  .cert th { background: #f2f2f2; }
  .cert td.r, .cert th.r { text-align: right; }
  .cert tfoot td { font-weight: 700; }
  .cert .words { font-size: 12px; font-style: italic; margin: 10px 0 24px; }
  .cert .sign { display: flex; justify-content: space-between; margin-top: 46px; font-size: 12px; }
  .cert .sign div { width: 45%; border-top: 1px solid #111; padding-top: 4px; text-align: center; }
  @media print { .no-print { display: none !important; } body { margin: 0; } .cert { max-width: none; } }
</style>
<div class="cert">
  <div class="org">
    <div class="name">${esc(slip.org_name)}</div>
    ${slip.org_address ? `<div class="meta">${esc(slip.org_address)}</div>` : ''}
    ${slip.org_pin ? `<div class="meta">PIN: ${esc(slip.org_pin)}</div>` : ''}
  </div>
  <div class="title">Withholding Tax Certificate</div>
  <div class="info">
    <div>
      <div><strong>Certificate No.:</strong> ${esc(slip.certificate_no)}</div>
      <div><strong>Date:</strong> ${esc(formatDate(slip.certificate_date))}</div>
      <div><strong>Payment Voucher:</strong> ${esc(slip.payment_voucher_no)}</div>
    </div>
    <div>
      <div><strong>Paid to:</strong> ${esc(slip.vendor_name)}</div>
      ${slip.vendor_pin ? `<div><strong>Supplier PIN:</strong> ${esc(slip.vendor_pin)}</div>` : ''}
      <div><strong>Gross amount:</strong> ${money(slip.gross_amount)}</div>
    </div>
  </div>
  <table>
    <thead><tr><th>Nature of payment</th><th class="r">Rate</th><th class="r">Amount subject to WHT</th><th class="r">Tax withheld</th></tr></thead>
    <tbody>${rows}</tbody>
    <tfoot><tr><td colspan="3" class="r">Total tax withheld</td><td class="r">${money(slip.total_wht)}</td></tr></tfoot>
  </table>
  <div class="words">${esc(slip.total_wht_words)}</div>
  <div class="sign">
    <div>Authorised signature</div>
    <div>Official stamp</div>
  </div>
</div>`;
}
