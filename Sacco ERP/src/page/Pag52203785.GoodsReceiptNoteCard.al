page 52203785 "Goods Receipt Note Card"
{
    ApplicationArea = All;
    PageType = Card;
    SourceTable = "Goods Receipt Note";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Delivery Note No."; Rec."Delivery Note No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("Purchase Order No."; Rec."Purchase Order No.")
                {
                    ApplicationArea = All;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Delivery Date"; Rec."Delivery Date")
                {
                    ApplicationArea = All;
                    Caption = 'DeliveryDate';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        if Rec."Delivery Date" < Today then Error('The delivery date cannot be earlier than today');
                    end;
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Control26; Rec.Approvals)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
            }
            part("Good Receipt Lines"; "Goods Receipt Note Subpage")
            {
                ApplicationArea = All;
                SubPageLink = "Document No"=FIELD("No.");
            }
        }
    // area(factboxes)
    // {
    //     //part("Attached Documents";"Document Attachment Factbox")
    //     {
    //         ApplicationArea = All;
    //         Caption = 'Attachments';
    //         SubPageLink = "Table ID"=CONST(66102),
    //                       "No."=FIELD("No.");
    //     }
    // }
    }
    actions
    {
        area(creation)
        {
            group("Related Actions")
            {
                Caption = 'Related Actions';

                action(Post)
                {
                    ApplicationArea = All;
                    Image = Post;
                    Promoted = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    begin
                        Rec.TestField(Status, Rec.Status::Approved);
                        Rec.TestField(Posted, false);
                        if not Confirm(StrSubstNo('Are you sure you want to Post Document No. %1', Rec."No."), true)then exit;
                        Glines.Reset;
                        Glines.SetRange("Document No", Rec."No.");
                        if Glines.FindSet then begin
                            repeat Glines.TestField("Quantity to Receive");
                                //MESSAGE('%1',Glines."Item No.");
                                Plines.Reset;
                                Plines.SetRange("Document Type", Plines."Document Type"::Order);
                                Plines.SetRange("Document No.", Rec."Purchase Order No.");
                                Plines.SetRange(Type, Plines.Type::Item);
                                Plines.SetRange("No.", Glines."Item No.");
                                if Plines.FindSet then repeat //MESSAGE('%1',Plines."No.");
 Plines."Qty. to Receive":=Glines."Quantity to Receive";
                                        Plines.Validate("Qty. to Receive");
                                        Plines.Modify;
                                    until Plines.Next = 0;
                            until Glines.Next = 0;
                        end;
                        //  if PurchaseHeader.Get(DocType::Order,"Purchase Order No.") then
                        //   CODEUNIT.Run(CODEUNIT::"Purch.-Post (Yes/No)-GRN",PurchaseHeader);
                        PurchRcptHeader.Reset;
                        PurchRcptHeader.SetRange("Order No.", Rec."Purchase Order No.");
                        if PurchRcptHeader.FindFirst then begin
                            Rec.Posted:=true;
                            Rec."Posted At":=Time;
                            Rec."Posted By":=UserId;
                            Rec."Posted On":=Today;
                            if Rec.Modify(true)then Message('Document No. %1 has been Successfully Received', Rec."No.");
                        end;
                        //END;
                        CurrPage.Close;
                    end;
                }
                action(Receipts)
                {
                    ApplicationArea = All;
                    Caption = 'Receipts';
                    Image = PostedReceipts;
                    Promoted = true;
                    PromotedCategory = Category11;
                //RunObject = Page "Posted Purchase Receipts";
                // RunPageLink = "Order No."=FIELD("Purchase Order No.");
                //RunPageView = SORTING("Order No.");
                //ToolTip = 'View a list of posted purchase receipts for the order.';
                }
                separator(Separator17)
                {
                }
            }
            group(Approvals)
            {
                Caption = 'Approvals';

                action("Send Approval Request")
                {
                    ApplicationArea = All;
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        Rec.TestField(Status, Rec.Status::New);
                        Rec.TestField("Delivery Note No.");
                        Rec.TestField("Purchase Order No.");
                        Glines.Reset;
                        Glines.SetRange("Document No", Rec."No.");
                        if Glines.FindSet then repeat Glines.TestField("Quantity to Receive");
                            until Glines.Next = 0;
                        if not Confirm(StrSubstNo('Are you sure you want to Send Approval Request for Document No. %1', Rec."No."), true)then exit;
                        //       if ApprovalsMgmt.CheckGoodsReceiptNoteApprovalsWorkflowEnabled(Rec) then
                        //         ApprovalsMgmt.OnSendGoodsReceiptNoteForApproval(Rec);
                        CurrPage.Close;
                    end;
                }
                action("Cancel Approval Request")
                {
                    ApplicationArea = All;
                    Image = CancelApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        Rec.TestField(Status, Rec.Status::"Pending Approval");
                        if not Confirm('Are you sure you want to Cancel Approval Request for Document No. %1')then exit;
                        //             if ApprovalsMgmt.CheckGoodsReceiptNoteApprovalsWorkflowEnabled(Rec) then
                        //               ApprovalsMgmt.OnCancelGoodsReceiptNoteApprovalRequest(Rec);
                        CurrPage.Close;
                    end;
                }
                separator(Separator18)
                {
                }
                action("Cancel Document")
                {
                    ApplicationArea = All;
                    Image = Cancel;
                    Promoted = true;
                    PromotedCategory = Category6;

                    trigger OnAction()
                    begin
                        Rec.TestField(Status, Rec.Status::"Pending Approval");
                        Rec.TestField(Posted, false);
                        if not Confirm('Are you sure you want to Cancel Document No')then exit;
                        ApprovalEntry.Reset;
                        ApprovalEntry.SetRange("Document No.", Rec."No.");
                        if ApprovalEntry.FindFirst then ApprovalEntry.DeleteAll;
                        Rec.Status:=Rec.Status::Rejected;
                        Rec.Modify;
                        Message('Document No. %1 has been Cancelled Successfully', Rec."No.");
                    end;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        EditGRN;
    end;
    var // ConfirmManagement: Codeunit "Confirm Management";
 Glines: Record "Goods Receipt Note Lines";
    Plines: Record "Purchase Line";
    //    PurchPostYesNo: Codeunit "Purch.-Post (Yes/No)";
    PurchaseHeader: Record "Purchase Header";
    DocType: Option Quote, "Order", Invoice, "Credit Memo", "Blanket Order", "Return Order";
    ApprovalEntry: Record "Approval Entry";
    //      ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    ItemLedgerEntry: Record "Item Ledger Entry";
    GoodsReceiptNote: Record "Goods Receipt Note";
    ItemJournalLine: Record "Item Journal Line";
    PurchaseLineCopy: Record "Purchase Line";
    ProcurementSetup: Record "Purchases & Payables Setup";
    EditControls: Boolean;
    NextNo: Code[20];
    QuantityToReceive: Decimal;
    PurchaseLine: Record "Purchase Line";
    PurchRcptHeader: Record "Purch. Rcpt. Header";
    DeliveryDate: Date;
    UserPostingBatches: Record "User Posting Batches";
    local procedure FnModifyLPO(DocN: Code[20]; LPO: Code[20])
    begin
    end;
    local procedure EditGRN(): Boolean begin
        EditControls:=true;
        if Rec.Posted = true then EditControls:=false;
    end;
    local procedure CreatePurchaseReceipt(var GoodsReceiptNote: Record "Goods Receipt Note")
    var
        PurchaseHeaderVARCOPY: Record "Purchase Header";
        PurchaseLineVARCOPY: Record "Purchase Line";
        PurchRcptHeaderVARCOPY: Record "Purch. Rcpt. Header";
        PurchRcptLineVARCOPY: Record "Purch. Rcpt. Line";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        GoodsReceiptNoteLines: Record "Goods Receipt Note Lines";
        DocumentType: Option "Order", Invoice;
    begin
        PurchaseHeaderVARCOPY.Reset;
        PurchaseHeaderVARCOPY.SetRange("No.", GoodsReceiptNote."Purchase Order No.");
        if PurchaseHeaderVARCOPY.FindFirst then begin
            PurchasesPayablesSetup.Get;
            PurchasesPayablesSetup.TestField("Posted Receipt Nos.");
            PurchRcptHeaderVARCOPY.Init;
            PurchRcptHeaderVARCOPY.TransferFields(PurchaseHeaderVARCOPY);
            NextNo:=NoSeriesManagement.GetNextNo(PurchasesPayablesSetup."Posted Receipt Nos.", Today, true);
            Message(Format(NextNo));
            PurchRcptHeaderVARCOPY."No.":=NextNo;
            PurchRcptHeaderVARCOPY."Order No.":=PurchaseHeaderVARCOPY."No.";
            if PurchRcptHeaderVARCOPY.Insert(true)then begin
                if PurchaseLineVARCOPY.Get(DocumentType::Order, PurchaseHeaderVARCOPY."No.", PurchaseLineVARCOPY."Line No.")then begin
                    repeat PurchRcptLineVARCOPY.Init;
                        //        PurchRcptLineVARCOPY.TRANSFERFIELDS(PurchaseLineVARCOPY);
                        PurchRcptLineVARCOPY."Line No."+=1000;
                        PurchRcptLineVARCOPY."Document No.":=NextNo;
                        Message(Format(PurchRcptLineVARCOPY."Document No."));
                        PurchRcptLineVARCOPY."Buy-from Vendor No.":=PurchRcptHeaderVARCOPY."Buy-from Vendor No.";
                        PurchRcptLineVARCOPY.Validate("Buy-from Vendor No.");
                        PurchRcptLineVARCOPY.Type:=PurchaseLineVARCOPY.Type;
                        PurchRcptLineVARCOPY."No.":=PurchaseLineVARCOPY."No.";
                        PurchRcptLineVARCOPY.Validate("No.");
                        PurchRcptLineVARCOPY."Location Code":=PurchaseLineVARCOPY."Location Code";
                        PurchRcptLineVARCOPY.Validate("Location Code");
                        PurchRcptLineVARCOPY."Posting Date":=PurchRcptHeaderVARCOPY."Posting Date";
                        GoodsReceiptNoteLines.Reset;
                        GoodsReceiptNoteLines.SetRange("Document No", Rec."No.");
                        if GoodsReceiptNoteLines.FindFirst then begin
                            PurchRcptLineVARCOPY.Reset;
                            PurchRcptLineVARCOPY.SetRange("No.", GoodsReceiptNoteLines."Item No.");
                            if PurchRcptLineVARCOPY.FindFirst then begin
                                PurchRcptLineVARCOPY.Quantity:=GoodsReceiptNoteLines."Quantity to Receive";
                                PurchRcptLineVARCOPY."Quantity (Base)":=GoodsReceiptNoteLines."Quantity to Receive";
                            end;
                        end;
                        if Abs(PurchaseLineVARCOPY."Qty. to Invoice") > Abs(PurchaseLineVARCOPY."Qty. to Receive")then begin
                            PurchRcptLineVARCOPY."Quantity Invoiced":=PurchaseLineVARCOPY."Qty. to Receive";
                            PurchRcptLineVARCOPY."Qty. Invoiced (Base)":=PurchaseLineVARCOPY."Qty. to Receive (Base)";
                        end
                        else
                        begin
                            PurchRcptLineVARCOPY."Quantity Invoiced":=PurchaseLineVARCOPY."Qty. to Invoice";
                            PurchRcptLineVARCOPY."Qty. Invoiced (Base)":=PurchaseLineVARCOPY."Qty. to Invoice (Base)";
                        end;
                        PurchRcptLineVARCOPY."Qty. Rcd. Not Invoiced":=PurchRcptLineVARCOPY.Quantity - PurchRcptLineVARCOPY."Quantity Invoiced";
                        if PurchaseLineVARCOPY."Document Type" = PurchaseLineVARCOPY."Document Type"::Order then begin
                            PurchRcptLineVARCOPY."Order No.":=PurchaseLineVARCOPY."Document No.";
                            PurchRcptLineVARCOPY."Order Line No.":=PurchaseLineVARCOPY."Line No.";
                        end;
                        PurchRcptLineVARCOPY.SetCurrentKey("Item Rcpt. Entry No.");
                        PurchRcptLineVARCOPY.SetAscending("Item Rcpt. Entry No.", true);
                        if PurchRcptLineVARCOPY.FindLast then PurchRcptLineVARCOPY."Item Rcpt. Entry No.":=PurchRcptLineVARCOPY."Item Rcpt. Entry No." + 1;
                        PurchRcptLineVARCOPY."VAT Base Amount":=0;
                        PurchRcptLineVARCOPY."Item Charge Base Amount":=PurchaseLineVARCOPY.Amount;
                        PurchRcptLineVARCOPY.Insert;
                    until PurchaseLineVARCOPY.Next = 0 end;
            end;
        end;
    end;
    local procedure InitFromPurchLine()
    begin
    end;
}
