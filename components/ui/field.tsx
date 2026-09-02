'use client';

import { useEffect, useRef, useState } from 'react';
import type { FormValues } from '@/lib/types';

export type FieldType =
  | 'text' | 'password' | 'number' | 'date' | 'time' | 'email' | 'select' | 'textarea' | 'checkbox' | 'currency';

export type SelectOption = string | { value: string | number | null; label: string };

export interface FieldProps {
  name: string;
  label: string;
  type?: FieldType;
  defaultValue?: string | number | null;
  options?: SelectOption[];
  hint?: string;
  required?: boolean;
  placeholder?: string;
  step?: string;
  min?: number | string;
  max?: number | string;
  maxLength?: number;
  rows?: number;
  disabled?: boolean;
  className?: string;
  /** Visually uppercases what the user types; the value itself is normalised server-side. */
  uppercase?: boolean;
  onChange?: (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => void;
}

/**
 * Labelled form control. Uncontrolled by design: the surrounding <form> is read
 * with FormData on submit, which keeps these forms as cheap as the string
 * templates they replace while still escaping values properly.
 */
export function Field({
  name, label, type = 'text', defaultValue = '', options, hint, required,
  placeholder, step, min, max, maxLength, rows, disabled, className, uppercase, onChange,
}: FieldProps) {
  const id = `f_${name}`;

  if (type === 'checkbox') {
    return (
      <div className="checkline">
        <input type="checkbox" name={name} id={id} defaultChecked={!!Number(defaultValue)} value="1" disabled={disabled}
          onChange={onChange} />
        <label htmlFor={id}>{label}</label>
      </div>
    );
  }

  if (type === 'currency') {
    return (
      <CurrencyField
        id={id} name={name} label={label} defaultValue={defaultValue} hint={hint} required={required}
        min={min} max={max} disabled={disabled} className={className} placeholder={placeholder}
      />
    );
  }

  let control;
  if (type === 'select') {
    control = (
      <select id={id} name={name} defaultValue={defaultValue ?? ''} required={required} disabled={disabled}
        onChange={onChange}>
        {(options || []).map((o) => {
          const value = typeof o === 'object' && o !== null ? o.value : o;
          const text = typeof o === 'object' && o !== null ? o.label : o;
          return <option key={String(value)} value={value ?? ''}>{text}</option>;
        })}
      </select>
    );
  } else if (type === 'textarea') {
    control = (
      <textarea id={id} name={name} rows={rows || 3} defaultValue={defaultValue ?? ''}
        placeholder={placeholder} maxLength={maxLength} disabled={disabled} />
    );
  } else {
    control = (
      <input id={id} name={name} type={type} defaultValue={defaultValue ?? ''} required={required}
        placeholder={placeholder} step={step} min={min} max={max} maxLength={maxLength} disabled={disabled}
        onChange={onChange} style={uppercase ? { textTransform: 'uppercase' } : undefined}
        autoComplete={type === 'password' ? 'new-password' : undefined} />
    );
  }

  return (
    <div className={`field ${className || ''}`}>
      <label htmlFor={id}>{label}{required ? <span className="req"> *</span> : null}</label>
      {control}
      {hint ? <div className="hint">{hint}</div> : null}
    </div>
  );
}

/** "1234567.5" -> "1,234,567.5". Groups only the integer part; leaves a trailing "." or
 *  partial decimal the user is mid-typing untouched. */
function groupThousands(raw: string): string {
  if (raw === '') return '';
  const neg = raw.startsWith('-');
  const body = neg ? raw.slice(1) : raw;
  const [int, ...rest] = body.split('.');
  const grouped = int.replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  const dec = rest.length ? `.${rest.join('')}` : (body.endsWith('.') ? '.' : '');
  return (neg ? '-' : '') + (grouped || (dec ? '0' : '')) + dec;
}

/** Settle a raw numeric string to exactly two decimal places ("100000" -> "100000.00"); left
 *  as-is when it isn't a finished number. Applied on mount and on blur so money reads like
 *  money at rest without fighting the user mid-type. */
export function toTwoDp(raw: string): string {
  if (raw === '' || raw === '-' || raw === '.' || raw.endsWith('.')) return raw;
  const n = Number(raw);
  return Number.isFinite(n) ? n.toFixed(2) : raw;
}

/** Strip anything that isn't part of a number: commas, stray symbols, extra dots/minuses. */
function sanitizeNumeric(s: string): string {
  let v = s.replace(/,/g, '').replace(/[^\d.-]/g, '').replace(/(?!^)-/g, '');
  const firstDot = v.indexOf('.');
  if (firstDot !== -1) v = v.slice(0, firstDot + 1) + v.slice(firstDot + 1).replace(/\./g, '');
  return v;
}

/**
 * A controlled money `<input>` — shows a thousands-separated value ("100,000.00") while its
 * `value`/`onChange` speak a clean numeric string ("100000"). Settles to two decimals on blur,
 * and enforces min/max through setCustomValidity so `form.reportValidity()` still blocks an
 * out-of-range amount. Used directly in grid cells (tariff matrices, journal lines); `Field
 * type="currency"` wraps it with a label + a hidden `name` input for FormData-based forms.
 */
export function MoneyInput({
  value, onChange, onBlur, id, name, required, disabled, placeholder, style, className, ariaLabel, min, max,
}: {
  value: string;
  onChange: (raw: string) => void;
  /** Fires after the value has settled to two decimals — e.g. a save-on-blur grid cell. */
  onBlur?: () => void;
  id?: string; name?: string; required?: boolean; disabled?: boolean; placeholder?: string;
  style?: React.CSSProperties; className?: string; ariaLabel?: string;
  min?: number | string; max?: number | string;
}) {
  const ref = useRef<HTMLInputElement>(null);
  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    let msg = '';
    if (value !== '' && value !== '.' && value !== '-' && !value.endsWith('.')) {
      const n = Number(value);
      if (Number.isNaN(n)) msg = 'Enter a valid amount';
      else if (min != null && n < Number(min)) msg = `Must be at least ${groupThousands(String(min))}`;
      else if (max != null && n > Number(max)) msg = `Cannot exceed ${groupThousands(String(max))}`;
    }
    el.setCustomValidity(msg);
  }, [value, min, max]);

  return (
    <input
      ref={ref} id={id} name={name} type="text" inputMode="decimal" autoComplete="off"
      required={required} disabled={disabled} placeholder={placeholder} style={style} className={className}
      aria-label={ariaLabel}
      value={groupThousands(value)}
      onChange={(e) => onChange(sanitizeNumeric(e.target.value))}
      onBlur={() => { onChange(toTwoDp(value)); onBlur?.(); }}
    />
  );
}

