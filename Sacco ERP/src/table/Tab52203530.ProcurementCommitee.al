table 52203530 "Procurement Commitee"
{
    DrillDownPageID = "Procurement Committee";
    LookupPageID = "Procurement Committee";

    fields
    {
        field(1; "Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(2; Description; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Minimum Members"; Integer)
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
