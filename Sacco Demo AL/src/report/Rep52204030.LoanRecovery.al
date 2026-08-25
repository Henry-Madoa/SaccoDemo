report 52204030 "Loan Recovery"
{
    UsageCategory = Administration;
    PreviewMode = PrintLayout;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Loan Recovery.rdl';

    dataset
    {
        dataitem("Loan Recovery Header"; "Loan Recovery Header")
        {
            RequestFilterFields = "Posting Date", "Member No";

            column(Document_No; "No.")
            {
            }
            column(Posting_Date; "Posting Date")
            {
            }
            column(Member_No; "Member No")
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
            column(Loan_Balance; "Loan Balance")
            {
            }
            column(Accrued_Interest; "Accrued Interest")
            {
            }
            column(Self_Recovery_Amount; "Self Recovery Amount")
            {
            }
            column(RecoveryAccountName; "Recovery Account Name")
            {
            }
            column(Guarantor_Deposit_Recovery; "Guarantor Deposit Recovery")
            {
            }
            column(Guarantor_Liability_Recovery; "Guarantor Liability Recovery")
            {
            }
            column(Total_Recoverable; "Total Recoverable")
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
            column("CompanyWebsite"; CompanyInformation."Home Page")
            {
            }
            column(PayrollNo; PayrollNo)
            {
            }
            column(Loan_No; "Loan No")
            {
            }
            trigger OnAfterGetRecord()
            begin
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);
                PayrollNo := '';
                if Members.Get("Member No") then PayrollNo := Members."Payroll No.";
                if PayrollNo = '' then PayrollNo := Members."Payroll No.";
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        Members: Record Members;
        PayrollNo: Code[20];
}
