table 52203707 "Goods Receipt Note Lines"
{
    fields
    {
        field(1; "Document No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Item.Get("Item No.")then "Item Description":=Item.Description;
            end;
        }
        field(4; "Item Description"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(5; Location; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Quantity Ordered"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Quantity to Receive"; Integer)
        {
            Caption = 'Quantity Received';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Quantity to Receive" > "Quantity Ordered" then begin
                    Error('You cannot receive more than %1', "Quantity Ordered");
                end
                else if "Quantity to Receive" < 0 then begin
                        Error('You cannot receive negative quantity');
                    end;
            end;
        }
        field(8; Comments; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Unit of Measure"; Code[30])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(10; "Unit Price"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Total Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Document No", "Line No.")
        {
        }
    }
    var Item: Record Item;
}
