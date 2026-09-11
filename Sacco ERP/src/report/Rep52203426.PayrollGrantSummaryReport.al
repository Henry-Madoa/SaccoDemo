report 52203426 "Payroll Grant  Summary Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Payroll Grant  Summary Report.rdlc';

    dataset
    {
        dataitem(Employee; Employee)
        {
            column(USERID; UserId)
            {
            }
            column(TODAY; TODAY)
            {
            }
            column(PeriodName; PeriodName)
            {
            }
            column(CurrReport_PAGENO; CurrReport.PAGENO)
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
            column(SHIF; SHIF)
            {
            }
            column(PAYE; PAYE)
            {
            }
            column(NSSF; NSSF)
            {
            }
            column(Pension; Pension)
            {
            }
            column(OtherDeduction; OtherDeduction)
            {
            }
            column(OtherAllowances; OtherAllowances)
            {
            }
            column(GlobalDimension6Code_Employee; Employee."Global Dimension 6 Code")
            {
            }
            column(JobDescription_Employee; Employee."Job Title")
            {
            }
            column(NationalID_Employee; Employee."National ID")
            {
            }
            trigger OnAfterGetRecord()
            begin
                IF NOT IncludeInactiveEmployees THEN Employee.SETFILTER("Employee Status", '=%1|=%2', Employee."Employee Status"::Active, Employee."Employee Status"::OnLeave);
                EmployeeName:="First Name" + ' ' + "Middle Name" + ' ' + "Last Name";
                BasicPay:=0;
                GrossPay:=0;
                NetPay:=0;
                Pension:=0;
                SHIF:=0;
                NSSF:=0;
                PAYE:=0;
                OtherDeduction:=0;
                OtherAllowances:=0;
                PeriodTrans.RESET;
                PeriodTrans.SETRANGE(PeriodTrans."Employee Code", Employee."No.");
                PeriodTrans.SETRANGE(PeriodTrans."Payroll Period", SelectedPeriod);
                PeriodTrans.SETFILTER(PeriodTrans."Group Order", '=1|=4|=9');
                PeriodTrans.SETFILTER(PeriodTrans."Sub Group Order", '<=1');
                PeriodTrans.SETCURRENTKEY(PeriodTrans."Employee Code", PeriodTrans."Period Month", PeriodTrans."Period Year", PeriodTrans."Group Order", PeriodTrans."Sub Group Order");
                IF PeriodTrans.FIND('-')THEN REPEAT IF PeriodTrans."Group Order" = 1 THEN BEGIN
                            BasicPay:=PeriodTrans.Amount;
                        end;
                        IF PeriodTrans."Group Order" = 4 THEN BEGIN
                            GrossPay:=PeriodTrans.Amount;
                        end;
                        IF PeriodTrans."Group Order" = 9 THEN BEGIN
                            NetPay:=PeriodTrans.Amount;
                        end;
                        IF GrossPay <> 0 THEN BEGIN
                            IF NetPay <> 0 THEN Percentage:=NetPay / GrossPay * 100;
                        end;
                    UNTIL PeriodTrans.NEXT = 0;
                PeriodTrans.RESET;
                PeriodTrans.SETRANGE(PeriodTrans."Employee Code", Employee."No.");
                PeriodTrans.SETRANGE(PeriodTrans."Payroll Period", SelectedPeriod);
                PeriodTrans.SETFILTER("Group Text", 'ALLOWANCE');
                IF PeriodTrans.FIND('-')THEN BEGIN
                    REPEAT OtherAllowances+=PeriodTrans.Amount;
                    UNTIL PeriodTrans.NEXT = 0;
                end;
                PeriodTrans.RESET;
                PeriodTrans.SETRANGE(PeriodTrans."Employee Code", Employee."No.");
                PeriodTrans.SETRANGE(PeriodTrans."Payroll Period", SelectedPeriod);
                PeriodTrans.SETRANGE("Group Text", 'DEDUCTIONS');
                PeriodTrans.SETFILTER("Transaction Code", '<>%1', 'TOT-DED');
                IF PeriodTrans.FIND('-')THEN BEGIN
                    REPEAT OtherDeduction+=PeriodTrans.Amount;
                    UNTIL PeriodTrans.NEXT = 0;
                end;
                PeriodTrans.RESET;
                PeriodTrans.SETRANGE(PeriodTrans."Employee Code", Employee."No.");
                PeriodTrans.SETRANGE(PeriodTrans."Payroll Period", SelectedPeriod);
                PeriodTrans.SETFILTER("Transaction Code", 'NSSF');
                IF PeriodTrans.FIND('-')THEN BEGIN
                    REPEAT NSSF+=PeriodTrans.Amount;
                    UNTIL PeriodTrans.NEXT = 0;
                end;
                PeriodTrans.RESET;
                PeriodTrans.SETRANGE(PeriodTrans."Employee Code", Employee."No.");
                PeriodTrans.SETRANGE(PeriodTrans."Payroll Period", SelectedPeriod);
                PeriodTrans.SETFILTER("Transaction Code", 'PAYE');
                IF PeriodTrans.FIND('-')THEN BEGIN
                    REPEAT PAYE+=PeriodTrans.Amount;
                    UNTIL PeriodTrans.NEXT = 0;
                end;
                PeriodTrans.RESET;
                PeriodTrans.SETRANGE(PeriodTrans."Employee Code", Employee."No.");
                PeriodTrans.SETRANGE(PeriodTrans."Payroll Period", SelectedPeriod);
                PeriodTrans.SETFILTER("Transaction Code", 'SHIF');
                IF PeriodTrans.FIND('-')THEN BEGIN
                    REPEAT SHIF+=PeriodTrans.Amount;
                    UNTIL PeriodTrans.NEXT = 0;
                end;
                PeriodTrans.RESET;
                PeriodTrans.SETRANGE(PeriodTrans."Employee Code", Employee."No.");
                PeriodTrans.SETRANGE(PeriodTrans."Payroll Period", SelectedPeriod);
                PeriodTrans.SETFILTER("Transaction Code", 'PENSION');
                IF PeriodTrans.FIND('-')THEN BEGIN
                    REPEAT Pension+=PeriodTrans.Amount;
                    UNTIL PeriodTrans.NEXT = 0;
                end;
                IF NetPay <= 0 THEN CurrReport.SKIP;
                TotBasicPay:=TotBasicPay + BasicPay;
                TotGrossPay:=TotGrossPay + GrossPay;
                TotNetPay:=TotNetPay + NetPay;
                OtherDeduction:=OtherDeduction - Pension;
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
                    Caption = 'Selected Period';
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
        objPeriod.RESET;
        objPeriod.SETRANGE(objPeriod."Start Date", SelectedPeriod);
        IF objPeriod.FIND('-')THEN BEGIN
            PeriodName:=objPeriod."Period Name";
        end;
        IF companyinfo.GET()THEN companyinfo.CALCFIELDS(companyinfo.Picture);
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
    SHIF: Decimal;
    PAYE: Decimal;
    NSSF: Decimal;
    Pension: Decimal;
    OtherDeduction: Decimal;
    OtherAllowances: Decimal;
    PensionCode: Code[50];
    IncludeInactiveEmployees: Boolean;
}
