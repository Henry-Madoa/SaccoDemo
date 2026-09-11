table 52203642 "Appraisal Proficiency Levels"
{
    DrillDownPageID = "Appraisal Proficiency Level";
    LookupPageID = "Appraisal Proficiency Level";

    fields
    {
        field(1; "Line No"; Integer)
        {
            AutoIncrement = true;
        }
        field(2; Level; Text[50])
        {
        }
    }
    keys
    {
        key(Key1; "Line No")
        {
        }
    }
}
