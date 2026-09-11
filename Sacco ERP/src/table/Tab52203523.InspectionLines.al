table 52203523 "Inspection Lines"
{
    fields
    {
        field(1; "No."; Code[20])
        {
        }
        field(2; "Line No."; Integer)
        {
        }
        field(3; "Item No."; Code[20])
        {
        }
        field(4; Description; Text[250])
        {
        }
        field(5; Quantity; Decimal)
        {
        }
        field(6; UoM; Code[10])
        {
        }
        field(7; "Unit Cost"; Decimal)
        {
        }
        field(8; "Total Cost"; Decimal)
        {
        }
        field(9; MFR; Text[30])
        {
        }
        field(10; "Catalog No."; Code[20])
        {
        }
    }
    keys
    {
        key(Key1; "No.", "Line No.")
        {
        }
    }
}
