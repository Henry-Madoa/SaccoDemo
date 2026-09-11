page 52203597 "Status of Fund"
{
    DeleteAllowed = false;
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Status of Fund";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Fund; Rec.Fund)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Fund Name"; Rec."Fund Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Project; Rec.Project)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Project Name"; Rec."Project Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Department; Rec.Department)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(FY; Rec.FY)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Total Allotment"; Rec."Total Allotment")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Total Commitment"; Rec."Total Commitment")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Total Obligation"; Rec."Total Obligation")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Total Disbursement"; Rec."Total Disbursement")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Total Open Commitment"; Rec."Total Open Commitment")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Total ULO"; Rec."Total ULO")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Fund Status Report")
            {
                ApplicationArea = Basic, Suite;
                Image = Print;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Report "Status of Fund Report";
            }
        }
    }
}
