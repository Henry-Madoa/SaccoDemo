table 52204093 "Inter Account Transfer"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            Editable = false;
        }
        field(2; "Document Type"; Option)
        {
            OptionMembers = "Savings Accounts","Share Capital";
        }
        field(3; Date; Date)
        {
            Editable = false;
        }
        field(4; "Member No"; Code[20])
        {
            TableRelation = Members;

            trigger OnValidate()
            var
                Vend: Record Vendor;
            begin
                Member.Get("Member No");
                if "Document Type" = "Document Type"::"Savings Accounts" then
                    Validate("Destination Member", "Member No");

                "Source Name" := Member."Full Name";
                "Transfer From" := '';

                if "Document Type" = "Document Type"::"Share Capital" then begin
                    if "Amount Type" = "Amount Type"::Full then begin
                        if not (Member.Status in [Member.Status::Deceased, Member.Status::Withdrawn]) then
                            Error('You can only transfer full Share Capital for Exited Members');
                    end;
                end;
                if "Document Type" = "Document Type"::"Savings Accounts" then begin
                    Vend.Reset;
                    Vend.SetRange("Member No.", "Member No");
                    Vend.SetRange("Product Posting Type", Vend."Product Posting Type"::"Withdrawable Deposit");
                    if Vend.FindFirst then begin
                        "Transacting Account" := Vend."No.";
                        Validate("Transfer From", Vend."No.");
                    end;
                end else if "Document Type" = "Document Type"::"Share Capital" then begin
                    Vend.Reset;
                    Vend.SetRange("Member No.", "Member No");
                    Vend.SetRange("Product Posting Type", Vend."Product Posting Type"::"Share Capital Account");
                    if Vend.FindFirst then
                        Validate("Transfer From", Vend."No.");
                end;
            end;
        }
        field(5; "Transacting Account"; Code[20])
        {
            Editable = false;
        }
        field(6; "Source Name"; Text[150])
        {
            Editable = false;
        }
        field(7; "Transfer From"; Code[20])
        {
            trigger OnLookup()
            var
                Vendor: Record Vendor;
            begin
                if "Document Type" = "Document Type"::"Savings Accounts" then begin
                    Vendor.Reset();
                    Vendor.SetRange("Member No.", "Member No");
                    Vendor.SetRange("Cash Transfer Allowed", true);
                    if Page.RunModal(0, Vendor) = ACTION::LookupOK then Validate("Transfer From", Vendor."No.");
                end;
            end;

            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                Vendor.Get("Transfer From");
                "Source Acc Posting Type" := Vendor."Product Posting Type";
                Vendor.CalcFields(Balance, "Uncleared Funds");
                SaccoProduct.Get(Vendor."Product Code");
                if "Amount Type" = "Amount Type"::Partial then
                    "Source Balance" := Abs(Vendor.Balance) - Vendor."Uncleared Funds" - SaccoProduct."Minimum Balance" else
                    "Source Balance" := Abs(Vendor.Balance) - Vendor."Uncleared Funds";
            end;
        }
        field(8; "Source Balance"; Decimal)
        {
            Caption = 'Balance';
            Editable = false;
        }
        field(9; "Source Acc Posting Type"; Enum "Product Posting Type")
        {
            Caption = 'Balance';
            Editable = false;
        }
        field(10; "Destination Member"; code[20])
        {
            Caption = 'Member';
            TableRelation = Members;

            trigger OnValidate()
            var
                Vend: Record Vendor;
            begin
                If "Document Type" = "Document Type"::"Share Capital" then begin
                    if "Destination Member" = "Member No" then
                        Error('You cannot transfer shares to the same Member.');
                end;
                Member.Get("Destination Member");
                "Destination Name" := Member."Full Name";
                "Destination Account" := '';

                if "Document Type" = "Document Type"::"Share Capital" then begin
                    Vend.Reset;
                    Vend.SetRange("Member No.", "Destination Member");
                    Vend.SetRange("Product Posting Type", Vend."Product Posting Type"::"Share Capital Account");
                    if Vend.FindFirst then
                        Validate("Destination Account", Vend."No.");
                end;
            end;
        }
        field(11; "Destination Account"; Code[20])
        {
            Caption = 'Account';

            trigger OnLookup()
            var
                Vendor: Record Vendor;
            begin
                if "Document Type" = "Document Type"::"Savings Accounts" then begin
                    Vendor.Reset();
                    Vendor.SetRange("Member No.", "Destination Member");
                    if (("Member No" = "Destination Member") and ("Transacting Account" = "Transfer From")) then
                        Vendor.SetFilter("Product Posting Type", '<>%1&<>%2', Vendor."Product Posting Type"::"Loan Account", Vendor."Product Posting Type"::"Withdrawable Deposit")
                    else if (("Member No" = "Destination Member") and ("Transacting Account" <> "Transfer From")) then begin
                        Vendor.SetFilter("Product Posting Type", '<>%1', Vendor."Product Posting Type"::"Loan Account");
                        Vendor.SetFilter("No.", '<>%1', "Transfer From");
                    end
                    else if "Member No" <> "Destination Member" then Vendor.SetFilter("Product Posting Type", '<>%1', Vendor."Product Posting Type"::"Loan Account");
                    if Page.RunModal(0, Vendor) = Action::LookupOK then begin
                        Validate("Destination Account", Vendor."No.");
                    end;
                end;
            end;

            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                Vendor.Get("Destination Account");
                "Destination Acc. Posting Type" := Vendor."Product Posting Type";
            end;
        }
        field(12; "Destination Name"; Text[150])
        {
            Editable = false;
            Caption = 'Name';
        }
        field(13; "Destination Acc. Posting Type"; Enum "Product Posting Type")
        {
            Caption = 'Balance';
            Editable = false;
        }
        field(14; "Amount Type"; Option)
        {
            OptionMembers = Partial,Full;
            trigger OnValidate()
            begin
                Validate("Member No");
                Validate("Transfer From");
            end;
        }
        field(15; Amount; Decimal)
        {
            trigger OnValidate()
            begin
                SaccoSetup.Get;
                Validate("Charge Code", SaccoSetup."Inter Acc Transfer Charges");
                If Amount - "Charge Amount" > "Source Balance" then
                    Error('You cannot transfer more than the Source Balance');
            end;
        }
        field(16; "Charge Code"; code[20])
        {
            Editable = false;
            TableRelation = "Transaction Charges";

            trigger OnValidate()
            var
                Integrations: Codeunit "Journal Management";
            begin
                if "Charge Code" <> '' then "Charge Amount" := Integrations.GetChargesAmount("Charge Code", Amount);
            end;
        }
        field(17; "Charge Amount"; Decimal)
        {
            Editable = false;
        }
        field(18; "Global Dimension 1 Code"; code[20])
        {
            CaptionClass = '1,1,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1), Blocked = const(false));
            Editable = false;
        }
        field(19; "Global Dimension 2 Code"; code[20])
        {
            CaptionClass = '1,1,2';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2), Blocked = const(false));
            Editable = false;
        }
        field(20; Status; Enum "Document Status")
        {
            Editable = false;
        }
        field(21; "Created By"; code[50])
        {
            TableRelation = "User Setup";
            Editable = false;
        }
        field(22; Posted; Boolean)
        {
            Editable = false;
        }
        field(23; "Posted Date"; Date)
        {
            Editable = false;
        }
        field(24; "Posted By"; code[50])
        {
            Editable = false;
            TableRelation = "User Setup";
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
        NoSeries: Codeunit NoSeriesManagement;
        SaccoSetup: Record "General Ledger Setup";
        SaccoProduct: Record "Sacco Products";
        Member: Record Members;
        UserSetup: Record "User Setup";
        Employee: Record Employee;

    trigger OnDelete()
    begin
        TestField(Status, Status::Open);
    end;

    trigger OnRename()
    begin
        TestField(Status, Status::Open);
    end;

    trigger OnInsert()
    begin
        SaccoSetup.Get();
        if "Document Type" = "Document Type"::"Savings Accounts" then begin
            SaccoSetup.TestField("Inter Acc. Trans. Nos.");
            if "No." = '' then "No." := NoSeries.GetNextNo(SaccoSetup."Inter Acc. Trans. Nos.", Today, true);
        end else if "Document Type" = "Document Type"::"Share Capital" then begin
            SaccoSetup.TestField("Share Capital Trans. Nos.");
            if "No." = '' then "No." := NoSeries.GetNextNo(SaccoSetup."Share Capital Trans. Nos.", Today, true);
        end;
        "Created By" := UserId;
        Date := WorkDate;
        Date := WorkDate;
        UserSetup.Get(UserId);
        if Employee.Get(UserSetup."Employee No.") then begin
            "Global Dimension 1 Code" := Employee."Global Dimension 1 Code";
            "Global Dimension 2 Code" := Employee."Global Dimension 2 Code";
        end;
    end;

    procedure Navigate()
    var
        NavigatePage: Page Navigate;
    begin
        NavigatePage.SetDoc("Posted Date", "No.");
        NavigatePage.SetRec(Rec);
        NavigatePage.Run;
    end;

    procedure OnBeforeSendForApproval()
    begin
        TestField(Amount);
    end;
}
