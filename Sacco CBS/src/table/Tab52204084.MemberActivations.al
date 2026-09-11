table 52204084 "Member Activations"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Member Activations";
    DrillDownPageId = "Member Activations";

    fields
    {
        field(1; "No."; code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Member No."; code[20])
        {
            TableRelation = Members where(Status = filter(<> Active));

            trigger OnValidate()
            var
                Members: Record Members;
            begin
                Members.Get("Member No.");
                "Member Name" := Members."Full Name";
            end;
        }
        field(3; "Member Name"; Text[100])
        {
            Editable = false;
        }
        field(4; "Document Date"; Date)
        {
        }
        field(5; Status; Enum "Document Status")
        {
            Editable = false;
        }
        field(6; Posted; Boolean)
        {
            Editable = false;
        }
        field(7; "Posted By"; Code[50])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(8; "Posted On"; DateTime)
        {
            Editable = false;
        }
        field(9; "Reactivation Fee"; Code[20])
        {
            TableRelation = "Transaction Charges";

            trigger OnValidate()
            var
                JournalMgt: Codeunit "Journal Management";
            begin
                "Reactivation Fee Amount" := JournalMgt.GetChargesAmount("Reactivation Fee", 1);
            end;
        }
        field(10; "Reactivation Fee Amount"; Decimal)
        {
            Editable = false;
        }
        field(11; "Payment Refrence"; code[20])
        {
        }
        field(12; "Pay From Account Type"; Option)
        {
            OptionMembers = "Cash Book","Member Account";
        }
        field(13; "Pay From Account"; Code[20])
        {
            trigger OnLookup()
            var
                Vendor: Record Vendor;
                Bank: Record "Bank Account";
            begin
                if "Pay From Account Type" = "Pay From Account Type"::"Cash Book" then begin
                    Bank.Reset();
                    Bank.SetRange(Blocked, false);
                    if Page.RunModal(0, Bank) = Action::LookupOK then begin
                        Validate("Pay From Account", Bank."No.");
                    end;
                end
                else begin
                    Vendor.Reset();
                    Vendor.SetRange("Member No.", Rec."Member No.");
                    Vendor.SetRange("Product Posting Type", Vendor."Product Posting Type"::"Withdrawable Deposit");
                    if Page.RunModal(0, Vendor) = Action::LookupOK then begin
                        Validate("Pay From Account", Vendor."No.");
                    end;
                end;
            end;
        }
        field(14; "Posting Date"; Date)
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
    var
        NoSeries: Codeunit NoSeriesManagement;
        SaccoSetup: Record "General Ledger Setup";
        Member: Record Members;

    trigger OnInsert()
    begin
        SaccoSetup.Get();
        SaccoSetup.TestField("Member Reactivation Nos");
        "No." := NoSeries.GetNextNo(SaccoSetup."Member Reactivation Nos", Today, true);
        "Document Date" := WorkDate;
    end;

    trigger OnDelete()
    begin
        TestField(Status, Status::Open);
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
