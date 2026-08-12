'use client';

import { useNav } from './nav-context';

/** Hamburger that opens the sidebar drawer. Hidden by CSS above 900px. */
export function NavToggle() {
  const { open, toggle } = useNav();

  return (
    <button
      type="button"
      className="nav-toggle"
      onClick={toggle}
      aria-label={open ? 'Close navigation' : 'Open navigation'}
      aria-expanded={open}
      aria-controls="app-sidebar"
    >
      {/* Three bars that fold into a cross when the drawer is open. */}
      <span className={`bars ${open ? 'x' : ''}`} aria-hidden="true">
        <i /><i /><i />
      </span>
    </button>
  );
}
