table 52203476 "Religions"
{
    DrillDownPageID = Religions;
    LookupPageID = Religions;

    fields
    {
        field(1; Religion; Code[50])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; Religion)
        {
        }
    }
}
