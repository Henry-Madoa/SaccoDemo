page 52203685 "Security Daily Shift"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Security Daily Shift";

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(No; Rec.No)
                {
                    ApplicationArea = All;
                }
                field(Date; Rec.Date)
                {
                    ApplicationArea = All;
                }
                field("Shift Code"; Rec."Shift Code")
                {
                    ApplicationArea = All;
                }
            }
            part(Guards; "Security Guards Register")
            {
                SubPageLink = "Shift Code"=field("Shift Code");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("&Guards")
            {
                ApplicationArea = All;
                Promoted = true;
                Image = ResourceGroup;
                RunObject = page "Security Guards Register";
                RunPageLink = Date=field(Date), "Shift Code"=field("Shift Code");
            }
        }
    }
}
