'use client';

import { AccountInstructionsPanel, type InstructionDraft } from '@/components/members/account-instructions';
import { saveEditAccountInstructions } from '@/app/actions/accountInstructions';
import type { AccountInstruction, MemberEditAccountInstruction } from '@/lib/types';

export function EditAccountInstructionPanel({ editNo, lines, predefined, canManage }: {
  editNo: string;
  lines: MemberEditAccountInstruction[];
  predefined: Pick<AccountInstruction, 'description'>[];
  canManage: boolean;
}) {
  return (
    <AccountInstructionsPanel
      lines={lines}
      predefined={predefined}
      canManage={canManage}
      onSave={(rows: InstructionDraft[]) => saveEditAccountInstructions(editNo, rows)}
      sub="The member's account instructions — applied onto the member when this edit is processed"
    />
  );
}
