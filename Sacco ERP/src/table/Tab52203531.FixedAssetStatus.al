table 52203531 "Fixed Asset Status"
{
    DataClassification = ToBeClassified;
    DataCaptionFields = Code, Description;
    DrillDownPageId = "Fixed Asset Status";
    LookupPageId = "Fixed Asset Status";

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Description; Text[50])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
}
