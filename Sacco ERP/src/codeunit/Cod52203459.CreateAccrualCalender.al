codeunit 52203459 "Create Accrual Calender"
{
    var DateFormulaVariable: DateFormula;
    procedure CreateCalender(CalendarCode: Code[50]; FiscalYearStartDate: Date; PeriodLength: DateFormula; NoofPeriods: Integer)
    var
        AccountingPeriod: Record "Accrual Period";
        InvtSetup: Record "Inventory Setup";
        FiscalYearStartDate2: Date;
        FirstPeriodStartDate: Date;
        FirstPeriodLocked: Boolean;
        i: Integer;
        HideDialog: Boolean;
        ConfirmManagement: Codeunit "Confirm Management";
        CreateAndCloseQst: Label 'The new fiscal year begins before an existing fiscal year, so the new year will be closed automatically.\\Do you want to create and close the fiscal year?';
        CreateQst: Label 'After you create the new fiscal year, you cannot change its starting date.\\Do you want to create the fiscal year?';
    begin
        AccountingPeriod.Reset;
        AccountingPeriod.SetRange("Calender Code", CalendarCode);
        if AccountingPeriod.FindSet then AccountingPeriod.DeleteAll;
        AccountingPeriod."Starting Date":=FiscalYearStartDate;
        AccountingPeriod.SetRange(Closed, false);
        // if AccountingPeriod.Find('-') then begin
        //   FirstPeriodStartDate := AccountingPeriod."Starting Date";
        //   FirstPeriodLocked := AccountingPeriod."Date Locked";
        //   if (not HideDialog) and (FiscalYearStartDate < FirstPeriodStartDate) and FirstPeriodLocked then
        //     if not Confirm(CreateAndCloseQst,false) then
        //       exit;
        // end else
        //   if not HideDialog then
        //     if not Confirm(CreateQst,false) then
        //       exit;    AccountingPeriod.SetRange(Closed);
        for i:=1 to NoofPeriods + 1 do begin
            if(FiscalYearStartDate <= FirstPeriodStartDate) and (i = NoofPeriods + 1)then exit;
            AccountingPeriod.Init;
            AccountingPeriod."Calender Code":=CalendarCode;
            AccountingPeriod."Starting Date":=CalcDate('CM', FiscalYearStartDate);
            AccountingPeriod.Validate("Starting Date");
            if(i = 1) or (i = NoofPeriods + 1)then begin
                AccountingPeriod."New Fiscal Year":=true;
                InvtSetup.Get;
                AccountingPeriod."Average Cost Calc. Type":=InvtSetup."Average Cost Calc. Type";
                AccountingPeriod."Average Cost Period":=InvtSetup."Average Cost Period";
            end;
            if(FirstPeriodStartDate = 0D) and (i = 1)then AccountingPeriod."Date Locked":=true;
            if(AccountingPeriod."Starting Date" < FirstPeriodStartDate) and FirstPeriodLocked then begin
                AccountingPeriod.Closed:=true;
                AccountingPeriod."Date Locked":=true;
            end;
            if not AccountingPeriod.Find('=')then AccountingPeriod.Insert;
            FiscalYearStartDate:=CalcDate(PeriodLength, FiscalYearStartDate);
        end;
    end;
}
