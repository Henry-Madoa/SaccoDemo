table 52203726 "Supplier Sub-Category"
{
    DataCaptionFields = "Sub-Category Code", "Sub-Category Description";
    DrillDownPageID = "Supplier Sub-Category";
    LookupPageID = "Supplier Sub-Category";

    fields
    {
        field(1; "Category Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Supplier Category"."Category Code";
        }
        field(2; "Sub-Category Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Sub-Category Description"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Category Code", "Sub-Category Code")
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Sub-Category Code", "Sub-Category Description")
        {
        }
    }
}
