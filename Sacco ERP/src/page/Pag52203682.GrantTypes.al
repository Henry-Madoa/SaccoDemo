page 52203682 "Grant Types"
{
    PageType = List;
    SourceTable = "Grant Types";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Grant Types"; Rec."Grant Types")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
