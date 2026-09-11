report 52204059 "Update Mobile Transactions"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Update Mobile Transactions';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(MobileTranssactions; "Channel Transactions")
        {
            column(EntryNo; "Entry No")
            {
            }
            trigger OnAfterGetRecord()
            var
                ObjMobileTrans: Record "Channel Transactions";
            begin
                ObjMobileTrans.reset;
                ObjMobileTrans.SetRange(ObjMobileTrans."Entry No", MobileTranssactions."Entry No");
                if ObjMobileTrans.findset then
                    repeat
                        ObjMobileTrans.Posted := true;
                        ObjMobileTrans."Posted On" := CurrentDateTime;
                        ObjMobileTrans.Modify(true);
                    until ObjMobileTrans.next = 0;
            end;
        }
    }
}
