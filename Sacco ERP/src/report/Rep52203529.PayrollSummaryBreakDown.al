report 52203529 "Payroll Summary Break Down"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Payroll Summary Break Down.rdlc';

    dataset
    {
        dataitem("Payroll Period Transaction"; "Payroll Period Transaction")
        {
            //The property 'DataItemTableView' shouldn't have an empty value.
            //DataItemTableView = '';
            RequestFilterFields = "Payroll Period";

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
            column(EmployeeCode_PayrollPeriodTransaction; "Payroll Period Transaction"."Employee Code")
            {
            }
            column(TransactionCode_PayrollPeriodTransaction; "Payroll Period Transaction"."Transaction Code")
            {
            }
            column(StaffName_PayrollPeriodTransaction; "Payroll Period Transaction"."Staff Name")
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
            column(TransactionType_PayrollPeriodTransaction; "Payroll Period Transaction"."Transaction Type")
            {
            }
            column(PayrollPeriod_PayrollPeriodTransaction; "Payroll Period Transaction"."Payroll Period")
            {
            }
            column(JobTitle; JobTitle)
            {
            }
            column(NationalID; NationalID)
            {
            }
            trigger OnAfterGetRecord()
            begin
                if "Payroll Period Transaction"."Payroll Period" = 0D then Error('You must select period');
                NationalID:='';
                JobTitle:='';
                Employee.Get("Payroll Period Transaction"."Employee Code");
                NationalID:=Employee."National ID";
                JobTitle:=Employee."Job Title";
            end;
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
    JobTitle: Text;
    NationalID: Text;
    Employee: Record Employee;
}
