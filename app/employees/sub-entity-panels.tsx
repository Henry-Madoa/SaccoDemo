'use client';

import { LineRowsFormButton, LineRowsPanel, type LineColumn } from '@/components/ui/line-rows-editor';
import { RELATIONSHIPS, GENDERS } from '@/lib/constants';
import {
  saveNextOfKin, saveBeneficiaries, saveDependants, saveEmergencyContacts,
  saveProfessionalBodies, saveWorkHistory, saveBankAccounts,
} from '@/app/actions/employees';
import type {
  EmployeeNextOfKin, EmployeeBeneficiary, EmployeeDependant, EmployeeEmergencyContact,
  EmployeeProfessionalBody, EmployeeWorkHistory, EmployeeBankAccount,
} from '@/lib/types';

type Row<T> = Omit<T, 'id'>;
const strip = <T extends { id: number }>(rows: T[]): Row<T>[] => rows.map(({ id: _id, ...r }) => r as Row<T>);

/* ------------------------------------------------------------------------ next of kin */
const NOK_COLUMNS: LineColumn<Row<EmployeeNextOfKin>>[] = [
  { key: 'full_name', label: 'Name' },
  { key: 'relationship', label: 'Relationship', type: 'select', options: RELATIONSHIPS },
  { key: 'phone', label: 'Phone', type: 'phone' },
  { key: 'id_no', label: 'ID No.' },
  { key: 'email', label: 'Email', type: 'email' },
];
const emptyNok = (): Row<EmployeeNextOfKin> => ({ employee_id: 0, full_name: '', relationship: null, id_no: null, phone: null, email: null });

export function NextOfKinPanel({ employeeId, rows, canManage }: { employeeId: number; rows: EmployeeNextOfKin[]; canManage: boolean }) {
  return (
    <LineRowsPanel title="Next of Kin" rows={strip(rows)} columns={NOK_COLUMNS} icon="👪"
      manageButton={canManage ? (
        <LineRowsFormButton title="Next of kin" rows={strip(rows)} columns={NOK_COLUMNS} emptyRow={emptyNok}
          onSave={(r) => saveNextOfKin(employeeId, r)} className="btn sm ghost" successTitle="Next of kin saved">
          Manage
        </LineRowsFormButton>
      ) : null} />
  );
}

/* ------------------------------------------------------------------------ beneficiaries */
const BEN_COLUMNS: LineColumn<Row<EmployeeBeneficiary>>[] = [
  { key: 'full_name', label: 'Name' },
  { key: 'relationship', label: 'Relationship', type: 'select', options: RELATIONSHIPS },
  { key: 'gender', label: 'Gender', type: 'select', options: GENDERS },
  { key: 'date_of_birth', label: 'Date of birth', type: 'date' },
  { key: 'percentage', label: 'Share %', type: 'number', width: 100 },
  { key: 'is_minor', label: 'Minor', type: 'checkbox', width: 60, render: (r) => (r.is_minor ? 'Yes' : 'No') },
];
const emptyBen = (): Row<EmployeeBeneficiary> => ({
  employee_id: 0, full_name: '', id_no: null, date_of_birth: null, relationship: null,
  gender: null, phone: null, email: null, percentage: 0, is_minor: false,
});

export function BeneficiariesPanel({ employeeId, rows, canManage }: { employeeId: number; rows: EmployeeBeneficiary[]; canManage: boolean }) {
  return (
    <LineRowsPanel title="Beneficiaries" rows={strip(rows)} columns={BEN_COLUMNS} icon="🎗"
      sub="Shares must not exceed 100%"
      manageButton={canManage ? (
        <LineRowsFormButton title="Beneficiaries" rows={strip(rows)} columns={BEN_COLUMNS} emptyRow={emptyBen}
          onSave={(r) => saveBeneficiaries(employeeId, r)} className="btn sm ghost" successTitle="Beneficiaries saved">
          Manage
        </LineRowsFormButton>
      ) : null} />
  );
}

/* ------------------------------------------------------------------------ dependants */
const DEP_COLUMNS: LineColumn<Row<EmployeeDependant>>[] = [
  { key: 'full_name', label: 'Name' },
  { key: 'relationship', label: 'Relationship', type: 'select', options: RELATIONSHIPS },
  { key: 'gender', label: 'Gender', type: 'select', options: GENDERS },
  { key: 'date_of_birth', label: 'Date of birth', type: 'date' },
  { key: 'id_or_birth_cert_no', label: 'ID / Birth Cert No.' },
  { key: 'is_student', label: 'Student', type: 'checkbox', width: 60, render: (r) => (r.is_student ? 'Yes' : 'No') },
];
const emptyDep = (): Row<EmployeeDependant> => ({
  employee_id: 0, full_name: '', id_or_birth_cert_no: null, date_of_birth: null,
  relationship: null, gender: null, is_student: false, status: 'ACTIVE',
});

export function DependantsPanel({ employeeId, rows, canManage }: { employeeId: number; rows: EmployeeDependant[]; canManage: boolean }) {
  return (
    <LineRowsPanel title="Medical Dependants" rows={strip(rows)} columns={DEP_COLUMNS} icon="🩺"
      manageButton={canManage ? (
        <LineRowsFormButton title="Medical dependants" rows={strip(rows)} columns={DEP_COLUMNS} emptyRow={emptyDep}
          onSave={(r) => saveDependants(employeeId, r)} className="btn sm ghost" successTitle="Dependants saved">
          Manage
        </LineRowsFormButton>
      ) : null} />
  );
}

