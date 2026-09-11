codeunit 52203450 "Accrue Leave Days"
{
    trigger OnRun()
    begin
        if CheckIfTodayIsInAccountingPeriod(Today)then begin
            LeaveSetup.Get();
            JournalTemplate:=LeaveSetup."Leave Journal Template";
            JournalBatch:=LeaveSetup."Leave Journal Batch";
            LeaveCalendar.Reset;
            LeaveCalendar.SetRange("Current Leave Calendar", true);
            if LeaveCalendar.FindFirst then begin
                HumanResourceMgmt.CreateLeaveJournalBatch(JournalTemplate, JournalBatch);
                HumanResourceMgmt.DeleteLeaveJournalLines(JournalTemplate, JournalBatch);
                LineNo:=1;
                LeaveTypes.Reset;
                LeaveTypes.SetRange("Acrue Days", true);
                if LeaveTypes.FindSet then begin
                    repeat Employee.Reset;
                        Employee.SetRange(Status, Employee.Status::Active);
                        if Employee.FindSet then begin
                            repeat DaysToPost:=0;
                                DaysToPost:=GetNoOfDaysToPost(Employee."Job Scale", LeaveTypes.Code);
                                LineNo:=LineNo + 1;
                                HumanResourceMgmt.BuildLeaveJournal(JournalTemplate, JournalBatch, LineNo, LeaveCalendar."Calendar Code", Employee."No.", Today, LeaveJournalLine."Leave Entry Type"::Accrued, 'ACCRUED', DaysToPost, 'Days accrued for ' + Format(Today, 0, '<Month Text>/<Year4>'), Employee."Global Dimension 1 Code", Employee."Global Dimension 2 Code", LeaveTypes.Code, 0D, 0D, 'ACCRUED');
                            until Employee.Next = 0;
                        end;
                    until LeaveTypes.Next = 0;
                    HumanResourceMgmt.PostLeaveJournalLinesAccrual(JournalTemplate, JournalBatch);
                end;
            end;
        end;
    end;
    var HumanResourceMgmt: Codeunit "Human Resource Management";
    LeaveTypes: Record "Leave Types";
    Employee: Record Employee;
    JournalTemplate: Code[30];
    JournalBatch: Code[50];
    LeaveSetup: Record "Leave Setup";
    LineNo: Integer;
    LeaveCalendar: Record "Leave Calendar";
    LeaveJournalLine: Record "Leave Journal Line";
    DaysToPost: Decimal;
    local procedure GetDateOfJoin(EmployeeCode: Code[50]): Date var
        Employee: Record Employee;
    begin
        if Employee.Get(EmployeeCode)then exit(Employee."Employment Date");
    end;
    local procedure GetLastAccrualDate(EmployeeCode: Code[50]; LeaveType: Code[50]; LeaveCalendar: Code[50]): Date var
        LeaveEntries: Record "Leave Ledger Entries";
    begin
        LeaveEntries.Reset;
        LeaveEntries.SetCurrentKey("Posting Date");
        LeaveEntries.SetRange("Employee No.", EmployeeCode);
        LeaveEntries.SetRange("Leave Type", LeaveType);
        LeaveEntries.SetRange("Leave Entry Type", LeaveEntries."Leave Entry Type"::Accrued);
        if LeaveEntries.FindLast then exit(LeaveEntries."Posting Date");
    end;
    local procedure GetNoOfDaysToPost(Grade: Code[20]; LeaveType: Code[50]): Decimal var
        LeaveDaysToAccrueMatrix: Record "Leave Days To Accrue Matrix";
    begin
        LeaveDaysToAccrueMatrix.Reset;
        LeaveDaysToAccrueMatrix.SetRange("Employee Grade Code", Grade);
        LeaveDaysToAccrueMatrix.SetRange("Leave Type", LeaveType);
        if LeaveDaysToAccrueMatrix.FindFirst then exit(LeaveDaysToAccrueMatrix."Days To Accrue");
    end;
    local procedure GetCurrentLeaveCalenderCode(): Code[20]var
        LeaveCalendar: Record "Leave Calendar";
    begin
        LeaveCalendar.Reset;
        LeaveCalendar.SetRange("Current Leave Calendar", true);
        if LeaveCalendar.FindFirst then exit(LeaveCalendar."Calendar Code");
    end;
    local procedure GetLastDateOfLeaveCalender(LeaveCalendarCode: Code[50]): Date var
        LeaveCalendar: Record "Leave Calendar";
    begin
        if LeaveCalendar.Get(LeaveCalendarCode)then exit(LeaveCalendar."End Date");
    end;
    local procedure CheckIfTodayIsInAccountingPeriod(DateToCHeck: Date)DateFound: Boolean var
        AccountingPeriod: Record "Accounting Period";
        LastDate: Date;
    begin
        AccountingPeriod.Reset;
        AccountingPeriod.SetRange(Closed, false);
        if AccountingPeriod.FindSet then begin
            repeat if DateToCHeck = AccountingPeriod."Starting Date" then exit(true)until AccountingPeriod.Next = 0;
        end;
    end;
}
