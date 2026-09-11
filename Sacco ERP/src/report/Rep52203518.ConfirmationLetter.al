report 52203518 "Confirmation Letter"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Confirmation Letter.rdlc';

    dataset
    {
        dataitem(Employee; Employee)
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
            column(No_Employee; Employee."No.")
            {
            }
            column(FirstName_Employee; Employee."First Name")
            {
            }
            column(MiddleName_Employee; Employee."Middle Name")
            {
            }
            column(LastName_Employee; Employee."Last Name")
            {
            }
            column(Initials_Employee; Employee.Initials)
            {
            }
            column(JobTitle_Employee; Employee."Job Title")
            {
            }
            column(SearchName_Employee; Employee."Search Name")
            {
            }
            column(Address_Employee; Employee.Address)
            {
            }
            column(Address2_Employee; Employee."Address 2")
            {
            }
            column(Grade_Employee; Employee."Job Scale")
            {
            }
            column(EndofProbationPeriod_Employee; Employee."End of Probation Period")
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
