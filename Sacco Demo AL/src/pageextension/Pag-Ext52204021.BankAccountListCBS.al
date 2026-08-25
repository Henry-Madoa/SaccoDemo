pageextension 52204021 "Bank Account List CBS" extends "Bank Account List"
{
    actions
    {
        addbefore("Detail Trial Balance")
        {
            action("Bank Balances Report")
            {
                ApplicationArea = Basic, Suite;
                Image = "Report";
                RunObject = Report "Bank Balances Report";
            }
            action("Cash Book")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Cash Book';
                Image = "Report";
                RunObject = Report "Cash Book";
            }
        }
    }
}
