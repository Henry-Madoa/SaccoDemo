page 52203650 "Security Company"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Security Company";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(No; Rec.No)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = All;
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                }
            }
            part(Gurds; "Security Guards")
            {
                SubPageLink = "Security Company"=field(No);
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Guards")
            {
                ApplicationArea = All;
                Promoted = true;
                image = Resource;
                RunObject = page "Security Guards";
                RunPageLink = "Security Company"=field(No);
            }
        }
    }
}
