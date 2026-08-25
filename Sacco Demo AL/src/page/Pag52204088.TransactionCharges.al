page 52204088 "Transaction Charges"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Transaction Charges";
    CardPageId = "Transaction Charge";
    Editable = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Charges)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = StepInto;
                Ellipsis = true;
                Scope = Repeater;
                RunObject = page "Transaction Charges Setup";
                RunPageLink = "Transaction Code"=field(Code);
            }
        }
    }
}
