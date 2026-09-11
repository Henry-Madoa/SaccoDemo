table 52203464 "Board Member Categories"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "Board Member Categories";
    LookupPageId = "Board Member Categories";

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Description; Text[100])
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
