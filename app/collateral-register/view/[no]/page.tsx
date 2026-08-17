import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction } from '@/lib/session';
import {
  getCollateralRegisterRow, getAdjacentCollateralRegisterNos, listLinkedLoansForCollateral,
} from '@/lib/collateralRegister';
import { formatDate } from '@/lib/format';
import { Page } from '@/components/layout/page';
import {
  Card, CardHead, DefinitionList, EmptyState, Pill, Stat, TableWrap, Toolbar, Spacer,
} from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import { CardNav } from '@/components/ui/card-nav';

export default async function CollateralRegisterDetailPage({ params }: {
  params: Promise<{ no: string }>;
}) {
  const user = await requireAction('COLLATERAL_REGISTER_READ');
  const { no } = await params;
  const register = await getCollateralRegisterRow(no);
  if (!register) notFound();

  const [linkedLoans, { prevNo, nextNo }] = await Promise.all([
    listLinkedLoansForCollateral(no),
    getAdjacentCollateralRegisterNos(no),
  ]);

  return (
    <>
      <CardNav
        prevHref={prevNo ? `/collateral-register/view/${prevNo}` : null}
        nextHref={nextNo ? `/collateral-register/view/${nextNo}` : null}
      />
      <Page
        title={`${register.collateral_type_code || register.category} — ${register.member_first_name} ${register.member_last_name}`}
        crumb={`${register.no} · ${register.member_no}`}
        user={user}
      >
      <Toolbar>
        <Link href="/collateral-register" className="btn ghost sm">← All registered collateral</Link>
        <Link href={`/collateral-applications/view/${register.no}`} className="btn ghost sm">View application</Link>
        <Link href={`/members/${register.member_id}`} className="btn ghost sm">View member</Link>
        <Spacer />
      </Toolbar>

      <div className="grid g4 stack-2">
        <Stat label="Collateral value" value={<Money cents={register.collateral_value} decimals={0} />} />
        <Stat label="Guarantee (LTV)" value={<Money cents={register.guarantee} decimals={0} />} />
        <Stat label="Linked loan balance" value={<Money cents={register.linked_loan_balance} decimals={0} />} />
        <Stat label="Available cover" value={<Money cents={register.collateral_balance} decimals={0} />} foot={<Pill status={register.status} />} />
      </div>

      <div className="grid split-side-sm">
        <div>
          <Card>
            <CardHead title="Collateral details" />
            <DefinitionList items={[
              ['Register no.', <span className="mono" key="no">{register.no}</span>],
              ['Member', <>{register.member_first_name} {register.member_last_name} <span className="mono">({register.member_no})</span></>],
              ['Category', register.category === 'VEHICLE' ? 'Vehicle' : 'Real Estate'],
              ['Collateral type', register.collateral_type_code || '—'],
              ['Description', register.collateral_description || '—'],
              ['Serial / Reg. no.', <span className="mono" key="serial">{register.serial_reg_no || '—'}</span>],
              ['County', register.county_name || '—'],
              ['Posting date', register.posting_date ? formatDate(register.posting_date) : '—'],
            ]} />
          </Card>

          <Card>
            <CardHead title="Owner details" />
            <DefinitionList items={[
              ['Owner name', register.owner_name || '—'],
              ['Owner ID no.', register.owner_id_no || '—'],
              ['Owner phone no.', register.owner_phone_no || '—'],
            ]} />
          </Card>

          {register.category === 'VEHICLE' ? (
            <Card>
              <CardHead title="Vehicle details" />
              <DefinitionList items={[
                ['Insurance expiry date', register.insurance_expiry_date ? formatDate(register.insurance_expiry_date) : '—'],
                ['Car track subscription due', register.car_track_due_date ? formatDate(register.car_track_due_date) : '—'],
              ]} />
            </Card>
          ) : null}

          {register.collected_at ? (
            <Card>
              <CardHead title="Collected" />
              <DefinitionList items={[['Collected on', formatDate(register.collected_at)]]} />
            </Card>
          ) : null}
        </div>

        <div>
          <Card>
            <CardHead
              title="Linked loans"
              sub="Every live loan currently drawing cover from this collateral item"
            />
            {linkedLoans.length ? (
              <TableWrap>
                <thead>
                  <tr><th>Loan no.</th><th>Member</th><th>Product</th><th className="num">Balance secured</th></tr>
                </thead>
                <tbody>
                  {linkedLoans.map((l) => (
                    <tr key={l.loan_id}>
                      <td className="mono"><Link href={`/loans/view/${l.loan_id}`}>{l.loan_no}</Link></td>
                      <td>{l.member_first_name} {l.member_last_name} <span className="tiny mono">({l.member_no})</span></td>
                      <td>{l.product_name}</td>
                      <td className="num"><Money cents={l.current_balance} decimals={0} /></td>
                    </tr>
                  ))}
                </tbody>
              </TableWrap>
            ) : <EmptyState icon="🔗" title="No loans currently secured by this item" />}
          </Card>
        </div>
      </div>
      </Page>
    </>
  );
}
