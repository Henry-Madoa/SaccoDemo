table 52203541 "PV EFT Charges"
{
    LookupPageId = "Payment EFT Charges";
    DrillDownPageId = "Payment EFT Charges";

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Line No"; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(3; Code; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Charges Setup";

            trigger OnValidate()
            begin
                if ChargesSetup.Get(Code)then begin
                    ChargesSetup.TestField("GL Account");
                    Description:=ChargesSetup.Description;
                    "GL Account":=ChargesSetup."GL Account";
                end;
            end;
        }
        field(4; Description; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5; "GL Account"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "G/L Account" where(Blocked=const(false), "Direct Posting"=const(true), "Account Type"=const(Posting));
        }
        field(6; "Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(7; Posted; Boolean)
        {
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "No.", "Line No")
        {
        }
    }
    trigger OnDelete()
    begin
        If PVHeader.Get(Rec."No.")then PVHeader.TestField(Status, PVHeader.Status::Open);
    end;
    trigger OnInsert()
    begin
        If PVHeader.Get(Rec."No.")then PVHeader.TestField(Status, PVHeader.Status::Open);
    end;
    var ChargesSetup: Record "Charges Setup";
    PVHeader: Record "Payment Voucher";
}
