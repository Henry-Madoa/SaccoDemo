page 52204055 "Cheque Instructions"
{
    PageType = ListPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Cheque Instructions";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account No"; Rec."Account No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Balance"; Rec."Loan Balance")
                {
                    Visible = false;
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
