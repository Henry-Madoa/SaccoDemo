page 52203470 "Leave Type Attachement Names"
{
    PageType = List;
    SourceTable = "Leave Type Attachement Names";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Attachement Name"; Rec."Attachement Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Attachement Description"; Rec."Attachement Description")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
