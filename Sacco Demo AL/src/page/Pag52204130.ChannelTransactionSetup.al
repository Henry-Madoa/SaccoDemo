page 52204130 "Channel Transaction Setup"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Channel Transaction Setup";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Transaction Code"; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Posting Type"; Rec."Posting Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("SMS Notification"; Rec."SMS Notification")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Charge Code"; Rec."Charge Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Charge Description"; Rec."Charge Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Balancing Account No"; Rec."Balancing Account No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Minimum Amount"; Rec."Minimum Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Maximum Amount"; Rec."Maximum Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
