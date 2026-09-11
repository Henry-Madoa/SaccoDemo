page 52203481 "Departmental Leave Plan"
{
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Leave Plan Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Employee Code."; Rec."Employee Code.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Leave Type Description"; Rec."Leave Type Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Days Planned"; Rec."Days Planned")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Holidays; Rec.Holidays)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Weekend Days"; Rec."Weekend Days")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Days; Rec.Days)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Leave Calender"; Rec."Leave Calender")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        if UserSetup.Get(UserId)then begin
            if not UserSetup."HR Admin" then Rec.SetRange("Global Dimension 1 Code", UserSetup."Head of Department");
        end
        else
            Error('Contact system admin to set up %1 in user setup', UserId);
        LeaveCalendar.Reset;
        LeaveCalendar.SetRange("Current Leave Calendar", true);
        if LeaveCalendar.FindFirst then Rec.SetRange("Leave Calender", LeaveCalendar."Calendar Code");
    end;
    var UserSetup: Record "User Setup";
    LeaveCalendar: Record "Leave Calendar";
}
