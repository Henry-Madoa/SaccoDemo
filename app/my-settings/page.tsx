import { requireUser } from '@/lib/session';
import { getEffectivePostingRange, getWorkDate } from '@/lib/postingDates';
import { today } from '@/lib/format';
import { Page } from '@/components/layout/page';
import { Card, CardHead, DefinitionList } from '@/components/ui/primitives';
import { WorkDateForm } from './work-date-form';
import { ProfileSwitcher } from './profile-switcher';
import { CompanySwitcherForm } from './company-switcher';
import { listCompanies } from '@/lib/companies';
import { getActiveCompany } from '@/lib/companyContext';

/** BC's own "My Settings" — currently just the Work Date, the date a user's own new documents
 *  suggest by default instead of the real system date. Any signed-in user manages their own; no
 *  particular permission is required beyond being logged in. */
export default async function MySettingsPage() {
  const user = await requireUser();
  const [workDate, range, companies, company] = await Promise.all([
    getWorkDate(user.id),
    getEffectivePostingRange(user.id),
    listCompanies(),
    getActiveCompany(),
  ]);
  const systemDate = today();

  const windowLabel = range.from || range.to
    ? `${range.from ?? 'Any date'}${range.fromTime ? ` ${range.fromTime}` : ''} – ${range.to ?? 'Any date'}${range.toTime ? ` ${range.toTime}` : ''}`
    : 'Unrestricted';

  return (
    <Page title="My Settings" crumb="Personal preferences" user={user}>
      <Card>
        <CardHead
          title="Role Centre"
          sub="Your home dashboard and which navigation groups your sidebar shows. It never changes your permissions — what you can view, create, edit, approve or delete is fixed by your roles."
        />
        <DefinitionList items={[
          ['Current Role Centre', `${user.activeProfile.icon ? `${user.activeProfile.icon} ` : ''}${user.activeProfile.name}`],
          ['Assigned to you', user.profiles.map((p) => p.name).join(', ') || '—'],
        ]} />
        <ProfileSwitcher profiles={user.profiles} activeId={user.activeProfile.id} />
      </Card>
      {companies.length > 1 ? (
        <Card>
          <div id="company" />
          <CardHead title="Company" sub="Which company this browser works in. A test copy holds its own data; the live company is never affected by what you do in a copy." />
          <DefinitionList items={[
            ['Current company', <>{company.display_name} <span className="mono">({company.code})</span>{company.is_default ? ' — live' : ' — test copy'}</>],
            company.assigned ? ['Assigned by', 'An administrator has assigned you to this company; only they can change it (User card → Company).'] : null,
          ]} />
          {!company.assigned ? <CompanySwitcherForm companies={companies.map((c) => ({ code: c.code, display_name: c.display_name, is_default: c.is_default }))} activeCode={company.code} /> : null}
        </Card>
      ) : null}
      <Card>
        <CardHead title="Work Date" sub="The date your own new documents suggest by default, in place of today's real date" />
        <DefinitionList items={[
          ['System date', systemDate],
          ['Your allowed posting window', windowLabel],
        ]} />
        <WorkDateForm workDate={workDate} systemDate={systemDate} />
        <div className="hint" style={{ marginTop: 8 }}>
          Must fall within your allowed posting window above — set by an administrator, either
          for you specifically (Admin Centre → Workflow Management → User Setup) or company-wide
          (Admin Centre → Company Information → Posting Dates).
        </div>
      </Card>
    </Page>
  );
}
