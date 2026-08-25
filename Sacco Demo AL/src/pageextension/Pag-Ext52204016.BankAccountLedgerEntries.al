pageextension 52204016 "Bank Account Ledger Entries" extends "Bank Account Ledger Entries"
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
        addafter(Description)
        {
            field("External Document No."; Rec."External Document No.")
            {
                ApplicationArea = Basic, Suite;
            }
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
