codeunit 52203439 "Gratuity Calculation"
{
    procedure CheckIfEmployeeContractExpires(EmpNo: Code[50]; PayrollDate: Date): Boolean var
        Employee: Record Employee;
    begin
        if Employee.Get(EmpNo)then begin
            if(Employee."Employment Date" <> 0D) and (Employee."End of Contract Date" <> 0D) and (Employee."Nature Of Employment" in[Employee."Nature Of Employment"::Contract])then begin
                if(Date2DMY(PayrollDate, 2) = Date2DMY(Employee."End of Contract Date", 2)) and (Date2DMY(PayrollDate, 3) = Date2DMY(Employee."End of Contract Date", 3))then exit(true)
                else
                    exit(false)end;
        end;
    end;
    procedure CalculateTotalBasicAmount(EmpNo: Code[50]; PayrollPeriod: Date; BasicPayAmount: Decimal): Decimal var
        PayrollPeriodTransaction: Record "Payroll Period Transaction";
        SubTotal: Decimal;
    begin
        PayrollPeriodTransaction.Reset;
        PayrollPeriodTransaction.SetRange("Employee Code", EmpNo);
        PayrollPeriodTransaction.SetRange("Transaction Code", 'BPAY');
        if PayrollPeriodTransaction.FindSet then begin
            PayrollPeriodTransaction.CalcSums(Amount);
            SubTotal:=PayrollPeriodTransaction.Amount;
        end;
        exit(SubTotal + BasicPayAmount);
    end;
    procedure CalculateGratuityAmount(EmpNo: Code[20]; PayrollPeriod: Date; CurrentBasicPayAmount: Decimal): Decimal var
        PayrollPeriodTransaction: Record "Payroll Period Transaction";
        TotalBasicPayAmount: Decimal;
        PayrollVitalSetup: Record "Payroll Vital Setup";
    begin
        TotalBasicPayAmount:=CalculateTotalBasicAmount(EmpNo, PayrollPeriod, CurrentBasicPayAmount);
        PayrollVitalSetup.Get;
        PayrollVitalSetup.TestField("Gratuity %");
        exit((PayrollVitalSetup."Gratuity %" / 100) * TotalBasicPayAmount);
    end;
}
