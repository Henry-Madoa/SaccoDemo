report 52203536 "Pension Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Pension Report.rdl';

    dataset
    {
        dataitem(Employee; Employee)
        {
            DataItemTableView = WHERE("Nature Of Employment"=FILTER(<>Board));
            RequestFilterFields = "No.";

            column(CompanyName; CompanyInformation.Name)
            {
            }
            column(CompanyPicture; CompanyInformation.Picture)
            {
            }
            column(CompanyAddress; CompanyInformation.Address)
            {
            }
            column(CompanyPhone; CompanyInformation."Phone No.")
            {
            }
            column(CompanyLocation; CompanyInformation.Location)
            {
            }
            column(CompanyEmail; CompanyInformation."E-Mail")
            {
            }
            column(CompanyWebsite; CompanyInformation."Home Page")
            {
            }
            column(CompanyPostCode; CompanyInformation."Post Code")
            {
            }
            column(KRANumber_Employee; Employee."KRA Number")
            {
            }
            column(NationalID_Employee; Employee."National ID")
            {
            }
            column(EmpName; EmpName)
            {
            }
            column(SNo; SNo)
            {
            }
            column(Pension; Pension)
            {
            }
            column(Paye; Paye)
            {
            }
            column(TotalAllowances; TotalAllowances)
            {
            }
            column(BasicPay; BasicPay)
            {
            }
            column(PayrollPeriod; PayrollPeriod)
            {
            }
            column(TaxablePay; TaxablePay)
            {
            }
            column(No_EmployeesHR; Employee."No.")
            {
            }
            column(PeriodName; PeriodName)
            {
            }
            column(NetPay; NetPay)
            {
            }
            column(EmployeeAmount; EmployeeAmount)
            {
            }
            column(EmployerAmount; EmployerAmount)
            {
            }
            column(VoluntaryPension; VoluntaryPension)
            {
            }
            column(TotalPension; EmployeeAmount + EmployerAmount + VoluntaryPension)
            {
            }
            column(PENSIONS_CONTRIBUTION_REPORT__;'PENSIONS CONTRIBUTION REPORT')
            {
            }
            column(PERIODCaption;'PERIOD')
            {
            }
            column(TotalCaption;'TOTAL')
            {
            }
            column(Prepared_By_;'Prepared By.............................................Sign.............................................Date.............................................')
            {
            }
            column(Verified_By_;'Verified By.............................................Sign.............................................Date.............................................')
            {
            }
            column(Audited_By_;'Audited By...............................................Sign.............................................Date.............................................')
            {
            }
            column(Approved_By_;'Approved By.............................................Sign.............................................Date.............................................')
            {
            }
            trigger OnAfterGetRecord()
            begin
                if not IncludeInactiveEmployees then Employee.SetFilter("Employee Status", '=%1|=%2', Employee."Employee Status"::Active, Employee."Employee Status"::OnLeave);
                SNo+=1;
                EmpName:=FullName;
                if PayrollPeriods.Get(PayrollPeriod)then PeriodName:=PayrollPeriods."Period Name";
                BasicPay:=0;
                TotalAllowances:=0;
                Paye:=0;
                Pension:=0;
                TaxablePay:=0;
                NetPay:=0;
                EmployeeAmount:=0;
                EmployerAmount:=0;
                VoluntaryPension:=0;
                PrPeriodTrans.Reset;
                PrPeriodTrans.SetRange("Employee Code", Employee."No.");
                PrPeriodTrans.SetRange("Payroll Period", PayrollPeriod);
                if PrPeriodTrans.FindSet then repeat if PayrollTransactionCode.Get(PrPeriodTrans."Transaction Code")then begin
                            if PayrollTransactionCode."Is Pension" and not PayrollTransactionCode."Is Voluntary" then EmployeeAmount+=PrPeriodTrans.Amount
                            else if PayrollTransactionCode."Is Pension" and PayrollTransactionCode."Is Voluntary" then VoluntaryPension+=PrPeriodTrans.Amount;
                        end;
                    until PrPeriodTrans.Next = 0;
                PayrollEmployerTransaction.Reset();
                PayrollEmployerTransaction.SetRange("Employee Code", Employee."No.");
                PayrollEmployerTransaction.SetRange("Payroll Period", PayrollPeriod);
                if PayrollEmployerTransaction.FindSet then begin
                    if PayrollTransactionCode.Get(PayrollEmployerTransaction."Transaction Code")then begin
                        if PayrollTransactionCode."Is Pension" then EmployerAmount+=PayrollEmployerTransaction.Amount;
                    end;
                end;
                PayrollEmployeeP9TaxInfo.Reset();
                PayrollEmployeeP9TaxInfo.SetRange("Employee Code", Employee."No.");
                PayrollEmployeeP9TaxInfo.SetRange("Payroll Period", PayrollPeriod);
                if PayrollEmployeeP9TaxInfo.FindFirst()then begin
                    BasicPay:=PayrollEmployeeP9TaxInfo."Basic Pay";
                    TotalAllowances:=PayrollEmployeeP9TaxInfo.Allowances;
                    Paye:=PayrollEmployeeP9TaxInfo.PAYE;
                    Pension:=PayrollEmployeeP9TaxInfo.Pension;
                    TaxablePay:=PayrollEmployeeP9TaxInfo."Taxable Pay";
                    NetPay:=PayrollEmployeeP9TaxInfo."Net Pay";
                end;
            end;
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
                if PayrollPeriod = 0D then Error('You must specify the payroll period');
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                field(PayrollPeriod; PayrollPeriod)
                {
                    ApplicationArea = All;
                    Caption = 'Payroll Period';
                    TableRelation = "Payroll Periods";
                }
                field("Include Inactive Employees"; IncludeInactiveEmployees)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        CompanyInfo.Get;
        if PayrollPeriod = 0D then Error('Please Specify the payroll period');
    end;
    var CompanyInfo: Record "Company Information";
    EmpName: Text[100];
    HrEmp: Record Employee;
    SNo: Integer;
    BasicPay: Decimal;
    TotalAllowances: Decimal;
    Paye: Decimal;
    PayrollPeriod: Date;
    Pension: Decimal;
    PrPeriodTrans: Record "Payroll Period Transaction";
    TaxablePay: Decimal;
    CompanyInformation: Record "Company Information";
    PeriodName: Text[100];
    PayrollPeriods: Record "Payroll Periods";
    NetPay: Decimal;
    EmployeeAmount: Decimal;
    EmployerAmount: Decimal;
    PayrollEmployerTransaction: Record "Payroll Employer Transaction";
    VoluntaryPension: Decimal;
    IncludeInactiveEmployees: Boolean;
    PayrollTransactionCode: Record "Payroll Transaction Code";
    i: Integer;
    PayrollPeriodTransaction: array[6]of Record "Payroll Period Transaction";
    PayrollEmployeeP9TaxInfo: Record "Payroll Employee P9 Tax Info";
    Allowances: array[20]of Decimal;
}
