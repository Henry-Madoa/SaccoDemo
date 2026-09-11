table 52203502 "Charges Setup"
{
    LookupPageId = "Charges Setup";
    DrillDownPageId = "Charges Setup";

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Description; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
        field(4; "GL Account"; Code[20])
        {
            TableRelation = "G/L Account" where(Blocked=const(false), "Direct Posting"=const(true), "Account Type"=const(Posting));
        }
    }
    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; Code, Description, "VAT Prod. Posting Group", "GL Account")
        {
        }
        fieldgroup(Brick; Code, Description, "VAT Prod. Posting Group", "GL Account")
        {
        }
    }
}
