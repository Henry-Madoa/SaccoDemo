page 52203692 "Training Attendee Comments"
{
    PageType = List;
    SourceTable = "Training Attendee Comments";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Application No"; Rec."Application No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Comment date"; Rec."Comment date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Comments; Rec.Comments)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
