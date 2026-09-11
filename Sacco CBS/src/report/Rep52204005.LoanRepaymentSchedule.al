report 52204005 "Loan Repayment Schedule"
{
    UsageCategory = Administration;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Loan Schedule.rdl';
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem(Loans; Loans)
        {
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
            column(Application_No; "No.")
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
            column(Application_Date; "Application Date")
            {
            }
            column(DisbursedAmount; DisbursedAmount)
            {
            }
            column(Applied_Amount; "Approved Amount")
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
                column(Expected_Date; "Expected Date")
                {
                }
            }
            trigger OnAfterGetRecord()
            begin
                CalcFields(Disbursements);
                SaccoSetup.Get;
                SaccoSetup.TestField("Opening Balance Posting Date");

                Loans.CalcFields(Disbursements);
                if Loans."Mode of Disbursement" = Loans."Mode of Disbursement"::"FOSA (Partial)" then begin
                    SaccoSetup.Get;
                    If Loans."Posting Date" < SaccoSetup."Opening Balance Posting Date" then
                        DisbursedAmount := Loans."Openning Disbursed Balance"
                    else
                        DisbursedAmount := Loans.Disbursements;

                    if DisbursedAmount = 0 then begin
                        Loans.TestField("First Disbursement");
                        DisbursedAmount := Loans."First Disbursement";
                    end;

                end else
                    DisbursedAmount := Loans."Approved Amount";

                if DisbursedAmount = 0 then
                    DisbursedAmount := Loans."Openning Disbursed Balance";

                if DisbursedAmount = 0 then
                    DisbursedAmount := Loans."Approved Amount";

                if DisbursedAmount = 0 then
                    DisbursedAmount := Loans."Loan Amount";

                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    var
        DisbursedAmount: Decimal;
        CompanyInformation: Record "Company Information";
        SaccoSetup: Record "General Ledger Setup";
}
