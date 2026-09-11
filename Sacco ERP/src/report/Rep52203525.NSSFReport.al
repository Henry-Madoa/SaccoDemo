report 52203525 "NSSF Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/NSSF Report.rdlc';

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
            column(EmployeeAmount; NSSFEmployeeAmount)
            {
            }
            column(EmployerAmount; NSSFEmployerAmount)
            {
            }
            column(NSSFNumber_Employee; Employee."NSSF No.")
            {
            }
            column(VoluntaryAmount; VoluntaryAmount)
            {
            }
            trigger OnAfterGetRecord()
            begin
                SNo+=1;
                EmpName:="First Name" + ' ' + "Middle Name" + ' ' + "Last Name";
                BasicPay:=0;
                TotalAllowances:=0;
                Paye:=0;
                Pension:=0;
                TaxablePay:=0;
                NetPay:=0;
                NSSFEmployeeAmount:=0;
                NSSFEmployerAmount:=0;
                VoluntaryAmount:=0;
                PrPeriodTrans.Reset;
                PrPeriodTrans.SetRange("Employee Code", Employee."No.");
                PrPeriodTrans.SetRange("Payroll Period", PayrollPeriod);
                if PrPeriodTrans.FindSet then repeat if PrPeriodTrans."Transaction Code" = 'NSSF' then begin
                            NSSFEmployeeAmount:=PrPeriodTrans.Amount;
                        end;
                        if PayrollEmployerTransaction.Get(Employee."No.", 'NSSF', PayrollPeriod)then begin
                            NSSFEmployerAmount:=PayrollEmployerTransaction.Amount;
                        end;
                        if PrPeriodTrans."Transaction Code" = 'NSSFVC01' then begin
                            VoluntaryAmount:=PrPeriodTrans.Amount;
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
    NSSFEmployeeAmount: Decimal;
    NSSFEmployerAmount: Decimal;
    PayrollEmployerTransaction: Record "Payroll Employer Transaction";
    VoluntaryAmount: Decimal;
}
