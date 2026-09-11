page 52203511 "Leave Staging Area"
{
    PageType = List;
    SourceTable = "Leave Staging Area";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Days; Rec.Days)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
