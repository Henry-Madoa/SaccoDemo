page 52203450 "Leave Plan List"
{
    CardPageID = "Leave Plan Card";
    PageType = List;
    SourceTable = "Leave Plan";
    SourceTableView = where(Status=const(Open));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Plan No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Leave Calender Code"; Rec."Leave Calendar Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
