'use client';

import {
  createContext, useCallback, useContext, useEffect, useState, type ReactNode,
} from 'react';
import { usePathname } from 'next/navigation';

interface NavState {
  open: boolean;
  toggle: () => void;
  close: () => void;
}

const NavContext = createContext<NavState>({ open: false, toggle: () => {}, close: () => {} });

/**
 * Drives the off-canvas sidebar on phones and tablets.
 *
 * The toggle lives in the top bar and the drawer is a sibling of it, so the
 * open flag has to sit above both. Above the breakpoint the sidebar is always
 * visible and this state simply goes unread.
 */
export function NavProvider({ children }: { children: ReactNode }) {
  const [open, setOpen] = useState(false);
  const pathname = usePathname();

  const close = useCallback(() => setOpen(false), []);
  const toggle = useCallback(() => setOpen((o) => !o), []);

  // Tapping a nav link should navigate *and* dismiss the drawer.
  useEffect(() => { setOpen(false); }, [pathname]);

  useEffect(() => {
    if (!open) return;
    const onKey = (e: KeyboardEvent) => { if (e.key === 'Escape') setOpen(false); };
    document.addEventListener('keydown', onKey);
    // The drawer covers the page; letting the page scroll underneath it reads
    // as the whole app sliding away.
    const { overflow } = document.body.style;
    document.body.style.overflow = 'hidden';
    return () => {
      document.removeEventListener('keydown', onKey);
      document.body.style.overflow = overflow;
    };
  }, [open]);

  return <NavContext.Provider value={{ open, toggle, close }}>{children}</NavContext.Provider>;
}

export const useNav = (): NavState => useContext(NavContext);
