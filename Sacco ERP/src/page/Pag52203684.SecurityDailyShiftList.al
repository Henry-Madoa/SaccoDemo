page 52203684 "Security Daily Shift List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Security Daily Shift";
    CardPageId = "Security Daily Shift";

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
                field(Date; Rec.Date)
                {
                    ApplicationArea = All;
                }
                field("Shift Code"; Rec."Shift Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
