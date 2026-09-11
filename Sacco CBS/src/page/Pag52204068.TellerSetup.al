page 52204068 "Teller Setup"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Teller Setup";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Setup Type"; Rec."Setup Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account Code"; Rec."Account Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Approval Limit"; Rec."Approval Limit")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Maximum Capacity"; Rec."Maximum Capacity")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Minimum Capacity"; Rec."Minimum Capacity")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
