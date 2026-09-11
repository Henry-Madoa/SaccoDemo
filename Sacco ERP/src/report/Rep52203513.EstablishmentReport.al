report 52203513 "Establishment Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Establishment Report.rdlc';

    dataset
    {
        dataitem("Dimension Value"; "Dimension Value")
        {
            RequestFilterFields = "Code";

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
            column(MaxNoofEmployees_DimensionValue; "Dimension Value"."Max No. of Employees")
            {
            }
            column(MinimumNoofEmployees_DimensionValue; "Dimension Value"."Minimum No. of Employees")
            {
            }
            column(Name_DimensionValue; "Dimension Value".Name)
            {
            }
            column(ReportFilters; ReportFilters)
            {
            }
            column(VacantPosition; VacantPosition)
            {
            }
            column(NoEmployees; NoEmployees)
            {
            }
            trigger OnAfterGetRecord()
            begin
                NoEmployees:=0;
                VacantPosition:=0;
                Employee.Reset;
                Employee.SetRange("Global Dimension 1 Code", "Dimension Value".Code);
                if Employee.FindSet then NoEmployees:=Employee.Count;
                VacantPosition:="Dimension Value"."Max No. of Employees" - NoEmployees;
            end;
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    trigger OnPreReport()
    begin
        ReportFilters:="Dimension Value".GetFilters;
    end;
    var CompanyInformation: Record "Company Information";
    ReportFilters: Text;
    HRDates: Codeunit "HR Dates";
    YearsToRetirement: Text;
    Age: Text;
    HumanResourceCommentLine: Record "Human Resource Comment Line";
    HumanResSetup: Record "Human Resources Setup";
    VacantPosition: Integer;
    Employee: Record Employee;
    NoEmployees: Integer;
}
