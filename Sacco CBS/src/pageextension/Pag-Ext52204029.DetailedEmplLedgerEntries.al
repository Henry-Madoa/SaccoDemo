pageextension 52204029 "Detailed Empl. Ledger Entries" extends "Detailed Empl. Ledger Entries"
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
