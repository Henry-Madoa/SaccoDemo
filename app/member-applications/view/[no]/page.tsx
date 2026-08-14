import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import { getMemberApplication } from '@/lib/memberApplications';
import { findPendingRoutedTask, isEligibleApprover, listWorkflowTasksForDocument } from '@/lib/workflow';
import { listApplicationNextOfKin, listApplicationNominees } from '@/lib/applicationNominees';
import { listApplicationSignatories } from '@/lib/applicationSignatories';
import { listApplicationAttachments } from '@/lib/applicationAttachments';
import {
  listActiveCounties, listActiveSubCounties, listActiveMemberCategories, listActiveDimensionValues,
} from '@/lib/pool';
import { getDimensionCaptions } from '@/lib/org';
import { imageSrc, isConfigured } from '@/lib/cloudinary';
import { Page } from '@/components/layout/page';
import { Toolbar, Spacer } from '@/components/ui/primitives';
import { ClientTabs } from '@/components/ui/client-tabs';
import {
  SubmitButton, CancelApprovalButton, ApproveButton, RejectButton, DelegateButton, ProcessButton,
} from '../../application-actions';
import { ApplicationBiometricPanel } from './biometric-panel';
import { ApplicationAttachmentPanel } from './attachment-panel';
import { ApplicationNextOfKinPanel, ApplicationNomineePanel } from './nok-nominee-form';
import { ApplicationSignatoryPanel } from './signatory-form';
import {
  GeneralInfoCard, BasicInfoCard, GroupInfoCard, ContactInfoCard,
} from './info-cards';
import { AuditTrail } from './audit-trail';

