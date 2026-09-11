table 52203767 "&Languages"
{
    DrillDownPageID = "&Languages";
    LookupPageID = "&Languages";

    fields
    {
        field(2; Code; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; Name; Text[100])
        {
            DataClassification = ToBeClassified;
            NotBlank = false;
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
