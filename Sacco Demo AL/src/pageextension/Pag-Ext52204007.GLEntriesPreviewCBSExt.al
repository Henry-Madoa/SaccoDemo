pageextension 52204007 "G/L Entries Preview CBS Ext." extends "G/L Entries Preview"
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
            field("Member Posting Type"; Rec."Product Posting Type")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
