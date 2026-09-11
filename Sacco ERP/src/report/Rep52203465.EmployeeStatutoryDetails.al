report 52203465 "Employee Statutory Details"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Employee Statutory Details.rdl';

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
            column(GratuityAmount; GratuityAmount)
            {
            }
            column(FullName_Employee; Employee.FullName)
            {
            }
            column(No_Employee; Employee."No.")
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
            column(MemberNo_Employee; Employee."Member No.")
            {
            }
            column(FosaAccNo_Employee; Employee."FOSA Account")
            {
            }
            column(BranchName_Employee; Employee."Branch Name")
            {
            }
            column(BankCode_Employee; Employee."Bank Code")
            {
            }
            column(BankName_Employee; Employee."Bank Name")
            {
            }
            trigger OnAfterGetRecord()
            begin
                IF(Employee."Bank Branch No." <> '') AND (Employee."Bank Code" <> '')THEN BEGIN
                    IF KenyaBankBranches.GET(Employee."Bank Code", Employee."Bank Branch No.")THEN BEGIN
                        Employee."Branch Name":=KenyaBankBranches."Branch Name";
                        Employee.MODIFY;
                    end;
                end;
            end;
            trigger OnPreDataItem()
            begin
                CompanyInformation.GET;
                CompanyInformation.CALCFIELDS(Picture);
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
    PeriodYear: Integer;
    GratuityAmount: Decimal;
    PayrollPeriods: Record "Payroll Periods";
    PayrollPeriodTransaction: Record "Payroll Period Transaction";
    KenyaBankCodes: Record "External Banks";
    KenyaBankBranches: Record "External Bank Branches";
}
