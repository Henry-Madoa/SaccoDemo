table 52204057 "Loan Recovery Header"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "Loan Recovery List";
    LookupPageId = "Loan Recovery List";

    fields
    {
        field(1; "No."; Code[20])
        {
        }
        field(2; "Member No"; Code[20])
        {
            TableRelation = Members;

            trigger OnValidate()
            var
                Members: Record Members;
                LoansMgt: Codeunit "Loans Management";
            begin
                Members.Get("Member No");
                "Member Name" := Members."Full Name";
                "Member Deposits" := LoansMgt.GetMemberDeposits("Member No");
            end;
        }
        field(3; "Member Name"; Text[150])
        {
            Editable = false;
        }
        field(4; "Loan No"; code[20])
        {
            TableRelation = Loans where("Member No." = field("Member No"), "Loan Balance" = filter('>0'));

            trigger OnValidate()
            var
                Loans: Record Loans;
                LoansMgt: Codeunit "Loans Management";
                AccruedInterest: Decimal;
            begin
                if Loans.Get("Loan No") then begin
                    Loans.CalcFields("Loan Balance", "Principal Balance");
                    "Product Description" := Loans."Product Description";
                    "Product Code" := Loans."Product Code";
                    "Loan Balance" := Loans."Loan Balance";
                    AccruedInterest := 0;
                    AccruedInterest := LoansMgt.GetProratedInterest("Loan No", "Posting Date");
                    "Accrued Interest" := AccruedInterest;
                    "Total Recoverable" := "Accrued Interest" + "Loan Balance";
                end;
            end;
        }
        field(5; "Product Code"; Code[20])
        {
            Editable = false;
        }
        field(6; "Product Description"; Text[100])
        {
            Editable = false;
        }
        field(7; "Loan Balance"; Decimal)
        {
            Editable = false;
        }
        field(8; "Posting Date"; Date)
        {
            trigger OnValidate()
            begin
                Validate("Loan No");
            end;
        }
        field(9; "Accrued Interest"; Decimal)
        {
            Editable = false;
        }
        field(10; "Total Recoverable"; Decimal)
        {
            Editable = false;
        }
        field(11; "Self Recovery Amount"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Loan Recovey Accounts"."Recovery Amount" where("Document No" = field("No.")));
        }
        field(12; "Member Deposits"; Decimal)
        {
            Editable = false;
        }
        field(13; "Created On"; DateTime)
        {
            Editable = false;
        }
        field(14; "Created By"; code[50])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(15; Status; Enum "Document Status")
        {
            Editable = false;
        }
        field(16; Processed; Boolean)
        {
            Editable = false;
        }
        field(17; "Guarantor Deposit Recovery"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Loan Recovery Lines"."Recovery Amount" where("No." = field("No."), "Recovery Type" = const(Deposits)));
        }
        field(18; "Guarantor Liability Recovery"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Loan Recovery Lines"."Recovery Amount" where("No." = field("No."), "Recovery Type" = const("Guarantor Liability Loan")));
        }
        field(19; "Member Balances"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = - sum("Detailed Vendor Ledg. Entry".Amount where("Member No." = field("Member No"), "Product Posting Type" = filter("Holiday Account" | "Non Withdrawable Deposit" | "Withdrawable Deposit")));
            Editable = false;
        }
        field(20; "Recovery Account Name"; Text[100])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Loan Recovey Accounts"."Account Name" where("Document No" = field("No.")));
        }
    }
    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }
    var
        SaccoSetup: Record "General Ledger Setup";
        Noseries: Codeunit NoSeriesManagement;

    trigger OnInsert()
    begin
        SaccoSetup.Get();
        SaccoSetup.TestField("Loan Recovery Nos");
        "No." := Noseries.GetNextNo(SaccoSetup."Loan Recovery Nos", Today, true);
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
        "Posting Date" := WorkDate;
    end;

    trigger OnDelete()
    var
        LoanRecoveryLines: Record "Loan Recovery Lines";
    begin
        TestField(Status, Status::Open);
        LoanRecoveryLines.Reset;
        LoanRecoveryLines.SetRange("No.", "No.");
        LoanRecoveryLines.DeleteAll;
    end;

    procedure Navigate()
    var
        NavigatePage: Page Navigate;
    begin
        NavigatePage.SetDoc("Posting Date", "No.");
        NavigatePage.SetRec(Rec);
        NavigatePage.Run;
    end;
}
