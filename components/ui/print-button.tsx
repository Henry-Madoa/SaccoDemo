'use client';

import type { ReactNode } from 'react';

export function PrintButton({ children = 'Print', className = 'btn ghost' }: {
  children?: ReactNode; className?: string;
}) {
  return (
    <button type="button" className={className} onClick={() => window.print()}>
      {children}
    </button>
  );
}
