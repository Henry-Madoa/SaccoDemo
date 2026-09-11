table 52204049 "External Recoveries Setup"
{
    DataClassification = ToBeClassified;
    LookupPageId = "External Recoveries Setup";
    DrillDownPageId = "External Recoveries Setup";

    fields
    {
        field(1; "Recovery Code"; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Recovery Description"; Text[50])
        {
        }
        field(3; "Post To Account Type"; Option)
        {
            OptionMembers = "G/L Account", "Payable Account";
        }
        Field(4; "Post To Account No"; Code[20])
        {
            TableRelation = if("Post To Account Type"=const("G/L Account"))"G/L Account" Where("Direct Posting"=const(true))
            else
            vendor where("Member No."=const(''));
        }
        field(5; Commission; Decimal)
        {
        }
        field(6; "Commission Account"; Code[20])
        {
            TableRelation = "G/L Account";
        }
    }
    keys
    {
        key(Key1; "Recovery Code")
        {
            Clustered = true;
        }
    }
}
