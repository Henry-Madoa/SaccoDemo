'use client';

import { useEffect, useRef, useState } from 'react';
import { useRouter } from 'next/navigation';
import { Card, CardHead, DefinitionList, Pill, TableWrap } from '@/components/ui/primitives';
import { Field, MoneyInput, readForm } from '@/components/ui/field';
import { MemberSelect } from '@/components/ui/member-select';
import { SearchableSelect } from '@/components/ui/searchable-select';
import { useToast } from '@/components/ui/toast';
import { Money } from '@/components/ui/money';
import { ChargesBreakdownButton } from '@/components/ui/charges-breakdown';
import { updateLoanApplication, memberDisbursementAccounts } from '@/app/actions/loans';
import { sectorsForLoanForm, subsectorsForSector, subsubsectorsForSubsector } from '@/app/actions/economicSectors';
import { calculateLoanProductCharges } from '@/lib/loans';
import { RECOVERY_MODES } from '@/lib/constants';
import { formatDate, humanise } from '@/lib/format';
import { toCents, toUnits } from '@/lib/format';
import type {
  EconomicSector, EconomicSubsector, EconomicSubsubsector, LoanFull, LoanProductWithCharges,
  Member, SavingsAccountWithProduct, CalculatedLoanCharge,
} from '@/lib/types';

/** Mirrors app/member-applications/view/[no]/info-cards.tsx's inline-editable card pattern —
 *  the same fields the New-application modal (application-form.tsx) captures, edited in place
 *  on the loan card instead of in a popup. lib/loanService.ts's update() needs every field
 *  (it isn't a partial update), so unlike the Employee/Member cards this stays a single section. */
