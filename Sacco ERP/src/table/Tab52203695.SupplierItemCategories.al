table 52203695 "Supplier Item Categories"
{
    fields
    {
        field(1; "Supplier No."; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Category; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Item Categories"."Category Code";

            trigger OnValidate()
            begin
                if ItemCategories.Get(Category)then Description:=ItemCategories.Description;
            end;
        }
        field(3; Description; Text[250])
        {
            DataClassification = ToBeClassified;
            Editable = true;
        }
        field(4; "Line No"; Integer)
        {
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Supplier No.", "Line No")
        {
        }
    }
    fieldgroups
    {
    }
    var ItemCategories: Record "Item Categories";
}
