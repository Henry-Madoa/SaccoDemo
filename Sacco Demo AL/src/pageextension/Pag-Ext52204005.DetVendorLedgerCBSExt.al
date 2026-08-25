pageextension 52204005 "Det. Vendor Ledger CBS Ext." extends "Detailed Vendor Ledg. Entries"
{
    layout
    {
        addafter("Document No.")
        {
            field("Member No."; Rec."Member No.")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Member Posting Type"; Rec."Product Posting Type")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Loan No."; Rec."Loan No.")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Transaction Type"; Rec."Sacco Transaction Type")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
