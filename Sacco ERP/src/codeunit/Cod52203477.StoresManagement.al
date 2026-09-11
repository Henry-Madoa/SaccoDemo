codeunit 52203477 "Stores Management"
{
    var RequsitionLines: Record "Requisition Lines";
    ItemJournaline: Record "Item Journal Line";
    CurrentJnlBatchName: Code[10];
    UserSetup: Record "User Setup";
    ItemLedger: Record "Item Ledger Entry";
    PurchPayablesSetup: Record "Purchases & Payables Setup";
    Batch: Record "Item Journal Batch";
    Text000: Label 'The document %1 is already posted';
    Text001: Label 'You are about to post this document, do you wish to continue?';
    ItemJnlLine: Record "Item Journal Line";
    JnlTemplate: Record "Item Journal Template";
    Text002: Label 'Your are about to receive Items on this Approved Purchase Requisition. Do you wish to continue?';
    procedure IssueStoreItems(var Requisition: Record "Requisition Header")
    var
        Text000: Label 'Procurement Notified! The stock item: %1 is out of stock, The quantity in store is %2';
        Text001: Label '%1 is Out of stock';
        Text002: Label '%1 has Requested %2 %3 but it is out of stock';
        Text003: Label 'Requisition %1 is already posted';
        Text004: Label 'The Requisition cannot be posted before it is fully approved';
        Text005: Label '%1 issued.';
        Text006: Label '%1. You have been issued with %2  of %3.';
        Text007: Label '%1 approved';
        Text008: Label '%1. You have been approved with %2 of %3.';
    begin
        with Requisition do begin
            PurchPayablesSetup.Get;
            PurchPayablesSetup.TestField("Store Issue Template");
            PurchPayablesSetup.TestField("Store Issue Batch"); // Delete Lines Present on the General Journal Line
            ItemJournaline.Reset;
            ItemJournaline.SetRange(ItemJournaline."Journal Template Name", PurchPayablesSetup."Store Issue Template");
            ItemJournaline.SetRange(ItemJournaline."Journal Batch Name", PurchPayablesSetup."Store Issue Batch");
            ItemJournaline.DeleteAll;
            Batch.Init;
            Batch."Journal Template Name":=PurchPayablesSetup."Store Issue Template";
            Batch.Name:=PurchPayablesSetup."Store Issue Batch";
            if not Batch.Get(Batch."Journal Template Name", Batch.Name)then Batch.Insert;
            if Posted then Error(Text004);
            RequsitionLines.Reset;
            RequsitionLines.SetRange(RequsitionLines."Requisition No", "No.");
            if RequsitionLines.Find('-')then repeat ItemJournaline.Init;
                    ItemJournaline."Journal Template Name":=PurchPayablesSetup."Store Issue Template";
                    ItemJournaline."Journal Batch Name":=PurchPayablesSetup."Store Issue Batch";
                    ItemJournaline."Line No.":=ItemJournaline."Line No." + 10000;
                    ItemJournaline."Posting Date":=WorkDate;
                    ItemJournaline."Entry Type":=ItemJournaline."Entry Type"::"Negative Adjmt.";
                    ItemJournaline."Document No.":=RequsitionLines."Requisition No";
                    ItemJournaline.Validate("Item No.", RequsitionLines."No.");
                    ItemJournaline."Location Code":=RequsitionLines."Location Code";
                    ItemJournaline.Validate("Location Code");
                    ItemJournaline."External Document No.":=RequsitionLines."Requisition No";
                    ItemJournaline.Validate(Quantity, RequsitionLines."Quantity To Issue");
                    ItemJournaline.Validate("Shortcut Dimension 1 Code", RequsitionLines."Global Dimension 1 Code");
                    ItemJournaline.Validate("Shortcut Dimension 2 Code", RequsitionLines."Global Dimension 2 Code");
                    if ItemJournaline.Quantity <> 0 then ItemJournaline.Insert(true);
                    RequsitionLines."Quantity Issued":=RequsitionLines."Quantity Issued" + RequsitionLines."Quantity To Issue";
                    RequsitionLines."Issued By":=UserId;
                    "Requisition Date":=WorkDate;
                    RequsitionLines.Modify;
                until RequsitionLines.Next = 0;
            ItemJournaline.SetRange(ItemJournaline."Journal Template Name", PurchPayablesSetup."Store Issue Template");
            ItemJournaline.SetRange(ItemJournaline."Journal Batch Name", PurchPayablesSetup."Store Issue Batch");
            CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post", ItemJournaline);
            CurrentJnlBatchName:=ItemJournaline.GetRangeMax("Journal Batch Name");
            ItemLedger.Reset;
            ItemLedger.SetRange(ItemLedger."Entry Type", ItemLedger."Entry Type"::"Negative Adjmt.");
            ItemLedger.SetRange(ItemLedger."Document No.", "No.");
            if ItemLedger.Find('-')then begin
            end;
        end;
    end;
}
