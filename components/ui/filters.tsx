'use client';

import { useEffect, useRef, useState, useTransition } from 'react';
import { usePathname, useRouter, useSearchParams } from 'next/navigation';
import type { SelectOption } from './field';

/**
 * Writes a value into the URL query string, which is what the page reads to
 * filter server-side. Keeping the filter in the URL means a filtered list is
 * shareable and survives a refresh — the old in-module `let q` did not.
 */
export function useQueryWriter() {
  const router = useRouter();
  const pathname = usePathname();
  const params = useSearchParams();
  const [pending, startTransition] = useTransition();

  const write = (key: string, value: string) => {
    const next = new URLSearchParams(params);
    if (value) next.set(key, value);
    else next.delete(key);
    startTransition(() => router.replace(`${pathname}?${next}`, { scroll: false }));
  };

  return { write, pending };
}

/** Debounced free-text filter bound to a query parameter. */
export function SearchInput({ paramName = 'q', placeholder, delay = 250 }: {
  paramName?: string; placeholder?: string; delay?: number;
}) {
  const params = useSearchParams();
  const { write } = useQueryWriter();
  const urlValue = params.get(paramName) ?? '';
  const [value, setValue] = useState(urlValue);
  const timer = useRef<ReturnType<typeof setTimeout> | undefined>(undefined);

  // Adopt the URL's value when the user navigates (back button, tab switch).
  useEffect(() => { setValue(urlValue); }, [urlValue]);

  useEffect(() => () => clearTimeout(timer.current), []);

  return (
    <input
      type="text"
      value={value}
      placeholder={placeholder}
      aria-label={placeholder}
      onChange={(e) => {
        const next = e.target.value;
        setValue(next);
        clearTimeout(timer.current);
        timer.current = setTimeout(() => write(paramName, next), delay);
      }}
    />
  );
}

/** Select bound to a query parameter, applied on change. */
export function SelectFilter({ paramName, options, allLabel = 'All', label }: {
  paramName: string; options: SelectOption[]; allLabel?: string; label?: string;
}) {
  const params = useSearchParams();
  const { write } = useQueryWriter();

  return (
    <select
      aria-label={label || allLabel}
      value={params.get(paramName) ?? ''}
      onChange={(e) => write(paramName, e.target.value)}
    >
      <option value="">{allLabel}</option>
      {options.map((o) => {
        const value = typeof o === 'object' && o !== null ? o.value : o;
        const text = typeof o === 'object' && o !== null ? o.label : o;
        return <option key={String(value)} value={value ?? ''}>{text}</option>;
      })}
    </select>
  );
}
