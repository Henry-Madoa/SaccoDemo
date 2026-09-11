report 52204082 "Cheque Deposit Slip"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Cheque Deposit Slip.rdl';

    dataset
    {
        dataitem("Cheque Deposits"; "Cheque Deposits")
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
            column(Account_No; "Account No.")
            {
            }
            column(Account_Name; "Account Name")
            {
            }
            column(Amount; Amount)
            {
            }
            column(Deposit_Date; "Deposit Date")
            {
            }
            column(Maturity_Date; "Maturity Date")
            {
            }
            column(Cheque_No; "Cheque No")
            {
            }
            column(AmountInWords; AmountInWords[1])
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
