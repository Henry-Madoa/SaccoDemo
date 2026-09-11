page 52203558 "Purch Requisition Lines"
{
    AutoSplitKey = true;
    Caption = 'Requisition Lines';
    MultipleNewLines = false;
    PageType = ListPart;
    SourceTable = "Requisition Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Enter the line type.';

                    trigger OnValidate()
                    begin
                        if(Rec.Type = Rec.Type::"Fixed Asset") or (Rec.Type = Rec.Type::Item)then ItemFixedV:=true
                        else
                            ItemFixedV:=false;
                    end;
                }
                field(No; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Enter the number of a general ledger account, item, or fixed asset, depending on what you selected in the Type field.';
                    Editable = Rec.Status = Rec.Status::Open;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Enter a code for the location where you want the items to be placed when they are received.';
                    Editable = Rec.Status = Rec.Status::Open;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Enter the unit of measure.';
                    Editable = ((Rec.Status = Rec.Status::Open) and (Rec.Type = Rec.Type::Item));
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec.Status = Rec.Status::Open;
                    ToolTip = 'Enter the price, in LCY, for one unit of the item.';
                }
                field(Quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Enter the number of units of the item specified on the line.';
                    Editable = Rec.Status = Rec.Status::Open;

                    trigger OnValidate()
                    begin
                        Rec.Amount:=Rec.Quantity * Rec."Unit Price";
                    end;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Enter the amount that is granted for the item on the line.';
                }
                field("Budget Available"; Rec."Budget Available")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    trigger OnInit()
    begin
        PurchReq:=false;
        StoreReq:=false;
        ItemFixedV:=false;
    end;
    trigger OnOpenPage()
    begin
        if ReqHeader."Requisition Type" = ReqHeader."Requisition Type"::"Purchase Requisition" then PurchReq:=true
        else
            PurchReq:=false; //Store
        if ReqHeader."Requisition Type" = ReqHeader."Requisition Type"::"Store Requisition" then StoreReq:=true
        else
            StoreReq:=false;
        if(Rec.Type = Rec.Type::"Fixed Asset") or (Rec.Type = Rec.Type::Item)then ItemFixedV:=true
        else
            ItemFixedV:=false;
    end;
    trigger OnAfterGetRecord()
    begin
        RequisitionLines.Reset;
        RequisitionLines.SetRange("Requisition No", Rec."Requisition No");
        RequisitionLines.SetRange("Line No", Rec."Line No");
        if RequisitionLines.FindFirst then begin
            RequisitionLines."Quantity To Issue":=RequisitionLines."Quantity Approved" - RequisitionLines."Quantity Issued";
            RequisitionLines.Modify;
        end;
        Rec.Amount:=Rec.Quantity * Rec."Unit Price";
    end;
    var RequisitionLines: Record "Requisition Lines";
    ReqHeader: Record "Requisition Header";
    PurchReq: Boolean;
    StoreReq: Boolean;
    ItemFixedV: Boolean;
}
