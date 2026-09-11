table 52203724 "Insurance Cover Type"
{
    DrillDownPageID = "Insurance Cover Types";
    LookupPageID = "Insurance Cover Types";

    fields
    {
        field(1; "Code"; Code[20])
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
        key(Key1; "Code")
        {
        }
    }
}
