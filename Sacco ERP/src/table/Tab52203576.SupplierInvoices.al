table 52203576 "Supplier Invoices"
{
    fields
    {
        field(1; "Line No."; Integer)
        {
        }
        field(2; "Account Type"; Text[30])
        {
        }
        field(3; "Account No."; Code[20])
        {
        }
        field(4; "Posting Date"; Date)
        {
        }
        field(5; "Document No."; Code[20])
        {
        }
        field(6; Description; Text[50])
        {
        }
        field(7; Amount; Decimal)
        {
        }
        field(8; "Bal. Account Type"; Text[30])
        {
        }
        field(9; "Bal. Account No."; Code[20])
        {
        }
    }
    keys
    {
        key(Key1; "Line No.")
        {
        }
    }
}
