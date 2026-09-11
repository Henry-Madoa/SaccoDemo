table 52203719 "Witholding Entries"
{
    fields
    {
        field(1; "Document No."; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "G/L Account"; Code[30])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "G/L Account" <> '' then if GLAccount.Get("G/L Account")then "G/L Name":=GLAccount.Name;
            end;
        }
        field(4; "G/L Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Vendor No."; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Vendor Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Tax/VAT"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Tax,Vat';
            OptionMembers = Tax, Vat;
        }
        field(8; "Tax/Vat Code"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Posting Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Posted By"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Posted Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Currency Code"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(13; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Amount (LCY)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Exchange Rate"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Posted On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(17; Description; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(18; "PIN No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Document No.", "Line No.", "G/L Account")
        {
        }
    }
    var GLAccount: Record "G/L Account";
}
