report 52204084 "STO Freeze Management"
{
    ProcessingOnly = true;

    dataset
    {
        dataitem("Standing Order"; "Standing Order")
        {
            trigger OnAfterGetRecord()
            begin
                FOSAManagement.STOFreezeMgmt("Standing Order"."No.", FreezeOption, FreezeEndDate);
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Parameters)
                {
                    field(Option; FreezeOption)
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    group(FreezeDate)
                    {
                        ShowCaption = false;
                        Visible = FreezeOption = FreezeOption::Freeze;

                        field("Freeze End Date"; FreezeEndDate)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowMandatory = true;
                        }
                    }
                }
            }
        }
    }
    var
        FreezeOption: Option Freeze,UnFreeze;
        FreezeEndDate: Date;
        FOSAManagement: Codeunit "FOSA Management";
}
