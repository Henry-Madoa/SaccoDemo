import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requirePerm, currentCan } from '@/lib/session';
import { getMemberDetail } from '@/lib/members';
import { listActiveSavingsProducts } from '@/lib/admin';
import { getDimensionCaptions } from '@/lib/org';
import { listAttachments } from '@/lib/attachments';
import { imageSrc, isConfigured } from '@/lib/cloudinary';
import { formatDate } from '@/lib/format';
import { Page } from '@/components/layout/page';
import {
  Card, DefinitionList, EmptyState, Pill, Stat, TableWrap, Toolbar, Spacer,
} from '@/components/ui/primitives';
import { CollapsibleCard } from '@/components/ui/collapsible-card';
import { Money, SignedMoney } from '@/components/ui/money';
import { OpenAccountButton } from './open-account-button';
import { MemberPhoto } from './photo-upload';
import { BiometricPanel } from './biometric-panel';
import { AttachmentPanel } from '@/components/attachments/attachment-panel';

export default async function MemberDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const user = await requirePerm('MEMBER:READ');
  const { id } = await params;
  const detail = await getMemberDetail(Number(id));
  if (!detail) notFound();

  const {
    member: m, accounts, loans, guaranteeing, transactions, appraisal, nextOfKin, nominees, signatories,
  } = detail;
  const [
    canOpen, canCreateLoan, attachments, savingsProducts, { caption1, caption2 },
  ] = await Promise.all([
    currentCan('SAVINGS:OPEN'), currentCan('LOAN:CREATE'),
    listAttachments('member', m.id), listActiveSavingsProducts(),
    getDimensionCaptions(),
  ]);
  const mediaEnabled = isConfigured();

  const totalSavings = accounts.reduce((a, x) => a + x.balance, 0);
  const runningLoans = loans.filter((l) => l.status === 'DISBURSED');
  const loanBalance = runningLoans.reduce((a, l) => a + l.principal_balance + l.interest_balance, 0);

  return (
    <Page
      title={`${m.first_name} ${m.last_name}`}
      crumb={m.member_no}
      user={user}
    >
      <Toolbar>
        <Link href="/members" className="btn ghost sm">← All members</Link>
        <Spacer />
        {canOpen ? <OpenAccountButton member={m} products={savingsProducts} /> : null}
        {canCreateLoan ? (
          <Link href={`/loans?new=${m.id}`} className="btn">New loan application</Link>
        ) : null}
      </Toolbar>

      <div className="grid g4 stack-2">
        <Stat label="Total savings" value={<Money cents={totalSavings} decimals={0} />}
          foot={`${accounts.length} account(s)`} />
        <Stat label="Loan balance" value={<Money cents={loanBalance} decimals={0} />}
          foot={`${runningLoans.length} running loan(s)`} />
        <Stat label="Loanable deposits" value={<Money cents={appraisal.deposits} decimals={0} />}
          foot="Basis for the multiplier" />
        <Stat label="Guaranteeing" value={guaranteeing.length} foot="loans for other members" />
      </div>

      <div className="grid split-side">
        <div>
          <Card>
            <div className="identity">
              <MemberPhoto
                memberId={m.id}
                name={`${m.first_name} ${m.last_name}`}
                photoSrc={imageSrc(m.photo, { width: 104, height: 104 })}
                canEdit={false}
                mediaEnabled={mediaEnabled}
              />
              <div>
                <div className="who">
                  {[m.title, m.first_name, m.middle_name, m.last_name].filter(Boolean).join(' ')}
                </div>
                <div className="meta">{m.member_no} · <Pill status={m.status} /></div>
              </div>
            </div>
            <DefinitionList items={[
              ['Category', m.member_category_name || '—'],
              ['Identification No.', <span className="mono" key="nid">{m.national_id || '—'}</span>],
              ['KRA PIN', <span className="mono" key="pin">{m.kra_pin || '—'}</span>],
              ['Date of birth', formatDate(m.date_of_birth)],
              ['Gender', m.gender || '—'],
              ['Joined', formatDate(m.join_date)],
              ['KYC', m.kyc_verified
                ? <Pill tone="ok" key="kyc">VERIFIED</Pill>
                : <Pill tone="warn" key="kyc">PENDING</Pill>],
              [caption1, m.global_dimension_1_name || '—'],
              [caption2, m.global_dimension_2_name || '—'],
            ]} />
          </Card>

          <CollapsibleCard title="Contact and Address">
            <DefinitionList items={[
              ['Phone', m.phone || '—'],
              ['Email', m.email || '—'],
              ['Postal address', m.postal_address || '—'],
              ['Physical address', m.physical_address || '—'],
              ['County', m.county_name || '—'],
              ['Sub-county', m.sub_county_name || '—'],
            ]} />
          </CollapsibleCard>

          <BiometricPanel
            memberId={m.id}
            images={{
              id_front: imageSrc(m.front_id_image, { width: 220, height: 140, crop: 'fit' }),
              id_back: imageSrc(m.back_id_image, { width: 220, height: 140, crop: 'fit' }),
              signature: imageSrc(m.signature_image, { width: 180, height: 100, crop: 'fit' }),
              fingerprint1: imageSrc(m.fingerprint1_image, { width: 140, height: 140, crop: 'fit' }),
              fingerprint2: imageSrc(m.fingerprint2_image, { width: 140, height: 140, crop: 'fit' }),
            }}
            canEdit={false}
            mediaEnabled={mediaEnabled}
          />

          <CollapsibleCard title="Employment" sub="Drives the affordability test">
            <DefinitionList items={[
              ['Employer', m.employer || '—'],
              ['Status', m.employment_status || '—'],
              ['Staff no.', <span className="mono" key="staff">{m.staff_no || '—'}</span>],
              ['Gross income', <Money cents={m.gross_income} key="gi" />],
              ['Other deductions', <Money cents={m.other_deductions} key="od" />],
            ]} />
          </CollapsibleCard>

          {m.member_category_type && m.member_category_type !== 'INDIVIDUAL' ? (
            <CollapsibleCard title="Group/Corporate information" sub="Entity and contact-person details">
              <DefinitionList items={[
                ['Group / entity name', m.group_name || '—'],
                ['Registration no.', <span className="mono" key="rn">{m.registration_no || '—'}</span>],
                ['Registration date', formatDate(m.registration_date)],
                ['Number of members', m.member_count ?? '—'],
                ['Contact person', m.contact_person_name || '—'],
                ['Contact phone', m.contact_person_phone || '—'],
                ['Contact email', m.contact_person_email || '—'],
              ]} />
            </CollapsibleCard>
          ) : null}

          {m.member_category_type && m.member_category_type !== 'INDIVIDUAL' ? (
            <CollapsibleCard title="Signatories" sub="Office bearers authorised to act on this account">
              {signatories.length ? (
                <TableWrap>
                  <thead>
                    <tr>
                      <th>Identification No</th><th>Name</th><th>Designation</th>
                      <th>Date of birth</th><th>Email</th><th>Phone</th>
                    </tr>
                  </thead>
                  <tbody>
                    {signatories.map((s) => (
                      <tr key={s.id}>
                        <td className="mono">{s.identification_no || '—'}</td>
                        <td><b>{s.name}</b></td>
                        <td>{s.designation || '—'}</td>
                        <td>{formatDate(s.date_of_birth)}</td>
                        <td>{s.email || '—'}</td>
                        <td>{s.phone || '—'}</td>
                      </tr>
                    ))}
                  </tbody>
                </TableWrap>
              ) : <EmptyState icon="✍" title="No signatories on file" />}
            </CollapsibleCard>
          ) : null}

          <CollapsibleCard title="Next of kin" sub="A member can have more than one">
            {nextOfKin.length ? (
              <TableWrap>
                <thead>
                  <tr><th>Name</th><th>Relationship</th><th>Phone</th></tr>
                </thead>
                <tbody>
                  {nextOfKin.map((n) => (
                    <tr key={n.id}>
                      <td><b>{n.name}</b></td>
                      <td>{n.relationship || '—'}</td>
                      <td>{n.phone || '—'}</td>
                    </tr>
                  ))}
                </tbody>
              </TableWrap>
            ) : <EmptyState icon="👪" title="No next of kin on file" />}
          </CollapsibleCard>

          <CollapsibleCard title="Nominees & beneficiaries" sub="Shares of benefit on the member's account">
            {nominees.length ? (
              <TableWrap>
                <thead>
                  <tr>
                    <th>Name</th><th>Relationship</th><th>Phone</th>
                    <th className="num">Share</th><th>Also NOK</th>
                  </tr>
                </thead>
                <tbody>
                  {nominees.map((n) => (
                    <tr key={n.id}>
                      <td><b>{n.name}</b></td>
                      <td>{n.relationship || '—'}</td>
                      <td>{n.phone || '—'}</td>
                      <td className="num">{n.percentage}%</td>
                      <td>{n.is_next_of_kin ? <Pill tone="info">YES</Pill> : '—'}</td>
                    </tr>
                  ))}
                </tbody>
              </TableWrap>
            ) : <EmptyState icon="🎗" title="No nominees on file" />}
          </CollapsibleCard>
        </div>

        <div>
          <CollapsibleCard title="Savings & deposit accounts" sub="Balances derived from posted transactions">
            {accounts.length ? (
              <TableWrap>
                <thead>
                  <tr>
                    <th>Account no.</th><th>Product</th><th>Opened</th><th>Status</th>
                    <th className="num">Balance</th><th />
                  </tr>
                </thead>
                <tbody>
                  {accounts.map((a) => (
                    <tr key={a.id}>
                      <td className="mono">{a.account_no}</td>
                      <td>{a.product_name}</td>
                      <td>{formatDate(a.opened_date)}</td>
                      <td><Pill status={a.status} /></td>
                      <td className="num"><b><Money cents={a.balance} /></b></td>
                      <td className="num"><Link href={`/savings/${a.id}`}>Open</Link></td>
                    </tr>
                  ))}
                </tbody>
              </TableWrap>
            ) : <EmptyState icon="💰" title="No savings accounts yet" />}
          </CollapsibleCard>

          <CollapsibleCard title="Loans" sub="Applications and running facilities">
            {loans.length ? (
              <TableWrap>
                <thead>
                  <tr>
                    <th>Loan no.</th><th>Product</th><th className="num">Principal</th>
                    <th className="num">Outstanding</th><th>Status</th><th>Class</th><th />
                  </tr>
                </thead>
                <tbody>
                  {loans.map((l) => (
                    <tr key={l.id}>
                      <td className="mono">{l.loan_no}</td>
                      <td>{l.product_name}</td>
                      <td className="num"><Money cents={l.principal} decimals={0} /></td>
                      <td className="num">
                        {l.status === 'DISBURSED'
                          ? <Money cents={l.principal_balance + l.interest_balance} decimals={0} />
                          : '—'}
                      </td>
                      <td><Pill status={l.status} /></td>
                      <td>{l.status === 'DISBURSED' ? <Pill status={l.classification} /> : '—'}</td>
                      <td className="num"><Link href={`/loans/${l.id}`}>Open</Link></td>
                    </tr>
                  ))}
                </tbody>
              </TableWrap>
            ) : <EmptyState icon="📄" title="No loans on file" />}
          </CollapsibleCard>

          {guaranteeing.length ? (
            <CollapsibleCard title="Guarantorship exposure" sub="Loans this member has guaranteed for others">
              <TableWrap>
                <thead>
                  <tr>
                    <th>Loan no.</th><th>Borrower</th><th className="num">Committed</th>
                    <th className="num">Loan balance</th><th>Status</th>
                  </tr>
                </thead>
                <tbody>
                  {guaranteeing.map((g) => (
                    <tr key={g.id}>
                      <td className="mono"><Link href={`/loans/${g.loan_id}`}>{g.loan_no}</Link></td>
                      <td>{g.first_name} {g.last_name}</td>
                      <td className="num"><Money cents={g.amount} decimals={0} /></td>
                      <td className="num"><Money cents={g.principal_balance} decimals={0} /></td>
                      <td><Pill status={g.loan_status} /></td>
                    </tr>
                  ))}
                </tbody>
              </TableWrap>
            </CollapsibleCard>
          ) : null}

          <AttachmentPanel
            entity="member"
            entityId={m.id}
            attachments={attachments}
            // KYC documents are edited through a member edit request, not directly here.
            canManage={false}
            mediaEnabled={mediaEnabled}
          />

          <CollapsibleCard title="Recent activity" sub="Last 40 postings across all accounts">
            {transactions.length ? (
              <TableWrap>
                <thead>
                  <tr>
                    <th>Reference</th><th>Date</th><th>Module</th><th>Type</th><th>Description</th>
                    <th className="num">Amount</th><th className="num">Balance</th>
                  </tr>
                </thead>
                <tbody>
                  {transactions.map((t) => (
                    <tr key={t.id} className={t.status === 'REVERSED' ? 'struck' : undefined}>
                      <td className="mono">{t.txn_ref}</td>
                      <td>{formatDate(t.value_date)}</td>
                      <td>{t.module}</td>
                      <td><Pill status={t.txn_type} /></td>
                      <td>{t.description || ''}</td>
                      <td className="num"><SignedMoney cents={t.amount} /></td>
                      <td className="num">
                        {t.running_balance != null ? <Money cents={t.running_balance} decimals={0} /> : '—'}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </TableWrap>
            ) : <EmptyState icon="🧾" title="No transactions yet" />}
          </CollapsibleCard>
        </div>
      </div>
    </Page>
  );
}
