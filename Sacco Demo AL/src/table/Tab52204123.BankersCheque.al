table 52204123 "Bankers Cheque"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Bankers Cheques";
    DrillDownPageId = "Bankers Cheques";

    fields
    {
        field(1; "No."; code[20])
        {
            Editable = false;
        }
        field(2; "Cheque Type"; code[20])
        {
            TableRelation = "Cheque Types" where(Type = const("Bankers Cheque"));

            trigger OnValidate()
            begin
                if ChequeTypes.Get("Cheque Type", ChequeTypes.Type::"Bankers Cheque") then begin
                    Description := ChequeTypes.Description;
                    "Max. Amount" := ChequeTypes."Maximum Amount";
                    "No. Series" := ChequeTypes."Transaction Nos.";
                end;
            end;
        }
        field(3; Description; Text[50])
        {
            Editable = false;
        }
        field(4; "Max. Amount"; Decimal)
        {
            Editable = false;
        }
        field(5; "Member No."; Code[20])
        {
            TableRelation = Members;

            trigger OnValidate()
            begin
                if Members.Get("Member No.") then "Account Name" := Members."Full Name";
            end;
        }
        field(6; "Account Type"; Code[20])
        {
            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                if Vendor.Get("Account Type") then begin
                    Vendor.CalcFields(Balance);
                    "Book Balance" := Vendor.Balance;
                end;
            end;

            trigger OnLookup()
            var
                Vendor: Record Vendor;
            begin
                Vendor.Reset();
                Vendor.SetRange("Member No.", "Member No.");
                Vendor.SetRange("Cash Transfer Allowed", true);
                Vendor.SetFilter("Product Posting Type", '%1|%2|%3|%4|%5', Vendor."Product Posting Type"::"Withdrawable Deposit", Vendor."Product Posting Type"::"Investments Account", Vendor."Product Posting Type"::"Holiday Account", Vendor."Product Posting Type"::"School Fee Account", Vendor."Product Posting Type"::"Junior Account");
                Vendor.SetRange(Blocked, Vendor.Blocked::" ");
                if Page.RunModal(0, Vendor) = Action::LookupOK then begin
                    Validate("Account Type", Vendor."No.");
                end;
            end;
        }
        field(7; "Account Name"; Text[50])
        {
            Editable = false;
        }
        field(8; "Payee Details"; Text[250])
        {
        }
        field(9; "Book Balance"; Decimal)
        {
            Editable = false;
        }
        field(10; Amount; Decimal)
        {
            trigger OnValidate()
            begin
                if Amount > "Max. Amount" then Error('You Cannot Sell Bankers Cheques More than %1', "Max. Amount");
                if Amount > "Book Balance" then Error('You Cannot Sell Bankers Cheques More than %1', "Book Balance");
                if Amount < 0 then Error('Please fill in the amount');
                if ChequeTypes.Get("Cheque Type", ChequeTypes.Type::"Bankers Cheque") then begin
                    if ChequeTypes."Clearing Charge" <> '' then begin
                        "Charge Amount" := JournalMgmt.GetChargesAmount(ChequeTypes."Clearing Charge", Amount);
                        "Net Amount" := Amount + "Charge Amount";
                    end;
                end;
            end;
        }
        field(11; "Created By"; Code[50])
        {
            TableRelation = "User Setup";
            Editable = false;
        }
        field(12; "Created On"; DateTime)
        {
            Editable = false;
        }
        field(13; "Posting Date"; Date)
        {
        }
        field(14; Posted; Boolean)
        {
            Editable = false;
        }
        field(15; "No. Series"; code[20])
        {
            Editable = false;
        }
        field(16; Status; Enum "Document Status")
        {
            Editable = false;
        }
        field(17; "Cheque No."; Code[20])
        {
        }
        field(18; "Charge Amount"; Decimal)
        {
            Editable = false;
        }
        field(19; "Net Amount"; Decimal)
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
    var
        NoSeries: Codeunit NoSeriesManagement;
        Members: Record Members;
        ChequeTypes: Record "Cheque Types";
        JournalMgmt: Codeunit "Journal Management";

    trigger OnInsert()
    begin
        "No." := NoSeries.GetNextNo("No. Series", Today, true);
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
        "Posting Date" := WorkDate();
    end;

    procedure Navigate()
    var
        NavigatePage: Page Navigate;
    begin
        NavigatePage.SetDoc("Posting Date", "No.");
        NavigatePage.SetRec(Rec);
        NavigatePage.Run;
    end;

    trigger OnDelete()
    begin
        TestField(Status, Status::Open);
    end;
}
