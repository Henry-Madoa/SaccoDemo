report 52204019 "Marture Fixed Deposits"
{
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    ProcessingOnly = true;

    dataset
    {
        dataitem("Fixed Deposit Register"; "Member Fixed Deposits")
        {
            DataItemTableView = where(Posted = const(true), Terminated = const(false));

            trigger OnAfterGetRecord()
            var
                FDManagement: Codeunit "Fixed Deposit Mgt.";
            begin
                if "Fixed Deposit Register"."End Date" = Today then begin
                    FDManagement.MatureFixedDeposit("Fixed Deposit Register");
                end
                else
                    CurrReport.Skip();
                ;
            end;
        }
    }
}
