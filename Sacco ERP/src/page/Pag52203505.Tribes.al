page 52203505 "Tribes"
{
    PageType = List;
    SourceTable = Tribes;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Tribe; Rec.Tribe)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
