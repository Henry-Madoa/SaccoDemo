report 52203538 "Payroll Summary Standard"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Payroll Summary Standard.rdlc';

    dataset
    {
        dataitem(Employee; Employee)
        {
            // DataItemTableView = WHERE("Type of Employee"=FILTER(Contract|"7"),"Board Member"=CONST(false));
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
                if not IncludeInactiveEmployees then
                    Employee.SetFilter(Status, '=%1|=%2', Employee."Employee Status"::Active, Employee."Employee Status"::OnLeave);
                Employee.SetFilter("Nature Of Employment", '<>%1', Employee."Nature Of Employment"::Board);
                EmployeeName := "First Name" + ' ' + "Middle Name" + ' ' + "Last Name";
                BasicPay := 0;
                GrossPay := 0;
                NetPay := 0;
                Pension := 0;
                SHIF := 0;
                NSSF := 0;
                PAYE := 0;
                OtherDeduction := 0;
                OtherAllowances := 0;
                PeriodTrans.Reset;
                PeriodTrans.SetRange(PeriodTrans."Employee Code", Employee."No.");
                PeriodTrans.SetRange(PeriodTrans."Payroll Period", SelectedPeriod);
                PeriodTrans.SetFilter(PeriodTrans."Group Order", '=1|=4|=9');
                PeriodTrans.SetFilter(PeriodTrans."Sub Group Order", '<=1');
                PeriodTrans.SetCurrentKey(PeriodTrans."Employee Code", PeriodTrans."Period Month", PeriodTrans."Period Year", PeriodTrans."Group Order", PeriodTrans."Sub Group Order");
                if PeriodTrans.Find('-') then
                    repeat
                        if PeriodTrans."Group Order" = 1 then begin
                            BasicPay := PeriodTrans.Amount;
                        end;
                        if PeriodTrans."Group Order" = 4 then begin
                            GrossPay := PeriodTrans.Amount;
                        end;
                        if PeriodTrans."Group Order" = 9 then begin
                            NetPay := PeriodTrans.Amount;
                        end;
                        if GrossPay <> 0 then begin
                            if NetPay <> 0 then Percentage := NetPay / GrossPay * 100;
                        end;
                    until PeriodTrans.Next = 0;
                PeriodTrans.Reset;
                PeriodTrans.SetRange(PeriodTrans."Employee Code", Employee."No.");
                PeriodTrans.SetRange(PeriodTrans."Payroll Period", SelectedPeriod);
                PeriodTrans.SetFilter("Group Text", 'ALLOWANCE');
                if PeriodTrans.Find('-') then begin
                    repeat
                        OtherAllowances += PeriodTrans.Amount;
                    until PeriodTrans.Next = 0;
                end;
                PeriodTrans.Reset;
                PeriodTrans.SetRange(PeriodTrans."Employee Code", Employee."No.");
                PeriodTrans.SetRange(PeriodTrans."Payroll Period", SelectedPeriod);
                PeriodTrans.SetRange("Group Text", 'DEDUCTIONS');
                PeriodTrans.SetFilter("Transaction Code", '<>%1', 'TOT-DED');
                if PeriodTrans.Find('-') then begin
                    repeat
                        OtherDeduction += PeriodTrans.Amount;
                    until PeriodTrans.Next = 0;
                end;
                PeriodTrans.Reset;
                PeriodTrans.SetRange(PeriodTrans."Employee Code", Employee."No.");
                PeriodTrans.SetRange(PeriodTrans."Payroll Period", SelectedPeriod);
                PeriodTrans.SetFilter("Transaction Code", 'NSSF');
                if PeriodTrans.Find('-') then begin
                    repeat
                        NSSF += PeriodTrans.Amount;
                    until PeriodTrans.Next = 0;
                end;
                PeriodTrans.Reset;
                PeriodTrans.SetRange(PeriodTrans."Employee Code", Employee."No.");
                PeriodTrans.SetRange(PeriodTrans."Payroll Period", SelectedPeriod);
                PeriodTrans.SetFilter("Transaction Code", 'PAYE');
                if PeriodTrans.Find('-') then begin
                    repeat
                        PAYE += PeriodTrans.Amount;
                    until PeriodTrans.Next = 0;
                end;
                PeriodTrans.Reset;
                PeriodTrans.SetRange(PeriodTrans."Employee Code", Employee."No.");
                PeriodTrans.SetRange(PeriodTrans."Payroll Period", SelectedPeriod);
                PeriodTrans.SetFilter("Transaction Code", 'SHIF');
                if PeriodTrans.Find('-') then begin
                    repeat
                        SHIF += PeriodTrans.Amount;
                    until PeriodTrans.Next = 0;
                end;
                PeriodTrans.Reset;
                PeriodTrans.SetRange(PeriodTrans."Employee Code", Employee."No.");
                PeriodTrans.SetRange(PeriodTrans."Payroll Period", SelectedPeriod);
                if PeriodTrans.Find('-') then begin
                    repeat
                        if PayrollTransactionCode.Get(PeriodTrans."Transaction Code") then if PayrollTransactionCode."Special Transactions" in [PayrollTransactionCode."Special Transactions"::"Defined Contribution"] then Pension += PeriodTrans.Amount;
                    until PeriodTrans.Next = 0;
                end;
                if NetPay <= 0 then CurrReport.Skip;
                TotBasicPay := TotBasicPay + BasicPay;
                TotGrossPay := TotGrossPay + GrossPay;
                TotNetPay := TotNetPay + NetPay;
                OtherDeduction := OtherDeduction - Pension;
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
        if objPeriod.Find('-') then begin
            PeriodName := objPeriod."Period Name";
        end;
        if companyinfo.Get() then companyinfo.CalcFields(companyinfo.Picture);
    end;

    var
        PeriodTrans: Record "Payroll Period Transaction";
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
        PayrollTransactionCode: Record "Payroll Transaction Code";
}
