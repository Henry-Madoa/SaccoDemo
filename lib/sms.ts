import 'server-only';

/*
 * Thin SMS-sending wrapper, shaped exactly like lib/mailer.ts.
 *
 * The AL reaches an SMS gateway through Codeunit "Notifications Management".SendSms; which gateway
 * is a per-deployment choice (Africa's Talking, Infobip, a bank's own aggregator), so this is a
 * seam rather than an integration: configure SMS_GATEWAY_URL and SMS_API_KEY and it posts there;
 * leave them unset and it logs instead.
 *
 * A failed or unconfigured send must never block the posting that triggered it — the money has
 * already moved and the document is already posted. A member who does not get their text can be
 * shown the receipt; a rolled-back posting is a far worse outcome.
 */

export interface SendSmsInput {
  /** The recipient's number. Normalised to E.164 against SMS_COUNTRY_CODE (default +254). */
  to: string;
  message: string;
  /** The sender ID the gateway should show — AL's SMSSource. */
  source?: string;
}

/**
 * Kenyan numbers are written locally as often as internationally, so `0722…`, `722…`,
 * `254722…` and `+254722…` all have to reach the same handset.
 */
export function normalisePhone(raw: string, countryCode = process.env.SMS_COUNTRY_CODE || '254'): string | null {
  const digits = String(raw ?? '').replace(/[^\d+]/g, '').replace(/^\+/, '');
  if (!digits) return null;
  if (digits.startsWith(countryCode)) return `+${digits}`;
  if (digits.startsWith('0')) return `+${countryCode}${digits.slice(1)}`;
  // A bare subscriber number, already missing both the trunk zero and the country code.
  if (digits.length >= 9 && digits.length <= 10) return `+${countryCode}${digits}`;
  return `+${digits}`;
}

export async function sendSms({ to, message, source }: SendSmsInput): Promise<void> {
  const url = process.env.SMS_GATEWAY_URL;
  const number = normalisePhone(to);
  if (!number) {
    console.log('[sms] no usable phone number — skipping send');
    return;
  }
  if (!url) {
    console.log('[sms] SMS_GATEWAY_URL not set — skipping send:', { to: number, message });
    return;
  }
  try {
    const res = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(process.env.SMS_API_KEY ? { Authorization: `Bearer ${process.env.SMS_API_KEY}` } : {}),
      },
      body: JSON.stringify({
        to: number,
        message,
        from: source || process.env.SMS_SENDER_ID || undefined,
      }),
    });
    if (!res.ok) console.error('[sms] gateway returned', res.status, await res.text().catch(() => ''));
  } catch (err) {
    console.error('[sms] send failed', err);
  }
}
