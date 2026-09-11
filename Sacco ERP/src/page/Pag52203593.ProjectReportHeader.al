page 52203593 "Project Report Header"
{
    PageType = Card;
    SourceTable = "Project Report Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Project; Rec.Project)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Project Name"; Rec."Project Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Report Start Date"; Rec."Report Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Report End Date"; Rec."Report End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part(Control9; "Project Report Details")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = Project=FIELD(Project);
            }
        }
        area(factboxes)
        {
            systempart(Control8; Notes)
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
