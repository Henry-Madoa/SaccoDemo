table 52204106 "Loan Product Linking"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Source Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Linked Product Code"; Code[20])
        {
            TableRelation = "Sacco Products" where(Indentation = const(1), Blocked = const(false));

            trigger OnValidate()
            var
                Products: Record "Sacco Products";
            begin
                if Products.Get("Linked Product Code") then "Linked Product Name" := Products.Description;
            end;
        }
        field(3; "Linked Product Name"; Text[100])
        {
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Source Code", "Linked Product Code")
        {
            Clustered = true;
        }
    }
}
