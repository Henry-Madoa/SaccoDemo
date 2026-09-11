table 52203596 "Academic Qualification"
{
    DrillDownPageID = "Academic Qualification";
    LookupPageID = "Academic Qualification";

    fields
    {
        field(1; Level; Text[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Education Level".Level;
        }
        field(2; Qualification; Text[150])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; Level, Qualification)
        {
        }
    }
}
