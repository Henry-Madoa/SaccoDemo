page 52203544 "SS Clearing Lines"
{
    AutoSplitKey = true;
    MultipleNewLines = false;
    PageType = ListPart;
    SourceTable = "Separation Lines";
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Control6)
            {
                ShowCaption = false;

                field(Item; Rec.Item)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Cleared; Rec.Cleared)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Cleared Date"; Rec."Cleared Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Department; Rec.Department)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
            }
        }
    }
}
