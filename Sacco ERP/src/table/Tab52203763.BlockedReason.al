table 52203763 "Blocked Reason"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Blocked Reasons";
    DrillDownPageId = "Blocked Reasons";

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
        key(Key1; Code, Description)
        {
            Clustered = true;
        }
        key(Key2; Description)
        {
        }
    }
}
