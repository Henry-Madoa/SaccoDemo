report 52204015 "Loan Transactions"
{
    UsageCategory = Administration;
    PreviewMode = PrintLayout;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Loan Transactions.rdl';

    dataset
    {
        dataitem("Loan Application"; Loans)
        {
            RequestFilterFields = "Date Filter", "Member No.", "No.", "Application Date";

            column(Application_No; "No.")
            {
            }
            column(Application_Date; "Application Date")
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
            column(Applied_Amount; "Loan Amount")
            {
            }
            column(Approved_Amount; "Approved Amount")
            {
            }
            column(Interest_Balance; "Interest Paid")
            {
            }
            column(Penalty_Balance; "Penalty Paid")
            {
            }
            column(Principal_Balance; "Principal Paid")
            {
            }
            column(Loan_Balance; "Loan Balance")
            {
            }
            column(Interest_Rate; "Interest Rate")
            {
            }
            column(Installments; Installments)
            {
            }
            column(Sales_Person; "Sales Representative")
            {
            }
            column(Sales_Person_Name; "Sales Representative Name")
            {
            }
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
            column(Total_Interest_Due; "Total Interest Due")
            {
            }
            column(Interest_Paid; "Interest Paid")
            {
            }
            column(Principal_Paid; "Principal Paid")
            {
            }
            trigger OnAfterGetRecord()
            begin
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);
                ProjectedInterest := 0;
                LoanSchedule.Reset();
                LoanSchedule.SetRange("Loan No.", "Loan Application"."No.");
                if LoanSchedule.FindSet() then begin
                    LoanSchedule.CalcSums("Interest Repayment");
                    ProjectedInterest := LoanSchedule."Interest Repayment";
                end;
                "Loan Application".CalcFields("Total Interest Due");
                ProjectedInterest -= "Loan Application"."Total Interest Due";
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        ProjectedInterest: Decimal;
        LoanSchedule: Record "Loan Schedule";
}
