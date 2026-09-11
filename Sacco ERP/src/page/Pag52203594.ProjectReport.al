page 52203594 "Project Report"
{
    CardPageID = "Project Report Header";
    PageType = List;
    SourceTable = "Project Report Header";

    layout
    {
        area(content)
        {
            repeater(General)
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