/* ------------------------------------------------------------------------ emergency contacts */
const EC_COLUMNS: LineColumn<Row<EmployeeEmergencyContact>>[] = [
  { key: 'full_name', label: 'Name' },
  { key: 'relationship', label: 'Relationship', type: 'select', options: RELATIONSHIPS },
  { key: 'phone', label: 'Phone', type: 'phone' },
  { key: 'alt_phone', label: 'Alt. Phone', type: 'phone' },
  { key: 'email', label: 'Email', type: 'email' },
];
const emptyEc = (): Row<EmployeeEmergencyContact> => ({ employee_id: 0, full_name: '', relationship: null, phone: null, alt_phone: null, email: null });

export function EmergencyContactsPanel({ employeeId, rows, canManage }: { employeeId: number; rows: EmployeeEmergencyContact[]; canManage: boolean }) {
  return (
    <LineRowsPanel title="Emergency Contacts" rows={strip(rows)} columns={EC_COLUMNS} icon="🚑"
      manageButton={canManage ? (
        <LineRowsFormButton title="Emergency contacts" rows={strip(rows)} columns={EC_COLUMNS} emptyRow={emptyEc}
          onSave={(r) => saveEmergencyContacts(employeeId, r)} className="btn sm ghost" successTitle="Emergency contacts saved">
          Manage
        </LineRowsFormButton>
      ) : null} />
  );
}

/* ------------------------------------------------------------------------ professional bodies */
const PB_COLUMNS: LineColumn<Row<EmployeeProfessionalBody>>[] = [
  { key: 'body_name', label: 'Professional Body' },
  { key: 'membership_no', label: 'Membership No.' },
  { key: 'from_date', label: 'From', type: 'date' },
  { key: 'to_date', label: 'To', type: 'date' },
];
const emptyPb = (): Row<EmployeeProfessionalBody> => ({ employee_id: 0, body_name: '', membership_no: null, from_date: null, to_date: null });

export function ProfessionalBodiesPanel({ employeeId, rows, canManage }: { employeeId: number; rows: EmployeeProfessionalBody[]; canManage: boolean }) {
  return (
    <LineRowsPanel title="Professional Bodies" rows={strip(rows)} columns={PB_COLUMNS} icon="🎓"
      manageButton={canManage ? (
        <LineRowsFormButton title="Professional bodies" rows={strip(rows)} columns={PB_COLUMNS} emptyRow={emptyPb}
          onSave={(r) => saveProfessionalBodies(employeeId, r)} className="btn sm ghost" successTitle="Professional bodies saved">
          Manage
        </LineRowsFormButton>
      ) : null} />
  );
}

/* ------------------------------------------------------------------------ work history */
const WH_COLUMNS: LineColumn<Row<EmployeeWorkHistory>>[] = [
  { key: 'institution', label: 'Institution' },
  { key: 'position_held', label: 'Position Held' },
  { key: 'from_date', label: 'From', type: 'date' },
  { key: 'to_date', label: 'To', type: 'date' },
  { key: 'reason_for_leaving', label: 'Reason for Leaving' },
];
const emptyWh = (): Row<EmployeeWorkHistory> => ({ employee_id: 0, institution: '', position_held: null, from_date: null, to_date: null, reason_for_leaving: null });

export function WorkHistoryPanel({ employeeId, rows, canManage }: { employeeId: number; rows: EmployeeWorkHistory[]; canManage: boolean }) {
  return (
    <LineRowsPanel title="Work History" rows={strip(rows)} columns={WH_COLUMNS} icon="🏢"
      manageButton={canManage ? (
        <LineRowsFormButton title="Work history" rows={strip(rows)} columns={WH_COLUMNS} emptyRow={emptyWh}
          onSave={(r) => saveWorkHistory(employeeId, r)} className="btn sm ghost" successTitle="Work history saved">
          Manage
        </LineRowsFormButton>
      ) : null} />
  );
}

/* ------------------------------------------------------------------------ bank accounts */
const BANK_COLUMNS: LineColumn<Row<EmployeeBankAccount>>[] = [
  { key: 'bank_code', label: 'Bank' },
  { key: 'branch', label: 'Branch' },
  { key: 'account_no', label: 'Account No.' },
  { key: 'percentage', label: 'Split %', type: 'number', width: 100 },
];
const emptyBank = (): Row<EmployeeBankAccount> => ({ employee_id: 0, bank_code: null, branch: null, account_no: '', percentage: 100 });

export function BankAccountsPanel({ employeeId, rows, canManage }: { employeeId: number; rows: EmployeeBankAccount[]; canManage: boolean }) {
  return (
    <LineRowsPanel title="Bank Accounts" rows={strip(rows)} columns={BANK_COLUMNS} icon="🏦"
      sub="Split percentages across every row must add up to 100%"
      manageButton={canManage ? (
        <LineRowsFormButton title="Bank accounts" rows={strip(rows)} columns={BANK_COLUMNS} emptyRow={emptyBank}
          onSave={(r) => saveBankAccounts(employeeId, r)} className="btn sm ghost" successTitle="Bank accounts saved">
          Manage
        </LineRowsFormButton>
      ) : null} />
  );
}
