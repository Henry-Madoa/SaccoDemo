page 52203510 "Hr Languages"
{
    PageType = List;
    SourceTable = "Hr Languages";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Languages; Rec.Languages)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
