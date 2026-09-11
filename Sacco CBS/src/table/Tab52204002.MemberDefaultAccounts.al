table 52204002 "Member Default Accounts"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Category Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Product Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Sacco Products" where(Indentation = const(1), Blocked = const(false), "Product Posting Type" = filter(<> "Loan Account"));

            trigger OnValidate()
            begin
                if ProductFactory.Get("Product Code") then "Product Description" := ProductFactory.Description;
            end;
        }
        field(3; "Product Description"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Category Code", "Product Code")
        {
            Clustered = true;
        }
    }
    var
        ProductFactory: Record "Sacco Products";
}
