report 52204001 "Accrue Interest"
{
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    ProcessingOnly = true;

    dataset
    {
        dataitem("Loan Application"; Loans)
        {
            DataItemTableView = where(Posted = const(true));

            trigger OnAfterGetRecord()
            var
                LoansManagement: Codeunit "Loans Management";
            begin
                LoansManagement.AccrueLoanInterest("Loan Application");
            end;
        }
    }
}
