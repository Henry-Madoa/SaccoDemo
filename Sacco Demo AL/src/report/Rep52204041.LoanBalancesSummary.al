report 52204041 "Loan Balances Summary"
{
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Loan Balances Summary.rdl';

    dataset
    {
        dataitem("Loan Application"; Loans)
        {
            DataItemTableView = where(Posted = filter(true)); //Fred
            RequestFilterFields = "Date Filter", "Member No.", "No.", "Application Date";

            column("CompanyAddress1"; CompanyInformation.Address)
            {
            }
            column("CompanyAddress2"; CompanyInformation."Address 2")
            {
            }
            column("CompanyEmail"; CompanyInformation."E-Mail")
            {
            }
            column("CompanyLogo"; CompanyInformation.Picture)
            {
            }
            column("CompanyName"; CompanyInformation.Name)
            {
            }
            column("CompanyPhone"; CompanyInformation."Phone No.")
            {
            }
            column(Application_No; "No.")
            {
            }
            column(Approved_Amount; "Approved Amount")
            {
            }
            column(Filters; Filters)
            {
            }
            column(Loan_Balance; "Loan Balance")
            {
            }
            column(Principal_Balance___At_Date; "Principal Balance - At Date")
            {
            }
            column(Product_Code; "Product Code")
            {
            }
            column(Product_Description; "Product Description")
            {
            }
            trigger OnPreDataItem()
            begin
                Filters := "Loan Application".GetFilters;
                CompanyInformation.Get();
                CompanyInformation.CalcFields(Picture);
            end;

            trigger OnAfterGetRecord()
            begin
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);
                EmployerCode := '';
                EmployerName := '';
                if Members.Get("Member No.") then begin
                    if Employers.Get(EmployerCode) then begin
                        EmployerCode := Employers.Code;
                        EmployerName := Employers.Name;
                    end;
                end;
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        Employers: Record Employers;
        Members: Record Members;
        EmployerCode, EmployerName : Code[100];
        Filters: Text;
}
