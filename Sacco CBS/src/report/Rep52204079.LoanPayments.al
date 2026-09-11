report 52204079 "Loan Payments"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Loan Payments.rdl';

    dataset
    {
        dataitem(Loans; Loans)
        {
            DataItemTableView = where("Loan Balance" = filter(<> 0), Posted = const(true), "Payment Date" = filter(<> 0D));
            RequestFilterFields = "Date Filter", "Member No.", "No.";

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
            column(CompanyWebsite; CompanyInformation."Home Page")
            {
            }
            column(No_; "No.")
            {
            }
            column(Member_No_; "Member No.")
            {
            }
            column(Member_Name; "Member Name")
            {
            }
            column(Product_Code; "Product Code")
            {
            }
            column(Product_Description; "Product Description")
            {
            }
            column(Debtor_Collector; "Debt Collector")
            {
            }
            column(Loan_Classification; "Loan Classification")
            {
            }
            column(Posting_Date; FORMAT("Posting Date"))
            {
            }
            column(Payment_Date; "Payment Date")
            {
            }
            column(Last_Pay_Date; FORMAT("Last Pay Date"))
            {
            }
            column(Repayment_End_Date; FORMAT("Repayment End Date"))
            {
            }
            column(Approved_Amount; "Approved Amount")
            {
            }
            column(Loan_Balance; "Loan Balance")
            {
            }
            column(Interest_Balance; "Interest Balance")
            {
            }
            column(Principal_Balance; "Principal Balance")
            {
            }
            column(Monthly_Installment; "Monthly Installment")
            {
            }
            column(Filters; Filters)
            {
            }
            trigger OnPreDataItem()
            begin
                Filters := Loans.GetFilters;
                CompanyInformation.Get();
                CompanyInformation.CalcFields(Picture);
            end;

            trigger OnAfterGetRecord()
            begin
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        Filters: Text;
}
