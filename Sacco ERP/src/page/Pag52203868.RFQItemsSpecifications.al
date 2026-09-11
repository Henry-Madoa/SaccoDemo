page 52203868 "RFQ Items Specifications"
{
    ApplicationArea = All;
    AutoSplitKey = true;
    PageType = List;
    SourceTable = "RFQ Item Specifications";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("RFQ No."; Rec."RFQ No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("No"; Rec.No)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Description"; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Specification"; Rec.Specification)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
    }
}
