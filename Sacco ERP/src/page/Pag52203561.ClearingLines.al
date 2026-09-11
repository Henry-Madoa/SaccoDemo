page 52203561 "Clearing Lines"
{
    MultipleNewLines = false;
    PageType = ListPart;
    SourceTable = "Separation Lines";

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
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Cleared; Rec.Cleared)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Cleared Date"; Rec."Cleared Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Department; Rec.Department)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
