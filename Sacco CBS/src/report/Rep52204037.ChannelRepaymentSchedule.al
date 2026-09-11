report 52204037 "Channel Repayment Schedule"
{
    UsageCategory = Administration;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Channel Loan Schedule.rdl';
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem("Loan Application"; "Channel Loan Application")
        {
            column(Application_No; "No.")
            {
            }
            column(Member_No_; "Member No.")
            {
            }
            column(Member_Name; "Member Name")
            {
            }
            column(Application_Date; "Application Date")
            {
            }
            column(Applied_Amount; "Applied Amount")
            {
            }
            column(Product_Code; "Product Code")
            {
            }
            column(Product_Description; "Product Description")
            {
            }
            dataitem("Loan Schedule"; "Loan Schedule")
            {
                DataItemLink = "Loan No." = field("No.");

                column(Entry_No; "Entry No")
                {
                }
                column(Document_No_; "Document No.")
                {
                }
                column(Principal_Repayment; "Principal Repayment")
                {
                }
                column(Interest_Repayment; "Interest Repayment")
                {
                }
                column(Monthly_Repayment; "Monthly Repayment")
                {
                }
                column(Running_Balance; "Running Balance")
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
                column(Expected_Date; "Expected Date")
                {
                }
            }
            trigger OnAfterGetRecord()
            begin
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
}
