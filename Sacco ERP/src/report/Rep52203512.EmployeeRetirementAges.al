report 52203512 "Employee Retirement Ages"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Employee Retirement Ages.rdlc';

    dataset
    {
        dataitem(Employee; Employee)
        {
            RequestFilterFields = "No.", "Employment Date", "Nature Of Employment";

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
            column(ReportFilters; ReportFilters)
            {
            }
            column(BirthDate_Employee; Employee."Birth Date")
            {
            }
            column(YearsToRetirement; YearsToRetirement)
            {
            }
            column(Age; Age)
            {
            }
            trigger OnAfterGetRecord()
            begin
                YearsToRetirement:='';
                Age:='';
                if Employee."Birth Date" <> 0D then begin
                    Age:=HRDates.DetermineDatesDiffrence(Employee."Birth Date", Today);
                    HumanResSetup.Get();
                    HumanResSetup.TestField("Retirement Age");
                    YearsToRetirement:=HRDates.DetermineDatesDiffrence(Today, CalcDate(HumanResSetup."Retirement Age", "Birth Date"));
                end;
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
        ReportFilters:=Employee.GetFilters;
    end;
    var CompanyInformation: Record "Company Information";
    ReportFilters: Text;
    HRDates: Codeunit "HR Dates";
    YearsToRetirement: Text;
    Age: Text;
    HumanResourceCommentLine: Record "Human Resource Comment Line";
    HumanResSetup: Record "Human Resources Setup";
    VacantPosisiton: Integer;
}
