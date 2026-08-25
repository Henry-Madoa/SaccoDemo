'use client';

import type { FormValues } from '@/lib/types';

export type FieldType = 'text' | 'password' | 'number' | 'date' | 'email' | 'select' | 'textarea' | 'checkbox';

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
  placeholder, step, min, maxLength, rows, disabled, className, uppercase, onChange,
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
        placeholder={placeholder} step={step} min={min} maxLength={maxLength} disabled={disabled}
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
