import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requirePerm, currentCan } from '@/lib/session';
import { getMemberApplication, listApplicationAuditTrail } from '@/lib/memberApplications';
import { listApplicationNextOfKin, listApplicationNominees } from '@/lib/applicationNominees';
import { listApplicationAttachments } from '@/lib/applicationAttachments';
import {
  listActiveCounties, listActiveSubCounties, listActiveMemberCategories, listActiveDimensionValues,
} from '@/lib/pool';
import { getDimensionCaptions } from '@/lib/org';
import { isConfigured } from '@/lib/cloudinary';
import { Page } from '@/components/layout/page';
import { Toolbar, Spacer } from '@/components/ui/primitives';
import { ClientTabs } from '@/components/ui/client-tabs';
import {
  SubmitButton, CancelApprovalButton, ApproveButton, RejectButton, ProcessButton,
} from '../../application-actions';
import { ApplicationBiometricPanel } from './biometric-panel';
import { ApplicationAttachmentPanel } from './attachment-panel';
import { ApplicationNextOfKinPanel, ApplicationNomineePanel } from './nok-nominee-form';
import { GeneralInfoCard, BasicInfoCard, GroupInfoCard } from './info-cards';
import { AuditTrail } from './audit-trail';

export default async function MemberApplicationDetailPage({ params }: { params: Promise<{ no: string }> }) {
  const user = await requirePerm('MEMBER:READ');
  const { no } = await params;
  const application = await getMemberApplication(no);
  if (!application) notFound();

  const [
    canUpdate, canCreate, canApprove, nextOfKin, nominees, attachments, auditTrail,
    counties, subCounties, memberCategories, gd1Values, gd2Values, { caption1, caption2 },
  ] = await Promise.all([
    currentCan('MEMBER:UPDATE'), currentCan('MEMBER:CREATE'), currentCan('MEMBER:APPROVE'),
    listApplicationNextOfKin(no), listApplicationNominees(no), listApplicationAttachments(no),
    listApplicationAuditTrail(no),
    listActiveCounties(), listActiveSubCounties(), listActiveMemberCategories(),
    listActiveDimensionValues(1), listActiveDimensionValues(2), getDimensionCaptions(),
  ]);
  const mediaEnabled = isConfigured();
  const isOpen = application.status === 'Open';
  const isIndividual = !application.member_category_type || application.member_category_type === 'INDIVIDUAL';
  const isOwnApplication = application.created_by === user.username;
  const canEditThis = canCreate && (!canApprove || isOwnApplication);

  const canEditFields = isOpen && canEditThis;

  const generalPanel = (
    <GeneralInfoCard
      application={application}
      counties={counties}
      subCounties={subCounties}
      memberCategories={memberCategories}
      globalDimension1Values={gd1Values}
      globalDimension2Values={gd2Values}
      caption1={caption1}
      caption2={caption2}
      canEdit={canEditFields}
    />
  );

  const basicPanel = <BasicInfoCard application={application} canEdit={canEditFields} />;

  const groupPanel = <GroupInfoCard application={application} canEdit={canEditFields} />;

  const nokPanel = (
    <ApplicationNextOfKinPanel applicationNo={no} nextOfKin={nextOfKin} canManage={canUpdate && isOpen} />
  );

  const nomineePanel = (
    <ApplicationNomineePanel applicationNo={no} nominees={nominees} canManage={canUpdate && isOpen} />
  );

  return (
    <Page
      title={`${application.first_name} ${application.last_name}`}
      crumb={`${application.no} · ${application.status}`}
      user={user}
    >
      <Toolbar>
        <Link href="/member-applications" className="btn ghost sm">← All applications</Link>
        <Spacer />
        {canEditFields ? <SubmitButton no={application.no} className="btn ghost" /> : null}
        {application.status === 'Pending Approval' && canCreate && isOwnApplication ? (
          <CancelApprovalButton no={application.no} className="btn ghost" />
        ) : null}
        {application.status === 'Pending Approval' && canApprove ? (
          <>
            <ApproveButton no={application.no} />
            <RejectButton no={application.no} className="btn ghost" />
          </>
        ) : null}
        {application.status === 'Approved' && canApprove ? <ProcessButton no={application.no} /> : null}
      </Toolbar>

      <ClientTabs
        initial="general"
        tabs={[
          { key: 'general', label: 'General Information' },
          { key: 'basic', label: isIndividual ? 'Basic Information' : 'Group/Corporate Information' },
          { key: 'biometric', label: 'Biometric Information' },
          { key: 'kyc', label: 'KYC Attachments' },
          { key: 'nok', label: 'Next Of Kin' },
          { key: 'nominee', label: 'Nominee' },
          { key: 'audit', label: 'Audit Trail' },
        ]}
        panels={{
          general: generalPanel,
          basic: isIndividual ? basicPanel : groupPanel,
          biometric: (
            <ApplicationBiometricPanel
              applicationNo={no}
              images={{
                id_front: application.front_id_image, id_back: application.back_id_image,
                signature: application.signature_image,
                fingerprint1: application.fingerprint1_image, fingerprint2: application.fingerprint2_image,
              }}
              canEdit={canUpdate && isOpen}
              mediaEnabled={mediaEnabled}
            />
          ),
          kyc: (
            <ApplicationAttachmentPanel
              applicationNo={no}
              attachments={attachments}
              canManage={canUpdate && isOpen}
              mediaEnabled={mediaEnabled}
            />
          ),
          nok: nokPanel,
          nominee: nomineePanel,
          audit: <AuditTrail application={application} trail={auditTrail} />,
        }}
      />
    </Page>
  );
}
