table 52203696 "Item Sub Categories"
{
    DrillDownPageID = "Item Sub Categories";
    LookupPageID = "Item Sub Categories";

    fields
    {
        field(1; "Category Code"; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = "Item Categories"."Category Code";
        }
        field(2; Description; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "G/l Account"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No.";
        }
    }
    keys
    {
        key(Key1; Description, "Category Code")
        {
        }
    }
    fieldgroups
    {
    }
}
