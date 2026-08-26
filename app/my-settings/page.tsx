import { requireUser } from '@/lib/session';
import { getEffectivePostingRange, getWorkDate } from '@/lib/postingDates';
import { today } from '@/lib/format';
import { Page } from '@/components/layout/page';
import { Card, CardHead, DefinitionList } from '@/components/ui/primitives';
import { WorkDateForm } from './work-date-form';

/** BC's own "My Settings" — currently just the Work Date, the date a user's own new documents
 *  suggest by default instead of the real system date. Any signed-in user manages their own; no
 *  particular permission is required beyond being logged in. */
export default async function MySettingsPage() {
  const user = await requireUser();
  const [workDate, range] = await Promise.all([
    getWorkDate(user.id),
    getEffectivePostingRange(user.id),
  ]);
  const systemDate = today();

  const windowLabel = range.from || range.to
    ? `${range.from ?? 'Any date'}${range.fromTime ? ` ${range.fromTime}` : ''} – ${range.to ?? 'Any date'}${range.toTime ? ` ${range.toTime}` : ''}`
    : 'Unrestricted';

  return (
    <Page title="My Settings" crumb="Personal preferences" user={user}>
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
