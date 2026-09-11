report 52203470 "Employee Kins"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Employee Kins.rdlc';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Employee Kins"; "Employee Relative")
        {
            RequestFilterFields = "Employee No.", "Relative Code";

            column(EmployeeCode_EmployeeKins; "Employee Kins"."Employee No.")
            {
            }
            column(Relationship_EmployeeKins; "Employee Kins"."Relative Code")
            {
            }
            column(SurName_EmployeeKins; "Employee Kins"."First Name" + '' + "Employee Kins"."Middle Name" + '' + "Employee Kins"."Last Name")
            {
            }
            column(DateOfBirth_EmployeeKins; "Employee Kins"."Birth Date")
            {
            }
            column(HomeTelNo_EmployeeKins; "Employee Kins"."Phone No.")
            {
            }
            column(Remarks_EmployeeKins; "Employee Kins".Comment)
            {
            }
            column(Name; Name)
            {
            }
            trigger OnAfterGetRecord()
            begin
                Employee.Reset;
                Employee.SetRange("No.", "Employee Kins"."Employee No.");
                if Employee.FindSet then Name:=Employee.FullName;
            end;
        }
    }
    var Employee: Record Employee;
    Name: Text;
}
