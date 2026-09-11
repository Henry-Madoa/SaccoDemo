codeunit 52203444 "Calculate Variance"
{
    trigger OnRun()
    begin
    //CalculateVarCe(090121D,100121D);
    end;
    var DetailedPayrollVariance: Record "Detailed Payroll Variance";
    procedure CalculateVarCe(PreviousPeriod: Date; CurrentPeriod: Date)
    var
        Employee: Record Employee;
        PayrollTransactionCode: Record "Payroll Transaction Code";
        PayrollPeriodTransaction: Record "Payroll Period Transaction";
        PreviousAmount: Decimal;
        CurrentAmount: Decimal;
        VarCe: Decimal;
    begin
        DetailedPayrollVariance.DeleteAll;
        PayrollTransactionCode.Reset;
        if PayrollTransactionCode.FindSet then begin
            repeat Employee.Reset;
                if Employee.FindSet then begin
                    repeat CurrentAmount:=0;
                        PreviousAmount:=0;
                        VarCe:=0;
                        PayrollPeriodTransaction.Reset;
                        PayrollPeriodTransaction.SetRange("Transaction Code", PayrollTransactionCode.Code);
                        PayrollPeriodTransaction.SetRange("Payroll Period", CurrentPeriod);
                        PayrollPeriodTransaction.SetRange("Employee Code", Employee."No.");
                        if PayrollPeriodTransaction.FindFirst then CurrentAmount:=PayrollPeriodTransaction.Amount
                        else
                            CurrentAmount:=0;
                        PayrollPeriodTransaction.Reset;
                        PayrollPeriodTransaction.SetRange("Transaction Code", PayrollTransactionCode.Code);
                        PayrollPeriodTransaction.SetRange("Payroll Period", PreviousPeriod);
                        PayrollPeriodTransaction.SetRange("Employee Code", Employee."No.");
                        if PayrollPeriodTransaction.FindFirst then PreviousAmount:=PayrollPeriodTransaction.Amount
                        else
                            PreviousAmount:=0;
                        if(PreviousAmount <> 0) and (CurrentAmount <> 0)then if PreviousAmount <> CurrentAmount then begin
                                VarCe:=CurrentAmount - PreviousAmount;
                            end;
                        if VarCe <> 0 then PopulateVarCeTable(Employee."No.", Employee.FullName, PreviousPeriod, CurrentPeriod, CurrentAmount, PreviousAmount, VarCe, 0, PayrollTransactionCode.Code, PayrollTransactionCode.Name);
                    until Employee.Next = 0;
                end;
            until PayrollTransactionCode.Next = 0;
        end;
    end;
    local procedure PopulateVarCeTable(EmployeeNo: Code[20]; EmployeeName: Text; PreviousPeriod: Date; CurrentPeriod: Date; CurrentAmount: Decimal; PreviousAmount: Decimal; VarCe: Decimal; PercentageVarCe: Decimal; TransactionCode: Code[50]; TransactionName: Text)
    var
        DetailedPayrollVarCe: Record "Detailed Payroll Variance";
    begin
        DetailedPayrollVarCe.Init;
        //  DetailedPayrollVarCe."Previous Period" := DetailedPayrollVarCe.Count + 1;
        // DetailedPayrollVarCe."Entry No" := TransactionCode;
        DetailedPayrollVarCe."Transaction Code":=TransactionName;
        DetailedPayrollVarCe."Transaction Name":=EmployeeNo;
        DetailedPayrollVarCe."Employee No.":=EmployeeName;
        // DetailedPayrollVarCe."Previous Amount" := CurrentPeriod;
        // DetailedPayrollVarCe."Employee Name" := PreviousPeriod;
        // DetailedPayrollVarCe."Current Period" := PreviousAmount;
        DetailedPayrollVarCe."Current Amount":=CurrentAmount;
        DetailedPayrollVarCe.VarCe:=VarCe;
        DetailedPayrollVarCe.Percentage:=PercentageVarCe;
        DetailedPayrollVarCe.Insert;
    end;
}
