table 52203685 "Disposal Customer Bids"
{
    DrillDownPageID = "Vendor Quoted Amount Per Item";
    LookupPageID = "Vendor Quoted Amount Per Item";

    fields
    {
        field(1; "Quote No"; Code[30])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(3; "Customer Name"; Text[250])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(4; "Line No"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5; "Item No"; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(6; "Item Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(7; "Quoted Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Quote No", "Line No")
        {
        }
        key(Key2; "Quoted Amount")
        {
        }
    }
}
