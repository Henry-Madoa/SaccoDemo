page 52204184 "Loan Recovery Accounts"
{
    PageType = ListPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Loan Recovey Accounts";
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Account No"; Rec."Account No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Current Balance"; Rec."Current Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Recovery Amount"; Rec."Recovery Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
