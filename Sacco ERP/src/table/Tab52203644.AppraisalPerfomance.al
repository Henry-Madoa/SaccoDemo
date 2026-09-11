table 52203644 "Appraisal Perfomance"
{
    DrillDownPageID = "Perfomance Level";
    LookupPageID = "Perfomance Level";

    fields
    {
        field(1; "Line Nos"; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Perfomace Level"; Text[50])
        {
        }
    }
    keys
    {
        key(Key1; "Line Nos")
        {
        }
    }
}
