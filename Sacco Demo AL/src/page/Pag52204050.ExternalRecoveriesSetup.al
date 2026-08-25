page 52204050 "External Recoveries Setup"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "External Recoveries Setup";

    layout
    {
        area(Content)
        {
            Repeater(General)
            {
                field("Recovery Code"; Rec."Recovery Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Recovery Description"; Rec."Recovery Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Post To Account Type"; Rec."Post To Account Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Post To Account No"; Rec."Post To Account No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Commission; Rec.Commission)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Commission Account"; Rec."Commission Account")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
