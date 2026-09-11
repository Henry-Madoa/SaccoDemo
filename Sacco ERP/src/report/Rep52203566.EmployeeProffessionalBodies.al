report 52203566 "Employee Proffessional Bodies"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Employee Proffessional Bodies.rdlc';

    dataset
    {
        dataitem(Employee; Employee)
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.";

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
            column(No_Employee; Employee."No.")
            {
            }
            column(FullName_Employee; Employee.FullName)
            {
            }
            column(EmploymentDate_Employee; Employee."Employment Date")
            {
            }
            column(NationalID_Employee; Employee."National ID")
            {
            }
            column(SHIFNumber_Employee; Employee."SHIF No.")
            {
            }
            column(NSSFNumber_Employee; Employee."NSSF No.")
            {
            }
            column(KRANumber_Employee; Employee."KRA Number")
            {
            }
            column(Start_Date; StartDate)
            {
            }
            column(End_Date; EndDate)
            {
            }
            dataitem("Employee Proffesional Bodies"; "Employee Proffesional Bodies")
            {
                DataItemLink = "Employee No."=FIELD("No.");

                column(EmployeeNo_EmployeeProffesionalBodies; "Employee Proffesional Bodies"."Employee No.")
                {
                }
                column(LineNo_EmployeeProffesionalBodies; "Employee Proffesional Bodies"."Line No.")
                {
                }
                column(BodyCode_EmployeeProffesionalBodies; "Employee Proffesional Bodies"."Body Code")
                {
                }
                column(FromDate_EmployeeProffesionalBodies; "Employee Proffesional Bodies"."From Date")
                {
                }
                column(ToDate_EmployeeProffesionalBodies; "Employee Proffesional Bodies"."To Date")
                {
                }
                column(Name_EmployeeProffesionalBodies; "Employee Proffesional Bodies".Name)
                {
                }
                column(EmployeeStatus_EmployeeProffesionalBodies; "Employee Proffesional Bodies"."Employee Status")
                {
                }
                column(Comment_EmployeeProffesionalBodies; "Employee Proffesional Bodies".Comment)
                {
                }
                column(MembershipNumber_EmployeeProffesionalBodies; "Employee Proffesional Bodies"."Membership Number")
                {
                }
                trigger OnAfterGetRecord()
                begin
                // IF "Employee Dependants"."Date of Birth"<>0D THEN
                //  BEGIN
                //    "Employee Dependants".Age:=HRDates.DetermineAge("Employee Dependants"."Date of Birth",TODAY);
                //    "Employee Dependants".MODIFY(TRUE);
                //  end;
                end;
            }
            trigger OnPreDataItem()
            begin
                CompanyInformation.GET;
                CompanyInformation.CALCFIELDS(Picture);
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
            }
        }
    }
    var CompanyInformation: Record "Company Information";
    StartDate: Date;
    EndDate: Date;
    HRDates: Codeunit "HR Dates";
}
