report 52203550 "Salary Advance Recovery Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Salary Advance Recovery Report.rdlc';

    dataset
    {
        dataitem("Payroll Period Transaction"; "Payroll Period Transaction")
        {
            DataItemTableView = WHERE("Transaction Type"=CONST(Deduction));
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
            column(Department_Name; DepartmentName)
            {
            }
            column(SD_Amount; SDAmount)
            {
            }
            column(Posting_Date; Datex)
            {
            }
            trigger OnAfterGetRecord()
            begin
                if Employee.Get("Payroll Period Transaction"."Employee Code")then JobTitle:=Employee."Job Title";
                SDAmount:=0;
                EmployeeLedgerEntry.Reset;
                EmployeeLedgerEntry.SetRange("Employee No.", "Payroll Period Transaction"."Employee Code");
                EmployeeLedgerEntry.SetRange("Document No.", "Payroll Period Transaction"."Imprest No");
                if EmployeeLedgerEntry.FindFirst then begin
                    EmployeeLedgerEntry.CalcFields(Amount);
                    SDAmount:=EmployeeLedgerEntry.Amount;
                    Datex:=EmployeeLedgerEntry."Posting Date";
                end;
                DimensionValue.RESET;
                DimensionValue.SETRANGE(Code, "Payroll Period Transaction"."Global Dimension 1 Code");
                IF DimensionValue.FINDFIRST THEN DepartmentName:=DimensionValue.Name;
            end;
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
                if TransactionCode = '' then Error('You must specify the Payroll Period');
                if PayrollTransactionCode.Get(TransactionCode)then TransactionName:=PayrollTransactionCode.Name;
                "Payroll Period Transaction".SetFilter("Payroll Period Transaction"."Transaction Code", '=%1', TransactionCode);
                "Payroll Period Transaction".SetFilter("Payroll Period Transaction"."Payroll Period", '=%1', PayrollPeriod);
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                field("Transaction Code"; TransactionCode)
                {
                    TableRelation = "Payroll Transaction Code".Code WHERE(Type=CONST(Deduction));
                }
                field("Payroll Period"; PayrollPeriod)
                {
                    TableRelation = "Payroll Periods"."Start Date";
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        ReportFilters:="Payroll Period Transaction".GetFilters();
        if ReportFilters = '' then ReportFilters:='None';
    end;
    var CompanyInformation: Record "Company Information";
    JobTitle: Text;
    Employee: Record Employee;
    TransactionCode: Code[50];
    TransactionName: Text;
    ReportFilters: Text;
    PayrollTransactionCode: Record "Payroll Transaction Code";
    PayrollPeriod: Date;
    DepartmentName: Text;
    DimensionValue: Record "Dimension Value";
    EmployeeLedgerEntry: Record "Employee Ledger Entry";
    SDAmount: Decimal;
    Datex: Date;
}
