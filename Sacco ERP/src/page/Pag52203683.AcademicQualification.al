page 52203683 "Academic Qualification"
{
    PageType = List;
    SourceTable = "Academic Qualification";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Level; Rec.Level)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Qualification; Rec.Qualification)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