export default async function MemberApplicationDetailPage({ params, searchParams }: {
  params: Promise<{ no: string }>;
  searchParams: Promise<{ edit?: string }>;
}) {
  const user = await requireAction('MEMBER_APPLICATIONS_READ');
  const { no } = await params;
  const { edit } = await searchParams;
  const startEditing = edit === '1';
  const application = await getMemberApplication(no);
  if (!application) notFound();

  const [
    canUpdate, canCreate, canApprove, nextOfKin, nominees, signatories, attachments,
    counties, subCounties, memberCategories, gd1Values, gd2Values, { caption1, caption2 }, tasks,
  ] = await Promise.all([
    currentCanAction('MEMBER_APPLICATIONS_UPDATE'), currentCanAction('MEMBER_APPLICATIONS_CREATE'), currentCanAction('MEMBER_APPLICATIONS_APPROVE'),
    listApplicationNextOfKin(no), listApplicationNominees(no), listApplicationSignatories(no),
    listApplicationAttachments(no),
    listActiveCounties(), listActiveSubCounties(), listActiveMemberCategories(),
    listActiveDimensionValues(1), listActiveDimensionValues(2), getDimensionCaptions(),
    listWorkflowTasksForDocument('MEMBER_APPLICATION', no),
  ]);
  const mediaEnabled = isConfigured();
  const isOpen = application.status === 'Open';
  const isIndividual = !application.member_category_type || application.member_category_type === 'INDIVIDUAL';
  const isOwnApplication = application.created_by === user.username;
  const canEditThis = canCreate && (!canApprove || isOwnApplication);

  // Approve/Reject/Delegate are only ever shown to whoever can actually decide this
  // specific application: the routed task's current approver (or their substitute/
  // delegate); an application with no matching workflow falls back to the coarse
  // MEMBER:APPROVE permission. Cancelling the approval request is only for whoever
  // actually sent it for approval, not just anyone who can create applications.
  const routedTask = application.status === 'Pending Approval'
    ? await findPendingRoutedTask('MEMBER_APPLICATION', no)
    : null;
  const canDecideThis = routedTask ? await isEligibleApprover(routedTask, user.id) : canApprove;
  const requestedBy = routedTask?.requested_by ?? application.created_by;
  const canCancelThis = canCreate && requestedBy === user.username;

  const canEditFields = isOpen && canEditThis;

  const generalPanel = (
    <GeneralInfoCard
      application={application}
      memberCategories={memberCategories}
      globalDimension1Values={gd1Values}
      globalDimension2Values={gd2Values}
      caption1={caption1}
      caption2={caption2}
      canEdit={canEditFields}
    />
  );

  const basicPanel = (
    <BasicInfoCard application={application} canEdit={canEditFields} startEditing={startEditing} />
  );

  const groupPanel = (
    <GroupInfoCard application={application} canEdit={canEditFields} startEditing={startEditing} />
  );

  const contactPanel = (
    <ContactInfoCard
      application={application} counties={counties} subCounties={subCounties} isIndividual={isIndividual}
      canEdit={canEditFields} startEditing={startEditing}
    />
  );

  const nokPanel = (
    <ApplicationNextOfKinPanel applicationNo={no} nextOfKin={nextOfKin} canManage={canUpdate && isOpen} />
  );

  const nomineePanel = (
    <ApplicationNomineePanel applicationNo={no} nominees={nominees} canManage={canUpdate && isOpen} />
  );

  const signatoryPanel = (
    <ApplicationSignatoryPanel applicationNo={no} signatories={signatories} canManage={canUpdate && isOpen} />
  );

  return (
    <Page
      title={[application.first_name, application.last_name].filter(Boolean).join(' ') || application.no}
      crumb={`${application.no} · ${application.status}`}
      user={user}
    >
      <Toolbar>
        <Link href="/member-applications" className="btn ghost sm">← All applications</Link>
        <Spacer />
        {canEditFields ? <SubmitButton no={application.no} className="btn ghost" /> : null}
        {application.status === 'Pending Approval' && canCancelThis ? (
          <CancelApprovalButton no={application.no} className="btn ghost" />
        ) : null}
        {application.status === 'Pending Approval' && canDecideThis ? (
          <>
            {routedTask ? <DelegateButton taskId={routedTask.id} className="btn ghost" /> : null}
            <ApproveButton no={application.no} />
            <RejectButton no={application.no} className="btn ghost" />
          </>
        ) : null}
        {application.status === 'Approved' && canApprove ? <ProcessButton no={application.no} /> : null}
      </Toolbar>

      <ClientTabs
        initial={startEditing && canEditFields ? 'basic' : 'general'}
        tabs={[
          { key: 'general', label: 'General Information' },
          { key: 'basic', label: isIndividual ? 'Basic Information' : 'Group/Corporate Information' },
          { key: 'contact', label: 'Contact & Addresses' },
          { key: 'biometric', label: 'Biometric Information' },
          { key: 'kyc', label: 'KYC Attachments' },
          { key: 'nominee', label: 'Nominee' },
          { key: 'nok', label: 'Next Of Kin' },
          ...(isIndividual ? [] : [{ key: 'signatory', label: 'Signatories' }]),
          { key: 'audit', label: 'Audit Trail' },
        ]}
        panels={{
          general: generalPanel,
          basic: isIndividual ? basicPanel : groupPanel,
          contact: contactPanel,
          biometric: (
            <ApplicationBiometricPanel
              applicationNo={no}
              images={{
                id_front: imageSrc(application.front_id_image, { width: 220, height: 140, crop: 'fit' }),
                id_back: imageSrc(application.back_id_image, { width: 220, height: 140, crop: 'fit' }),
                signature: imageSrc(application.signature_image, { width: 180, height: 100, crop: 'fit' }),
                fingerprint1: imageSrc(application.fingerprint1_image, { width: 140, height: 140, crop: 'fit' }),
                fingerprint2: imageSrc(application.fingerprint2_image, { width: 140, height: 140, crop: 'fit' }),
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
          ...(isIndividual ? {} : { signatory: signatoryPanel }),
          audit: <AuditTrail application={application} tasks={tasks} />,
        }}
      />
    </Page>
  );
}
