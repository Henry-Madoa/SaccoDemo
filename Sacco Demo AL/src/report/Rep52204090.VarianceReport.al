report 52204090 "Variance Report"
{
    UsageCategory = Administration;
    PreviewMode = PrintLayout;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Variance Report.rdl';

    dataset
    {
        dataitem(Loans; Loans)
        {
            RequestFilterFields = "Date Filter", "Staff No", "Employer Code", "Posting Date";
            CalcFields = "Interest Paid", "Principal Balance", "Loan Balance";

            column(Loan_No; "No.")
            {
            }
            column(Product_Code; "Product Code")
            {
            }
            column(Product_Description; "Product Description")
            {
            }
            column(Member_No_; "Member No.")
            {
            }
            column(Member_Name; "Member Name")
            {
            }
            column(EmployerCode; "Employer Code")
            {
            }
            column(StaffNo; "Staff No")
            {
            }
            column(MonthylRepayment; MonthylRepayment)
            {
            }
            column(TotalPaid; -("Interest Paid" + "Principal Paid"))
            {
            }
            column(PrincipalArrears; "Principal Arrears")
            {
            }
            column(InterestArrears; "Interest Arrears")
            {
            }
            column(RepaymentVariance; ("Interest Paid" + "Principal Paid") + MonthylRepayment)
            {
            }
            column(Loan_Balance; "Loan Balance")
            {
            }
            column(DebtorCollector; "Debt Collector")
            {
            }
            column(LastPayDate; "Last Pay Date")
            {
            }
            column(LoanClassification; "Loan Classification")
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
                LoanSchedule.SetRange("Loan No.", Loans."No.");
                if LoanSchedule.FindSet() then begin
                    LoanSchedule.CalcSums("Interest Repayment");
                    ProjectedInterest := LoanSchedule."Interest Repayment";
                    MonthylRepayment := LoanSchedule."Monthly Repayment";
                end;

                Loans.CalcFields("Total Interest Due");

                ProjectedInterest -= Loans."Total Interest Due";
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        ProjectedInterest: Decimal;
        LoanSchedule: Record "Loan Schedule";
        MonthylRepayment: Decimal;
}
