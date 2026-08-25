page 52204029 "Collateral Types"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Collateral Types";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Category; Rec.Category)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Value Multiplier"; Rec."Value Multiplier")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
