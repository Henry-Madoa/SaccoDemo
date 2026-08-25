page 52204109 "Dividend Member List"
{
    PageType = List;
    SourceTable = "Dividend Member List";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Member No."; Rec."Member No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
