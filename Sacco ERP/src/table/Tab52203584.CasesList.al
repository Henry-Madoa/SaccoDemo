table 52203584 "Cases List"
{
    DrillDownPageID = "Cases Type List";
    LookupPageID = "Cases Type List";

    fields
    {
        field(1; "Case Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Case Desription"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Case Category"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Cases Category"."Category Code";
        }
    }
    keys
    {
        key(Key1; "Case Code")
        {
        }
    }
}
