tableextension 52203437 "Human Resources Setup" extends "Human Resources Setup"
{
    fields
    {
        // Add changes to table fields here
        field(52203423; "Working Hours in a Day"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(52203424; "Applicant Nos."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(52203425; "Overtime Nos."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(52203426; "Appraisal Nos"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(52203427; "Appraisal Journal Template"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(52203428; "Appraisal Journal Batch"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(52203429; "Disciplinary Cases Nos"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(52203430; "Job Application Nos"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(52203431; "Job Nos"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(52203432; "Job Requisition Nos"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(52203433; "Trainers Nos"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(52203434; "Training Application Nos"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(52203435; "Interview Nos"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(52203436; "Exit Nos"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(52203437; "Contract Exp. Not. Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(52203438; "Appraisal Notification Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(52203439; "Training Plan Nos"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(52203440; "Maximum No. of Trainings"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(52203441; "Training Notification"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(52203442; "Web Client Link"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(52203443; "Probation Notifications"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(52203444; "Delete Apps Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(52203445; "Document Upload Nos."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(52203446; "Imprest Limits"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(52203447; "Profile Nos"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(52203448; "Grievances Nos"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(52203449; "Change Request Nos."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(52203450; "Medical Expense Account"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No." WHERE("Account Category" = FILTER(Expense | Liabilities));
        }
        field(52203451; "Maximum Imprest Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(52203452; "Dependant Age Limit"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(52203453; "Exit Form Nos."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(52203454; "Work Start Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(52203455; "Work End Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(52203456; "Maximum Overtime Hours"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(52203457; "Leave Reimbursement Nos."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(52203458; "One Point Eligibility"; Text[70])
        {
            DataClassification = ToBeClassified;

            trigger OnLookup()
            begin
                AppraisalRatings.Reset;
                if PAGE.RunModal(PAGE::"Appraisal Ratings", AppraisalRatings) = ACTION::LookupOK then "One Point Eligibility" := AppraisalRatings.Code;
            end;
        }
        field(52203459; "One Point Nos."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(52203460; "KRA Percentage"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(52203461; "Competencies Percentage"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(52203462; "Union Retirement Age"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(52203463; "Basic Pay Divider Union"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(52203464; "Basic Pay Divider Professional"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(52203465; "Retirement Age"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(52203466; "Leave Allowance Min. Days"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(52203467; "Training Need"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(52203468; PAYE; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(52203469; NSSF; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(52203470; VAT; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(52203471; Pension; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(52203472; "Installment Tax"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(52203473; "Corp Tax"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(52203474; "Installment Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(52203475; "Logo Position on Documents"; Option)
        {
            Caption = 'Logo Position on Documents';
            DataClassification = ToBeClassified;
            OptionCaption = 'No Logo,Left,Center,Right';
            OptionMembers = "No Logo",Left,Center,Right;
        }
        field(52203476; No; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(52203477; "Default Location"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Location.Code;
        }
        field(52203478; "Payslip Message"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(52203479; "Training Expense Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Expense Codes" where("Account Type" = const("G/L Account"));
        }
        field(52203480; "Overtime Expense Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Expense Codes" where("Account Type" = const("G/L Account"));
        }
        field(52203481; "Laptop Expense Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Expense Codes" where("Account Type" = const("G/L Account"));
        }
        field(52203482; "Laptop Facilitation %"; Decimal)
        {
            DataClassification = ToBeClassified;
            MinValue = 1;
            MaxValue = 100;
        }
        field(52203483; "Laptop Facilitation Limit"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }
    var
        AppraisalRatings: Record "Appraisal Ratings";
}
