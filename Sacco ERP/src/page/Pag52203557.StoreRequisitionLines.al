page 52203557 "Store Requisition Lines"
{
    AutoSplitKey = true;
    MultipleNewLines = false;
    PageType = ListPart;
    SourceTable = "Requisition Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Requisition No"; Rec."Requisition No")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Enter the line type.';
                    Editable = Rec.Status = Rec.Status::Open;
                }
                field(No; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Enter the number of a general ledger account, item, or fixed asset, depending on what you selected in the Type field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Description';
                    Editable = false;
                    ToolTip = 'Enter a description of the entry of the product to be purchased.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Enter a code for the location where you want the items to be placed when they are received.';
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    Editable = Rec.Status = Rec.Status::Open;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Enter the unit of measure.';
                }
                field(Quantity; Rec.Quantity)
                {
                    Editable = Rec.Status = Rec.Status::Open;
                    Caption = 'Quantity';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Enter the number of units of the item specified on the line.';
                }
                field("Quantity Approved"; Rec."Quantity Approved")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec.Status = Rec.Status::"Pending Approval";
                    ToolTip = 'Enter the number of the units of the item to be issued for store request.';
                }
                field("Quantity To Issue"; Rec."Quantity To Issue")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec.Status = Rec.Status::Approved;
                    ToolTip = 'Enter the number of the units of the item to be issued for store request.';
                }
                field("Quantity Issued"; Rec."Quantity Issued")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Enter the number of the units of the item on the line that will be posted as Issued.';
                }
                field("Quantity in Store"; Rec."Quantity in Store")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Enter how many units, such as pieces, boxes, or cans, of the item are in inventory.';
                }
            }
        }
    }
}
