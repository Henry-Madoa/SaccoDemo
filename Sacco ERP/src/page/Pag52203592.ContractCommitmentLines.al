page 52203592 "Contract Commitment Lines"
{
    AutoSplitKey = true;
    Caption = 'Commitment Lines';
    MultipleNewLines = false;
    PageType = ListPart;
    SourceTable = "Contract Commitment Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Commitment Date"; Rec."Commitment Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Expense Code"; Rec."Expense Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Expense Description"; Rec."Expense Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("GL Account No."; Rec."GL Account No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
