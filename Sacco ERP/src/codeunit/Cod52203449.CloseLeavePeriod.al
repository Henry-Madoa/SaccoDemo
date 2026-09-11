codeunit 52203449 "Close Leave Period"
{
    local procedure CheckIfLeaveTypeHasMaxLeaveDays(LeaveType: Code[20])YesNo: Boolean var
        LeaveTypes: Record "Leave Types";
    begin
        if LeaveTypes.Get(LeaveType)then begin
            if LeaveTypes."Carry Forward Allowed" then exit(true)
            else
                exit(false);
        end;
    end;
    local procedure GetMaxNooLeaveDaysCarryFoward(LeaveType: Code[20]): Decimal var
        LeaveTypes: Record "Leave Types";
    begin
        if LeaveTypes.Get(LeaveType)then begin
            exit(LeaveTypes."Max Carry Forward Days");
        end;
    end;
    local procedure GetBalanceForEmployeeForLeaveType(LeaveType: Code[20]; EmployeeCode: Code[30]; LeaveYear: Code[30]): Decimal var
        LeaveEntries: Record "Leave Ledger Entries";
    begin
        LeaveEntries.Reset;
        LeaveEntries.SetRange("Leave Type", LeaveType);
        LeaveEntries.SetRange("Leave Year Code", LeaveYear);
        LeaveEntries.SetRange("Employee No.", EmployeeCode);
        if LeaveEntries.FindSet then begin
            LeaveEntries.CalcSums(Quantity);
            exit(LeaveEntries.Quantity);
        end;
    end;
    local procedure CheckIfThereIsNoLeaveTypeWithMarkedForCarryFoward(LeaveCalendar: Record "Leave Calendar")
    var
        LeaveTypes: Record "Leave Types";
    begin
        LeaveTypes.Reset;
        LeaveTypes.SetRange("Carry Forward Allowed", true);
        if not LeaveTypes.FindFirst then begin
            if not Confirm('No leave type has been marked for carry foward of leave balances to the next period \ Do you wish to continue?')then exit;
            CreateNewPeriod(LeaveCalendar);
        end;
    end;
    procedure CloseLeaveCalendar(LeaveCalendar: Record "Leave Calendar")
    var
        Employee: Record Employee;
        LeaveTypes: Record "Leave Types";
        LineNo: Integer;
        HumanResourceMgmt: Codeunit "Human Resource Management";
        NoOfFDaysCarryFoward: Decimal;
        LeaveBalance: Decimal;
        MaxLeaveDaysToCarry: Decimal;
        LeaveJournalTemplate: Code[40];
        LeaveJournalBatch: Code[40];
        LeaveJournalLine: Record "Leave Journal Line";
        LeaveSetup: Record "Leave Setup";
        ProgressWindow: Dialog;
        RenewableDays: Decimal;
        LeaveDaysToAccrueMatrix: Record "Leave Days To Accrue Matrix";
    begin
        LeaveSetup.Get;
        LeaveJournalTemplate:=LeaveSetup."Leave Journal Template";
        LeaveJournalBatch:=LeaveSetup."Leave Journal Batch";
        HumanResourceMgmt.CreateLeaveJournalBatch(LeaveJournalTemplate, LeaveJournalBatch);
        HumanResourceMgmt.DeleteLeaveJournalLines(LeaveJournalTemplate, LeaveJournalBatch);
        LeaveTypes.Reset;
        LeaveTypes.SetRange(Disabled, false);
        if LeaveTypes.FindSet then begin
            ProgressWindow.Open('Processing Leave Balance #1#################################################################');
            repeat ProgressWindow.Update(1, LeaveTypes.Code + ':' + LeaveTypes.Description);
                MaxLeaveDaysToCarry:=GetMaxNooLeaveDaysCarryFoward(LeaveTypes.Code);
                Employee.Reset;
                Employee.SetFilter(Status, '=%1', Employee.Status::Active);
                if Employee.FindSet then begin
                    repeat LeaveBalance:=GetBalanceForEmployeeForLeaveType(LeaveTypes.Code, Employee."No.", LeaveCalendar."Calendar Code");
                        NoOfFDaysCarryFoward:=LeaveBalance;
                        if(NoOfFDaysCarryFoward > MaxLeaveDaysToCarry) and (MaxLeaveDaysToCarry > 0)then NoOfFDaysCarryFoward:=MaxLeaveDaysToCarry;
                        if LeaveTypes."Carry Forward Allowed" then begin
                            RenewableDays:=0;
                            if LeaveTypes.Gender in[LeaveTypes.Gender::Both]then RenewableDays:=LeaveTypes.Days;
                            if((LeaveTypes.Gender = LeaveTypes.Gender::Female) and (Employee.Gender = Employee.Gender::Female))then RenewableDays:=LeaveTypes.Days;
                            if((LeaveTypes.Gender = LeaveTypes.Gender::Male) and (Employee.Gender = Employee.Gender::Male))then RenewableDays:=LeaveTypes.Days;
                            LineNo:=LineNo + 1;
                            if NoOfFDaysCarryFoward > 0 then HumanResourceMgmt.BuildLeaveJournal(LeaveJournalTemplate, LeaveJournalBatch, LineNo, Format(Date2DMY(CalcDate('1D', LeaveCalendar."End Date"), 3)), Employee."No.", Today, LeaveJournalLine."Leave Entry Type"::OpeinigBalance, 'OPENBAL', NoOfFDaysCarryFoward, 'Balance from ' + Format(LeaveCalendar."Calendar Code") + ' brought foward', Employee."Global Dimension 1 Code", Employee."Global Dimension 2 Code", LeaveTypes.Code, 0D, 0D, 'OPENBAL');
                            LineNo:=LineNo + 1;
                            if RenewableDays > 0 then HumanResourceMgmt.BuildLeaveJournal(LeaveJournalTemplate, LeaveJournalBatch, LineNo, Format(Date2DMY(CalcDate('1D', LeaveCalendar."End Date"), 3)), Employee."No.", Today, LeaveJournalLine."Leave Entry Type"::OpeinigBalance, 'OPENBAL', RenewableDays, 'Opening Balance for the period ' + Format(Date2DMY(CalcDate('1D', LeaveCalendar."End Date"), 3)), Employee."Global Dimension 1 Code", Employee."Global Dimension 2 Code", LeaveTypes.Code, 0D, 0D, 'OPENBAL');
                        end
                        else
                        begin
                            RenewableDays:=0;
                            if LeaveTypes.Gender in[LeaveTypes.Gender::Both]then RenewableDays:=LeaveTypes.Days;
                            if((LeaveTypes.Gender = LeaveTypes.Gender::Female) and (Employee.Gender = Employee.Gender::Female))then RenewableDays:=LeaveTypes.Days;
                            if((LeaveTypes.Gender = LeaveTypes.Gender::Male) and (Employee.Gender = Employee.Gender::Male))then RenewableDays:=LeaveTypes.Days;
                            LineNo:=LineNo + 1;
                            if RenewableDays > 0 then HumanResourceMgmt.BuildLeaveJournal(LeaveJournalTemplate, LeaveJournalBatch, LineNo, Format(Date2DMY(CalcDate('1D', LeaveCalendar."End Date"), 3)), Employee."No.", Today, LeaveJournalLine."Leave Entry Type"::OpeinigBalance, 'OPENBAL', RenewableDays, 'Opening Balance for the period ' + Format(Date2DMY(CalcDate('1D', LeaveCalendar."End Date"), 3)), Employee."Global Dimension 1 Code", Employee."Global Dimension 2 Code", LeaveTypes.Code, 0D, 0D, 'OPENBAL');
                        end;
                    until Employee.Next = 0;
                end;
            until LeaveTypes.Next = 0;
            ProgressWindow.Close();
        end;
        HumanResourceMgmt.PostLeaveJournalLines(LeaveJournalTemplate, LeaveJournalBatch);
        CreateNewPeriod(LeaveCalendar);
        CLoseLeaveLedgerEntriesForClosedPeriod(LeaveCalendar);
    end;
    local procedure CreateNewPeriod(LeaveCalendar: Record "Leave Calendar")
    var
        LeaveCalendarVar: Record "Leave Calendar";
    begin
        ExecuteClosure(LeaveCalendar);
        if LeaveCalendarVar.Get(LeaveCalendar."Calendar Code")then begin
            if LeaveCalendar.Get(Format(Date2DMY(CalcDate('1D', LeaveCalendar."End Date"), 3)))then //Create new period
 LeaveCalendarVar.Init;
            LeaveCalendarVar."Calendar Code":=Format(Date2DMY(CalcDate('1D', LeaveCalendar."End Date"), 3));
            LeaveCalendarVar."Created By":=UserId;
            LeaveCalendarVar."Start Date":=CalcDate('1D', LeaveCalendar."End Date");
            LeaveCalendarVar."End Date":=CalcDate('1Y', LeaveCalendar."End Date");
            LeaveCalendarVar.Validate("End Date");
            LeaveCalendarVar."Current Leave Calendar":=true;
            LeaveCalendarVar.Description:=LeaveCalendarVar."Calendar Code" + ' Leave Calender';
            LeaveCalendarVar."Date Created":=WorkDate;
            LeaveCalendarVar."Last Modified By":=UserId;
            LeaveCalendarVar."Date Modified":=WorkDate;
            if LeaveCalendarVar.Insert then Message('Leave period %1 has been closed and %2 opened', LeaveCalendar."Calendar Code", Format(Date2DMY(CalcDate('1D', LeaveCalendar."End Date"), 3)));
        end;
    end;
    local procedure ExecuteClosure(LeaveCalendar: Record "Leave Calendar")
    var
        LeaveCalendarVar: Record "Leave Calendar";
    begin
        if LeaveCalendarVar.Get(LeaveCalendar."Calendar Code")then begin
            LeaveCalendarVar."Current Leave Calendar":=false;
            LeaveCalendarVar.Closed:=true;
            LeaveCalendarVar."Closed On":=WorkDate;
            LeaveCalendarVar."Closed By":=UserId;
            LeaveCalendarVar.Modify(true);
        end;
    end;
    local procedure CLoseLeaveLedgerEntriesForClosedPeriod(LeaveCalendar: Record "Leave Calendar")
    var
        LeaveEntries: Record "Leave Ledger Entries";
    begin
        LeaveEntries.Reset;
        LeaveEntries.SetRange("Leave Year Code", LeaveCalendar."Calendar Code");
        if LeaveEntries.FindSet then begin
            repeat LeaveEntries.Closed:=true;
                LeaveEntries.Modify(true);
            until LeaveEntries.Next = 0;
        end;
    end;
}
