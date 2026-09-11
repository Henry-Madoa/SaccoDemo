page 52203725 "OverView Manager Comments"
{
    PageType = List;
    SourceTable = "Overview Manager Comments";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Comments; Rec.Comments)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
