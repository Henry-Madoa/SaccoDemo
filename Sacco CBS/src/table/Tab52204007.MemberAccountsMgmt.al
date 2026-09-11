table 52204007 "Member Accounts Mgmt."
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(2; "Document Type"; Enum "Member Accounts Mgmt. Types")
        {
        }
        field(3; Description; Text[250])
        {
            Caption = 'Reason';
        }
        field(4; Date; Date)
        {
            Editable = false;
        }
        field(5; "Member No."; Code[20])
        {
            TableRelation = Members;

            trigger OnValidate()
            begin
                Member.Get("Member No.");
                "Member Name" := Member.FullName;
            end;
        }
        field(6; "Member Name"; Text[100])
        {
            Editable = false;
        }
        field(7; "Account No"; Code[20])
        {
            TableRelation = if ("Document Type" = const(Activation)) Vendor where("Member No." = field("Member No."), "Product Posting Type" = filter(<> "Loan Account" & <> "Withdrawable Deposit" & <> "Share Capital Account" & <> "Non Withdrawable Deposit" & <> "Benevolent Account"), Status = filter(Closed | Withdrawn | Deceased))
            else if ("Document Type" = const(Deactivation)) Vendor where("Member No." = field("Member No."), "Product Posting Type" = filter(<> "Loan Account" & <> "Withdrawable Deposit" & <> "Share Capital Account" & <> "Non Withdrawable Deposit" & <> "Benevolent Account"), Status = filter(Active | Dormant | "Not Paid Up" | Inactive));

            trigger OnValidate()
            begin
                Vend.Get("Account No");
                Vend.CalcFields(Balance);
                "Account Name" := Vend.Name;
                Balance := Vend.Balance;
            end;
        }
        field(8; "Account Name"; Text[100])
        {
            Editable = false;
        }
        field(9; Balance; Decimal)
        {
            Editable = false;
        }
        field(10; Charge; Code[20])
        {
            TableRelation = "Transaction Charges";

            trigger OnValidate()
            begin
                TransactionCharges.Get(Charge);
                "Charge Description" := TransactionCharges.Description;
                "Charge Amount" := JournalMgmt.GetChargesAmount(Charge, 1);
            end;
        }
        field(11; "Charge Description"; Text[100])
        {
            Editable = false;
        }
        field(12; "Charge Amount"; Decimal)
        {
            Editable = false;
        }
        field(14; Status; Enum "Document Status")
        {
            Editable = false;
        }
        field(15; Processed; Boolean)
        {
            Editable = false;
        }
        field(16; "Processed By"; Code[50])
        {
            Editable = false;
        }
        field(17; "Processed Date"; Date)
        {
            Editable = false;
        }
        field(18; "Deactivation Reason"; Text[250])
        {
            TableRelation = "Blocked Reason".Description;
            Editable = false;
        }
        field(19; "Created By"; Code[100])
        {
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        Date := WorkDate;
        SaccoSetup.Get;
        if "No." = '' then begin
            if "Document Type" = "Document Type"::Activation then begin
                SaccoSetup.TestField("Member Acc. Activation Nos.");
                "No." := NoSeries.GetNextNo(SaccoSetup."Member Acc. Activation Nos.", Today, true);
            end
            else if "Document Type" = "Document Type"::Deactivation then begin
                SaccoSetup.TestField("Member Acc. Deativation Nos.");
                "No." := NoSeries.GetNextNo(SaccoSetup."Member Acc. Deativation Nos.", Today, true);
            end;
        end;
        "Created By" := UserId;
    end;

    trigger OnDelete()
    begin
        TestField(Status, Status::Open);
    end;

    var
        Member: Record Members;
        Vend: Record Vendor;
        TransactionCharges: Record "Transaction Charges";
        SaccoSetup: Record "General Ledger Setup";
        NoSeries: Codeunit NoSeriesManagement;
        JournalMgmt: Codeunit "Journal Management";

    procedure Navigate()
    var
        NavigatePage: Page Navigate;
    begin
        NavigatePage.SetDoc("Processed Date", "No.");
        NavigatePage.SetRec(Rec);
        NavigatePage.Run;
    end;

    procedure OnBeforeSendForApproval()
    begin
        if "Document Type" = "Document Type"::Deactivation then begin
            TestField(Description);
            TestField("Deactivation Reason");
            TestField("Account No");
            TestField(Balance, 0);
        end;
        if "Document Type" = "Document Type"::Deactivation then begin
            TestField(Description);
            TestField("Account No");
        end;
    end;
}
