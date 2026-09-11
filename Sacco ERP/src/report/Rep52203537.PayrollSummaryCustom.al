report 52203537 "Payroll Summary Custom"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Payroll Summary Custom.rdlc';

    dataset
    {
        dataitem("Payroll Period Transaction"; "Payroll Period Transaction")
        {
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
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
}