export function LoanDetailsCard({ loan: l, members, products, computedCharges, canEdit }: {
  loan: LoanFull;
  members: Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>[];
  products: LoanProductWithCharges[];
  computedCharges: CalculatedLoanCharge[];
  canEdit: boolean;
}) {
  const router = useRouter();
  const toast = useToast();
  const formRef = useRef<HTMLFormElement>(null);
  const [editing, setEditing] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');

  const [memberId, setMemberId] = useState(String(l.member_id));
  const [productId, setProductId] = useState(String(l.product_id));
  const [principal, setPrincipal] = useState(toUnits(l.principal));
  const [termMonths, setTermMonths] = useState(String(l.term_months));
  const [accounts, setAccounts] = useState<SavingsAccountWithProduct[]>([]);
  const [disburseToAccountId, setDisburseToAccountId] = useState(String(l.disburse_to_account_id ?? ''));
  const [sectors, setSectors] = useState<EconomicSector[]>([]);
  const [sectorCode, setSectorCode] = useState(l.sector_code ?? '');
  const [subsectors, setSubsectors] = useState<EconomicSubsector[]>([]);
  const [subSectorCode, setSubSectorCode] = useState(l.sub_sector_code ?? '');
  const [subsubsectors, setSubsubsectors] = useState<EconomicSubsubsector[]>([]);
  const [subSubsectorCode, setSubSubsectorCode] = useState(l.sub_subsector_code ?? '');

  useEffect(() => {
    if (!editing) return;
    sectorsForLoanForm().then((res) => { if (res.ok) setSectors(res.data); });
  }, [editing]);
  useEffect(() => {
    let cancelled = false;
    if (!editing || !sectorCode) { setSubsectors([]); return; }
    subsectorsForSector(sectorCode).then((res) => { if (!cancelled && res.ok) setSubsectors(res.data); });
    return () => { cancelled = true; };
  }, [editing, sectorCode]);
  useEffect(() => {
    let cancelled = false;
    if (!editing || !sectorCode || !subSectorCode) { setSubsubsectors([]); return; }
    subsubsectorsForSubsector(sectorCode, subSectorCode).then((res) => { if (!cancelled && res.ok) setSubsubsectors(res.data); });
    return () => { cancelled = true; };
  }, [editing, sectorCode, subSectorCode]);
  useEffect(() => {
    let cancelled = false;
    if (!editing || !memberId) { setAccounts([]); return; }
    memberDisbursementAccounts(Number(memberId)).then((res) => {
      if (!cancelled && res.ok) setAccounts(res.data);
    });
    return () => { cancelled = true; };
  }, [editing, memberId]);

  const startEdit = () => {
    setMemberId(String(l.member_id)); setProductId(String(l.product_id)); setPrincipal(toUnits(l.principal));
    setTermMonths(String(l.term_months)); setDisburseToAccountId(String(l.disburse_to_account_id ?? ''));
    setSectorCode(l.sector_code ?? ''); setSubSectorCode(l.sub_sector_code ?? ''); setSubSubsectorCode(l.sub_subsector_code ?? '');
    setError(''); setEditing(true);
  };

  const product = products.find((p) => String(p.id) === productId);
  const principalCents = toCents(principal);
  const previewCharges = product && principalCents > 0
    ? calculateLoanProductCharges(product.charges, principalCents, Number(termMonths) || 0)
    : [];
  const previewChargesTotal = previewCharges.reduce((s, c) => s + c.amount, 0);

  const save = async () => {
    const form = formRef.current;
    if (!form || !form.reportValidity()) return;
    setBusy(true);
    setError('');
    try {
      const values = readForm(form);
      const res = await updateLoanApplication(l.id, values);
      if (!res.ok) { setError(res.error || 'Could not save'); return; }
      toast('Application updated', undefined, 'ok');
      setEditing(false);
      router.refresh();
    } finally {
      setBusy(false);
    }
  };

  return (
    <Card>
      <CardHead title="Facility details" sub={<>Status <Pill status={l.status} /></>}>
        {canEdit && !editing ? <button type="button" className="btn sm ghost" onClick={startEdit}>Edit</button> : null}
      </CardHead>

      {!editing ? (
        <DefinitionList items={[
          ['Loan number', <span className="mono" key="no">{l.loan_no}</span>],
          ['Member', <>{l.first_name} {l.last_name} <span className="mono">({l.member_no})</span></>],
          ['Product', l.product_name],
          ['Purpose', l.purpose || '—'],
          ['Economic sector', l.sector_code ? `${l.sector_code} — ${l.sector_name}` : '—'],
          ['Sub-sector', l.sub_sector_code ? `${l.sub_sector_code} — ${l.sub_sector_name}` : '—'],
          ['Sub-subsector', l.sub_subsector_code ? `${l.sub_subsector_code} — ${l.sub_subsector_name}` : '—'],
          ['Recovery mode', humanise(l.recovery_mode)],
          ['Applied', `${formatDate(l.applied_date)} by ${l.created_by || '—'}`],
          ['Approved', l.approved_date ? `${formatDate(l.approved_date)} by ${l.approved_by}` : '—'],
          l.rejected_reason ? ['Rejected because', l.rejected_reason] : null,
          ['Disbursed', formatDate(l.disbursed_date)],
          ['First instalment', formatDate(l.first_due_date)],
          ['Total interest', <Money cents={l.total_interest} key="ti" />],
          l.status === 'DISBURSED' || l.status === 'CLOSED'
            ? ['Charges recovered',
              <ChargesBreakdownButton key="fees" charges={computedCharges} totalOverride={l.fees_charged}
                label="Charges recovered at disbursement" />]
            : ['Estimated charges',
              <ChargesBreakdownButton key="fees" charges={computedCharges} label="Estimated charges" />],
          ['Principal repaid', <Money cents={l.principal_paid} key="pp" />],
          ['Interest repaid', <Money cents={l.interest_paid} key="ip" />],
        ]} />
      ) : (
        <>
          <form ref={formRef} onSubmit={(e) => e.preventDefault()}>
            <div className="grid g2">
              <MemberSelect id="f_memberId" name="memberId" members={members} value={memberId} onChange={setMemberId} required />
              <SearchableSelect id="f_productId" name="productId" label="Loan product" required
                items={products} getValue={(p) => String(p.id)}
                getLabel={(p) => `${p.name} (${p.interest_rate}% ${p.interest_method.toLowerCase()})`}
                value={productId} onChange={setProductId} placeholder="Search loan product…" emptyText="No matching products" />

              <div className="field">
                <label htmlFor="f_principal">Amount applied for <span className="req">*</span></label>
                <MoneyInput id="f_principal" name="principal" required disabled={!product} value={principal} onChange={setPrincipal} />
                <div className="hint">
                  {product
                    ? `${product.name} range: ${(product.min_amount / 100).toLocaleString()} – ${(product.max_amount / 100).toLocaleString()}`
                    : 'Choose a loan product above to enter an amount'}
                </div>
              </div>
              <div className="field">
                <label htmlFor="f_termMonths">Repayment period (months) <span className="req">*</span></label>
                <input id="f_termMonths" name="termMonths" type="number" required value={termMonths} onChange={(e) => setTermMonths(e.target.value)} />
              </div>
              <Field name="purpose" label="Purpose" placeholder="e.g. Business expansion" defaultValue={l.purpose ?? ''} />

              <div className="field">
                <label htmlFor="f_sectorCode">Economic sector</label>
                <select id="f_sectorCode" name="sectorCode" value={sectorCode}
                  onChange={(e) => { setSectorCode(e.target.value); setSubSectorCode(''); setSubSubsectorCode(''); }}>
                  <option value="">— Not classified —</option>
                  {sectors.map((s) => <option key={s.code} value={s.code}>{s.code} — {s.name}</option>)}
                </select>
              </div>
              <div className="field">
                <label htmlFor="f_subSectorCode">Sub-sector</label>
                <select id="f_subSectorCode" name="subSectorCode" value={subSectorCode} disabled={!sectorCode}
                  onChange={(e) => { setSubSectorCode(e.target.value); setSubSubsectorCode(''); }}>
                  <option value="">{sectorCode ? '— None —' : 'Pick a sector first'}</option>
                  {subsectors.map((s) => <option key={s.id} value={s.code}>{s.code} — {s.name}</option>)}
                </select>
              </div>
              <div className="field">
                <label htmlFor="f_subSubsectorCode">Sub-subsector</label>
                <select id="f_subSubsectorCode" name="subSubsectorCode" value={subSubsectorCode} disabled={!subSectorCode}
                  onChange={(e) => setSubSubsectorCode(e.target.value)}>
                  <option value="">{subSectorCode ? '— None —' : 'Pick a sub-sector first'}</option>
                  {subsubsectors.map((s) => <option key={s.id} value={s.code}>{s.code} — {s.description}</option>)}
                </select>
              </div>

              <SearchableSelect key={accounts.length} name="disburseToAccountId" label="Disburse to"
                items={accounts} getValue={(a) => String(a.id)} getLabel={(a) => `${a.account_no} — ${a.product_name}`}
                value={disburseToAccountId} onChange={setDisburseToAccountId}
                placeholder="Pay out through the bank" emptyText="No matching accounts" />
              <Field name="recoveryMode" label="Recovery mode" type="select" options={RECOVERY_MODES} defaultValue={l.recovery_mode} />
            </div>

            {previewCharges.length ? (
              <Card className="inset">
                <CardHead title="Loan charges" sub="Computed automatically from the product's charge parameters" />
                <TableWrap>
                  <thead><tr><th>Charge</th><th className="num">Amount</th></tr></thead>
                  <tbody>
                    {previewCharges.map((c) => (
                      <tr key={c.chargeId}>
                        <td>{c.chargeDescription || c.chargeCode}{c.prorated ? ' (prorated)' : ''}</td>
                        <td className="num"><Money cents={c.amount} /></td>
                      </tr>
                    ))}
                  </tbody>
                  <tfoot>
                    <tr><td>Total charges</td><td className="num"><b><Money cents={previewChargesTotal} /></b></td></tr>
                    <tr><td>Net amount payable</td><td className="num"><b><Money cents={principalCents - previewChargesTotal} /></b></td></tr>
                  </tfoot>
                </TableWrap>
              </Card>
            ) : null}
          </form>
          <div className="inline" style={{ marginTop: 'var(--sp)' }}>
            {error ? <div className="modal-error">{error}</div> : null}
            <button type="button" className="btn ghost sm" onClick={() => setEditing(false)} disabled={busy}>Cancel</button>
            <button type="button" className="btn sm" onClick={save} disabled={busy}>{busy ? 'Saving…' : 'Save'}</button>
          </div>
        </>
      )}
    </Card>
  );
}
