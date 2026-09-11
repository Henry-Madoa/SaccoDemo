report 52203522 "Promotions Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Promotions Report.rdlc';

    dataset
    {
        dataitem("Employee Change Request"; "Employee Change Request")
        {
            DataItemTableView = WHERE("Nature of Change"=CONST("Proffesional Bodies"));

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
            column(No_EmployeeChangeRequest; "Employee Change Request"."No.")
            {
            }
            column(NatureofChange_EmployeeChangeRequest; "Employee Change Request"."Nature of Change")
            {
            }
            column(EmployeeNo_EmployeeChangeRequest; "Employee Change Request"."Employee No")
            {
            }
            column(EmployeeName_EmployeeChangeRequest; "Employee Change Request"."Employee Name")
            {
            }
            column(CurrentGrade_EmployeeChangeRequest; "Employee Change Request"."Current Grade")
            {
            }
            column(NewGrade_EmployeeChangeRequest; "Employee Change Request"."New Grade")
            {
            }
            column(CurrentJob_EmployeeChangeRequest; "Employee Change Request"."Current Job")
            {
            }
            column(NewJob_EmployeeChangeRequest; "Employee Change Request"."New Job")
            {
            }
            column(PreviousPointer_EmployeeChangeRequest; "Employee Change Request"."Approval Entries")
            {
            }
            column(NewPointer_EmployeeChangeRequest; "Employee Change Request"."Current Pointer")
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
    PeriodYear: Integer;
    GratuityAmount: Decimal;
    PayrollPeriods: Record "Payroll Periods";
    PayrollPeriodTransaction: Record "Payroll Period Transaction";
}
