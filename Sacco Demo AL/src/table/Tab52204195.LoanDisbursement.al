table 52204195 "Loan Disbursement"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Loan Disbursements";
    DrillDownPageId = "Loan Disbursements";

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Description; Text[100])
        {
        }
        field(3; "Member No."; Code[20])
        {
            TableRelation = Members where(Status = const(Active));

            trigger OnValidate()
            begin
                Members.Get("Member No.");
                "Member Name" := Members.FullName;
            end;
        }
        field(4; "Member Name"; Text[80])
        {
            Editable = false;
        }
        field(5; "Loan No."; Code[20])
        {
            TableRelation = Loans where("Member No." = field("Member No."), "Mode of Disbursement" = const("FOSA (Partial)"), "Loan Balance" = filter(<> 0), "Fully Disbursed" = const(false));

            trigger OnValidate()
            var
                GeneralLedgerSetup: Record "General Ledger Setup";
            begin
                Loans.Get("Loan No.");
                Loans.CalcFields(Disbursements);
                "Approved Amount" := Loans."Approved Amount";

                "Disbursed Amount" := Loans.Disbursements;

                if Loans."Posting Date" < GeneralLedgerSetup."Opening Balance Posting Date" then
                    "Disbursed Amount" := Loans."Openning Disbursed Balance";

            end;
        }
        field(6; "Approved Amount"; Decimal)
        {
            Editable = false;
        }
        field(7; "Disbursed Amount"; Decimal)
        {
            Editable = false;
        }
        field(8; Amount; Decimal)
        {
            trigger OnValidate()
            begin
                If (Amount > "Approved Amount" - "Disbursed Amount") then Error('You cannot disburse more that the remaining Amount \\Remaining Amount: %1', "Approved Amount" - "Disbursed Amount");
                Validate("Charge Code");
            end;
        }
        field(9; "Charge Code"; Code[20])
        {
            TableRelation = "Transaction Charges";

            trigger OnValidate()
            begin
                if "Charge Code" <> '' then "Charge Amount" := Integrations.GetChargesAmount("Charge Code", Amount);
            end;
        }
        field(10; "Charge Amount"; Decimal)
        {
            Editable = false;
        }
        field(11; Status; Enum "Document Status")
        {
            Editable = false;
        }
        field(12; "Created By"; Code[100])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(13; "Created On"; DateTime)
        {
            Editable = false;
        }
        field(14; "Processed By"; Code[50])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(15; Processed; Boolean)
        {
            Editable = false;
        }
        field(16; "Processed On"; Date)
        {
            Editable = false;
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        NoSeries: Codeunit "No. Series";
        Members: Record Members;
        Loans: Record Loans;
        Integrations: Codeunit "Journal Management";

    trigger OnInsert()
    begin
        GeneralLedgerSetup.Get;
        GeneralLedgerSetup.TestField("Loan Disbursement Nos.");
        "No." := NoSeries.GetNextNo(GeneralLedgerSetup."Loan Disbursement Nos.", Today, true);
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
    end;

    trigger OnDelete()
    begin
        TestField(Status, Status::Open);
    end;

    procedure AssistEdit(OldLoanDisbursement: Record "Loan Disbursement"): Boolean
    var
        LoanDisbursement: Record "Loan Disbursement";
    begin
        LoanDisbursement := Rec;
        GeneralLedgerSetup.Get;
        GeneralLedgerSetup.TestField("Loan Disbursement Nos.");
        if NoSeries.LookupRelatedNoSeries(GeneralLedgerSetup."Loan Disbursement Nos.", GeneralLedgerSetup."Loan Disbursement Nos.", GeneralLedgerSetup."Loan Disbursement Nos.") then begin
            LoanDisbursement."No." := NoSeries.GetNextNo(GeneralLedgerSetup."Loan Disbursement Nos.");
            Rec := LoanDisbursement;
            exit(true);
        end;
    end;

    procedure DocumentNoIsVisible(): Boolean
    var
        DocumentNoVisibility: Codeunit DocumentNoVisibility;
        DocNoVisible: Boolean;
        NoSeriesCode: Code[20];
    begin
        GeneralLedgerSetup.Get;
        GeneralLedgerSetup.TestField("Loan Disbursement Nos.");
        NoSeriesCode := GeneralLedgerSetup."Loan Disbursement Nos.";
        DocNoVisible := DocumentNoVisibility.ForceShowNoSeriesForDocNo(NoSeriesCode);
        exit(DocNoVisible);
    end;

    procedure OnBeforeSendForApproval()
    begin
        TestField(Description);
        TestField("Member No.");
        TestField("Loan No.");
        TestField(Amount);
    end;
}
