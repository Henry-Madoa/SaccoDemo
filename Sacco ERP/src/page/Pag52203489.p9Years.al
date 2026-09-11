page 52203489 "p9 Years"
{
    PageType = List;
    SourceTable = "P9 Years";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Period Year"; Rec."Period Year")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
