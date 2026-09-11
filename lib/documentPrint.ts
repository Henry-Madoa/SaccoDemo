/*
 * Business document printing — the shared chrome behind every printable Sales, Purchase and
 * Cash Management document.
 *
 * The AL application prints these through RDLC layouts (./ssrs/SalesInvoice.rdl,
 * PurchaseReceipt.rdl, PaymentVoucher.rdl, CustomerReceipt.rdl …), and every one of those
 * layouts is built the same way: company letterhead with the logo from Company Information, a
 * document title band, the trading party, a header/meta grid, the document lines, totals, the
 * amount spelled out in words, then the approver signatures pulled from User Setup.
 *
 * This module is that layout, once, as a view-model plus renderer:
 *
 *   buildX() -> PrintDocument -> renderDocument() -> a self-contained HTML fragment
 *
 * Callers (lib/salesDocumentPrint.ts, lib/purchaseDocumentPrint.ts, lib/paymentVoucherSlip.ts,
 * lib/receiptSlip.ts) only describe WHAT is on the paper; nothing about how it looks lives in
 * them. The output carries its own <style>, uses no external assets beyond the Cloudinary logo
 * and signature images, and is sized for A4 with `@page` margins, so "Print / Save as PDF" in
 * the browser produces the same page every time.
 */
import { all } from './db.ts';
import { getOrg, getTheme } from './org.ts';
import { imageSrc } from './cloudinary.ts';
import { formatDateTime, formatMoney } from './format.ts';
import { renderSignatureHtml, signaturesFor } from './userSignatures.ts';
import type { SignatureBlock, WorkflowDocumentType } from './types.ts';

export const esc = (s: unknown): string => String(s ?? '')
  .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

/** The letterhead — Company Information + the society's own theme colours. */
export interface PrintBrand {
  name: string;
  logo: string | null;
  address_lines: string[];
  contact_lines: string[];
  /** Bank / paybill an invoice asks to be settled to — AL's CompanyBankName / AccountNumber. */
  pay_to: string | null;
  footer: string | null;
  currency_code: string;
  currency_symbol: string;
  primary: string;
  accent: string;
}

/** A trading party block — "Bill to", "Vendor", "Pay to", "Received from". */
export interface PrintParty {
  heading: string;
  name: string;
  lines: string[];
}

export interface PrintMeta {
  label: string;
  value: string;
  /** Renders the value in the brand colour — used for the document total on the header grid. */
  strong?: boolean;
}

export interface PrintColumn {
  key: string;
  label: string;
  align?: 'left' | 'right' | 'center';
  width?: string;
  /** 'signature' prints the cell value as an image URL — a scanned signature where one is on
   *  file, otherwise the ruled line it replaces (the guarantor column on a loan application). */
  kind?: 'text' | 'signature';
}

export interface PrintRow {
  cells: Record<string, string>;
  /** A comment / narration line — printed lighter, spanning the whole table. */
  muted?: boolean;
  /** A carried-forward line — an opening or closing balance — printed bold on a tinted band. */
  strong?: boolean;
}

export interface PrintTotal {
  label: string;
  value: string;
  /** The grand total: reversed out in the brand colour. */
  grand?: boolean;
  /** A deduction — printed in brackets. */
  negative?: boolean;
}

export interface PrintSignature {
  label: string;
  block: SignatureBlock | null;
}

export interface PrintNote {
  heading: string;
  body: string;
}

/**
 * A further table under the main one, with its own heading — a document that states several
 * ledgers rather than one list of lines (the Member Statement's per-account and per-loan
 * activity). An invoice has no sections; it is all one table.
 */
export interface PrintSection {
  heading: string;
  sub?: string | null;
  /** Right-hand side of the section's heading bar — typically its closing balance. */
  badge?: string | null;
  columns: PrintColumn[];
  rows: PrintRow[];
  /** Shown in place of the table when the section has no rows. */
  empty?: string;
}

