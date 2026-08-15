/*
 * Presentation helpers. Pure functions with no database or DOM access, so the
 * same code formats a figure on the server during SSR and in the browser after
 * hydration — which is what keeps the two renders byte-identical.
 */
import type { Cents } from './types.ts';

export interface FormatConfig {
  symbol: string;
  locale: string;
  code: string;
}

export interface MoneyOptions extends Partial<FormatConfig> {
  decimals?: number;
  showSymbol?: boolean;
}

export const DEFAULT_FORMAT: FormatConfig = { symbol: 'KSh', locale: 'en-KE', code: 'KES' };

/** Minor units -> "KSh 12,345.00". */
export function formatMoney(cents: Cents | null | undefined, opts: MoneyOptions = {}): string {
  const { symbol = DEFAULT_FORMAT.symbol, locale = DEFAULT_FORMAT.locale, decimals = 2, showSymbol = true } = opts;
  const value = Number(cents || 0) / 100;
  const prefix = showSymbol ? `${symbol} ` : '';
  return prefix + value.toLocaleString(locale, {
    minimumFractionDigits: decimals,
    maximumFractionDigits: decimals,
  });
}

/** Minor units -> "KSh 1.2M". For stat tiles and chart axes, where width is scarce. */
export function formatMoneyShort(cents: Cents | null | undefined, opts: Partial<FormatConfig> = {}): string {
  const { symbol = DEFAULT_FORMAT.symbol } = opts;
  const raw = Number(cents || 0);
  const v = Math.abs(raw) / 100;
  const sign = raw < 0 ? '-' : '';
  const prefix = `${symbol} `;
  if (v >= 1e9) return `${sign}${prefix}${(v / 1e9).toFixed(2)}B`;
  if (v >= 1e6) return `${sign}${prefix}${(v / 1e6).toFixed(2)}M`;
  if (v >= 1e3) return `${sign}${prefix}${(v / 1e3).toFixed(1)}K`;
  return `${sign}${prefix}${v.toFixed(0)}`;
}

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

export function formatDate(iso: string | null | undefined): string {
  if (!iso) return '—';
  const d = new Date(String(iso).length <= 10 ? `${iso}T00:00:00` : iso);
  if (Number.isNaN(d.getTime())) return String(iso);
  return `${String(d.getDate()).padStart(2, '0')} ${MONTHS[d.getMonth()]} ${d.getFullYear()}`;
}

export function formatDateTime(iso: string | null | undefined): string {
  if (!iso) return '—';
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return String(iso);
  return `${formatDate(iso)} ${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
}

/** "2026-08" -> "Aug '26". */
export function formatMonth(ym: string | null | undefined): string {
  if (!ym) return '';
  const [y, m] = String(ym).split('-');
  return `${MONTHS[Number(m) - 1]} '${String(y).slice(2)}`;
}

export const today = (): string => new Date().toISOString().slice(0, 10);

export const startOfYear = (): string => `${new Date().getFullYear()}-01-01`;

export const initials = (name: string | null | undefined): string =>
  String(name || '?').trim().split(/\s+/).slice(0, 2).map((x) => x[0]).join('').toUpperCase();

/** Shillings typed by a user -> integer cents. */
export const toCents = (v: string | number | null | undefined): Cents =>
  Math.round(Number(String(v ?? 0).replace(/,/g, '') || 0) * 100);

/** Integer cents -> the decimal string a number input expects. */
export const toUnits = (cents: Cents | null | undefined): string => (Number(cents || 0) / 100).toFixed(2);

export type Tone = '' | 'ok' | 'warn' | 'bad' | 'info' | 'accent';

const STATUS_TONE: Record<string, Tone> = {
  ACTIVE: 'ok', POSTED: 'ok', APPROVED: 'ok', DISBURSED: 'ok', PAID: 'ok', PERFORMING: 'ok', OPEN: 'ok',
  VERIFIED: 'ok', ALLOWED: 'ok', YES: 'ok', ELIGIBLE: 'ok',
  CLOSED: '', HEADER: '', RESTRICTED: '', ARCHIVED: '',
  PENDING: 'warn', DUE: 'warn', PARTIAL: 'warn', WATCH: 'warn', DORMANT: 'warn', APPLICATION: 'warn',
  SUBSTANDARD: 'warn', REFERRED: 'warn', 'PENDING APPROVAL': 'warn',
  REJECTED: 'bad', REVERSED: 'bad', SUSPENDED: 'bad', FROZEN: 'bad', DOUBTFUL: 'bad', LOSS: 'bad',
  WRITTEN_OFF: 'bad', 'WRITTEN OFF': 'bad', EXITED: 'bad', DISABLED: 'bad',
  // "Document Status" values (e.g. member_application.status) are Title Case, not SCREAMING_CASE.
  Open: 'ok', Approved: 'ok', Committed: 'ok', Fulfilled: 'ok', Cleared: 'ok', Received: 'ok',
  'Pending Approval': 'warn', 'Pending Prepayment': 'warn', Running: 'warn',
  Rejected: 'bad', Reversed: 'bad', Terminated: 'bad', Bounced: 'bad',
  Closed: '', Archived: '',
};

/** Maps a domain status to the pill tone. */
export const statusTone = (status: string | null | undefined): Tone =>
  STATUS_TONE[String(status ?? '')] ?? '';

/** "WRITTEN_OFF" -> "WRITTEN OFF". */
export const humanise = (s: string | null | undefined): string => String(s ?? '').replace(/_/g, ' ');

/** Byte count -> "1.4 MB", for attachment listings. */
export function formatBytes(bytes: number | null | undefined): string {
  const n = Number(bytes || 0);
  if (!n) return '—';
  if (n < 1024) return `${n} B`;
  if (n < 1024 * 1024) return `${(n / 1024).toFixed(0)} KB`;
  return `${(n / 1024 / 1024).toFixed(1)} MB`;
}
