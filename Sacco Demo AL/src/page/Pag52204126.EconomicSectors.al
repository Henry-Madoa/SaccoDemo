page 52204126 "Economic Sectors"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Economic Sectors";
    CardPageId = "Economic Sector";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Sector Code"; rEC."Sector Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Sector Name"; rEC."Sector Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created By"; rEC."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created On"; rEC."Created On")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
