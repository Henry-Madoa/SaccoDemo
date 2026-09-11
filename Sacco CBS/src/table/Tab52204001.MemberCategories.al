table 52204001 "Member Categories"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Member Categories";
    DrillDownPageId = "Member Categories";

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Description; Text[50])
        {
        }
        field(3; "Category Type";Enum "Member Category Types")
        {
        }
        field(4; "No. Series"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(5; "Registration Fee"; Decimal)
        {
        }
        field(6; "Class"; Code[20])
        {
            TableRelation = "Sacco Lookup Values".Code where(Type=const("Member Classes"));
        }
        field(7; "Registration Fee Account"; Code[20])
        {
            TableRelation = "G/L Account" where(Blocked=const(false), "Income/Balance"=const("Income Statement"), "Account Category"=const(Income), "Account Type"=const(Posting));
        }
        field(8; Channels; Boolean)
        {
        }
    }
    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
}
