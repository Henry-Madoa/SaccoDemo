page 52203506 "Religions"
{
    PageType = List;
    SourceTable = Religions;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Religion; Rec.Religion)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
