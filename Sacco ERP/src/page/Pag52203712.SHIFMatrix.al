page 52203712 "SHIF Matrix"
{
    PageType = List;
    SourceTable = "Payroll SHIF";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Tier Code"; Rec."Tier Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("SHIF Tier"; Rec."SHIF Tier")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Lower Limit"; Rec."Lower Limit")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Upper Limit"; Rec."Upper Limit")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
