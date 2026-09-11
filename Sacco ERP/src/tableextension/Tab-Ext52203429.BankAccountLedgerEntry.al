tableextension 52203429 "Bank Account Ledger Entry" extends "Bank Account Ledger Entry"
{
    fields
    {
        field(50000; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        modify(Description)
        {
            Width = 250;
        }
    }
}
