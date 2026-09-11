report 52203561 "Payroll Grant Summary Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Payroll Grant Summary Report.rdlc';

    dataset
    {
        dataitem("Payroll Charged Grants"; "Payroll Charged Grants")
        {
            RequestFilterFields = "Payroll Period", "Emp Code";

            column(EmpCode_PayrollChargedGrants; "Payroll Charged Grants"."Emp Code")
            {
            }
            column(PayrollPeriod_PayrollChargedGrants; "Payroll Charged Grants"."Payroll Period")
            {
            }
            column(PeriodMonth_PayrollChargedGrants; "Payroll Charged Grants"."Period Month")
            {
            }
            column(PeriodYear_PayrollChargedGrants; "Payroll Charged Grants"."Period Year")
            {
            }
            column(GrantCode_PayrollChargedGrants; "Payroll Charged Grants"."Grant Code")
            {
            }
            column(Percentage_PayrollChargedGrants; "Payroll Charged Grants".Percentage)
            {
            }
            column(USERID; UserId)
            {
            }
            column(TODAY; TODAY)
            {
            }
            column(NationalID; NationalID)
            {
            }
            column(Title; Title)
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
            trigger OnAfterGetRecord()
            begin
                objEmp.GET("Payroll Charged Grants"."Emp Code");
                EmployeeName:=objEmp.FullName;
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
                PeriodTrans.SETRANGE(PeriodTrans."Employee Code", "Payroll Charged Grants"."Emp Code");
                PeriodTrans.SETRANGE(PeriodTrans."Payroll Period", "Payroll Charged Grants"."Payroll Period");
                PeriodTrans.SETFILTER(PeriodTrans."Transaction Code", '=%1|=%2|=%3', 'BPAY', 'GPAY', 'NPAY');
                PeriodTrans.SETCURRENTKEY(PeriodTrans."Employee Code", PeriodTrans."Period Month", PeriodTrans."Period Year", PeriodTrans."Group Order", PeriodTrans."Sub Group Order");
                IF PeriodTrans.FIND('-')THEN REPEAT IF PeriodTrans."Transaction Code" = 'BPAY' THEN BEGIN
                            BasicPay:=(PeriodTrans.Amount * ("Payroll Charged Grants".Percentage / 100));
                        end;
                        IF PeriodTrans."Transaction Code" = 'GPAY' THEN BEGIN
                            GrossPay:=(PeriodTrans.Amount * ("Payroll Charged Grants".Percentage / 100));
                        end;
                        IF PeriodTrans."Transaction Code" = 'NPAY' THEN BEGIN
                            NetPay:=(PeriodTrans.Amount * ("Payroll Charged Grants".Percentage / 100));
                        end;
                    UNTIL PeriodTrans.NEXT = 0;
                PeriodTrans.RESET;
                PeriodTrans.SETRANGE(PeriodTrans."Employee Code", "Payroll Charged Grants"."Emp Code");
                PeriodTrans.SETRANGE(PeriodTrans."Payroll Period", "Payroll Charged Grants"."Payroll Period");
                PeriodTrans.SETFILTER("Group Text", 'ALLOWANCE');
                IF PeriodTrans.FIND('-')THEN BEGIN
                    REPEAT OtherAllowances+=(PeriodTrans.Amount * ("Payroll Charged Grants".Percentage / 100));
                    UNTIL PeriodTrans.NEXT = 0;
                end;
                PeriodTrans.RESET;
                PeriodTrans.SETRANGE(PeriodTrans."Employee Code", "Payroll Charged Grants"."Emp Code");
                PeriodTrans.SETRANGE(PeriodTrans."Payroll Period", "Payroll Charged Grants"."Payroll Period");
                PeriodTrans.SETRANGE("Group Text", 'DEDUCTIONS');
                PeriodTrans.SETFILTER("Transaction Code", '<>%1', 'TOT-DED');
                IF PeriodTrans.FIND('-')THEN BEGIN
                    REPEAT OtherDeduction+=(PeriodTrans.Amount * ("Payroll Charged Grants".Percentage / 100));
                    UNTIL PeriodTrans.NEXT = 0;
                end;
                PeriodTrans.RESET;
                PeriodTrans.SETRANGE(PeriodTrans."Employee Code", "Payroll Charged Grants"."Emp Code");
                PeriodTrans.SETRANGE(PeriodTrans."Payroll Period", "Payroll Charged Grants"."Payroll Period");
                PeriodTrans.SETFILTER("Transaction Code", 'NSSF');
                IF PeriodTrans.FIND('-')THEN BEGIN
                    REPEAT NSSF+=(PeriodTrans.Amount * ("Payroll Charged Grants".Percentage / 100));
                    UNTIL PeriodTrans.NEXT = 0;
                end;
                PeriodTrans.RESET;
                PeriodTrans.SETRANGE(PeriodTrans."Employee Code", "Payroll Charged Grants"."Emp Code");
                PeriodTrans.SETRANGE(PeriodTrans."Payroll Period", "Payroll Charged Grants"."Payroll Period");
                PeriodTrans.SETFILTER("Transaction Code", 'PAYE');
                IF PeriodTrans.FIND('-')THEN BEGIN
                    REPEAT PAYE+=(PeriodTrans.Amount * ("Payroll Charged Grants".Percentage / 100));
                    UNTIL PeriodTrans.NEXT = 0;
                end;
                PeriodTrans.RESET;
                PeriodTrans.SETRANGE(PeriodTrans."Employee Code", "Payroll Charged Grants"."Emp Code");
                PeriodTrans.SETRANGE(PeriodTrans."Payroll Period", "Payroll Charged Grants"."Payroll Period");
                PeriodTrans.SETFILTER("Transaction Code", 'SHIF');
                IF PeriodTrans.FIND('-')THEN BEGIN
                    REPEAT SHIF+=(PeriodTrans.Amount * ("Payroll Charged Grants".Percentage / 100));
                    UNTIL PeriodTrans.NEXT = 0;
                end;
                PeriodTrans.RESET;
                PeriodTrans.SETRANGE(PeriodTrans."Employee Code", "Payroll Charged Grants"."Emp Code");
                PeriodTrans.SETRANGE(PeriodTrans."Payroll Period", "Payroll Charged Grants"."Payroll Period");
                PeriodTrans.SETFILTER("Transaction Code", 'PENSION');
                IF PeriodTrans.FIND('-')THEN BEGIN
                    REPEAT Pension+=(PeriodTrans.Amount * ("Payroll Charged Grants".Percentage / 100));
                    UNTIL PeriodTrans.NEXT = 0;
                end;
                IF NetPay <= 0 THEN CurrReport.SKIP;
                TotBasicPay:=TotBasicPay + BasicPay;
                TotGrossPay:=TotGrossPay + GrossPay;
                TotNetPay:=TotNetPay + NetPay;
                OtherDeduction:=OtherDeduction - Pension;
                Title:='';
                Title:=objEmp."Job Title";
                NationalID:=objEmp."National ID";
            end;
            trigger OnPreDataItem()
            begin
                IF "Payroll Charged Grants".GETFILTER("Payroll Period") = '' THEN ERROR('You have to select the period');
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
            }
        }
    }
    trigger OnPreReport()
    begin
        objPeriod.RESET;
        objPeriod.SETRANGE(objPeriod."Start Date", "Payroll Charged Grants"."Payroll Period");
        IF objPeriod.FIND('-')THEN BEGIN
            PeriodName:=objPeriod."Period Name";
        end;
        IF CompanyInformation.GET()THEN CompanyInformation.CALCFIELDS(CompanyInformation.Picture);
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
    CompanyInformation: Record "Company Information";
    NationalID: Code[10];
    Title: Text;
}
