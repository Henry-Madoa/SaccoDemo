codeunit 52204009 "Payroll Loan Management"
{
    procedure LoanProcessing()
    var
        DateFilter: Text;
        MonthlyInterestAmount: Decimal;
    begin
        Employee.Reset();
        Employee.SetFilter("Employee Status", '%1|%2|%3', Employee."Employee Status"::Active, Employee."Employee Status"::OnLeave, Employee."Employee Status"::"Pending Final Payment");
        if Employee.FindSet then begin
            DateFilter := '';
            DateFilter := format(FnGetPayrollPeriod()) + '..' + Format(CalcDate('CM', FnGetPayrollPeriod()));
            repeat
                Loans.Reset();
                Loans.SetRange("Member No.", Employee."Member No.");
                Loans.SetFilter("Loan Balance", '<>%1', 0);
                if Loans.FindSet then begin
                    repeat
                        If ProductFactory.Get(Loans."Product Code") then begin
                            if ProductFactory."Checkoff Product" then begin
                                Loans.CalcFields("Loan Balance", "Monthly Principal", "Monthly Interest");
                                if Loans."Monthly Principal" <> 0 then begin
                                    PayrollTransactionCode[1].Reset();
                                    PayrollTransactionCode[1].SetRange("Coop Parameter", PayrollTransactionCode[1]."Coop Parameter"::loan);
                                    PayrollTransactionCode[1].SetRange("Loan Product", Loans."Product Code");
                                    if PayrollTransactionCode[1].FindFirst() then begin
                                        MonthlyInterestAmount := Round(Loans."Loan Balance" * ((Loans."Interest Rate" / 100) * (1 / 12)), 0.5, '=');
                                        GenerateLoanTransaction(PayrollTransactionCode[1], Employee, Loans."No.", Loans."Monthly Principal", MonthlyInterestAmount, Loans."Loan Balance");
                                    end;
                                end;
                            end;
                        end;
                    until Loans.Next = 0;
                end;
            until Employee.Next = 0;
        end;
    end;

    local procedure GenerateLoanTransaction(TransactionCode: Record "Payroll Transaction Code"; EmployeeRec: Record Employee; LoanNo: Code[20]; PrincipalAmount: Decimal; InterestAmount: Decimal; LoanBalance: Decimal)
    var
        PayrollPeriods: Record "Payroll Periods";
    begin
        PayrollPeriods.RESET;
        PayrollPeriods.SETRANGE(Closed, FALSE);
        IF NOT PayrollPeriods.FINDFIRST THEN ERROR('No open payroll period was found');
        PayrollEmployeeTransaction[1].Reset();
        PayrollEmployeeTransaction[1].SetRange("Employee Code", EmployeeRec."No.");
        PayrollEmployeeTransaction[1].SetRange("Transaction Code", TransactionCode.Code);
        PayrollEmployeeTransaction[1].SetRange("Payroll Period", PayrollPeriods."Start Date");
        if PayrollEmployeeTransaction[1].FindFirst() then begin
            PayrollEmployeeTransaction[1].Amount := Round(PrincipalAmount, 1);
            PayrollEmployeeTransaction[1].Membership := EmployeeRec."Member No.";
            PayrollEmployeeTransaction[1]."Loan Product" := TransactionCode."Loan Product";
            PayrollEmployeeTransaction[1].Validate("Loan Number", LoanNo);
            PayrollEmployeeTransaction[1].Validate(Balance, LoanBalance);
            PayrollEmployeeTransaction[1].Modify(true);
            GenerateLoanInterestTransaction(PayrollEmployeeTransaction[1], InterestAmount);
        end
        else begin
            PayrollEmployeeTransaction[1].Init;
            PayrollEmployeeTransaction[1].Validate("Employee Code", EmployeeRec."No.");
            PayrollEmployeeTransaction[1].Validate("Transaction Code", TransactionCode.Code);
            PayrollEmployeeTransaction[1].Validate("Payroll Period", PayrollPeriods."Start Date");
            PayrollEmployeeTransaction[1].Amount := Round(PrincipalAmount, 1);
            PayrollEmployeeTransaction[1].Membership := EmployeeRec."Member No.";
            PayrollEmployeeTransaction[1]."Loan Product" := TransactionCode."Loan Product";
            PayrollEmployeeTransaction[1].Validate("Loan Number", LoanNo);
            PayrollEmployeeTransaction[1].Validate(Balance, LoanBalance);
            PayrollEmployeeTransaction[1].Insert(true);
            GenerateLoanInterestTransaction(PayrollEmployeeTransaction[1], InterestAmount);
        end;
    end;

    local procedure GenerateLoanInterestTransaction(EmployeeTransaction: Record "Payroll Employee Transaction"; InterestAmount: Decimal)
    var
        PayrollPeriods: Record "Payroll Periods";
    begin
        PayrollPeriods.RESET;
        PayrollPeriods.SETRANGE(Closed, FALSE);
        IF NOT PayrollPeriods.FINDFIRST THEN ERROR('No open payroll period was found');
        PayrollTransactionCode[2].Reset();
        PayrollTransactionCode[2].SetRange("Coop Parameter", PayrollTransactionCode[2]."Coop Parameter"::"loan Interest");
        PayrollTransactionCode[2].SetRange("Principal Loan", EmployeeTransaction."Transaction Code");
        If PayrollTransactionCode[2].FindFirst() then begin
            PayrollEmployeeTransaction[3].Init;
            PayrollEmployeeTransaction[3].TransferFields(EmployeeTransaction);
            PayrollEmployeeTransaction[3].Validate("Transaction Code", PayrollTransactionCode[2].Code);
            PayrollEmployeeTransaction[3].Validate(Amount, Round(InterestAmount, 1));
            //PayrollEmployeeTransaction[3].Balance:=
            PayrollEmployeeTransaction[4].Reset();
            PayrollEmployeeTransaction[4].SetRange("Employee Code", PayrollEmployeeTransaction[3]."Employee Code");
            PayrollEmployeeTransaction[4].SetRange("Transaction Code", PayrollEmployeeTransaction[3]."Transaction Code");
            PayrollEmployeeTransaction[4].SetRange("Payroll Period", PayrollPeriods."Start Date");
            if not PayrollEmployeeTransaction[4].FindFirst() then begin
                PayrollEmployeeTransaction[3].Insert;
            end
            else if PayrollEmployeeTransaction[4].FindFirst() then begin
                PayrollEmployeeTransaction[4].Validate(Amount, Round(InterestAmount, 1));
                PayrollEmployeeTransaction[4]."Loan Product" := EmployeeTransaction."Loan Product";
                PayrollEmployeeTransaction[4].Membership := EmployeeTransaction.Membership;
                PayrollEmployeeTransaction[4].Validate("Loan Number", EmployeeTransaction."Loan Number");
                PayrollEmployeeTransaction[4].Modify(true);
            end;
        end;
    end;

    var
        Employee: Record Employee;
        PayrollTransactionCode: array[3] of Record "Payroll Transaction Code";
        PayrollEmployeeTransaction: array[4] of Record "Payroll Employee Transaction";
        Loans: Record Loans;
        ProductFactory: Record "Sacco Products";

    procedure FnGetPayrollPeriod(): Date
    var
        PayrollPeriods: Record "Payroll Periods";
    begin
        PayrollPeriods.RESET;
        PayrollPeriods.SETRANGE(Closed, FALSE);
        if PayrollPeriods.FindFirst() then exit(PayrollPeriods."Start Date");
    end;
}
