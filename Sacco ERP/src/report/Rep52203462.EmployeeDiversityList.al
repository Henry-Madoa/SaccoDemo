report 52203462 "Employee Diversity List"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Employee Diversity List.rdlc';

    dataset
    {
        dataitem(Employee; Employee)
        {
            RequestFilterFields = "No.", "Employment Date", Title;

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
            column(Grade_Employee; Employee."Job Scale")
            {
            }
            column(Pointer_Employee; Employee."J-G Steps")
            {
            }
            column(GlobalDimension1Code_Employee; Employee."Global Dimension 1 Code")
            {
            }
            column(GlobalDimension2Code_Employee; Employee."Global Dimension 2 Code")
            {
            }
            column(GlobalDimension3Code_Employee; Employee."Global Dimension 3 Code")
            {
            }
            column(GlobalDimension4Code_Employee; Employee."Global Dimension 4 Code")
            {
            }
            column(GlobalDimension5Code_Employee; Employee."Global Dimension 5 Code")
            {
            }
            column(ContractStartDate_Employee; Employee."Contract Start Date")
            {
            }
            column(ContractEndDate_Employee; Employee."Contract End Date")
            {
            }
            column(Gender_Employee; Employee.Gender)
            {
            }
            column(CountryRegionCode_Employee; Employee."Country/Region Code")
            {
            }
            column(CountyofOrigin_Employee; Employee."County of Origin")
            {
            }
            column(EthnicOrigin_Employee; Employee."Ethnic Origin")
            {
            }
            trigger OnPreDataItem()
            begin
                CompanyInformation.GET;
                CompanyInformation.CALCFIELDS(Picture);
                ReportFilters:=Employee.GETFILTERS;
            end;
        }
    }
    trigger OnPreReport()
    begin
        ReportFilters:=Employee.GETFILTERS;
    end;
    var CompanyInformation: Record "Company Information";
    ReportFilters: Text;
}
