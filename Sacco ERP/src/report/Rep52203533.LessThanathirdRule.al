report 52203533 "Less Than a third Rule"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Payroll GrossNet Pay.rdlc';
    Caption = 'Less Than a third Rule';

    dataset
    {
        dataitem(Employee; Employee)
        {
            DataItemTableView = WHERE("Nature Of Employment"=FILTER(<>Board));

            column(USERID; UserId)
            {
            }
            column(TODAY; Today)
            {
            }
            column(PeriodName; PeriodName)
            {
            }
            column(CurrReport_PAGENO; CurrReport.PageNo)
            {
            }
            column(companyinfo_Picture; companyinfo.Picture)
            {
            }
            column(companyinfoName; companyinfo.Name)
            {
            }
            column(BasicPay; BasicPay)
            {
            }
            column(GrossPay; GrossPay)
            {
            }
            column(EmployeeName; EmployeeName)
            {
            }
            column(NetPay; NetPay)
            {
            }
            column(TotNetPay; TotNetPay)
            {
            }
            column(TotGrossPay; TotGrossPay)
            {
            }
            column(TotBasicPay; TotBasicPay)
            {
            }
            column(Percentage; Percentage)
            {
            }
            column(No_EmployeesHR; Employee."No.")
            {
            }
            column(TotDeductions; TotDeductions)
            {
            }
            column(KRANumber_Employee; Employee."KRA Number")
            {
            }
            trigger OnAfterGetRecord()
            begin
                if not IncludeInactiveEmployees then Employee.SetFilter("Employee Status", '=%1|=%2', Employee."Employee Status"::Active, Employee."Employee Status"::OnLeave);
                EmployeeName:="First Name" + ' ' + "Middle Name" + ' ' + "Last Name";
                BasicPay:=0;
                GrossPay:=0;
                NetPay:=0;
                PeriodTrans.Reset;
                PeriodTrans.SetRange(PeriodTrans."Employee Code", Employee."No.");
                PeriodTrans.SetRange(PeriodTrans."Payroll Period", SelectedPeriod);
                PeriodTrans.SetFilter(PeriodTrans."Group Order", '=1|=4|=9');
                PeriodTrans.SetFilter(PeriodTrans."Sub Group Order", '<=1');
                PeriodTrans.SetCurrentKey(PeriodTrans."Employee Code", PeriodTrans."Period Month", PeriodTrans."Period Year", PeriodTrans."Group Order", PeriodTrans."Sub Group Order");
                if PeriodTrans.Find('-')then repeat if PeriodTrans."Transaction Code" = 'GPAY' then TotGrossPay:=PeriodTrans.Amount;
                        if PeriodTrans."Transaction Code" = 'TOT-DED' then TotDeductions:=PeriodTrans.Amount;
                        if PeriodTrans."Transaction Code" = 'NPAY' then NetPay:=PeriodTrans.Amount;
                        if PeriodTrans."Transaction Code" = 'BPAY' then BasicPay:=PeriodTrans.Amount;
                    until PeriodTrans.Next = 0;
                if BasicPay <= 0 then CurrReport.Skip;
                if NetPay > ((1 / 3) / BasicPay)then CurrReport.Skip;
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                field(SelectedPeriod; SelectedPeriod)
                {
                    ApplicationArea = All;
                    Caption = 'Selected Period';
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
        objPeriod.Reset;
        objPeriod.SetRange(objPeriod."Start Date", SelectedPeriod);
        if objPeriod.Find('-')then begin
            PeriodName:=objPeriod."Period Name";
        end;
        if companyinfo.Get()then companyinfo.CalcFields(companyinfo.Picture);
    end;
    var PeriodTrans: Record "Payroll Period Transaction";
    BasicPay: Decimal;
    GrossPay: Decimal;
    NetPay: Decimal;
    TotBasicPay: Decimal;
    TotGrossPay: Decimal;
    TotNetPay: Decimal;
    EmployeeName: Text[150];
    objEmp: Record Employee;
    objPeriod: Record "Payroll Periods";
    SelectedPeriod: Date;
    PeriodName: Text[30];
    PeriodFilter: Text[30];
    companyinfo: Record "Company Information";
    Gross_and_Net_pay_scheduleCaptionLbl: Label 'Gross and Net pay schedule';
    Basic_Pay_CaptionLbl: Label 'Basic Pay:';
    Gross_Pay_CaptionLbl: Label 'Gross Pay:';
    Net_Pay_CaptionLbl: Label 'Net Pay:';
    User_Name_CaptionLbl: Label 'User Name:';
    Print_Date_CaptionLbl: Label 'Print Date:';
    Period_CaptionLbl: Label 'Period:';
    Page_No_CaptionLbl: Label 'Page No:';
    Prepared_by_______________________________________Date_________________CaptionLbl: Label 'Prepared by……………………………………………………..                 Date……………………………………………';
    Checked_by________________________________________Date_________________CaptionLbl: Label 'Checked by…………………………………………………..                   Date……………………………………………';
    Authorized_by____________________________________Date_________________CaptionLbl: Label 'Authorized by……………………………………………………..              Date……………………………………………';
    Approved_by______________________________________Date_________________CaptionLbl: Label 'Approved by……………………………………………………..                Date……………………………………………';
    Totals_CaptionLbl: Label 'Totals:';
    Percentage: Decimal;
    IncludeInactiveEmployees: Boolean;
    TotDeductions: Decimal;
}
