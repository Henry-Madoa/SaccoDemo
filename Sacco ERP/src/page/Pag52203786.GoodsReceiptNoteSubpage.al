page 52203786 "Goods Receipt Note Subpage"
{
    AutoSplitKey = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Goods Receipt Note Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No"; Rec."Document No")
                {
                    Visible = false;
                }
                field("Line No."; Rec."Line No.")
                {
                    Visible = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    Editable = false;
                }
                field("Item Description"; Rec."Item Description")
                {
                    Editable = false;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                }
                field(Location; Rec.Location)
                {
                    Editable = false;
                }
                field("Quantity Ordered"; Rec."Quantity Ordered")
                {
                    Caption = 'Quantity';
                    Editable = false;
                }
                field("Quantity to Receive"; Rec."Quantity to Receive")
                {
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    Caption = 'Amount';
                    Editable = false;
                }
                field(Comments; Rec.Comments)
                {
                }
            }
        }
    }
    actions
    {
    }
}
