report 52203489 "Employee List"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Employee List.rdl';

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
            column(JobTitle_Employee; Employee."Job Title")
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
            column(GlobalDimension1Code_Employee; Employee."Global Dimension 1 Code")
            {
            }
            column(GlobalDimension2Code_Employee; Employee."Global Dimension 2 Code")
            {
            }
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
}
