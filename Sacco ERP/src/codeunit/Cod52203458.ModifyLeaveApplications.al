codeunit 52203458 "Modify Leave Applications"
{
    procedure CheckIfDayIsAWeekend(Day: Date): Boolean var
        Date: Record Date;
    begin
        Date.Reset;
        Date.SetRange("Period Start", Day);
        Date.SetRange("Period Type", Date."Period Type"::Date);
        if Date.FindFirst then if Date."Period Name" in['Saturday', 'Sunday']then exit(true)
            else
                exit(false);
    end;
    procedure CheckApprovedLeaveApplication(Day: Date; CalenderCode: Code[20]): Boolean var
        leaveApplication: Record "Leave Applications";
        HumanResourceMgmt: Codeunit "Human Resource Management";
        LeaveJournalTemplate: Code[40];
        LeaveJournalBatch: Code[40];
        LeaveJournalLine: Record "Leave Journal Line";
        LeaveSetup: Record "Leave Setup";
        LineNo: Integer;
        DayofInterest: Date;
        DayWithinLeaveApp: Boolean;
    begin
        leaveApplication.Reset;
        leaveApplication.SetRange("Leave Calender Code", CalenderCode);
        leaveApplication.SetRange(Posted, true);
        leaveApplication.SetRange(Status, leaveApplication.Status::Approved);
        if leaveApplication.FindSet then begin
            LeaveSetup.Get;
            LeaveJournalTemplate:=LeaveSetup."Leave Journal Template";
            LeaveJournalBatch:=LeaveSetup."Leave Journal Batch";
            HumanResourceMgmt.CreateLeaveJournalBatch(LeaveJournalTemplate, LeaveJournalBatch);
            repeat DayWithinLeaveApp:=false;
                DayofInterest:=Day;
                if(DayofInterest >= leaveApplication."Start Date") and (DayofInterest <= leaveApplication."End Date")then DayWithinLeaveApp:=true;
                if DayWithinLeaveApp then begin
                    LineNo:=LineNo + 1;
                    HumanResourceMgmt.BuildLeaveJournal(LeaveJournalTemplate, LeaveJournalBatch, LineNo, leaveApplication."Leave Calender Code", leaveApplication."Employee No", Today, LeaveJournalLine."Leave Entry Type"::Reimbursement, leaveApplication."No.", 1, 'Leave Days reimbursed for holiday of ' + Format(Day), leaveApplication."Global Dimension 1 Code", leaveApplication."Global Dimension 2 Code", leaveApplication."Leave Code", 0D, 0D, leaveApplication."No.");
                    leaveApplication.Validate("Days Applied");
                    leaveApplication.Modify(true);
                end;
            until leaveApplication.Next = 0;
            HumanResourceMgmt.PostLeaveJournalLines(LeaveJournalTemplate, LeaveJournalBatch);
        end;
    end;
}
