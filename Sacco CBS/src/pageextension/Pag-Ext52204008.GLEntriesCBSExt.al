pageextension 52204008 "G/L Entries CBS Ext." extends "General Ledger Entries"
{
    layout
    {
        addafter("Posting Date")
        {
            field("Transaction Type"; Rec."Sacco Transaction Type")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Member No."; Rec."Member No.")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Loan No."; Rec."Loan No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Loan No. field.', Comment = '%';
            }
            field("Member Posting Type"; Rec."Product Posting Type")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