export interface PrintDocument {
  brand: PrintBrand;
  /** "SALES INVOICE", "PURCHASE RECEIPT (GRN)" … the title beside the letterhead. */
  title: string;
  subtitle?: string | null;
  /** Diagonal stamp across the page — "DRAFT", "PENDING APPROVAL", "COPY". */
  watermark?: string | null;
  /** A register too wide for portrait A4 — the P9 card, the banker's cheque schedule. */
  landscape?: boolean;
  status?: { label: string; tone: 'ok' | 'warn' | 'bad' | 'info' } | null;
  parties: PrintParty[];
  meta: PrintMeta[];
  columns: PrintColumn[];
  rows: PrintRow[];
  totals: PrintTotal[];
  /** Shown in place of the main table when the document has no lines. */
  empty?: string;
  /** Detail tables printed after the main one — see PrintSection. */
  sections?: PrintSection[];
  amount_words?: string | null;
  notes?: PrintNote[];
  signatures?: PrintSignature[];
  footnote?: string | null;
}

/**
 * The letterhead every printable document shares. Mirrors the AL reports' `CompanyInformation`
 * columns (Name, Picture, Address, Phone No., E-Mail, Home Page, Post Code), with the theme's
 * brand colours so a printed document matches the screen it was raised on.
 */
export async function printBrand(): Promise<PrintBrand | null> {
  const [org, theme] = await Promise.all([getOrg(), getTheme()]);
  if (!org) return null;
  return {
    name: org.name,
    logo: imageSrc(org.logo, { width: 320, height: 320, crop: 'fit' }),
    address_lines: [
      org.physical_address,
      [org.postal_address, org.city].filter(Boolean).join(', '),
      org.country,
    ].filter((l): l is string => !!l && !!l.trim()),
    contact_lines: [
      [org.phone_primary, org.phone_secondary].filter(Boolean).join(' / '),
      [org.email, org.website].filter(Boolean).join('   •   '),
    ].filter((l) => !!l.trim()),
    // What a payer needs to settle the invoice, in the order the AL Sales Invoice layout prints
    // it: who the account is held by, where it is, then how to reach it.
    pay_to: [
      org.bank_account_name ? `Account name: ${org.bank_account_name}` : null,
      org.bank_name ? `Bank: ${org.bank_name}` : null,
      org.bank_branch ? `Branch: ${org.bank_branch}` : null,
      org.bank_account_no ? `A/C No: ${org.bank_account_no}` : null,
      org.paybill_no ? `Paybill: ${org.paybill_no}` : null,
    ].filter(Boolean).join('\n') || null,
    footer: org.statement_footer,
    currency_code: org.currency_code,
    currency_symbol: org.currency_symbol,
    primary: theme.tokens['--brand-primary'] || '#0f7a52',
    accent: theme.tokens['--brand-accent'] || '#c9a227',
  };
}

/** What `amountInWords()` should call the currency — AL's "Amount To Words" codeunit takes the
 *  currency code and spells the name out in full. */
const CURRENCY_WORDS: Record<string, string> = {
  KES: 'Kenya Shillings', UGX: 'Uganda Shillings', TZS: 'Tanzania Shillings', RWF: 'Rwandan Francs',
  USD: 'US Dollars', EUR: 'Euro', GBP: 'Pounds Sterling',
};

export const currencyLabel = (code: string | null | undefined): string =>
  CURRENCY_WORDS[String(code ?? '').toUpperCase()] ?? String(code ?? '');

/** Money formatter for a document in `code` — the org's symbol for local currency, the ISO code
 *  itself for anything foreign, so a USD invoice never prints "KSh". */
export function documentMoney(brand: PrintBrand, code: string | null | undefined): (c: number) => string {
  const symbol = !code || code === brand.currency_code ? brand.currency_symbol : code;
  return (c: number): string => formatMoney(c, { symbol });
}

/**
 * Who signs the printout: whoever raised the document, then each approver who cleared it.
 *
 * The AL reports read this out of the Approval Entry table (Sender ID -> 1st approver, Approver
 * ID -> 2nd..4th); here the equivalent trail is workflow_task, one APPROVED row per step. A
 * signatory with nothing on file still prints the ruled line, so the paper never depends on an
 * administrator having got round to uploading a scan.
 */
