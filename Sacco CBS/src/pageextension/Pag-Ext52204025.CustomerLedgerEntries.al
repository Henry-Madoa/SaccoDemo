pageextension 52204025 "Customer Ledger Entries" extends "Customer Ledger Entries"
{
    layout
    {
        modify(Amount)
        {
            Visible = false;
        }
        modify("Debit Amount")
        {
            Visible = false;
        }
        modify("Credit Amount")
        {
            Visible = false;
        }
        addafter(Amount)
        {
            field("&Debit Amount"; Rec."Debit Amount")
            {
                ApplicationArea = Basic, Suite;
            }
            field("&Credit Amount"; Rec."Credit Amount")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
