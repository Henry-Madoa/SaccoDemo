codeunit 52203454 "Accrue Past Leave Days"
{
    trigger OnRun()
    begin
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
                    Employee.SetRange(Status, Employee.Status::Inactive);
                    if Employee.FindSet then begin
                        repeat DaysToPost:=0;
                            DaysToPost:=CalculateDaysToAccrue(Employee."No.", LeaveTypes."Days To Accrue");
                            if DaysToPost > 0 then begin
                                LineNo:=LineNo + 1;
                                HumanResourceMgmt.BuildLeaveJournal(JournalTemplate, JournalBatch, LineNo, LeaveCalendar."Calendar Code", Employee."No.", Today, LeaveJournalLine."Leave Entry Type"::Accrued, 'ACCRUED', DaysToPost, 'Days accrued upto ' + Format(Today, 0, '<Month Text>/<Year4>') + ' From ' + Format(Employee."Employment Date", 0, '<Month Text>/<Year4>'), Employee."Global Dimension 1 Code", Employee."Global Dimension 2 Code", LeaveTypes.Code, 0D, 0D, 'ACCRUED');
                            end;
                        until Employee.Next = 0;
                    end;
                until LeaveTypes.Next = 0;
                HumanResourceMgmt.PostLeaveJournalLines(JournalTemplate, JournalBatch);
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
    local procedure GetNoOfDaysToPost(): Decimal var
        AccountingPeriod: Record "Accounting Period";
        AccountingPeriodDates: array[12]of Date;
        LastDate: Date;
        i: Integer;
    begin
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
    local procedure CalculateDaysToAccrue(EmployeeCode: Code[20]; DaysToMultiply: Decimal)DaysAccrued: Decimal var
        Employee: Record Employee;
    begin
        if Employee.Get(EmployeeCode)then begin
            DaysAccrued:=0;
            if Employee."Employment Date" <> 0D then begin
                if Date2DMY(Employee."Employment Date", 3) < Date2DMY(Today, 3)then begin
                    DaysAccrued:=((12 - (Date2DMY(Employee."Employment Date", 2))) * DaysToMultiply) + (Date2DMY(Today, 2) * DaysToMultiply);
                end;
                if Date2DMY(Employee."Employment Date", 3) = Date2DMY(Today, 3)then begin
                    DaysAccrued:=(Date2DMY(Today, 2) - Date2DMY(Employee."Employment Date", 2)) * DaysToMultiply;
                end;
            end;
        end;
        exit(DaysAccrued);
    end;
}
