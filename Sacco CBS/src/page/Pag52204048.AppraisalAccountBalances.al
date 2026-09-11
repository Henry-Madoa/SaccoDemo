page 52204048 "Appraisal Account Balances"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Appraisal Accounts";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

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
                field("Account Description"; Rec."Account Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Balance; Rec.Balance)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Mulltipled Value"; Rec."Mulltipled Value")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
