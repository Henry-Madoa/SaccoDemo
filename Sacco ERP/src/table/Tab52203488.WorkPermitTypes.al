table 52203488 "Work Permit Types"
{
    DrillDownPageID = "Work Permit Types";
    LookupPageID = "Work Permit Types";

    fields
    {
        field(1; "Permit Type"; Text[70])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Permit Type")
        {
        }
    }
}
