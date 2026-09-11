report 52204048 "Double Loans"
{
    PreviewMode = Normal;
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/DoubleLoans.rdl';

    dataset
    {
        dataitem(Members; Members)
        {
            column(Member_No_; "No.")
            {
            }
            column(Payroll_No; "Payroll No.")
            {
            }
            column(Full_Name; "Full Name")
            {
            }
            dataitem("Loan Application"; Loans)
            {
                DataItemLink = "Member No." = field("No.");
                DataItemTableView = sorting("No.") where("Loan Balance" = filter(<> 0));

                column(Application_No; "No.")
                {
                }
                column(Product_Code; "Product Code")
                {
                }
                column(Applied_Amount; "Loan Amount")
                {
                }
                column(Approved_Amount; "Approved Amount")
                {
                }
                column(Loan_Balance; "Loan Balance")
                {
                }
            }
            trigger OnAfterGetRecord()
            begin
                if not LoansMgt.HasDoubleLoan(Members."No.") then CurrReport.Skip();
            end;
        }
    }
    var
        LoansMgt: Codeunit "Loans Management";
}
