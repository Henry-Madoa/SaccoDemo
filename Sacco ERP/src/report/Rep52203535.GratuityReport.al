report 52203535 "Gratuity Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Gratuity Report.rdlc';

    dataset
    {
        dataitem(Employee; Employee)
        {
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
            column(EmployeeAmount; NSSFEmployeeAmount)
            {
            }
            column(EmployerAmount; NSSFEmployerAmount)
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
                NSSFEmployeeAmount:=0;
                NSSFEmployerAmount:=0;
                PrPeriodTrans.Reset;
                PrPeriodTrans.SetRange("Employee Code", Employee."No.");
                PrPeriodTrans.SetRange("Payroll Period", PayrollPeriod);
                if PrPeriodTrans.FindSet then repeat if PrPeriodTrans."Transaction Code" = 'GRAT' then begin
                            NSSFEmployeeAmount:=PrPeriodTrans.Amount;
                            NSSFEmployerAmount:=PrPeriodTrans."Emp Amount";
                        end;
                    until PrPeriodTrans.Next = 0;
                if NSSFEmployeeAmount = 0 then CurrReport.Skip;
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
    NSSFEmployeeAmount: Decimal;
    NSSFEmployerAmount: Decimal;
    IncludeInactiveEmployees: Boolean;
}