/** Field's `type="currency"` branch — a labelled MoneyInput backed by a hidden `name` input so
 *  the surrounding FormData-based form still submits a clean numeric string. */
function CurrencyField({
  id, name, label, defaultValue, hint, required, min, max, disabled, className, placeholder,
}: {
  id: string; name: string; label: string;
  defaultValue?: string | number | null;
  hint?: string; required?: boolean; min?: number | string; max?: number | string;
  disabled?: boolean; className?: string; placeholder?: string;
}) {
  const initial = defaultValue == null || defaultValue === '' ? '' : toTwoDp(String(defaultValue));
  const [raw, setRaw] = useState(initial);

  return (
    <div className={`field ${className || ''}`}>
      <label htmlFor={id}>{label}{required ? <span className="req"> *</span> : null}</label>
      <MoneyInput
        id={id} value={raw} onChange={setRaw}
        required={required} disabled={disabled} placeholder={placeholder} min={min} max={max}
      />
      <input type="hidden" name={name} value={raw} />
      {hint ? <div className="hint">{hint}</div> : null}
    </div>
  );
}

/**
 * Read a <form> into a plain object.
 * Unchecked checkboxes are absent from FormData, so every checkbox in the form
 * is normalised to 0/1 explicitly — otherwise clearing one would silently send
 * `undefined` and COALESCE would keep the old value.
 */
export function readForm(form: HTMLFormElement): FormValues {
  const out: FormValues = {};
  for (const [key, value] of new FormData(form).entries()) {
    if (typeof value === 'string') out[key] = value;
  }
  for (const el of form.querySelectorAll<HTMLInputElement>('input[type=checkbox][name]')) {
    out[el.name] = el.checked ? 1 : 0;
  }
  return out;
}
