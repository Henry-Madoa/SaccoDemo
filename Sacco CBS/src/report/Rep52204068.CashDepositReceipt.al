report 52204068 "Cash Deposit Receipt"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Cash Deposit.rdl';

    dataset
    {
        dataitem("Teller Transactions"; "Teller Transactions")
        {
            column(Document_No; "No.")
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
            column(Transaction_Type; "Transaction Type")
            {
            }
            column(Member_No; "Member No.")
            {
            }
            column(Member_Name; "Member Name")
            {
            }
            column(Account_No; "Account No")
            {
            }
            column(Account_Name; "Account Name")
            {
            }
            column(Amount; Amount)
            {
            }
            column(Teller; Teller)
            {
            }
            column(Till; Till)
            {
            }
            column(Created_On; "Created On")
            {
            }
            column(Posting_Date; "Posting Date")
            {
            }
            column(Created_By; "Created By")
            {
            }
            column(Global_Dimension_1_Code; "Global Dimension 1 Code")
            {
            }
            column(AmountInWords; AmountInWords[1])
            {
            }
            column(Transacted_By_Name; "Transacted By Name")
            {
            }
            column(Transacted_By_ID_No; "Transacted By ID No")
            {
            }
            column(Description; Description)
            {
            }
            trigger OnAfterGetRecord()
            begin
                CompanyInformation.get;
                ObjGLLedgerSet.Get();
                CompanyInformation.CalcFields(Picture);
                ObjCheck.FormatNoText(AmountInWords, Amount, ObjGLLedgerSet."LCY Code");
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        DateFilter: Text;
        AmountInWords: array[2] of Text[80];
        ObjGLLedgerSet: Record "General Ledger Setup";
        ObjCheck: Codeunit "Amount To Words";
}
