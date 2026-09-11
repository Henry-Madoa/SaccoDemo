page 52203700 "Training Employee Costs"
{
    PageType = ListPart;
    SourceTable = "Training Employee Costs";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Expense Code"; Rec."Expense Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Cost; Rec.Cost)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
