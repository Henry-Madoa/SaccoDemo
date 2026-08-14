'use client';

import { useState, type ReactNode } from 'react';
import { Card } from './primitives';

export interface CollapsibleCardProps {
  title: ReactNode;
  sub?: ReactNode;
  /** Collapsed on first render — the default is expanded. */
  defaultCollapsed?: boolean;
  className?: string;
  children: ReactNode;
}

/** A Card whose header toggles the body open/closed on click — no separate chevron control. */
export function CollapsibleCard({ title, sub, defaultCollapsed = false, className, children }: CollapsibleCardProps) {
  const [collapsed, setCollapsed] = useState(defaultCollapsed);

  return (
    <Card className={className}>
      <button type="button" className="card-head card-head-toggle" aria-expanded={!collapsed}
        onClick={() => setCollapsed((c) => !c)}>
        <div>
          <h3>{title}</h3>
          {sub ? <div className="card-sub">{sub}</div> : null}
        </div>
      </button>
      <div className={`collapsible-body ${collapsed ? 'collapsed' : ''}`}>
        <div className="collapsible-body-inner">{children}</div>
      </div>
    </Card>
  );
}
