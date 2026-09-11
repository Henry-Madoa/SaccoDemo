pageextension 52204023 "General Ledger Entries" extends "General Ledger Entries"
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
            field("&Amount"; Rec.Amount)
            {
                ApplicationArea = Basic, Suite;
            }
        }
        addafter("External Document No.")
        {
            field("&Source Code"; Rec."Source Code")
            {
                ApplicationArea = All;
            }
        }
    }
}
