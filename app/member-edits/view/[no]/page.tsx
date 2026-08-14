import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requirePerm, currentCan } from '@/lib/session';
import { getMemberEditRequest, listEditAuditTrail, diffMemberEditFields } from '@/lib/memberEdits';
import { getMember } from '@/lib/members';
import { findPendingRoutedTask, isEligibleApprover } from '@/lib/workflow';
import {
  listActiveCounties, listActiveSubCounties, listActiveMemberCategories, listActiveDimensionValues,
} from '@/lib/pool';
import { getDimensionCaptions } from '@/lib/org';
import { isConfigured } from '@/lib/cloudinary';
import { Page } from '@/components/layout/page';
import { Card, CardHead, Toolbar, Spacer } from '@/components/ui/primitives';
import { ClientTabs } from '@/components/ui/client-tabs';
import {
  SubmitButton, CancelApprovalButton, ApproveButton, RejectButton, DelegateButton, ProcessButton,
} from '../../edit-actions';
import { MemberEditPhoto } from './photo-panel';
import { EditRequestBiometricPanel } from './biometric-panel';
import { GeneralInfoCard, BasicInfoCard, GroupInfoCard } from './info-cards';
import { ChangesSummary } from './changes-summary';
import { AuditTrail } from './audit-trail';

export default async function MemberEditDetailPage({ params }: { params: Promise<{ no: string }> }) {
  const user = await requirePerm('MEMBER:READ');
  const { no } = await params;
  const request = await getMemberEditRequest(no);
  if (!request) notFound();

  const [
    canUpdate, canApprove, currentMember, auditTrail,
    counties, subCounties, memberCategories, gd1Values, gd2Values, { caption1, caption2 },
  ] = await Promise.all([
    currentCan('MEMBER:UPDATE'), currentCan('MEMBER:APPROVE'),
    getMember(request.member_id),
    listEditAuditTrail(no),
    listActiveCounties(), listActiveSubCounties(), listActiveMemberCategories(),
    listActiveDimensionValues(1), listActiveDimensionValues(2), getDimensionCaptions(),
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

  const generalPanel = (
    <GeneralInfoCard
      request={request}
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

  const basicPanel = <BasicInfoCard request={request} canEdit={canEditFields} />;
  const groupPanel = <GroupInfoCard request={request} canEdit={canEditFields} />;

  const photoPanel = (
    <MemberEditPhoto
      editNo={no}
      name={`${request.first_name} ${request.last_name}`}
      photoSrc={request.photo}
      canEdit={canEditFields}
      mediaEnabled={mediaEnabled}
    />
  );

  return (
    <Page
      title={`${request.first_name} ${request.last_name}`}
      crumb={`${request.no} · ${request.status} · editing ${request.member_no}`}
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
      </Toolbar>

      <ChangesSummary diffs={diffs} />

      <ClientTabs
        initial="general"
        tabs={[
          { key: 'general', label: 'General Information' },
          { key: 'basic', label: isIndividual ? 'Basic Information' : 'Group/Corporate Information' },
          { key: 'photo', label: 'Photo & Biometrics' },
          { key: 'audit', label: 'Audit Trail' },
        ]}
        panels={{
          general: generalPanel,
          basic: isIndividual ? basicPanel : groupPanel,
          photo: (
            <div>
              <Card>
                <CardHead title="Photo" sub="Shown across the member's profile" />
                {photoPanel}
              </Card>
              <EditRequestBiometricPanel
                editNo={no}
                images={{
                  id_front: request.front_id_image, id_back: request.back_id_image,
                  signature: request.signature_image,
                  fingerprint1: request.fingerprint1_image, fingerprint2: request.fingerprint2_image,
                }}
                canEdit={canEditFields}
                mediaEnabled={mediaEnabled}
              />
            </div>
          ),
          audit: <AuditTrail request={request} trail={auditTrail} />,
        }}
      />
    </Page>
  );
}