export async function documentSignatories(
  documentType: WorkflowDocumentType,
  entityId: string,
  preparedBy: string | null | undefined,
  labels: { prepared: string; approved: string } = { prepared: 'Prepared by', approved: 'Approved by' },
): Promise<PrintSignature[]> {
  const decided = await all<{ decided_by: string }>(
    `SELECT decided_by FROM workflow_task
     WHERE document_type = ? AND entity_id = ? AND status = 'APPROVED' AND decided_by IS NOT NULL
     ORDER BY decided_at, id`,
    documentType, String(entityId),
  );
  const approvers = [...new Set(decided.map((d) => d.decided_by))].slice(0, 2);
  const blocks = await signaturesFor([preparedBy, ...approvers]);
  return [
    { label: labels.prepared, block: blocks.get(preparedBy?.trim() ?? '') ?? null },
    ...(approvers.length
      ? approvers.map((a, i) => ({
        label: approvers.length > 1 ? `${labels.approved} (${i + 1})` : labels.approved,
        block: blocks.get(a.trim()) ?? null,
      }))
      : [{ label: labels.approved, block: null }]),
  ];
}

/* ------------------------------------------------------------------------ rendering */

const align = (c: PrintColumn): string => `ta-${c.align ?? 'left'}`;

function headerBlock(doc: PrintDocument): string {
  const b = doc.brand;
  return `
  <header class="dp-head">
    <div class="dp-brand">
      ${b.logo ? `<img class="dp-logo" src="${esc(b.logo)}" alt="" />` : ''}
      <div class="dp-brand-text">
        <div class="dp-org">${esc(b.name)}</div>
        ${b.address_lines.map((l) => `<div class="dp-line">${esc(l)}</div>`).join('')}
        ${b.contact_lines.map((l) => `<div class="dp-line">${esc(l)}</div>`).join('')}
      </div>
    </div>
    <div class="dp-ident-box">
      <div class="dp-title">${esc(doc.title)}</div>
      ${doc.subtitle ? `<div class="dp-subtitle">${esc(doc.subtitle)}</div>` : ''}
      ${doc.status ? `<div class="dp-status dp-${doc.status.tone}">${esc(doc.status.label)}</div>` : ''}
    </div>
  </header>`;
}

function metaBlock(doc: PrintDocument, wide = false): string {
  if (!doc.meta.length) return '';
  // Beside a party the meta is a two-column table; spanning the page on its own (a register's
  // filter header) that would strand labels and values at opposite edges, so it wraps into
  // label-over-value cells instead.
  if (wide) {
    return `
  <div class="dp-meta-wide">
    ${doc.meta.map((m) => `
    <div class="dp-meta-item">
      <div class="dp-meta-k">${esc(m.label)}</div>
      <div class="dp-meta-v${m.strong ? ' dp-meta-strong' : ''}">${esc(m.value)}</div>
    </div>`).join('')}
  </div>`;
  }
  return `
  <table class="dp-meta">
    <tbody>
      ${doc.meta.map((m) => `
      <tr>
        <td class="dp-meta-k">${esc(m.label)}</td>
        <td class="dp-meta-v${m.strong ? ' dp-meta-strong' : ''}">${esc(m.value)}</td>
      </tr>`).join('')}
    </tbody>
  </table>`;
}

function partiesBlock(doc: PrintDocument): string {
  const parties = doc.parties.map((p) => `
    <div class="dp-party">
      <div class="dp-party-h">${esc(p.heading)}</div>
      <div class="dp-party-n">${esc(p.name)}</div>
      ${p.lines.filter(Boolean).map((l) => `<div class="dp-line">${esc(l)}</div>`).join('')}
    </div>`).join('');
  // With no trading party — a register or a schedule — the meta grid takes the full width
  // instead of sitting in a narrow column beside nothing.
  const meta = doc.meta.length
    ? `<div class="dp-party dp-party-meta${doc.parties.length ? '' : ' dp-meta-only'}">${metaBlock(doc, !doc.parties.length)}</div>`
    : '';
  if (!parties && !meta) return '';
  return `<section class="dp-parties">${parties}${meta}</section>`;
}

