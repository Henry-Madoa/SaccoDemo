'use client';

import { AccountInstructionsPanel, type InstructionDraft } from '@/components/members/account-instructions';
import { saveApplicationAccountInstructions } from '@/app/actions/accountInstructions';
import type { AccountInstruction, MemberApplicationAccountInstruction } from '@/lib/types';

export function ApplicationAccountInstructionPanel({ applicationNo, lines, predefined, canManage }: {
  applicationNo: string;
  lines: MemberApplicationAccountInstruction[];
  predefined: Pick<AccountInstruction, 'description'>[];
  canManage: boolean;
}) {
  return (
    <AccountInstructionsPanel
      lines={lines}
      predefined={predefined}
      canManage={canManage}
      onSave={(rows: InstructionDraft[]) => saveApplicationAccountInstructions(applicationNo, rows)}
      sub="What the member wants the SACCO to observe when operating this account — carried onto the member on approval"
    />
  );
}
