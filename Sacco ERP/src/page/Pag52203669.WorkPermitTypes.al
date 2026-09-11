page 52203669 "Work Permit Types"
{
    PageType = List;
    SourceTable = "Work Permit Types";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Permit Type"; Rec."Permit Type")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
