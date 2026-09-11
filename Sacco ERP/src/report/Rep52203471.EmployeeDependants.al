report 52203471 "Employee Dependants"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Employee Dependants.rdl';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(EmployeeRelative; "Employee Relative")
        {
            RequestFilterFields = "Employee No.", "Relative Code";

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
            column(EmployeeCode_EmployeeKins; EmployeeRelative."Employee No.")
            {
            }
            column(Relationship_EmployeeKins; EmployeeRelative."Relative Code")
            {
            }
            column(DependantName_EmployeeKins; EmployeeRelative."First Name" + ' ' + EmployeeRelative."Middle Name" + ' ' + EmployeeRelative."Last Name")
            {
            }
            column(DateOfBirth_EmployeeKins; EmployeeRelative."Birth Date")
            {
            }
            column(ID_Birth_Certificate_No_EmployeeKins; EmployeeRelative."ID/Birth Certificate No.")
            {
            }
            column(Gender_EmployeeKins; EmployeeRelative.Gender)
            {
            }
            column(HomeTelNo_EmployeeKins; EmployeeRelative."Phone No.")
            {
            }
            column(Remarks_EmployeeKins; EmployeeRelative.Comment)
            {
            }
            column(EmpName; EmpName)
            {
            }
            trigger OnAfterGetRecord()
            begin
                Employee.Reset;
                Employee.SetRange("No.", EmployeeRelative."Employee No.");
                if Employee.FindSet then EmpName:=Employee.FullName;
            end;
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
    Employee: Record Employee;
    EmpName: Text;
}
