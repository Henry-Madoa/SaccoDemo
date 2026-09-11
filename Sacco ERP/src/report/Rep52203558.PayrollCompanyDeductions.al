report 52203558 "Payroll Company Deductions"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Payroll Company Deductions.rdlc';

    dataset
    {
        dataitem("Payroll Period Transaction"; "Payroll Period Transaction")
        {
            RequestFilterFields = "Global Dimension 1 Code", "Global Dimension 2 Code";

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
            column(TransactionType_PayrollPeriodTransaction; "Payroll Period Transaction"."Transaction Type")
            {
            }
            column(PeriodMonth_PayrollPeriodTransaction; "Payroll Period Transaction"."Period Month")
            {
            }
            column(PeriodYear_PayrollPeriodTransaction; "Payroll Period Transaction"."Period Year")
            {
            }
            column(PeriodFilter_PayrollPeriodTransaction; "Payroll Period Transaction"."Period Filter")
            {
            }
            column(PayrollPeriod_PayrollPeriodTransaction; "Payroll Period Transaction"."Payroll Period")
            {
            }
            column(EmployeeCode_PayrollPeriodTransaction; "Payroll Period Transaction"."Employee Code")
            {
            }
            column(TransactionCode_PayrollPeriodTransaction; "Payroll Period Transaction"."Transaction Code")
            {
            }
            column(GroupText_PayrollPeriodTransaction; "Payroll Period Transaction"."Group Text")
            {
            }
            column(TransactionName_PayrollPeriodTransaction; "Payroll Period Transaction"."Transaction Name")
            {
            }
            column(Amount_PayrollPeriodTransaction; "Payroll Period Transaction".Amount)
            {
            }
            column(Balance_PayrollPeriodTransaction; "Payroll Period Transaction".Balance)
            {
            }
            column(StaffName_PayrollPeriodTransaction; "Payroll Period Transaction"."Staff Name")
            {
            }
            column(GlobalDimension1Code_PayrollPeriodTransaction; "Payroll Period Transaction"."Global Dimension 1 Code")
            {
            }
            column(GlobalDimension2Code_PayrollPeriodTransaction; "Payroll Period Transaction"."Global Dimension 2 Code")
            {
            }
            column(JobTitle; JobTitle)
            {
            }
            column(TransactionCode; TransactionCode)
            {
            }
            column(TransactionName; TransactionName)
            {
            }
            column(ReportFilters; ReportFilters)
            {
            }
            column(PayrollPeriod; PayrollPeriod)
            {
            }
            trigger OnAfterGetRecord()
            begin
                JobTitle:='';
                IF Employee.GET("Payroll Period Transaction"."Employee Code")THEN JobTitle:=Employee."Job Title";
            end;
            trigger OnPreDataItem()
            begin
                CompanyInformation.GET;
                CompanyInformation.CALCFIELDS(Picture);
                IF PayrollPeriod = 0D THEN IF PayrollTransactionCode.GET(TransactionCode)THEN TransactionName:=PayrollTransactionCode.Name;
                "Payroll Period Transaction".SETFILTER("Payroll Period Transaction"."Payroll Period", '=%1', PayrollPeriod);
                "Payroll Period Transaction".SETFILTER("Payroll Period Transaction"."Transaction Code", '=%1', TransactionCode);
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                field("Payroll Period"; PayrollPeriod)
                {
                    TableRelation = "Payroll Periods"."Start Date";
                }
                field("Transaction Code"; TransactionCode)
                {
                    TableRelation = "Payroll Transaction Code" WHERE(Type=CONST("Company Deduction"));
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        ReportFilters:="Payroll Period Transaction".GETFILTERS();
        IF ReportFilters = '' THEN ReportFilters:='None';
    end;
    var CompanyInformation: Record "Company Information";
    JobTitle: Text;
    Employee: Record Employee;
    TransactionCode: Code[30];
    TransactionName: Text;
    ReportFilters: Text;
    PayrollTransactionCode: Record "Payroll Transaction Code";
    PayrollPeriod: Date;
}
