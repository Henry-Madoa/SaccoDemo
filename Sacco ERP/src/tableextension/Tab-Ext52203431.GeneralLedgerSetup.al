tableextension 52203431 "General Ledger Setup" extends "General Ledger Setup"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Payment Voucher Template"; Code[10])
        {
            TableRelation = "Gen. Journal Template";
        }
        field(50001; "Claims Template"; Code[10])
        {
            TableRelation = "Gen. Journal Template";
        }
        field(50003; "Petty Cash Template"; Code[10])
        {
            TableRelation = "Gen. Journal Template";
        }
        field(50005; "Post VAT"; Boolean)
        {
        }
        field(50006; "Imprest Processing Max Time"; Decimal)
        {
        }
        field(50008; "PV Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(50009; "Imprest Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(50010; "Petty Cash Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(50012; "Receipt Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(50013; "Budget Check"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50014; "Current Budget Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(50015; "Current Budget End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(50016; "Current Budget"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Budget Name";
        }
        field(50017; "EFT Files Path"; Text[250])
        {
        }
        field(50018; "EFT Approver Email"; Text[50])
        {
        }
        field(50019; "Login Email Notification"; Boolean)
        {
            Caption = 'Email Notification';
        }
        field(50020; "Login SMS Notification"; Boolean)
        {
            Caption = 'SMS Notification';
        }
        field(50022; "Employee Payment Terms"; Code[10])
        {
            TableRelation = "Payment Terms";
        }
        field(50023; "Imprest Template"; Code[20])
        {
            TableRelation = "Gen. Journal Template";
        }
        field(50024; "Imprest Deduction Code"; Code[10])
        {
            TableRelation = "Payroll Transaction Code" where(Type = const(Deduction));
        }
        field(50025; "Imprest Earning Code"; Code[10])
        {
            TableRelation = "Payroll Transaction Code" where(Type = const(Income));
        }
        field(50026; "Contract Commitment Nos."; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(50027; "Watermark Portrait"; BLOB)
        {
            SubType = Bitmap;
        }
        field(50028; "Request for Payment Nos."; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(50029; "RFPY Workflow User Group"; Code[20])
        {
            TableRelation = "Workflow User Group";
        }
        field(50030; "PV Workflow User Group"; Code[20])
        {
            TableRelation = "Workflow User Group";
        }
        field(50031; "EFT Max Approval Amount"; Decimal)
        {
        }
        field(50032; "Commitment Nos."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(50034; "Staff Claim Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(50035; "Suppl. Budget Request Nos"; Code[20])
        {
            TableRelation = "No. Series";
            Caption = 'Virement Budget Request Nos.';
        }
        field(50036; "Email Pattern"; Text[250])
        {
        }
        field(50037; "Narration Pattern"; Text[250])
        {
        }
        field(50038; "Budget Plan"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(50039; "Imprest Batch"; Code[10])
        {
        }
        field(50058; "Max No Outstanding Imprests"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(50059; "Temporary Rights Nos."; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(50060; "Deactivate Mails"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50061; "JV Nos."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(50062; "FD No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(50063; "Reconsiliation Nos."; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(50064; "Rounding Type"; Option)
        {
            Caption = 'Amount Precision Type';
            OptionMembers = " ",Nearest,Up,Down;
        }
        field(50065; "Salary Advance Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(50066; "Payment Voucher Batch"; Code[10])
        {
        }
        field(50067; "Claims Batch"; Code[10])
        {
        }
        field(50068; "Imprest Surrender Batch"; Code[10])
        {
        }
        field(50069; "Petty Cash Batch"; Code[10])
        {
        }
        field(50071; "Board Allowance Nos"; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(50072; "Payroll Template"; Code[10])
        {
            TableRelation = "Gen. Journal Template";
        }
        field(50073; "Payroll Batch"; Code[10])
        {
        }
        field(52203457; "Receipt Approval Limit"; Decimal)
        {
        }
        field(52203458; "Petty Cash Limit"; Decimal)
        {
        }
        field(52203427; "Receipt Template"; Code[10])
        {
            TableRelation = "Gen. Journal Template";
        }
        field(52203455; "Receipt Batch"; Code[10])
        {
        }
    }
}
