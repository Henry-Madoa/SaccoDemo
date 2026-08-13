import { requirePerm } from '@/lib/session';
import { listActiveMemberCategories } from '@/lib/pool';
import { Page } from '@/components/layout/page';
import { NewApplicationForm } from './new-application-form';

export default async function NewMemberApplicationPage() {
  const user = await requirePerm('MEMBER:CREATE');
  const memberCategories = await listActiveMemberCategories();

  return (
    <Page title="New member application" crumb="Capture the essentials, fill in the rest afterwards" user={user}>
      <NewApplicationForm memberCategories={memberCategories} />
    </Page>
  );
}
