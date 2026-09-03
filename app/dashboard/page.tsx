import { requireAction } from '@/lib/session';
import { SuperRoleCentre } from './centres/super';
import { CrmRoleCentre } from './centres/crm';
import { CreditRoleCentre } from './centres/credit';
import { FosaRoleCentre } from './centres/fosa';
import { FinanceManagerRoleCentre } from './centres/finance-manager';
import { AccountantRoleCentre } from './centres/accountant';

/**
 * The dashboard is a Role Centre dispatcher (Business Central "Role Center"). Which one renders is
 * decided by the user's active Profile (My Settings → Role Centre) — a landing-page choice that
 * grants no permissions. Every Role Centre is permission-aware: a widget the viewer's permission
 * set does not unlock shows as a locked card.
 */
export default async function DashboardPage() {
  const user = await requireAction('DASHBOARD_VIEW');
  switch (user.activeProfile.role_centre) {
    case 'CRM': return <CrmRoleCentre user={user} />;
    case 'CREDIT': return <CreditRoleCentre user={user} />;
    case 'FOSA': return <FosaRoleCentre user={user} />;
    case 'FINANCE_MANAGER': return <FinanceManagerRoleCentre user={user} />;
    case 'ACCOUNTANT': return <AccountantRoleCentre user={user} />;
    default: return <SuperRoleCentre user={user} />;
  }
}
