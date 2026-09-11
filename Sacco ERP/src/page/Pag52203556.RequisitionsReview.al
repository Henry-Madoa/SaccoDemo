page 52203556 "Requisitions Review"
{
    Caption = 'Requisitions Review';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Requisition Lines";
    SourceTableView = WHERE(Status=const(Approved), Processed=CONST(false));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Decision; Rec.Decision)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Target No."; Rec."Target No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Requisition No"; Rec."Requisition No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(No; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Quantity in Store"; Rec."Quantity in Store")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(MFR; Rec.MFR)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Catalog No."; Rec."Catalog No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(Execute)
            {
                ApplicationArea = Basic, Suite;
                Image = ExecuteBatch;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Counter:=0;
                    Names:='';
                    Window.Open('Processing Requisition Line #####1 for #####2', Counter, Names);
                    Requisition.Reset;
                    Requisition.SetRange("Decision By", UserId);
                    Requisition.SetFilter(Decision, '<>%1', Requisition.Decision::" ");
                    Requisition.SetFilter("Target No.", '<>%1', '');
                    Requisition.SetRange(Processed, false);
                    if Requisition.Find('-')then begin
                        repeat Counter:=Counter + 1;
                            if Requisition.Decision = Requisition.Decision::"Append to Blanket Order" then begin
                            end
                            else if Requisition.Decision = Requisition.Decision::"Append to Order" then begin
                                    PurchOrderLineCopy.Reset;
                                    PurchOrderLineCopy.SetRange("Document Type", PurchOrderLineCopy."Document Type"::Order);
                                    PurchOrderLineCopy.SetRange("Document No.", Rec."Target No.");
                                    if PurchOrderLineCopy.FindLast then LastLineNo:=PurchOrderLineCopy."Line No.";
                                    //Create Lines
                                    PurchOrderLine.Init;
                                    PurchOrderLine."Document Type":=PurchOrderLine."Document Type"::Order;
                                    PurchOrderLine."Document No.":=Requisition."Target No.";
                                    PurchOrderLine."Line No.":=LastLineNo + 1000;
                                    PurchOrderLine."Catalog No.":=Requisition."Catalog No.";
                                    PurchOrderLine.MFR:=Requisition.MFR;
                                    PurchOrderLine.Type:=Requisition.Type;
                                    PurchOrderLine.Validate("No.", Requisition."No.");
                                    PurchOrderLine.Description:=CopyStr(Requisition.Description, 1, 250);
                                    PurchOrderLine."Location Code":=Requisition."Location Code";
                                    PurchOrderLine."Currency Code":=Requisition."Currency Code";
                                    PurchOrderLine.Validate(Quantity, Requisition.Quantity);
                                    PurchOrderLine.Validate("Unit of Measure Code", Requisition."Unit of Measure");
                                    PurchOrderLine.Validate("Direct Unit Cost", Requisition."Unit Price");
                                    PurchOrderLine.Validate("Unit Cost", Requisition."Unit Price");
                                    PurchOrderLine.Validate("Shortcut Dimension 1 Code", Requisition."Global Dimension 1 Code");
                                    PurchOrderLine.Validate("Shortcut Dimension 2 Code", Requisition."Global Dimension 2 Code");
                                    PurchOrderLine.Insert;
                                    Requisition."Order No":=Requisition."Target No.";
                                    Requisition.Processed:=true;
                                    Requisition.Modify;
                                    if ReqHeader.Get(Requisition."Requisition No")then begin
                                        ReqHeader."PO Generated Directly":=true;
                                        ReqHeader."PO Generated By":=UserId;
                                        ReqHeader."PO Generated Date":=WorkDate;
                                        ReqHeader."PO Number":=PurchOrderHeader."No.";
                                        ReqHeader."PR Closed":=true;
                                        ReqHeader."PR Closed By":=ReqHeader."PR Closed By"::"Purchase Order";
                                        ReqHeader.Modify;
                                    end;
                                end
                                else if Requisition.Decision = Requisition.Decision::"Blanket Order" then begin
                                    end
                                    else if Requisition.Decision = Requisition.Decision::Inventory then begin
                                        end
                                        else if Requisition.Decision = Requisition.Decision::Order then begin
                                                //Keep PO Number
                                                if not TempPO.Get(Requisition."Target No.")then begin
                                                    //Create Header
                                                    PurchOrderHeader.Init;
                                                    PurchOrderHeader."Document Type":=PurchOrderHeader."Document Type"::Order;
                                                    PurchOrderHeader."No. Printed":=0;
                                                    PurchOrderHeader.Status:=PurchOrderHeader.Status::Open;
                                                    PurchOrderHeader."No.":='';
                                                    PurchOrderHeader."Requisition No":=Requisition."Requisition No";
                                                    PurchOrderHeader."Order Date":=WorkDate;
                                                    PurchOrderHeader."Document Date":=WorkDate;
                                                    PurchOrderHeader."Expected Receipt Date":=WorkDate;
                                                    if ReqHeader.Get(Requisition."Requisition No")then begin
                                                        PurchOrderHeader."Shortcut Dimension 1 Code":=Requisition."Global Dimension 1 Code";
                                                        PurchOrderHeader."Shortcut Dimension 2 Code":=Requisition."Global Dimension 2 Code";
                                                    end;
                                                    PurchOrderHeader."Currency Code":=Requisition."Currency Code";
                                                    PurchOrderHeader."Location Code":=Requisition."Location Code";
                                                    PurchOrderHeader."Posting Date":=WorkDate;
                                                    PurchOrderHeader.Insert(true);
                                                    PurchOrderHeader.Validate("Buy-from Vendor No.", Requisition."Target No.");
                                                    PurchOrderHeader.Validate("Shortcut Dimension 1 Code", Requisition."Global Dimension 1 Code");
                                                    PurchOrderHeader.Validate("Shortcut Dimension 2 Code", Requisition."Global Dimension 2 Code");
                                                    PurchOrderHeader.Modify(true); //Create Lines
                                                    PurchOrderLine.Init;
                                                    PurchOrderLine."Document Type":=PurchOrderLine."Document Type"::Order;
                                                    PurchOrderLine."Document No.":=PurchOrderHeader."No.";
                                                    PurchOrderLine."Line No.":=Counter;
                                                    PurchOrderLine."Catalog No.":=Requisition."Catalog No.";
                                                    PurchOrderLine.MFR:=Requisition.MFR;
                                                    PurchOrderLine.Type:=Requisition.Type;
                                                    PurchOrderLine.Validate("No.", Requisition."No.");
                                                    PurchOrderLine.Description:=CopyStr(Requisition.Description, 1, 250);
                                                    PurchOrderLine."Location Code":=Requisition."Location Code";
                                                    PurchOrderLine."Currency Code":=Requisition."Currency Code";
                                                    PurchOrderLine.Validate(Quantity, Requisition.Quantity);
                                                    PurchOrderLine.Validate("Unit of Measure Code", Requisition."Unit of Measure");
                                                    PurchOrderLine.Validate("Direct Unit Cost", Requisition."Unit Price");
                                                    PurchOrderLine.Validate("Unit Cost", Requisition."Unit Price");
                                                    if ReqHeader.Get(Requisition."Requisition No")then begin
                                                        PurchOrderLine.Validate("Shortcut Dimension 1 Code", Requisition."Global Dimension 1 Code");
                                                        PurchOrderLine.Validate("Shortcut Dimension 2 Code", Requisition."Global Dimension 2 Code");
                                                    end;
                                                    PurchOrderLine.Insert;
                                                    Requisition."Order No":=PurchOrderHeader."No.";
                                                    Requisition.Processed:=true;
                                                    Requisition.Modify;
                                                    if ReqHeader.Get(Requisition."Requisition No")then begin
                                                        ReqHeader."PO Generated Directly":=true;
                                                        ReqHeader."PO Generated By":=UserId;
                                                        ReqHeader."PO Generated Date":=WorkDate;
                                                        ReqHeader."PO Number":=PurchOrderHeader."No.";
                                                        ReqHeader."PR Closed":=true;
                                                        ReqHeader."PR Closed By":=ReqHeader."PR Closed By"::"Purchase Order";
                                                        ReqHeader.Modify;
                                                    end;
                                                    //
                                                    TempPO.Init;
                                                    TempPO."Vendor No.":=Requisition."Target No.";
                                                    TempPO."PO No.":=PurchOrderHeader."No.";
                                                    TempPO.Insert;
                                                end
                                                else
                                                begin
                                                    //Create Lines
                                                    PurchOrderLine.Init;
                                                    PurchOrderLine."Document Type":=PurchOrderLine."Document Type"::Order;
                                                    PurchOrderLine."Document No.":=TempPO."PO No.";
                                                    PurchOrderLine."Line No.":=Counter;
                                                    PurchOrderLine."Catalog No.":=Requisition."Catalog No.";
                                                    PurchOrderLine.MFR:=Requisition.MFR;
                                                    PurchOrderLine.Type:=Requisition.Type;
                                                    PurchOrderLine.Validate("No.", Requisition."No.");
                                                    PurchOrderLine.Description:=CopyStr(Requisition.Description, 1, 250);
                                                    PurchOrderLine."Location Code":=Requisition."Location Code";
                                                    PurchOrderLine."Currency Code":=Requisition."Currency Code";
                                                    PurchOrderLine.Validate(Quantity, Requisition.Quantity);
                                                    PurchOrderLine.Validate("Unit of Measure Code", Requisition."Unit of Measure");
                                                    PurchOrderLine.Validate("Direct Unit Cost", Requisition."Unit Price");
                                                    PurchOrderLine.Validate("Unit Cost", Requisition."Unit Price");
                                                    if ReqHeader.Get(Requisition."Requisition No")then begin
                                                        PurchOrderLine.Validate("Shortcut Dimension 1 Code", Requisition."Global Dimension 1 Code");
                                                        PurchOrderLine.Validate("Shortcut Dimension 2 Code", Requisition."Global Dimension 2 Code");
                                                    end;
                                                    PurchOrderLine.Insert;
                                                    Requisition."Order No":=TempPO."PO No.";
                                                    Requisition.Processed:=true;
                                                    Requisition.Modify;
                                                    if ReqHeader.Get(Requisition."Requisition No")then begin
                                                        ReqHeader."PO Generated Directly":=true;
                                                        ReqHeader."PO Generated By":=UserId;
                                                        ReqHeader."PO Generated Date":=WorkDate;
                                                        ReqHeader."PO Number":=PurchOrderHeader."No.";
                                                        ReqHeader."PR Closed":=true;
                                                        ReqHeader."PR Closed By":=ReqHeader."PR Closed By"::"Purchase Order";
                                                        ReqHeader.Modify;
                                                    end;
                                                end;
                                            //PO Number
                                            end
                                            else if Requisition.Decision = Requisition.Decision::RFQ then begin
                                                    //Keep RFQ Number
                                                    if not TempRFQ.Get(Requisition."Target No.")then begin
                                                        //Create Header
                                                        PurchOrderHeader.Init;
                                                        PurchOrderHeader."Document Type":=PurchOrderHeader."Document Type"::Quote;
                                                        PurchOrderHeader."No. Printed":=0;
                                                        PurchOrderHeader.Status:=PurchOrderHeader.Status::Open;
                                                        PurchOrderHeader."No.":='';
                                                        PurchOrderHeader."Requisition No":=Requisition."Requisition No";
                                                        PurchOrderHeader."Order Date":=WorkDate;
                                                        PurchOrderHeader."Document Date":=WorkDate;
                                                        PurchOrderHeader."Expected Receipt Date":=WorkDate;
                                                        if ReqHeader.Get(Requisition."Requisition No")then begin
                                                            PurchOrderHeader."Shortcut Dimension 1 Code":=Requisition."Global Dimension 1 Code";
                                                            PurchOrderHeader."Shortcut Dimension 2 Code":=Requisition."Global Dimension 2 Code";
                                                        end;
                                                        PurchOrderHeader."Currency Code":=Requisition."Currency Code";
                                                        PurchOrderHeader."Location Code":=Requisition."Location Code";
                                                        PurchOrderHeader."Posting Date":=WorkDate;
                                                        PurchOrderHeader.Insert(true);
                                                        PurchOrderHeader.Validate("Buy-from Vendor No.", Requisition."Target No.");
                                                        PurchOrderHeader.Validate("Shortcut Dimension 1 Code", Requisition."Global Dimension 1 Code");
                                                        PurchOrderHeader.Validate("Shortcut Dimension 2 Code", Requisition."Global Dimension 2 Code");
                                                        PurchOrderHeader.Modify(true); //Create Lines
                                                        PurchOrderLine.Init;
                                                        PurchOrderLine."Document Type":=PurchOrderLine."Document Type"::Quote;
                                                        PurchOrderLine."Document No.":=PurchOrderHeader."No.";
                                                        PurchOrderLine."Line No.":=Counter;
                                                        PurchOrderLine."Catalog No.":=Requisition."Catalog No.";
                                                        PurchOrderLine.MFR:=Requisition.MFR;
                                                        PurchOrderLine.Type:=Requisition.Type;
                                                        PurchOrderLine.Validate("No.", Requisition."No.");
                                                        PurchOrderLine.Description:=CopyStr(Requisition.Description, 1, 250);
                                                        PurchOrderLine."Location Code":=Requisition."Location Code";
                                                        PurchOrderLine."Currency Code":=Requisition."Currency Code";
                                                        PurchOrderLine.Validate(Quantity, Requisition.Quantity);
                                                        PurchOrderLine.Validate("Unit of Measure Code", Requisition."Unit of Measure");
                                                        PurchOrderLine.Validate("Direct Unit Cost", Requisition."Unit Price");
                                                        PurchOrderLine.Validate("Unit Cost", Requisition."Unit Price");
                                                        if ReqHeader.Get(Requisition."Requisition No")then begin
                                                            PurchOrderLine.Validate("Shortcut Dimension 1 Code", Requisition."Global Dimension 1 Code");
                                                            PurchOrderLine.Validate("Shortcut Dimension 2 Code", Requisition."Global Dimension 2 Code");
                                                        end;
                                                        PurchOrderLine.Insert; //
                                                        TempRFQ.Init;
                                                        TempRFQ."Vendor No.":=Requisition."Target No.";
                                                        TempRFQ."RFQ No.":=PurchOrderHeader."No.";
                                                        TempRFQ.Insert;
                                                    end
                                                    else
                                                    begin
                                                        //Create Lines
                                                        PurchOrderLine.Init;
                                                        PurchOrderLine."Document Type":=PurchOrderLine."Document Type"::Quote;
                                                        PurchOrderLine."Document No.":=TempRFQ."RFQ No.";
                                                        PurchOrderLine."Line No.":=Counter;
                                                        PurchOrderLine."Catalog No.":=Requisition."Catalog No.";
                                                        PurchOrderLine.MFR:=Requisition.MFR;
                                                        PurchOrderLine.Type:=Requisition.Type;
                                                        PurchOrderLine.Validate("No.", Requisition."No.");
                                                        PurchOrderLine.Description:=CopyStr(Requisition.Description, 1, 250);
                                                        PurchOrderLine."Location Code":=Requisition."Location Code";
                                                        PurchOrderLine."Currency Code":=Requisition."Currency Code";
                                                        PurchOrderLine.Validate(Quantity, Requisition.Quantity);
                                                        PurchOrderLine.Validate("Unit of Measure Code", Requisition."Unit of Measure");
                                                        PurchOrderLine.Validate("Direct Unit Cost", Requisition."Unit Price");
                                                        PurchOrderLine.Validate("Unit Cost", Requisition."Unit Price");
                                                        if ReqHeader.Get(Requisition."Requisition No")then begin
                                                            PurchOrderLine.Validate("Shortcut Dimension 1 Code", Requisition."Global Dimension 1 Code");
                                                            PurchOrderLine.Validate("Shortcut Dimension 2 Code", Requisition."Global Dimension 2 Code");
                                                        end;
                                                        PurchOrderLine.Insert;
                                                    end;
                                                //RFQ Number
                                                end;
                            Window.Update(1, Counter);
                            Window.Update(2, Requisition.Description);
                        until Requisition.Next = 0;
                    end;
                    Window.Close;
                end;
            }
        }
    }
    var Requisition: Record "Requisition Lines";
    LPONo: Code[20];
    RFQNo: Code[20];
    Window: Dialog;
    Names: Text;
    Counter: Integer;
    TempPO: Record "Requisition Review Temp PO" temporary;
    TempRFQ: Record "Requisition Review Temp RFQ" temporary;
    PurchOrderHeader: Record "Purchase Header";
    PurchOrderLine: Record "Purchase Line";
    ReqHeader: Record "Requisition Header";
    Requisition2: Record "Requisition Lines";
    PurchOrderLineCopy: Record "Purchase Line";
    LastLineNo: Integer;
}
