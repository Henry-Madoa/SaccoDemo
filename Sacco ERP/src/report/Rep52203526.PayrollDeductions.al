report 52203526 "Payroll Deductions"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Payroll Deductions.rdlc';

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
            column(ID_Number; NationaID)
            {
            }
            dataitem(Employee_; Employee)
            {
                DataItemLink = "No."=field("Employee Code");

                column(StaffName_PayrollPeriodTransaction; Employee_.FullName)
                {
                }
            }
            trigger OnAfterGetRecord()
            begin
                if Employee.Get("Payroll Period Transaction"."Employee Code")then JobTitle:=Employee."Job Title";
                if Employee.Get("Payroll Period Transaction"."Employee Code")then NationaID:=Employee."National ID";
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
                    ApplicationArea = All;
                    TableRelation = "Payroll Transaction Code".Code WHERE(Type=CONST(Deduction));
                }
                field("Payroll Period"; PayrollPeriod)
                {
                    ApplicationArea = All;
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
    NationaID: Text;
    DimensionValue: Record "Dimension Value";
}
