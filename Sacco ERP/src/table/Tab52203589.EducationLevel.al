table 52203589 "Education Level"
{
    DrillDownPageID = "Education Level";
    LookupPageID = "Education Level";

    fields
    {
        field(1; Level; Text[50])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; Level)
        {
        }
    }
}
