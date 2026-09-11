table 52203423 "Receipt Header"
{
    DataClassification = ToBeClassified;
    LookupPageId = Receipts;
    DrillDownPageId = Receipts;

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Receipt Type";Enum "Receipt Type")
        {
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                ReceiptLines.Reset;
                ReceiptLines.SetRange("No.", Rec."No.");
                If ReceiptLines.FindFirst then ReceiptLines.DeleteAll(true);
            end;
        }
        field(3; "Bank Account"; Code[20])
        {
            TableRelation = "Bank Account";

            trigger OnValidate()
            begin
                if Bank.Get("Bank Account")then "Bank Account Name":=Bank.Name;
            end;
        }
        field(4; "Bank Account Name"; Text[100])
        {
            Editable = false;
        }
        field(5; "External Document No."; code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Manual Receipt No."; Code[100])
        {
        }
        field(7; "Pay Mode"; code[20])
        {
            TableRelation = "Payment Method";
        }
        field(8; Description; Text[50])
        {
        }
        field(9; Amount; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Receipt Lines".Amount where("No."=field("No.")));
            Editable = false;
        }
        field(10; "Global Dimension 1 Code"; code[20])
        {
            CaptionClass = '1,1,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1));
        }
        field(11; "Global Dimension 2 Code"; code[20])
        {
            CaptionClass = '1,1,2';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2));
        }
        field(12; Status;Enum "Document Status")
        {
            Editable = false;
        }
        field(13; "Created By"; Code[100])
        {
            TableRelation = "User Setup";
            Editable = false;
        }
        field(14; "Created On"; Date)
        {
            Editable = false;
        }
        field(15; "Posted Date"; Date)
        {
            Editable = false;
        }
        field(16; Posted; Boolean)
        {
            Editable = true;
        }
        field(17; "Approval Limit"; Decimal)
        {
            Editable = true;
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }
    var GeneralLedgerSetup: Record "General Ledger Setup";
    NoSeries: Codeunit NoSeriesManagement;
    Bank: Record "Bank Account";
    Employee: Record Employee;
    UserSetup: Record "User Setup";
    ReceiptLines: Record "Receipt Lines";
    trigger OnDelete()
    begin
        TestField(Status, Status::Open);
        ReceiptLines.Reset();
        ReceiptLines.SetRange("No.", "No.");
        if ReceiptLines.FindSet then ReceiptLines.DeleteAll(true);
    end;
    trigger OnRename()
    begin
        TestField(Status, Status::Open);
    end;
    trigger OnInsert()
    begin
        GeneralLedgerSetup.get;
        GeneralLedgerSetup.TestField("Receipt Nos");
        GeneralLedgerSetup.TestField("Receipt Approval Limit");
        if "No." = '' then "No.":=NoSeries.GetNextNo(GeneralLedgerSetup."Receipt Nos", Today, true);
        "Created By":=UserId;
        "Created On":=WorkDate;
        if UserSetup.Get(UserId)then if Employee.Get(UserSetup."Employee No.")then begin
                "Global Dimension 1 Code":=Employee."Global Dimension 1 Code";
                "Global Dimension 2 Code":=Employee."Global Dimension 2 Code";
            end;
        "Approval Limit":=GeneralLedgerSetup."Receipt Approval Limit";
    end;
    procedure Navigate()
    var
        NavigatePage: Page Navigate;
    begin
        NavigatePage.SetDoc("Posted Date", "No.");
        NavigatePage.SetRec(Rec);
        NavigatePage.Run;
    end;
}
