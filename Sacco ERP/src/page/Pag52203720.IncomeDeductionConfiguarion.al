page 52203720 "Income/Deduction Configuarion"
{
    PageType = List;
    SourceTable = "Income/Deduction Configuration";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Transaction Code"; Rec."Transaction Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Transaction Description"; Rec."Transaction Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
