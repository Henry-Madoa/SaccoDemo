report 52203544 "NITA Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/NITA Report.rdlc';

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
            column(SHIFNumber_Employee; Employee."SHIF No.")
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
            column(SHIFAmount; SHIFAmount)
            {
            }
            trigger OnAfterGetRecord()
            begin
                if not IncludeInactiveEmployees then Employee.SetFilter("Employee Status", '=%1|%2', Employee."Employee Status"::Active, Employee."Employee Status"::OnLeave);
                SNo+=1;
                EmpName:="First Name" + ' ' + "Middle Name" + ' ' + "Last Name";
                BasicPay:=0;
                TotalAllowances:=0;
                Paye:=0;
                Pension:=0;
                TaxablePay:=0;
                NetPay:=0;
                SHIFAmount:=0;
                PrPeriodTrans.Reset;
                PrPeriodTrans.SetRange("Employee Code", Employee."No.");
                PrPeriodTrans.SetRange("Payroll Period", PayrollPeriod);
                if PrPeriodTrans.FindSet then repeat if PrPeriodTrans."Transaction Code" = '0062' then SHIFAmount:=PrPeriodTrans.Amount;
                    until PrPeriodTrans.Next = 0;
                if SHIFAmount = 0 then CurrReport.Skip;
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
                    Caption = 'Payroll Period';
                    TableRelation = "Payroll Periods";
                }
                field("Include Inactive Employees"; IncludeInactiveEmployees)
                {
                    ApplicationArea = Basic, Suite;
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
    EmpName: Text;
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
    PeriodName: Text;
    PayrollPeriods: Record "Payroll Periods";
    NetPay: Decimal;
    SHIFAmount: Decimal;
    IncludeInactiveEmployees: Boolean;
}
