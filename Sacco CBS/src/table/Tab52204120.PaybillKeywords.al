table 52204120 "Paybill Keywords"
{
    LookupPageId = "Paybill Keywords";
    DrillDownPageId = "Paybill Keywords";
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Kewyword Code"; Code[5])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Product Code"; Code[20])
        {
            TableRelation = "Sacco Products" where(Indentation = const(1));

            trigger OnValidate()
            begin
                if SaccoProducts.Get("Product Code") then begin
                    Description := SaccoProducts.Description;
                    "Product Posting Type" := SaccoProducts."Product Posting Type";
                end;
            end;
        }
        field(3; Description; Text[150])
        {
            Editable = false;
        }
        field(4; "Product Posting Type"; Enum "Product Posting Type")
        {
            Editable = false;
        }
        field(5; "Transaction Type"; Enum "Paybill Transaction Types")
        {
        }
    }
    keys
    {
        key(Key1; "Kewyword Code")
        {
            Clustered = true;
        }
    }
    var
        SaccoProducts: Record "Sacco Products";
}
