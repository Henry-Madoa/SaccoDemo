table 52203761 "Professional Bodies"
{
    DrillDownPageID = "Professional Bodies";
    LookupPageID = "Professional Bodies";

    fields
    {
        field(1; Code; Code[50])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(2; Name; Text[100])
        {
        }
    }
    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }
}
