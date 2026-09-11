pageextension 52203464 "Posted Purch Inv" extends "Posted Purchase Invoices"
{
    layout
    {
        addafter("Amount Including VAT")
        {
            field("Amount Remaining To Request"; Rec."Amount Remaining To Request")
            {
                ApplicationArea = Basic, Suite;
                StyleExpr = Style;
            }
        }
        addafter(Corrective)
        {
            field("Order No._2"; Rec."Order No.")
            {
                Caption = 'Order No';
                ApplicationArea = Basic, Suite;
                StyleExpr = Style;
            }
            field("User ID"; Rec."User ID")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Posted By';
                StyleExpr = Style;
            }
            field("Order Created By"; Rec."Order Created By")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'User ID';
                StyleExpr = Style;
            }
        }
        modify("No.")
        {
            StyleExpr = Style;
        }
        modify("Vendor Invoice No.")
        {
            StyleExpr = Style;
        }
        modify("Buy-from Vendor No.")
        {
            StyleExpr = Style;
        }
        modify("Buy-from Vendor Name")
        {
            StyleExpr = Style;
        }
        modify("Currency Code")
        {
            StyleExpr = Style;
        }
        modify(Amount)
        {
            StyleExpr = Style;
        }
        modify("Amount Including VAT")
        {
            StyleExpr = Style;
        }
        modify("Location Code")
        {
            StyleExpr = Style;
        }
        modify("No. Printed")
        {
            StyleExpr = Style;
        }
        modify("Due Date")
        {
            StyleExpr = Style;
        }
        modify("Remaining Amount")
        {
            StyleExpr = Style;
            Visible = false;
        }
        modify(Closed)
        {
            StyleExpr = Style;
        }
        modify(Cancelled)
        {
            StyleExpr = Style;
        }
        modify(Corrective)
        {
            StyleExpr = Style;
        }
    }
    actions
    {
        // Add changes to page actions here
        addafter("Update Document")
        {
            action("Create Request For Payment")
            {
                ApplicationArea = Basic, Suite;
                Image = CreateSKU;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Enabled = not Rec."Payment Requested";

                trigger OnAction()
                begin
                    Paymentmgmt.InvoicePaymentRequest(Rec);
                end;
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        SetStyle;
        OrderHeader.Reset();
        OrderHeader.SetRange("Document Type", OrderHeader."Document Type"::Order);
        OrderHeader.SetRange("No.", Rec."Order No.");
        if OrderHeader.FindFirst then;
    end;

    trigger OnAfterGetRecord()
    begin
        SetStyle;
    end;

    trigger OnOpenPage()
    begin
        SetStyle;
        InherateDocumentAttachments();
    end;

    local procedure SetStyle()
    begin
        //Style:
        Style := '';
        IF ((Rec."Partial Payment Request") and (not Rec."Payment Requested")) then Style := 'StrongAccent';
        IF Rec."Payment Requested" THEN Style := 'Favorable';
    end;

    procedure InherateDocumentAttachments()
    begin
        PurchInv.Reset;
        PurchInv.SetAscending("No.", false);
        PurchInv.Setfilter("Remaining Amount", '<>%1', 0);
        PurchInv.SetFilter("Pre-Assigned No.", '<>%1', '');
        if PurchInv.FindSet then begin
            repeat
                DocumentAttachment.Reset();
                DocumentAttachment.SetRange("Table ID", 38);
                DocumentAttachment.SetRange("No.", PurchInv."Pre-Assigned No.");
                if DocumentAttachment.FindSet() then begin
                    repeat
                        DocumentAttachmentCheck.Reset();
                        DocumentAttachmentCheck.SetRange("Table ID", 122);
                        DocumentAttachmentCheck.SetRange("No.", PurchInv."No.");
                        DocumentAttachmentCheck.SetRange("File Name", DocumentAttachment."File Name");
                        DocumentAttachmentCheck.SetRange("File Type", DocumentAttachment."File Type");
                        if not DocumentAttachmentCheck.FindFirst then begin
                            DocumentAttachmentInt.Init();
                            DocumentAttachmentInt.TransferFields(DocumentAttachment);
                            DocumentAttachmentInt."Table ID" := 122;
                            DocumentAttachmentInt."No." := PurchInv."No.";
                            DocumentAttachmentInt.Insert(true);
                        end;
                    until DocumentAttachment.Next() = 0;
                end;
            until PurchInv.Next() = 0;
        end;
    end;

    var
        Paymentmgmt: Codeunit "Payment Management";
        Style: Text;
        OrderHeader: Record "Purchase Header";
        DocumentAttachment: Record "Document Attachment";
        DocumentAttachmentCheck: Record "Document Attachment";
        DocumentAttachmentInt: Record "Document Attachment";
        PurchHeader: Record "Purchase Header";
        PurchInv: Record "Purch. Inv. Header";
}
