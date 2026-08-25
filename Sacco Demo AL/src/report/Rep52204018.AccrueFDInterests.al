report 52204018 "Accrue FD Interests"
{
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    ProcessingOnly = true;

    dataset
    {
        dataitem("Fixed Deposit Register"; "Member Fixed Deposits")
        {
            DataItemTableView = where(Posted = const(true));

            trigger OnAfterGetRecord()
            begin
                FDManagement.PostFDAccrual("Fixed Deposit Register");
            end;
        }
    }
    var
        FDManagement: Codeunit "Fixed Deposit Mgt.";
}
