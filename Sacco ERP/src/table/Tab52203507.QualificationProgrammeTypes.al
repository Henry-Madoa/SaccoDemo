table 52203507 "Qualification Programme Types"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Qualification Programme Types";
    DrillDownPageId = "Qualification Programme Types";

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Description; Text[250])
        {
            DataClassification = ToBeClassified;
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
