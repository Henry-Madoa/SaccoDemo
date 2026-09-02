import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import { getMemberEditRequest, diffMemberEditFields, getAdjacentEditRequestNos, type MemberEditView } from '@/lib/memberEdits';
import { getMember, listActiveMembers } from '@/lib/members';
import { listEditNextOfKin, listEditNominees } from '@/lib/editNominees';
import { listEditAccountInstructions, listActiveAccountInstructions } from '@/lib/accountInstructions';
import { listEditSignatories } from '@/lib/editSignatories';
import { listEditAttachments } from '@/lib/editAttachments';
import { findPendingRoutedTask, isEligibleApprover, listWorkflowTasksForDocument } from '@/lib/workflow';
import {
  listActiveCounties, listActiveSubCounties, listActiveMemberCategories, listActiveDimensionValues,
} from '@/lib/pool';
import { getDimensionCaptions } from '@/lib/org';
import { imageSrc, isConfigured } from '@/lib/cloudinary';
import { Page } from '@/components/layout/page';
import { Card, CardHead, Toolbar, Spacer } from '@/components/ui/primitives';
import { ClientTabs } from '@/components/ui/client-tabs';
import { CardNav } from '@/components/ui/card-nav';
import { DocumentActionsMenu } from '@/components/ui/document-actions';
import {
  SubmitButton, CancelApprovalButton, ApproveButton, RejectButton, DelegateButton, ProcessButton,
} from '../../edit-actions';
import { MemberEditPhoto } from './photo-panel';
import { EditRequestBiometricPanel } from './biometric-panel';
import { EditAttachmentPanel } from './attachment-panel';
import { EditNextOfKinPanel, EditNomineePanel } from './nok-nominee-form';
import { EditAccountInstructionPanel } from './account-instruction-form';
import { EditSignatoryPanel } from './signatory-form';
import {
  GeneralInfoCard, BasicInfoCard, GroupInfoCard, ContactInfoCard,
} from './info-cards';
import { ChangesSummary } from './changes-summary';
import { AuditTrail } from './audit-trail';

const EDIT_VIEWS: MemberEditView[] = ['open', 'pending', 'approved', 'processed'];

