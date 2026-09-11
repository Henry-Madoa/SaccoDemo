page 52203688 "Bonus Rates"
{
    PageType = List;
    SourceTable = "Bonus Rates";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Period Sequence"; Rec.Period)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Multiplier; Rec.Multiplier)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
