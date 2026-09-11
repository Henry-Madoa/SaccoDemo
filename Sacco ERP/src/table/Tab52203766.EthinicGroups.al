table 52203766 "Ethinic Groups"
{
    DrillDownPageID = "Ethinic Groups";
    LookupPageID = "Ethinic Groups";

    fields
    {
        field(1; "Code"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Description; Text[30])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Code")
        {
        }
    }
    fieldgroups
    {
    }
}
