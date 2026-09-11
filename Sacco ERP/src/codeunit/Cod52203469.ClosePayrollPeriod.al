codeunit 52203469 "Close Payroll Period"
{
    [IntegrationEvent(false, false)]
    local procedure OnBeforeTransferTransactions(PayrollPeriods: Record "Payroll Periods")
    begin
    end;
    [IntegrationEvent(false, false)]
    local procedure OnAfterCloseTransferTransactions(PayrollPeriods: Record "Payroll Periods")
    begin
    end;
    [IntegrationEvent(false, false)]
    procedure OnClosePayrollPeriod(PayrollPeriods: Record "Payroll Periods")
    begin
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Close Payroll Period", 'OnClosePayrollPeriod', '', false, false)]
    local procedure TransferTransactions(PayrollPeriods: Record "Payroll Periods")
    var
        PayrollEmployeeTransaction: Record "Payroll Employee Transaction";
        NextPeriod: Date;
        PayrollTransactionCode: Record "Payroll Transaction Code";
        Employee: Record Employee;
    begin
        OnBeforeTransferTransactions(PayrollPeriods);
        with PayrollPeriods do begin
            NextPeriod:=CalcDate('CM+1D', PayrollPeriods."Start Date");
            PayrollEmployeeTransaction.Reset;
            PayrollEmployeeTransaction.SetRange("Payroll Period", "Start Date");
            if PayrollEmployeeTransaction.FindSet then begin
                repeat if Employee.Get(PayrollEmployeeTransaction."Employee Code")then begin
                        if Employee."Employee Status" <> Employee."Employee Status"::"Pending Final Payment" then begin
                            if PayrollTransactionCode.Get(PayrollEmployeeTransaction."Transaction Code")then begin
                                if(not PayrollEmployeeTransaction."Temporary Transaction")then //IF NOT (PayrollTransactionCode."Special Transactions" IN [PayrollTransactionCode."Special Transactions"::"Imprest Recovery"]) THEN
 PayrollEmployeeTransaction.Rename(PayrollEmployeeTransaction."Employee Code", PayrollEmployeeTransaction."Transaction Code", NextPeriod, Date2DMY(NextPeriod, 2), Date2DMY(NextPeriod, 3))
                                else
                                    PayrollEmployeeTransaction.Delete;
                            end;
                        end
                        else
                        begin
                            Employee.Validate("Employee Status", Employee."Employee Status"::Inactive);
                            Employee.Modify(true);
                        end;
                    end;
                until PayrollEmployeeTransaction.Next = 0;
            end;
        end;
        OnAfterCloseTransferTransactions(PayrollPeriods);
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Close Payroll Period", 'OnAfterCloseTransferTransactions', '', false, false)]
    local procedure CreateTheNewPeriod(PayrollPeriods: Record "Payroll Periods")
    var
        PayrollPeriodsVar: Record "Payroll Periods";
        NextPeriod: Date;
    begin
        with PayrollPeriods do begin
            NextPeriod:=CalcDate('CM+1D', "Start Date");
        end;
        PayrollPeriodsVar.Init;
        PayrollPeriodsVar."Period Name":=Format(NextPeriod, 0, '<Month text>-<Year4>');
        PayrollPeriodsVar."Start Date":=NextPeriod;
        PayrollPeriodsVar."End Date":=CalcDate('CM', NextPeriod);
        PayrollPeriodsVar."Period Month":=Date2DMY(NextPeriod, 2);
        PayrollPeriodsVar."Period Year":=Date2DMY(NextPeriod, 3);
        PayrollPeriodsVar."Created By":=UserId;
        PayrollPeriodsVar."Created On":=WorkDate;
        PayrollPeriodsVar.Insert;
        CloseTheOldPeriod(PayrollPeriods, PayrollPeriodsVar."Period Name");
    end;
    local procedure CloseTheOldPeriod(var PayrollPeriods: Record "Payroll Periods"; NextPeriodName: Text)
    begin
        with PayrollPeriods do begin
            PayrollPeriods.Closed:=true;
            PayrollPeriods."Closed By":=UserId;
            PayrollPeriods."Closed On":=WorkDate;
            Modify(true);
        end;
        Message('[%1] successfully closed and [%2] opened', PayrollPeriods."Period Name", NextPeriodName);
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Close Payroll Period", 'OnBeforeTransferTransactions', '', false, false)]
    local procedure CheckIfSalaryAdvancedIsFullyPaid(PayrollPeriods: Record "Payroll Periods")
    var
        PayrollTransactionCode: Record "Payroll Transaction Code";
        // SalaryAdvanceRepSchedule: Record "Salary Advance Rep. Schedule";
        PayrollEmployeeTransaction: Record "Payroll Employee Transaction";
    begin
    // PayrollEmployeeTransaction.RESET;
    // PayrollEmployeeTransaction.SETFILTER("Imprest No",'<>%1','');
    // IF PayrollEmployeeTransaction.FINDFIRST THEN
    //  BEGIN
    //    REPEAT
    //      IF PayrollTransactionCode.GET(PayrollEmployeeTransaction."Transaction Code") THEN
    //        BEGIN
    //          IF PayrollTransactionCode."Special Transactions" IN [PayrollTransactionCode."Special Transactions"::"Salary Adv Recovery"] THEN
    //            BEGIN
    //              SalaryAdvanceRepSchedule.RESET;
    //              SalaryAdvanceRepSchedule.SETCURRENTKEY("Entry No");
    //              SalaryAdvanceRepSchedule.SETRANGE("Loan No",PayrollEmployeeTransaction."Imprest No");
    //              SalaryAdvanceRepSchedule.SETRANGE(Paid,FALSE);
    //              IF SalaryAdvanceRepSchedule.FINDFIRST THEN
    //                BEGIN
    //                  SalaryAdvanceRepSchedule.Paid:=TRUE;
    //                  SalaryAdvanceRepSchedule.MODIFY(TRUE);
    //                end;
    //            end;
    //        end;
    //    UNTIL PayrollEmployeeTransaction.NEXT=0;
    //  end;
    //
    //
    // PayrollEmployeeTransaction.RESET;
    // PayrollEmployeeTransaction.SETFILTER("Imprest No",'<>%1','');
    // IF PayrollEmployeeTransaction.FINDFIRST THEN
    //  BEGIN
    //    REPEAT
    //      IF PayrollTransactionCode.GET(PayrollEmployeeTransaction."Transaction Code") THEN
    //        BEGIN
    //          IF PayrollTransactionCode."Special Transactions" IN [PayrollTransactionCode."Special Transactions"::"Salary Adv Recovery"] THEN
    //            BEGIN
    //              SalaryAdvanceRepSchedule.RESET;
    //              SalaryAdvanceRepSchedule.SETCURRENTKEY("Entry No");
    //              SalaryAdvanceRepSchedule.SETRANGE("Loan No",PayrollEmployeeTransaction."Imprest No");
    //              SalaryAdvanceRepSchedule.SETRANGE(Paid,FALSE);
    //              IF NOT SalaryAdvanceRepSchedule.FINDFIRST THEN
    //                BEGIN
    //                  PayrollEmployeeTransaction.DELETE;
    //                end;
    //            end;
    //        end;
    //    UNTIL PayrollEmployeeTransaction.NEXT=0;
    //  end;
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Close Payroll Period", 'OnAfterCloseTransferTransactions', '', false, false)]
    local procedure CheckIfDecemberAndCalculateGratuity(PayrollPeriods: Record "Payroll Periods")
    var
        Employee: Record Employee;
        GratuityLedgerEntries: Record "Gratuity Ledger Entries";
        PayrollPeriodTransaction: Record "Payroll Period Transaction";
        Eligible: Boolean;
        IsConfirmed: Boolean;
        MonthNo: Integer;
        YearNo: Integer;
        EmploymentMonth: Integer;
        EmploymentYear: Integer;
        BasicPay: Decimal;
        PayrollSalaryCard: Record "Payroll Salary Card";
        GratuityAmount: Decimal;
        PayrollVitalSetup: Record "Payroll Vital Setup";
        PeriodStartDate: Date;
        PeriodEndDate: Date;
    begin
        Employee.Reset;
        Employee.SetFilter("Employee Status", '=%1|%2', Employee."Employee Status"::Active, Employee."Employee Status"::OnLeave);
        if Employee.FindSet then begin
            repeat GratuityAmount:=0;
                if Employee."Probation Status" in[Employee."Probation Status"::Confirmed]then begin
                    if Employee."End of Probation Period" <> 0D then begin
                        Eligible:=false;
                        if(Date2DMY(Employee."End of Probation Period", 2) = PayrollPeriods."Period Month") and (Date2DMY(Employee."End of Probation Period", 3) < PayrollPeriods."Period Year")then Eligible:=true;
                        if Eligible then begin
                            PayrollSalaryCard.Get(Employee."No.");
                            PayrollVitalSetup.Get;
                            GratuityAmount:=(PayrollVitalSetup."Gratuity %" / 100) * PayrollSalaryCard."Basic Pay";
                            GratuityLedgerEntries.Init;
                            GratuityLedgerEntries."Employee No":=Employee."No.";
                            GratuityLedgerEntries."Payroll Year":=PayrollPeriods."Period Year";
                            GratuityLedgerEntries."Payroll Period":=PayrollPeriods."Start Date";
                            GratuityLedgerEntries."Date of confirmation":=Employee."End of Probation Period";
                            if Evaluate(PeriodEndDate, (Format(Date2DMY(Employee."End of Probation Period", 1)) + '/' + Format(PayrollPeriods."Period Month") + '/' + Format(PayrollPeriods."Period Year")))then begin
                                GratuityLedgerEntries."Period End Date":=PeriodEndDate;
                                GratuityLedgerEntries."Period Start Date":=CalcDate('-1Y', PeriodEndDate);
                            end;
                            GratuityLedgerEntries.Amount:=GratuityAmount;
                            GratuityLedgerEntries.Paid:=false;
                            GratuityLedgerEntries.Insert;
                        end;
                    end;
                end;
            until Employee.Next = 0;
        end;
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Close Payroll Period", 'OnBeforeTransferTransactions', '', false, false)]
    local procedure CheckIfGratuityIsPaid(PayrollPeriods: Record "Payroll Periods")
    var
        PayrollTransactionCode: Record "Payroll Transaction Code";
        PayrollEmployeeTransaction: Record "Payroll Employee Transaction";
        GratuityLedgerEntries: Record "Gratuity Ledger Entries";
    begin
        PayrollEmployeeTransaction.Reset;
        if PayrollEmployeeTransaction.FindSet then begin
            repeat if PayrollTransactionCode.Get(PayrollEmployeeTransaction."Transaction Code")then begin
                    if PayrollTransactionCode."Special Transactions" in[PayrollTransactionCode."Special Transactions"::Gratuity]then begin
                        GratuityLedgerEntries.Reset;
                        GratuityLedgerEntries.SetRange("Employee No", PayrollEmployeeTransaction."Employee Code");
                        if GratuityLedgerEntries.FindSet then begin
                            GratuityLedgerEntries.CalcSums(Amount);
                            if GratuityLedgerEntries.Amount = PayrollEmployeeTransaction.Amount then begin
                                repeat GratuityLedgerEntries.Paid:=true;
                                    GratuityLedgerEntries.Modify(true);
                                until GratuityLedgerEntries.Next = 0;
                                PayrollEmployeeTransaction.Delete;
                            end;
                        end;
                    end;
                end;
            until PayrollEmployeeTransaction.Next = 0;
        end;
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Close Payroll Period", 'OnBeforeTransferTransactions', '', false, false)]
    local procedure UpdateBalances(PayrollPeriods: Record "Payroll Periods")
    var
        PayrollEmployeeTransaction: Record "Payroll Employee Transaction";
        PayrollTransactionCode: Record "Payroll Transaction Code";
    begin
        PayrollEmployeeTransaction.Reset;
        PayrollEmployeeTransaction.SetRange("Payroll Period", PayrollPeriods."Start Date");
        if PayrollEmployeeTransaction.FindSet then begin
            repeat PayrollEmployeeTransaction.Validate(PayrollEmployeeTransaction.Balance, Round((PayrollEmployeeTransaction.Balance - PayrollEmployeeTransaction.Amount)));
                PayrollEmployeeTransaction.Modify(true);
                if PayrollEmployeeTransaction."Transaction Code" = 'SALARY ADV' then begin
                    if PayrollEmployeeTransaction.Balance <= 0 then PayrollEmployeeTransaction.Delete;
                end;
            until PayrollEmployeeTransaction.Next = 0;
        end;
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Close Payroll Period", 'OnAfterCloseTransferTransactions', '', false, false)]
    local procedure DropVariedAndZeroBalanceTransaction(PayrollPeriods: Record "Payroll Periods")
    var
        PayrollEmployeeTransaction: Record "Payroll Employee Transaction";
        PayrollTransactionCode: Record "Payroll Transaction Code";
    begin
        if PayrollEmployeeTransaction.FindSet then begin
            repeat PayrollTransactionCode.Get(PayrollEmployeeTransaction."Transaction Code");
                if PayrollTransactionCode.Frequency in[PayrollTransactionCode.Frequency::Varied]then begin
                    PayrollEmployeeTransaction.Delete end;
            //    IF PayrollTransactionCode."Balance Type" IN [PayrollTransactionCode."Balance Type"::Reducing] THEN
            //      IF PayrollEmployeeTransaction.Balance<=0 THEN
            //        PayrollEmployeeTransaction.DELETE;
            until PayrollEmployeeTransaction.Next = 0;
        end;
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Close Payroll Period", 'OnAfterCloseTransferTransactions', '', false, false)]
    local procedure DropCompletedExecutedPeriods(PayrollPeriods: Record "Payroll Periods")
    var
        PayrollEmployeeTransaction: Record "Payroll Employee Transaction";
    begin
    /*PayrollEmployeeTransaction.RESET;
            PayrollEmployeeTransaction.SETFILTER("No Of Periods",'>%1',0);
            PayrollEmployeeTransaction.SETFILTER("No Of Periods",'=%1',PayrollEmployeeTransaction."Executed periods");
            IF PayrollEmployeeTransaction.FINDSET THEN
             BEGIN
               PayrollEmployeeTransaction.DELETEALL;
             end;*/
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Close Payroll Period", 'OnBeforeTransferTransactions', '', false, false)]
    local procedure IncrementExecutedPeriods(PayrollPeriods: Record "Payroll Periods")
    var
        PayrollEmployeeTransaction: Record "Payroll Employee Transaction";
    begin
        PayrollEmployeeTransaction.Reset;
        PayrollEmployeeTransaction.SetRange("Payroll Period", PayrollPeriods."Start Date");
        PayrollEmployeeTransaction.SetFilter("No Of Periods", '>%1', 0);
        if PayrollEmployeeTransaction.FindSet then begin
            repeat PayrollEmployeeTransaction."Executed periods"+=1;
                PayrollEmployeeTransaction.Modify(true);
                if PayrollEmployeeTransaction."Executed periods" = PayrollEmployeeTransaction."No Of Periods" then PayrollEmployeeTransaction.Delete;
            until PayrollEmployeeTransaction.Next = 0;
        end;
    end;
}
