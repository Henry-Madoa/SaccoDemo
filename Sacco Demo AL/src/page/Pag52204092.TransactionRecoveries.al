page 52204092 "Transaction Recoveries"
{
    PageType = ListPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Transaction Recoveries";
    SourceTableView = sorting(Prioirity) order(ascending);
    Editable = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Recovery Type"; Rec."Recovery Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Recovery Code"; Rec."Recovery Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Recovery Descrition"; Rec."Recovery Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Recovery Amount"; Rec."Deduction Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Prioirity; Rec.Prioirity)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
