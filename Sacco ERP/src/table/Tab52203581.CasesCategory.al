table 52203581 "Cases Category"
{
    DrillDownPageID = "Casess Category";
    LookupPageID = "Casess Category";

    fields
    {
        field(1; "Category Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Category Desription"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Category Code")
        {
        }
    }
}