/** One line table — the document's own lines, or a section's. */
function tableHtml(columns: PrintColumn[], rows: PrintRow[], empty: string): string {
  const head = columns
    .map((c) => `<th class="${align(c)}"${c.width ? ` style="width:${c.width}"` : ''}>${esc(c.label)}</th>`)
    .join('');
  const noteKey = columns[1]?.key ?? columns[0].key;
  const body = rows.length
    ? rows.map((r) => {
      if (r.muted) {
        return `<tr class="dp-note-row"><td colspan="${columns.length}">${esc(r.cells[noteKey] ?? '')}</td></tr>`;
      }
      const cells = columns.map((c) => {
        const value = r.cells[c.key] ?? '';
        const body = c.kind === 'signature'
          ? (value ? `<img class="dp-cell-sig" src="${esc(value)}" alt="" />` : '<div class="dp-cell-rule"></div>')
          : esc(value);
        return `<td class="${align(c)}">${body}</td>`;
      }).join('');
      return `<tr class="${r.strong ? 'dp-strong-row' : ''}">${cells}</tr>`;
    }).join('')
    : `<tr><td class="dp-empty" colspan="${columns.length}">${esc(empty)}</td></tr>`;
  return `
  <table class="dp-lines">
    <thead><tr>${head}</tr></thead>
    <tbody>${body}</tbody>
  </table>`;
}

function linesBlock(doc: PrintDocument): string {
  if (!doc.columns.length) return '';
  return tableHtml(doc.columns, doc.rows, doc.empty ?? 'No lines on this document.');
}

function sectionsBlock(doc: PrintDocument): string {
  const sections = doc.sections ?? [];
  if (!sections.length) return '';
  return sections.map((s) => `
  <section class="dp-sec">
    <div class="dp-sec-h">
      <div>
        <div class="dp-sec-t">${esc(s.heading)}</div>
        ${s.sub ? `<div class="dp-sec-s">${esc(s.sub)}</div>` : ''}
      </div>
      ${s.badge ? `<div class="dp-sec-b">${esc(s.badge)}</div>` : ''}
    </div>
    ${tableHtml(s.columns, s.rows, s.empty ?? 'No activity in the selected period.')}
  </section>`).join('');
}

function totalsBlock(doc: PrintDocument): string {
  const totals = doc.totals.length ? `
    <table class="dp-totals">
      <tbody>
        ${doc.totals.map((t) => `
        <tr class="${t.grand ? 'dp-grand' : ''}">
          <td class="dp-t-k">${esc(t.label)}</td>
          <td class="dp-t-v">${t.negative ? `(${esc(t.value)})` : esc(t.value)}</td>
        </tr>`).join('')}
      </tbody>
    </table>` : '';
  const words = doc.amount_words ? `
    <div class="dp-words">
      <div class="dp-words-h">Amount in words</div>
      <div class="dp-words-b">${esc(doc.amount_words)}</div>
    </div>` : '';
  if (!totals && !words) return '';
  return `<section class="dp-foot-grid">${words || '<div></div>'}${totals}</section>`;
}

function notesBlock(doc: PrintDocument): string {
  const notes = (doc.notes ?? []).filter((n) => n.body && n.body.trim());
  if (!notes.length) return '';
  return `
  <section class="dp-notes">
    ${notes.map((n) => `
    <div class="dp-note">
      <div class="dp-note-h">${esc(n.heading)}</div>
      <div class="dp-note-b">${esc(n.body)}</div>
    </div>`).join('')}
  </section>`;
}

function signBlock(doc: PrintDocument): string {
  const sigs = doc.signatures ?? [];
  if (!sigs.length) return '';
  return `<section class="dp-sign">${sigs.map((s) => renderSignatureHtml(s.block, s.label)).join('')}</section>`;
}

