'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { GlAccountSelect } from '@/components/ui/gl-account-select';
import { SearchableSelect } from '@/components/ui/searchable-select';
import { Pill, Spacer } from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import { saveMemberCategory } from '@/app/actions/pool';
import { CreateDefaultAccountsButton } from './create-default-accounts-modal';
import { MEMBER_CATEGORY_TYPES, MEMBER_CATEGORY_STATUSES } from '@/lib/constants';
import { humanise, toUnits } from '@/lib/format';
import type {
  GlAccount, MemberCategoryDefaultAccountRow, MemberCategoryWithUsage, SavingsProduct,
} from '@/lib/types';

interface DefaultAccountRow {
  savings_product_id: number | '';
  description: string;
}

const emptyRow = (): DefaultAccountRow => ({ savings_product_id: '', description: '' });

export function MemberCategoryFormButton({ category, defaultAccounts, accounts, savingsProducts, className = 'btn', children }: {
  category?: MemberCategoryWithUsage | null;
  defaultAccounts?: MemberCategoryDefaultAccountRow[];
  accounts: GlAccount[];
  savingsProducts: SavingsProduct[];
  className?: string;
  children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const c = category ?? null;
  const [regFeeAccountId, setRegFeeAccountId] = useState(String(c?.registration_fee_account_id ?? ''));
  // A brand-new category starts with no default accounts — only editing an
  // existing one seeds rows, and only the ones it actually has.
  const [rows, setRows] = useState<DefaultAccountRow[]>(() =>
    (defaultAccounts || []).map((d) => ({
      savings_product_id: d.savings_product_id,
      description: d.savings_product_name,
    })));

  const update = (i: number, productId: number | '') => {
    const product = savingsProducts.find((p) => p.id === productId);
    setRows((cur) => cur.map((r, k) => (k === i ? { savings_product_id: productId, description: product?.name || '' } : r)));
  };

  const remove = (i: number) =>
    setRows((cur) => cur.filter((_, k) => k !== i));

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          wide
          title={c ? `Edit ${c.description}` : 'New member category'}
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveMemberCategory(
            c ? c.id : null,
            values,
            rows.filter((r) => r.savings_product_id !== ''),
          )}
          submitLabel="Save category"
          successTitle="Category saved"
        >
          <div className="grid g3">
            <Field name="code" label="Category code" defaultValue={c?.code} required disabled={!!c}
              maxLength={20} uppercase />
            <Field name="description" label="Description" defaultValue={c?.description} required maxLength={80} />
            <Field name="category_type" label="Category type" type="select" required
              defaultValue={c?.category_type}
              options={MEMBER_CATEGORY_TYPES.map((t) => ({ value: t.value, label: t.label }))} />
            <Field name="registration_fee_sh" label="Registration fee" type="number" step="0.01"
              defaultValue={c ? toUnits(c.registration_fee) : 0} />
            <GlAccountSelect name="registration_fee_account_id" label="Registration fee GL account"
              accounts={accounts} value={regFeeAccountId} onChange={setRegFeeAccountId} />
            {c ? (
              <Field name="status" label="Status" type="select" defaultValue={c?.status}
                options={MEMBER_CATEGORY_STATUSES} />
            ) : null}
          </div>

          <table style={{ marginTop: 'calc(var(--sp)*1.5)' }}>
            <thead>
              <tr>
                <th>Savings product</th>
                <th>Default account name</th>
                <th style={{ width: 40 }} />
              </tr>
            </thead>
            <tbody>
              {rows.map((row, i) => (
                <tr key={i}>
                  <td>
                    <SearchableSelect name={`categoryDefaultAccountProduct${i}`} ariaLabel="Savings product"
                      items={savingsProducts} getValue={(p) => String(p.id)} getLabel={(p) => `${p.code} — ${p.name}`}
                      value={String(row.savings_product_id || '')}
                      onChange={(v) => update(i, v ? Number(v) : '')} />
                  </td>
                  <td>
                    <input type="text" value={row.description} disabled aria-label="Default account name" />
                  </td>
                  <td>
                    <button type="button" className="btn sm ghost" onClick={() => remove(i)}
                      aria-label="Remove row">×</button>
                  </td>
                </tr>
              ))}
              {!rows.length ? (
                <tr><td colSpan={3} className="tiny">No default accounts yet.</td></tr>
              ) : null}
            </tbody>
          </table>
          <div className="inline" style={{ marginTop: 10 }}>
            <button type="button" className="btn ghost sm" onClick={() => setRows((cur) => [...cur, emptyRow()])}>
              Add default account
            </button>
          </div>
        </FormModal>
      ) : null}
    </>
  );
}

/**
 * A member-category row in the Setup Pool table, expandable in place to show
 * its default accounts — the same inline pattern used for a county's
 * sub-counties, so the Member categories card is the single place both live.
 */
export function MemberCategoryRow({ category, defaultAccounts, accounts, savingsProducts }: {
  category: MemberCategoryWithUsage;
  defaultAccounts: MemberCategoryDefaultAccountRow[];
  accounts: GlAccount[];
  savingsProducts: SavingsProduct[];
}) {
  const [expanded, setExpanded] = useState(false);

  return (
    <>
      <tr>
        <td className="mono">
          <button type="button" className="btn sm ghost" aria-expanded={expanded}
            aria-label={expanded ? 'Collapse default accounts' : 'Expand default accounts'}
            onClick={() => setExpanded((v) => !v)}>
            {expanded ? '▾' : '▸'}
          </button>{' '}
          {category.code}
        </td>
        <td><b>{category.description}</b></td>
        <td>{humanise(category.category_type)}</td>
        <td className="num"><Money cents={category.registration_fee} /></td>
        <td className="mono tiny">{category.registration_fee_account_code || '—'}</td>
        <td className="num">{category.default_accounts}</td>
        <td className="num">{category.members}</td>
        <td><Pill status={category.status} /></td>
        <td className="num">
          <div className="inline" style={{ justifyContent: 'flex-end' }}>
            <CreateDefaultAccountsButton categoryId={category.id} categoryLabel={category.description} />
            <MemberCategoryFormButton
              category={category}
              defaultAccounts={defaultAccounts}
              accounts={accounts}
              savingsProducts={savingsProducts}
              className="btn sm ghost"
            >
              Edit
            </MemberCategoryFormButton>
          </div>
        </td>
      </tr>
      {expanded ? (
        <tr>
          <td colSpan={9} style={{ background: 'var(--surface-2)', padding: 0 }}>
            <div style={{ padding: '10px 10px 14px 40px' }}>
              <div className="inline" style={{ marginBottom: 8 }}>
                <span className="tiny">Default accounts for {category.description}</span>
                <Spacer />
                <MemberCategoryFormButton
                  category={category}
                  defaultAccounts={defaultAccounts}
                  accounts={accounts}
                  savingsProducts={savingsProducts}
                  className="btn sm ghost"
                >
                  Manage default accounts
                </MemberCategoryFormButton>
              </div>
              {defaultAccounts.length ? (
                <table>
                  <thead>
                    <tr><th>Savings product</th><th>Default account name</th></tr>
                  </thead>
                  <tbody>
                    {defaultAccounts.map((d) => (
                      <tr key={d.id}>
                        <td className="mono tiny">{d.savings_product_code} — {d.savings_product_name}</td>
                        <td>{d.description}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              ) : <div className="tiny">No default accounts yet.</div>}
            </div>
          </td>
        </tr>
      ) : null}
    </>
  );
}
