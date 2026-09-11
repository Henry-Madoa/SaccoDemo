report 52203490 "Employement Qualification"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Employement Qualification.rdlc';

    dataset
    {
        dataitem(Employee; Employee)
        {
            PrintOnlyIfDetail = true;

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
            dataitem("Employee Qualification"; "Employee Qualification")
            {
                DataItemLink = "Employee No."=FIELD("No.");

                column(QualificationCode_EmployeeQualification; "Employee Qualification"."Qualification Code")
                {
                }
                column(FromDate_EmployeeQualification; "Employee Qualification"."From Date")
                {
                }
                column(ToDate_EmployeeQualification; "Employee Qualification"."To Date")
                {
                }
                column(Type_EmployeeQualification; "Employee Qualification".Type)
                {
                }
                column(Description_EmployeeQualification; "Employee Qualification".Description)
                {
                }
                column(InstitutionCompany_EmployeeQualification; "Employee Qualification"."Institution/Company")
                {
                }
                column(CourseGrade_EmployeeQualification; "Employee Qualification"."Course Grade")
                {
                }
                column(Comment_EmployeeQualification; "Employee Qualification".Comment)
                {
                }
            }
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
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
}
