table 52204107 "Channel Loan Blocking"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Member No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Product Code"; Code[20])
        {
            TableRelation = "Sacco Products" where(Indentation = const(1), Blocked = const(false), "Mobile Loan" = const(true));

            trigger OnValidate()
            var
                Products: Record "Sacco Products";
            begin
                if Products.Get("Product Code") then "Product Name" := Products.Description;
            end;
        }
        field(3; "Product Name"; Text[100])
        {
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Member No", "Product Code")
        {
            Clustered = true;
        }
    }
}
