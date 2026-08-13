import 'server-only';
import { Resend } from 'resend';

/*
 * Thin mail-sending wrapper around Resend.
 *
 * A failed or unconfigured send must never block the workflow action that
 * triggered it — the on-screen notification and the document state change are
 * the things that actually matter. RESEND_API_KEY absent (e.g. a fresh clone
 * before the admin has configured it) just logs instead of sending.
 */

let client: Resend | null | undefined;

function getClient(): Resend | null {
  if (client !== undefined) return client;
  const key = process.env.RESEND_API_KEY;
  client = key ? new Resend(key) : null;
  return client;
}

export interface SendMailInput {
  to: string | string[];
  subject: string;
  html: string;
}

export async function sendMail({ to, subject, html }: SendMailInput): Promise<void> {
  const resend = getClient();
  const from = process.env.RESEND_FROM_EMAIL || 'notifications@example.com';
  if (!resend) {
    console.log('[mailer] RESEND_API_KEY not set — skipping send:', { to, subject });
    return;
  }
  try {
    await resend.emails.send({ from, to, subject, html });
  } catch (err) {
    console.error('[mailer] send failed', err);
  }
}

const appUrl = (): string => (process.env.APP_URL || 'http://localhost:3000').replace(/\/$/, '');

const wrapper = (title: string, bodyHtml: string, link: string): string => `
  <div style="font-family:Arial,Helvetica,sans-serif;max-width:520px;margin:0 auto;padding:24px;">
    <h2 style="margin:0 0 12px;">${title}</h2>
    ${bodyHtml}
    <p style="margin-top:24px;">
      <a href="${appUrl()}${link}" style="background:#0f7b52;color:#fff;padding:10px 18px;
        border-radius:6px;text-decoration:none;display:inline-block;">Open in SaccoDemo</a>
    </p>
  </div>`;

export function approvalRequestedEmail(documentLabel: string, requestedBy: string, link: string): string {
  return wrapper(
    'Approval requested',
    `<p><b>${documentLabel}</b> was submitted by <b>${requestedBy}</b> and is waiting for your decision.</p>`,
    link,
  );
}

export function approvalDecidedEmail(
  documentLabel: string, approved: boolean, decidedBy: string, comment: string | null, link: string,
): string {
  return wrapper(
    approved ? 'Request approved' : 'Request rejected',
    `<p><b>${documentLabel}</b> was ${approved ? 'approved' : 'rejected'} by <b>${decidedBy}</b>.</p>
     ${comment ? `<p style="color:#555;">"${comment}"</p>` : ''}`,
    link,
  );
}