/** The document body itself, without the stylesheet — see renderDocuments(). */
function documentBody(doc: PrintDocument): string {
  const b = doc.brand;
  return `
<div class="dp">
  ${doc.watermark ? `<div class="dp-watermark">${esc(doc.watermark)}</div>` : ''}
  ${headerBlock(doc)}
  <div class="dp-rule"></div>
  <div class="dp-rule-2"></div>
  ${partiesBlock(doc)}
  ${linesBlock(doc)}
  ${totalsBlock(doc)}
  ${sectionsBlock(doc)}
  ${notesBlock(doc)}
  ${signBlock(doc)}
  <footer class="dp-footer">
    <div>${esc(doc.footnote || b.footer || 'This is a computer-generated document.')}</div>
    <div>Printed ${esc(formatDateTime(new Date().toISOString()))}</div>
  </footer>
</div>`;
}

/**
 * Several documents as one printout — a batch of statements, one member per sheet. The
 * stylesheet is emitted once, since every document in a batch shares the same brand colours.
 */
export function renderDocuments(docs: PrintDocument[]): string {
  if (!docs.length) return '';
  return documentStyles(docs[0]) + docs.map(documentBody).join('\n');
}

/** One document — inline styles only, its own `@page` / `@media print` rules. */
export function renderDocument(doc: PrintDocument): string {
  return documentStyles(doc) + documentBody(doc);
}

