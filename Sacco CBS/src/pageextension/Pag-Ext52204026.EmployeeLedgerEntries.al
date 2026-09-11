pageextension 52204026 "Employee Ledger Entries" extends "Employee Ledger Entries"
{
    layout
    {
        modify(Amount)
        {
            Visible = false;
        }
        addafter(Amount)
        {
            field("Debit Amount"; Rec."Debit Amount")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Credit Amount"; Rec."Credit Amount")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
