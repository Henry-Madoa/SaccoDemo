page 52203766 "Investment Posting Group"
{
    PageType = Card;
    SourceTable = "Investment Posting Group";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Group; Rec.Group)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Debit Account No."; Rec."Debit Account No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Credit Account No."; Rec."Credit Account No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Receivable Acc."; Rec."Interest Receivable Acc.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Received Acc."; Rec."Interest Received Acc.")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
