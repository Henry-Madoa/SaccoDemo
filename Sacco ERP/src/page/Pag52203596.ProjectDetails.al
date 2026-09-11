page 52203596 "Project Details"
{
    PageType = List;
    SourceTable = "Project Details";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Donor Code"; Rec."Donor Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Donor Description"; Rec."Donor Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Project Name"; Rec."Project Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Duration; Rec.Duration)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Approval Date"; Rec."Approval Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Currency; Rec.Currency)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Approved Amount"; Rec."Approved Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Approval/Withdrawal"; Rec."Approval/Withdrawal")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Contract Date"; Rec."Contract Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Contract Amount"; Rec."Contract Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Expected Amount (Transfers)"; Rec."Expected Amount (Transfers)")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Actual Amount (Transfers)"; Rec."Actual Amount (Transfers)")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control19; Notes)
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Project Overview Report")
            {
                ApplicationArea = Basic, Suite;
                Image = "Report";
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Report "Project Overview Report";
            }
            action("List of Partners")
            {
                ApplicationArea = Basic, Suite;
                Image = "Report";
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Report "List of Partners";
            }
        }
    }
}