export default async function MemberEditDetailPage({ params, searchParams }: {
  params: Promise<{ no: string }>;
  searchParams: Promise<{ edit?: string; view?: string }>;
}) {
  const user = await requireAction('MEMBER_EDITS_READ');
  const { no } = await params;
  const { edit, view: viewRaw } = await searchParams;
  const startEditing = edit === '1';
  const view = EDIT_VIEWS.includes(viewRaw as MemberEditView) ? (viewRaw as MemberEditView) : undefined;
  const request = await getMemberEditRequest(no);
  if (!request) notFound();

  const [
    canUpdate, canApprove, currentMember,
    counties, subCounties, memberCategories, gd1Values, gd2Values, { caption1, caption2 },
    nextOfKin, nominees, signatories, attachments, tasks, { prevNo, nextNo },
    accountInstructions, predefinedInstructions,
  ] = await Promise.all([
    currentCanAction('MEMBER_EDITS_UPDATE'), currentCanAction('MEMBER_EDITS_APPROVE'),
    getMember(request.member_id),
    listActiveCounties(), listActiveSubCounties(), listActiveMemberCategories(),
    listActiveDimensionValues(1), listActiveDimensionValues(2), getDimensionCaptions(),
    listEditNextOfKin(no), listEditNominees(no), listEditSignatories(no), listEditAttachments(no),
    listWorkflowTasksForDocument('MEMBER_EDIT', no),
    getAdjacentEditRequestNos(no, view),
    listEditAccountInstructions(no),
    listActiveAccountInstructions(),
  ]);
  if (!currentMember) notFound();

  const mediaEnabled = isConfigured();
  const isOpen = request.status === 'Open';
  const isIndividual = !request.member_category_type || request.member_category_type === 'INDIVIDUAL';
  const isOwnRequest = request.created_by === user.username;
  const canEditThis = canUpdate && (!canApprove || isOwnRequest);

  // Same shape as the member application's approver resolution: the routed task's current
  // approver (or their substitute/delegate) decides it; no matching workflow falls back to
  // the coarse MEMBER:APPROVE permission. Cancelling is only for whoever sent it for approval.
  const routedTask = request.status === 'Pending Approval'
    ? await findPendingRoutedTask('MEMBER_EDIT', no)
    : null;
  const canDecideThis = routedTask ? await isEligibleApprover(routedTask, user.id) : canApprove;
  const requestedBy = routedTask?.requested_by ?? request.created_by;
  const canCancelThis = canUpdate && requestedBy === user.username;

  const canEditFields = isOpen && canEditThis;
  const diffs = diffMemberEditFields(currentMember, request);
  const pendingWith = tasks.find((t) => t.status === 'PENDING')?.pending_with;
  const editMembers = canEditFields ? await listActiveMembers() : [];

  const generalPanel = (
    <GeneralInfoCard
      request={request}
      memberCategories={memberCategories}
      globalDimension1Values={gd1Values}
      globalDimension2Values={gd2Values}
      caption1={caption1}
      caption2={caption2}
      members={editMembers}
      canEdit={canEditFields}
    />
  );

  const basicPanel = (
    <BasicInfoCard request={request} canEdit={canEditFields} startEditing={startEditing} />
  );
  const groupPanel = (
    <GroupInfoCard request={request} canEdit={canEditFields} startEditing={startEditing} />
  );

  const contactPanel = (
    <ContactInfoCard
      request={request} counties={counties} subCounties={subCounties} isIndividual={isIndividual}
      canEdit={canEditFields} startEditing={startEditing}
    />
  );

  const photoPanel = (
    <MemberEditPhoto
      editNo={no}
      name={`${request.first_name} ${request.last_name}`}
      photoSrc={imageSrc(request.photo, { width: 104, height: 104 })}
      canEdit={canEditFields}
      mediaEnabled={mediaEnabled}
    />
  );

  const nomineePanel = (
    <EditNomineePanel editNo={no} nominees={nominees} canManage={canUpdate && isOpen} />
  );

  const nokPanel = (
    <EditNextOfKinPanel editNo={no} nextOfKin={nextOfKin} canManage={canUpdate && isOpen} />
  );

  const signatoryPanel = (
    <EditSignatoryPanel editNo={no} signatories={signatories} canManage={canUpdate && isOpen} />
  );

  const accountInstructionPanel = (
    <EditAccountInstructionPanel
      editNo={no} lines={accountInstructions} predefined={predefinedInstructions}
      canManage={canUpdate && isOpen}
    />
  );

  return (
    <>
      <CardNav
        prevHref={prevNo ? `/member-edits/view/${prevNo}${view ? `?view=${view}` : ''}` : null}
        nextHref={nextNo ? `/member-edits/view/${nextNo}${view ? `?view=${view}` : ''}` : null}
      />
      <Page
        title={`${request.first_name} ${request.last_name}`}
        crumb={`${request.no} · ${request.status} · editing ${request.member_no}${pendingWith ? ` · pending with ${pendingWith}` : ''}`}
        user={user}
      >
      <Toolbar>
        <Link href="/member-edits" className="btn ghost sm">← All edit requests</Link>
        <Link href={`/members/${request.member_id}`} className="btn ghost sm">View member</Link>
        <Spacer />
        {canEditFields ? <SubmitButton no={request.no} className="btn ghost" /> : null}
        {request.status === 'Pending Approval' && canCancelThis ? (
          <CancelApprovalButton no={request.no} className="btn ghost" />
        ) : null}
        {request.status === 'Pending Approval' && canDecideThis ? (
          <>
            {routedTask ? <DelegateButton taskId={routedTask.id} className="btn ghost" /> : null}
            <ApproveButton no={request.no} />
            <RejectButton no={request.no} className="btn ghost" />
          </>
        ) : null}
        {request.status === 'Approved' && canApprove ? <ProcessButton no={request.no} /> : null}
        <DocumentActionsMenu />
      </Toolbar>

      <ChangesSummary diffs={diffs} />

      <ClientTabs
        initial={startEditing && canEditFields ? 'basic' : 'general'}
        tabs={[
          { key: 'general', label: 'General Information' },
          { key: 'basic', label: isIndividual ? 'Basic Information' : 'Group/Corporate Information' },
          { key: 'contact', label: 'Contact & Addresses' },
          { key: 'photo', label: 'Photo & Biometrics' },
          { key: 'kyc', label: 'KYC Attachments' },
          { key: 'nominee', label: 'Nominee' },
          { key: 'nok', label: 'Next Of Kin' },
          { key: 'instructions', label: 'Account Instructions' },
          ...(isIndividual ? [] : [{ key: 'signatory', label: 'Signatories' }]),
          { key: 'audit', label: 'Audit Trail' },
        ]}
        panels={{
          general: generalPanel,
          basic: isIndividual ? basicPanel : groupPanel,
          contact: contactPanel,
          photo: (
            <div>
              <Card>
                <CardHead title="Photo" sub="Shown across the member's profile" />
                {photoPanel}
              </Card>
              <EditRequestBiometricPanel
                editNo={no}
                images={{
                  id_front: imageSrc(request.front_id_image, { width: 220, height: 140, crop: 'fit' }),
                  id_back: imageSrc(request.back_id_image, { width: 220, height: 140, crop: 'fit' }),
                  signature: imageSrc(request.signature_image, { width: 180, height: 100, crop: 'fit' }),
                  fingerprint1: imageSrc(request.fingerprint1_image, { width: 140, height: 140, crop: 'fit' }),
                  fingerprint2: imageSrc(request.fingerprint2_image, { width: 140, height: 140, crop: 'fit' }),
                }}
                canEdit={canEditFields}
                mediaEnabled={mediaEnabled}
              />
            </div>
          ),
          kyc: (
            <EditAttachmentPanel
              editNo={no}
              attachments={attachments}
              canManage={canUpdate && isOpen}
              mediaEnabled={mediaEnabled}
            />
          ),
          nominee: nomineePanel,
          nok: nokPanel,
          instructions: accountInstructionPanel,
          ...(isIndividual ? {} : { signatory: signatoryPanel }),
          audit: <AuditTrail request={request} tasks={tasks} />,
        }}
      />
      </Page>
    </>
  );
}
