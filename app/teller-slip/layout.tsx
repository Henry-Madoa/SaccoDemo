import type { ReactNode } from 'react';

/** A deliberately chrome-less layout — the slip route is meant to be printed or saved as PDF,
 *  so it renders without the app shell. */
export default function Layout({ children }: { children: ReactNode }) {
  return <div style={{ padding: '24px 16px', background: '#fff', minHeight: '100vh' }}>{children}</div>;
}
