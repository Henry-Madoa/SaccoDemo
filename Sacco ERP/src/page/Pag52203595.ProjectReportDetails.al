page 52203595 "Project Report Details"
{
    PageType = ListPart;
    SourceTable = "Project Report Details";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Amount By Project"; Rec."Amount By Project")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Amount Other Projects"; Rec."Amount Other Projects")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Annual Budget"; Rec."Annual Budget")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Budget Usage (%)"; Rec."Budget Usage (%)")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
