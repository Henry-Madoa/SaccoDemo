report 52204040 "Disbursement Summary"
{
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Disbursement Summary.rdl';

    dataset
    {
        dataitem(Loans; Loans)
        {
            RequestFilterFields = "Date Filter", "Member No.", "No.", "Application Date";
            DataItemTableView = where(Posted = const(true));
            column("CompanyLogo"; CompanyInformation.Picture)
            {
            }
            column("CompanyName"; CompanyInformation.Name)
            {
            }
            column("CompanyAddress1"; CompanyInformation.Address)
            {
            }
            column("CompanyAddress2"; CompanyInformation."Address 2")
            {
            }
            column("CompanyPhone"; CompanyInformation."Phone No.")
            {
            }
            column("CompanyEmail"; CompanyInformation."E-Mail")
            {
            }
            column(Category; Category)
            {
            }
            column(ProductCode; "Product Code")
            {
            }
            column(Product_Description; "Product Description")
            {
            }
            column(Application_No; "No.")
            {
            }
            column(Loan_Amount; "Loan Amount")
            {
            }
            column(Approved_Amount; "Approved Amount")
            {
            }
            column(Disbursements; Disbursements)
            {
            }
            column(Bridged_Amount; "Bridged Amount")
            {
            }
            column(Fresh_Loan; FreshLoan)
            {
            }
            column(Installments; Installments)
            {
            }
            column(Filters; Filters)
            {
            }
            dataitem(SaccoProducts; "Sacco Products")
            {
                DataItemLink = Code = field("Product Code");
                column(Maximum_Installments; "Maximum Installments")
                {
                }
                column(Interest_Rate; "Interest Rate")
                {
                }
            }
            trigger OnPreDataItem()
            begin
                Filters := Loans.GetFilters;
                CompanyInformation.Get();
                CompanyInformation.CalcFields(Picture);
            end;

            trigger OnAfterGetRecord()
            begin
                CalcFields(Disbursements, "Bridged Amount");
                FreshLoan := 0;
                FreshLoan := "Approved Amount" - "Bridged Amount";
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        FreshLoan: Decimal;
        Filters: Text;
}
