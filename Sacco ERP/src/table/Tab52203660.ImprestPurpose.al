table 52203660 "Imprest Purpose"
{
    DrillDownPageID = "Imprest Purpose";
    LookupPageID = "Imprest Purpose";

    fields
    {
        field(1; "Purpose Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Purpose Desscription"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Purpose Code")
        {
        }
    }
}
