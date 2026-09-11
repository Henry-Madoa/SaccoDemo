page 52203676 "Education Level"
{
    PageType = List;
    SourceTable = "Education Level";

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
            }
        }
    }
}
