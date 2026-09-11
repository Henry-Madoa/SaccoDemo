table 52203577 "Clearance Sections"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Clearance Section";
    DrillDownPageId = "Clearance Section";

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Name; Text[50])
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
