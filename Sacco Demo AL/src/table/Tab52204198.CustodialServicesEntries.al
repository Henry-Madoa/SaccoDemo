table 52204198 "Custodial Services Entries"
{
    fields
    {
        field(1; "Custodial No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Posting Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(4; Description; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(5; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(6; Posted; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(7; "Entry Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Billable,Information';
            OptionMembers = Billable, Information;
        }
    }
    keys
    {
        key(Key1; "Custodial No.", "Document No.")
        {
            Clustered = true;
        }
    }
}
