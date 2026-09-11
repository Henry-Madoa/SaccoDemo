page 52203508 "List of Schools"
{
    PageType = List;
    SourceTable = "List Of Schools";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Institution; Rec.Institution)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
