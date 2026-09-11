table 52204206 "Member Charging"
{
    LookupPageId = "Member Chargings";
    DrillDownPageId = "Member Chargings";
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            Editable = false;
        }
        field(2; "Description"; Text[100])
        {
        }
        field(3; "Member No."; Code[20])
        {
            TableRelation = Members;

            trigger OnValidate()
            begin
                if Member.Get("Member No.") then begin
                    "Member Name" := Member.FullName;
                    Validate("Source Account", MemberManagement.GetMemberAccount("Member No.", ProductPostingType::"Withdrawable Deposit"));
                end;
            end;
        }
        field(4; "Member Name"; Text[80])
        {
            Editable = false;
        }
        field(5; "Source Account"; Code[20])
        {
            Editable = false;
            TableRelation = Vendor where("Member No." = field("Member No."));

            trigger OnValidate()
            begin
                if Vendor.Get("Source Account") then begin
                    Vendor.CalcFields(Balance, "Uncleared Funds");
                    SaccoProducts.Get(Vendor."Product Code");
                    "Source Balance" := Vendor.Balance - Vendor."Uncleared Funds" - SaccoProducts."Minimum Balance" - ChannelsIntegrations.GetPendingChannelsTransactions(Vendor."Member No.");
                    if "Source Balance" < 0 then "Source Balance" := 0;
                end;
            end;
        }
        field(6; "Source Balance"; Decimal)
        {
            Editable = false;
        }
        field(7; "Charge Code"; Code[20])
        {
            TableRelation = "Transaction Charges";

            trigger OnValidate()
            var
                TransactionCharges: Record "Transaction Charges";
                JournalManagement: Codeunit "Journal Management";
            begin
                If TransactionCharges.Get("Charge Code") then
                    "Posting Transaction Type" := TransactionCharges."Posting Transaction Type";

                Validate("Amount Charged", JournalManagement.GetChargesAmount("Charge Code", "No Of Pages"));
            end;
        }
        field(8; "Posting Transaction Type"; Enum "Sacco Transaction Type")
        {
        }
        field(9; "No Of Pages"; Integer)
        {
            trigger OnValidate()
            begin
                Validate("Charge Code");
            end;
        }
        field(10; "Amount Charged"; Decimal)
        {
            Editable = false;

            trigger OnValidate()
            begin
                If "Source Balance" < "Amount Charged" then Error('The Account has insufficient balance for charging');
            end;
        }
        field(11; "Created By"; Code[50])
        {
        }
        field(12; "Created On"; DateTime)
        {
        }
        field(13; Posted; Boolean)
        {
        }
        field(14; "Posted By"; Code[50])
        {
        }
        field(15; "Posted On"; DateTime)
        {
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
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.TestField("Member Charging Nos.");
        if "No." = '' then "No." := NoSeries.GetNextNo(GeneralLedgerSetup."Member Charging Nos.", Today, true);
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
    end;

    trigger OnDelete()
    begin
        TestField(Posted, false);
    end;

    trigger OnRename()
    begin
        TestField(Posted, false);
    end;

    var
        Vendor: Record Vendor;
        Member: Record Members;
        MemberManagement: Codeunit "Member Management";
        ChannelsIntegrations: Codeunit "Channels Integrations";
        NoSeries: Codeunit NoSeriesManagement;
        ProductPostingType: Enum "Product Posting Type";
        SaccoProducts: Record "Sacco Products";
        GeneralLedgerSetup: Record "General Ledger Setup";

    procedure OnBeforePosting()
    begin
        TestField("Member No.");
        TestField("Charge Code");
        TestField(Description);
        if "Posting Transaction Type" = "Posting Transaction Type"::"Statement Charge" then TestField("No Of Pages");
        TestField("Amount Charged");
    end;

    procedure Navigate()
    var
        NavigatePage: Page Navigate;
    begin
        NavigatePage.SetDoc(System.DT2Date("Posted On"), "No.");
        NavigatePage.SetRec(Rec);
        NavigatePage.Run;
    end;
}
