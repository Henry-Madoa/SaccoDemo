table 52204091 "Cheque Book Applications"
{
    DataClassification = ToBeClassified;

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
            begin
                "Account Name" := '';
                "Account No" := '';
                Members.Get("Member No");
                "Member Name" := Members."Full Name";
            end;
        }
        field(3; "Member Name"; Text[150])
        {
            Editable = false;
        }
        field(4; "Application Date"; Date)
        {
        }
        field(5; "Clearing Charge"; Code[20])
        {
            TableRelation = "Transaction Charges";

            ;
        }
        field(6; "Serial No"; Code[20])
        {
        }
        field(7; "Created On"; DateTime)
        {
            Editable = false;
        }
        field(8; "Created By"; Code[100])
        {
            Editable = false;
        }
        field(9; Status; Enum "Document Status")
        {
            Editable = false;
        }
        field(10; "Processed"; Boolean)
        {
            Editable = false;
        }
        field(11; "Processed On"; Date)
        {
            Editable = false;
        }
        field(12; "Account No"; Code[20])
        {
            TableRelation = Vendor where("Member No." = field("Member No"), "Cheque Book Allowed" = const(true));

            trigger OnValidate()
            var
                ChequeBook: Record "Cheque Books";
            begin
                ChequeBook.Reset();
                ChequeBook.SetRange("Account No", "Account No");
                ChequeBook.SetRange(Active, true);
                if ChequeBook.FindFirst() then begin
                    ChequeBook.CalcFields(Drawn);
                    "Leaf Balance" := ChequeBook."No of Leafs" - ChequeBook.Drawn;
                    Vendor.Get("Account No");
                    "Account Name" := Vendor.Name;
                end;
            end;
        }
        field(13; "Account Name"; Text[150])
        {
            Editable = false;
        }
        field(14; "Collected By Name"; Text[150])
        {
        }
        field(15; "Collected By ID No"; Code[20])
        {
        }
        field(16; "Collected By Phone No"; Code[20])
        {
        }
        field(17; "Collected On"; Date)
        {
        }
        field(18; "Collected At"; Time)
        {
        }
        field(19; "Leaf Charge"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(20; "No. of Leafs"; Integer)
        {
            trigger OnValidate()
            var
                JournalMgt: Codeunit "Journal Management";
            begin
                TestField("Leaf Charge");
                "Charge Amount" := JournalMgt.GetChargesAmount("Leaf Charge", "No. of Leafs");
            end;
        }
        field(21; "Charge Amount"; Decimal)
        {
            Editable = false;
        }
        field(22; "Leaf Balance"; Integer)
        {
            Editable = false;
        }
        field(23; "Reason for Application"; Text[250])
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
    fieldgroups
    {
        fieldgroup(DropDown; "No.", "Member No", "Serial No")
        {
        }
    }
    var
        SaccoSetup: Record "General Ledger Setup";
        NoSeries: Codeunit NoSeriesManagement;
        Vendor: Record Vendor;

    trigger OnInsert()
    begin
        SaccoSetup.Get();
        SaccoSetup.TestField("Cheque Book App. Nos");
        "No." := NoSeries.GetNextNo(SaccoSetup."Cheque Book App. Nos", Today, true);
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
        "Application Date" := WorkDate;
    end;

    procedure Navigate()
    var
        NavigatePage: Page Navigate;
    begin
        NavigatePage.SetDoc("Processed On", "No.");
        NavigatePage.SetRec(Rec);
        NavigatePage.Run;
    end;

    trigger OnDelete()
    begin
        TestField(Status, Status::Open);
    end;
}
