table 52203694 "Item Categories"
{
    DrillDownPageID = "Procurement Item Categories";
    LookupPageID = "Procurement Item Categories";

    fields
    {
        field(1; "Category Code"; Integer)
        {
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
        field(2; Description; Text[250])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Category Code")
        {
        }
    }
    fieldgroups
    {
    }
}
