table 52203446 "Non Working Days & Dates"
{
    fields
    {
        field(1; Date; Date)
        {
            trigger OnValidate()
            begin
                if not Confirm('Adding an holiday will modify approved leaves and post reimbursments for affected leaves')then begin
                    Date:=0D;
                    exit;
                end;
                if ModifyLeaveApplications.CheckIfDayIsAWeekend(Date)then LeaveCalendar.Reset;
                LeaveCalendar.SetRange("Current Leave Calendar", true);
                if LeaveCalendar.FindFirst then ModifyLeaveApplications.CheckApprovedLeaveApplication(Date, LeaveCalendar."Calendar Code");
            end;
        }
        field(2; Reason; Text[100])
        {
        }
        field(3; Recurring; Boolean)
        {
        }
    }
    keys
    {
        key(Key1; Date)
        {
        }
    }
    var ModifyLeaveApplications: Codeunit "Modify Leave Applications";
    LeaveCalendar: Record "Leave Calendar";
}