function documentStyles(doc: PrintDocument): string {
  const b = doc.brand;
  return `
<style>
  @page { size: A4${doc.landscape ? ' landscape' : ''}; margin: 12mm 12mm 14mm; }
  .dp {
    --dp-primary: ${esc(b.primary)};
    --dp-accent: ${esc(b.accent)};
    --dp-ink: #16211d;
    --dp-muted: #667077;
    --dp-rule: #dfe4e2;
    font-family: "Segoe UI", Arial, Helvetica, sans-serif;
    color: var(--dp-ink);
    /* On screen the document is a sheet of paper on the app's own background — which may be
       dark — so it paints its own white ground rather than inheriting one. */
    background: #fff;
    max-width: ${doc.landscape ? '301mm' : '214mm'}; margin: 0 auto; padding: 12mm 12mm 8mm;
    border-radius: 2px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, .12), 0 10px 30px rgba(0, 0, 0, .09);
    font-size: 11.5px; line-height: 1.45; position: relative; overflow: hidden;
  }
  .dp * { box-sizing: border-box; }

  /* ---------------------------------------------------------------- letterhead */
  .dp-head { display: flex; justify-content: space-between; align-items: flex-start; gap: 16px; }
  .dp-brand { display: flex; gap: 12px; align-items: flex-start; min-width: 0; }
  .dp-logo { width: 66px; height: 66px; object-fit: contain; flex: none; }
  .dp-org { font-size: 19px; font-weight: 700; letter-spacing: .01em; color: var(--dp-primary);
    line-height: 1.2; margin-bottom: 3px; text-transform: uppercase; }
  .dp-line { font-size: 10.5px; color: var(--dp-muted); }

  .dp-ident-box { text-align: right; flex: none; }
  .dp-title { font-size: 17px; font-weight: 700; letter-spacing: .12em; text-transform: uppercase;
    color: var(--dp-ink); white-space: nowrap; }
  .dp-subtitle { font-size: 10px; color: var(--dp-muted); letter-spacing: .06em;
    text-transform: uppercase; margin-top: 2px; }
  .dp-status { display: inline-block; margin-top: 6px; padding: 2px 10px; border-radius: 999px;
    font-size: 9.5px; font-weight: 700; letter-spacing: .09em; text-transform: uppercase;
    border: 1px solid currentColor; }
  .dp-ok { color: #0f7a52; } .dp-warn { color: #b96b00; }
  .dp-bad { color: #c0392b; } .dp-info { color: #1d6fb8; }

  .dp-rule { height: 3px; margin-top: 9px; background: var(--dp-primary); }
  .dp-rule-2 { height: 1px; margin-bottom: 12px; background: var(--dp-accent); }

  /* ------------------------------------------------------------- parties / meta */
  .dp-parties { display: flex; gap: 12px; align-items: stretch; margin-bottom: 12px; }
  .dp-party { flex: 1 1 0; min-width: 0; padding: 8px 10px; border: 1px solid var(--dp-rule);
    border-radius: 4px; background: #fbfcfc; }
  .dp-party-h { font-size: 9px; font-weight: 700; letter-spacing: .1em; text-transform: uppercase;
    color: var(--dp-primary); margin-bottom: 3px; }
  .dp-party-n { font-size: 13px; font-weight: 700; margin-bottom: 2px; }
  .dp-party-meta { flex: 0 0 44%; padding: 4px 10px; background: #fff; }
  .dp-party-meta.dp-meta-only { flex: 1 1 100%; padding: 8px 10px; }
  .dp-meta-wide { display: flex; flex-wrap: wrap; gap: 6px 28px; }
  .dp-meta-item { min-width: 130px; }
  .dp-meta-item .dp-meta-k { font-size: 9px; font-weight: 700; letter-spacing: .09em;
    text-transform: uppercase; }
  .dp-meta-item .dp-meta-v { text-align: left; font-size: 12px; }
  .dp-cell-sig { display: block; max-width: 130px; max-height: 34px; object-fit: contain; }
  .dp-cell-rule { height: 26px; border-bottom: 1px solid #8b9490; min-width: 90px; }

  .dp-meta { width: 100%; border-collapse: collapse; }
  .dp-meta td { padding: 2.5px 0; font-size: 10.5px; vertical-align: top; }
  .dp-meta-k { color: var(--dp-muted); white-space: nowrap; padding-right: 10px; }
  .dp-meta-v { text-align: right; font-weight: 600; }
  .dp-meta-strong { color: var(--dp-primary); font-size: 12px; }

  /* --------------------------------------------------------------------- lines */
  .dp-lines { width: 100%; border-collapse: collapse; margin-bottom: 10px; }
  .dp-lines thead th { background: var(--dp-primary); color: #fff; font-size: 9.5px; font-weight: 700;
    letter-spacing: .07em; text-transform: uppercase; padding: 7px 8px; text-align: left;
    white-space: nowrap; }
  .dp-lines thead th.ta-right { text-align: right; }
  .dp-lines thead th.ta-center { text-align: center; }
  /* pre-line so a builder can stack two figures in one cell (the voucher's VAT / WHT column)
     with a newline, while ordinary text still wraps on its own. */
  .dp-lines tbody td { padding: 6px 8px; border-bottom: 1px solid var(--dp-rule); font-size: 11px;
    vertical-align: top; white-space: pre-line; }
  .dp-lines tbody tr:nth-child(even) td { background: #f7f9f8; }
  .dp-lines .ta-right { text-align: right; } .dp-lines .ta-center { text-align: center; }
  .dp-note-row td { color: var(--dp-muted); font-style: italic; }
  .dp-lines tbody tr.dp-strong-row td { font-weight: 700; background: #eef4f1;
    border-bottom: 1px solid #c9d6d0; }
  .dp-empty { text-align: center; color: var(--dp-muted); padding: 16px 8px; }

  /* ------------------------------------------------------------------ sections */
  .dp-sec { margin-top: 14px; page-break-inside: auto; }
  .dp-sec-h { display: flex; justify-content: space-between; align-items: baseline; gap: 12px;
    border-left: 3px solid var(--dp-accent); padding: 4px 10px; background: #f5f7f6;
    margin-bottom: 6px; }
  .dp-sec-t { font-size: 12.5px; font-weight: 700; }
  .dp-sec-s { font-size: 9.5px; color: var(--dp-muted); letter-spacing: .04em;
    text-transform: uppercase; }
  .dp-sec-b { font-size: 12.5px; font-weight: 700; color: var(--dp-primary); white-space: nowrap; }

  /* ------------------------------------------------------------ totals / words */
  .dp-foot-grid { display: flex; gap: 16px; align-items: flex-start; justify-content: space-between; }
  .dp-words { flex: 1 1 auto; padding: 8px 10px; border-left: 3px solid var(--dp-accent);
    background: #fbfaf5; align-self: stretch; display: flex; flex-direction: column;
    justify-content: center; }
  .dp-words-h { font-size: 9px; font-weight: 700; letter-spacing: .1em; text-transform: uppercase;
    color: var(--dp-muted); }
  .dp-words-b { font-size: 11.5px; font-style: italic; font-weight: 600; margin-top: 2px; }
  .dp-totals { flex: 0 0 46%; border-collapse: collapse; }
  .dp-totals td { padding: 4px 8px; font-size: 11.5px; border-bottom: 1px solid var(--dp-rule); }
  .dp-t-k { color: var(--dp-muted); }
  .dp-t-v { text-align: right; font-weight: 600; white-space: nowrap; }
  .dp-totals tr.dp-grand td { background: var(--dp-primary); color: #fff; font-weight: 700;
    font-size: 13px; border-bottom: none; padding: 7px 8px; }
  .dp-totals tr.dp-grand .dp-t-k { color: #fff; letter-spacing: .05em; text-transform: uppercase;
    font-size: 10px; }

  /* --------------------------------------------------------------------- notes */
  .dp-notes { margin-top: 12px; display: flex; gap: 12px; }
  .dp-note { flex: 1 1 0; padding: 7px 10px; border: 1px dashed var(--dp-rule); border-radius: 4px; }
  .dp-note-h { font-size: 9px; font-weight: 700; letter-spacing: .1em; text-transform: uppercase;
    color: var(--dp-muted); margin-bottom: 2px; }
  .dp-note-b { font-size: 10.5px; white-space: pre-wrap; }

  /* ---------------------------------------------------------------- signatures */
  .dp-sign { display: flex; justify-content: space-between; gap: 20px; margin-top: 26px;
    page-break-inside: avoid; }
  .dp .sig-block { flex: 1; min-width: 130px; }
  .dp .sig-block .sig-img { display: block; max-width: 170px; max-height: 48px; margin-bottom: 2px; }
  .dp .sig-block .sig-rule { height: 44px; border-bottom: 1px solid #8b9490; margin-bottom: 2px; }
  .dp .sig-block .sig-label { font-size: 9.5px; color: var(--dp-muted); padding-top: 3px;
    letter-spacing: .04em; text-transform: uppercase; }

  /* ------------------------------------------------------------------- footers */
  .dp-footer { margin-top: 18px; padding-top: 7px; border-top: 1px solid var(--dp-rule);
    display: flex; justify-content: space-between; gap: 12px; font-size: 9px; color: var(--dp-muted); }
  /* Centred on the sheet rather than the viewport, so the stamp lands the same way on screen
     and on paper however long the document runs. */
  .dp-watermark { position: absolute; inset: 0; display: flex; align-items: center;
    justify-content: center; font-size: 48px; font-weight: 800; letter-spacing: .12em;
    color: rgba(20,40,32,.07); transform: rotate(-24deg); pointer-events: none; z-index: 0;
    text-transform: uppercase; white-space: nowrap; }
  .dp > *:not(.dp-watermark) { position: relative; z-index: 1; }
  /* A batch printout (renderDocuments) — one document per sheet. */
  .dp + .dp { margin-top: 20px; }

  @media print {
    .dp + .dp { break-before: page; page-break-before: always; margin-top: 0; }
    .no-print { display: none !important; }
    body { margin: 0; background: #fff; }
    /* The @page margin above is the paper's margin — the sheet drops its screen padding. The
       screen-only overflow clip has to go too: a clipped box that spans pages loses the pages
       after the first. */
    .dp { max-width: none; font-size: 11px; padding: 0; box-shadow: none; border-radius: 0;
      overflow: visible; }
    .dp-lines thead { display: table-header-group; }
    .dp-lines tr, .dp-party, .dp-foot-grid { page-break-inside: avoid; }
    .dp-sec-h { page-break-after: avoid; break-after: avoid; }
    .dp-lines thead th, .dp-totals tr.dp-grand td, .dp-lines tbody tr:nth-child(even) td,
    .dp-lines tbody tr.dp-strong-row td, .dp-sec-h {
      -webkit-print-color-adjust: exact; print-color-adjust: exact;
    }
  }
</style>`;
}
