'use client';

import { useState, type ReactNode } from 'react';

export interface ClientTabDefinition {
  key: string;
  label: string;
}

/**
 * In-page tab switcher for Server Component content.
 *
 * Each panel is fetched and rendered on the server once; only the visibility
 * toggle runs on the client, so a 7-tab page doesn't need 7 round trips.
 */
export function ClientTabs({ tabs, initial, panels }: {
  tabs: ClientTabDefinition[];
  initial: string;
  panels: Record<string, ReactNode>;
}) {
  const [active, setActive] = useState(initial);

  return (
    <>
      <div className="tabs">
        {tabs.map((t) => (
          <button key={t.key} type="button" className={t.key === active ? 'active' : ''}
            onClick={() => setActive(t.key)}>
            {t.label}
          </button>
        ))}
      </div>
      {panels[active]}
    </>
  );
}
