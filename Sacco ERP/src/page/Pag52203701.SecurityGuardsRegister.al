page 52203701 "Security Guards Register"
{
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Security Guards Register";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Guard No"; Rec."Guard No")
                {
                    ApplicationArea = All;
                }
                field("Guard Name"; Rec."Guard Name")
                {
                    ApplicationArea = All;
                }
                field("Allocated Section"; Rec."Allocated Section")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
