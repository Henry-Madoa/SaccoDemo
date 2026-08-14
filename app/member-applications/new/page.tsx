import { requireAction } from '@/lib/session';
import { listActiveMemberCategories, listActiveDimensionValues } from '@/lib/pool';
import { getDimensionCaptions } from '@/lib/org';
import { Page } from '@/components/layout/page';
import { NewApplicationForm } from './new-application-form';

export default async function NewMemberApplicationPage() {
  const user = await requireAction('MEMBER_APPLICATIONS_CREATE');
  const [memberCategories, gd1Values, gd2Values, { caption1, caption2 }] = await Promise.all([
    listActiveMemberCategories(),
    listActiveDimensionValues(1),
    listActiveDimensionValues(2),
    getDimensionCaptions(),
  ]);

  return (
    <Page title="New member application" crumb="Capture the essentials, fill in the rest afterwards" user={user}>
      <NewApplicationForm
        memberCategories={memberCategories}
        globalDimension1Values={gd1Values}
        globalDimension2Values={gd2Values}
        caption1={caption1}
        caption2={caption2}
      />
    </Page>
  );
}
