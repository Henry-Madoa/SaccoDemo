import type { Metadata, Viewport } from 'next';
import type { ReactNode } from 'react';
import './globals.css';
import { ensureSeeded } from '@/lib/bootstrap';
import { getOrgBrand, getTheme, themeCss } from '@/lib/org';
import { FormatProvider } from '@/components/ui/format-provider';
import { ToastProvider } from '@/components/ui/toast';

export const dynamic = 'force-dynamic';

/**
 * `maximumScale` is deliberately left alone — a teller checking a figure on a
 * phone must be able to pinch-zoom the ledger.
 */
export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
};

export async function generateMetadata(): Promise<Metadata> {
  await ensureSeeded();
  const org = await getOrgBrand();
  return {
    title: `${org?.short_name || org?.name || 'SACCO'} — Core Banking System`,
    description: 'Core Banking & Management Information System',
    icons: {
      icon: "data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>🏦</text></svg>",
    },
  };
}

export default async function RootLayout({ children }: { children: ReactNode }) {
  await ensureSeeded();
  const [org, theme] = await Promise.all([getOrgBrand(), getTheme()]);

  return (
    <html lang="en">
      <head>
        {/*
          Theme tokens are rendered into the first byte of the document rather
          than fetched as a stylesheet, so there is no unstyled flash and the
          sign-in screen already wears the society's colours.
        */}
        <style id="theme-tokens" dangerouslySetInnerHTML={{ __html: themeCss(theme.tokens) }} />
      </head>
      <body>
        <FormatProvider org={org}>
          <ToastProvider>{children}</ToastProvider>
        </FormatProvider>
      </body>
    </html>
  );
}
