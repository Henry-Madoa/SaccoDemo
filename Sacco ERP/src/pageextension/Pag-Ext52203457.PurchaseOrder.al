pageextension 52203457 "Purchase Order" extends "Purchase Order"
{
    layout
    {
        // Add changes to page layout here
        movebefore(Status; "Posting Description")
        moveafter("Buy-from Vendor Name"; "Shortcut Dimension 1 Code")
        moveafter("Shortcut Dimension 1 Code"; "Shortcut Dimension 2 Code")
        moveafter("Shortcut Dimension 2 Code"; "Responsibility Center")
        moveafter("Buy-from Vendor Name"; "Posting Description")
        modify("Posting Description")
        {
            Visible = true;
            ShowMandatory = true;
            Editable = Rec.Status = Rec.Status::Open;
        }
        modify("Assigned User ID")
        {
            Editable = false;
        }
        modify("No.")
        {
            Editable = false;
            Visible = true;

            trigger OnDrillDown()
            var
                Vendor: Record Vendor;
            begin
                Vendor.SetRange("Account Type", Vendor."Account Type"::Supplier);
                Page.Run(Page::"Vendor List", Vendor);
            end;

            trigger OnLookup(var Text: Text): Boolean
            var
                Vendor: Record Vendor;
            begin
                Vendor.SetRange("Account Type", Vendor."Account Type"::Supplier);
                Page.Run(Page::"Vendor List", Vendor);
            end;
        }
        modify("Buy-from Vendor Name")
        {
            Editable = false;
        }
        modify("Buy-from Address")
        {
            Editable = false;
        }
        modify("Buy-from Address 2")
        {
            Editable = false;
        }
        modify("Buy-from City")
        {
            Editable = false;
        }
        modify("Buy-from County")
        {
            Editable = false;
        }
        modify("Buy-from Post Code")
        {
            Editable = false;
        }
        modify("Buy-from Country/Region Code")
        {
            Editable = false;
        }
        modify("Vendor Order No.")
        {
            Editable = false;
        }
        modify("Vendor Shipment No.")
        {
            Editable = false;
            Visible = false;
        }
        modify("Buy-from Vendor No.")
        {
            Editable = Rec.Status = Rec.Status::Open;
        }
        modify("Buy-from Contact No.")
        {
            Editable = Rec.Status = Rec.Status::Open;
        }
        modify("Buy-from Contact")
        {
            Editable = Rec.Status = Rec.Status::Open;
        }
        modify("Document Date")
        {
            Editable = Rec.Status = Rec.Status::Open;
        }
        modify("Responsibility Center")
        {
            Editable = Rec.Status = Rec.Status::Open;
        }
        modify("Ship-to County")
        {
            Editable = Rec.Status = Rec.Status::Open;
        }
        modify("Expected Receipt Date")
        {
            Editable = Rec.Status = Rec.Status::Open;
        }
        modify("Prices Including VAT")
        {
            Editable = Rec.Status = Rec.Status::Open;
        }
        modify("VAT Bus. Posting Group")
        {
            Editable = Rec.Status = Rec.Status::Open;
        }
        modify("Payment Terms Code")
        {
            Editable = Rec.Status = Rec.Status::Open;
        }
        modify("Payment Discount %")
        {
            Editable = Rec.Status = Rec.Status::Open;
        }
        modify("Shipment Method Code")
        {
            Editable = Rec.Status = Rec.Status::Open;
        }
        modify("Payment Reference")
        {
            Editable = Rec.Status = Rec.Status::Open;
        }
        modify("Creditor No.")
        {
            Editable = Rec.Status = Rec.Status::Open;
        }
        modify("On Hold")
        {
            Editable = Rec.Status = Rec.Status::Open;
        }
        modify("Requested Receipt Date")
        {
            Editable = Rec.Status = Rec.Status::Open;
        }
        modify("Promised Receipt Date")
        {
            Editable = Rec.Status = Rec.Status::Open;
        }
        modify("Currency Code")
        {
            Editable = Rec.Status = Rec.Status::Open;
        }
        addafter(Status)
        {
            field("Order Type"; Rec."Order Type")
            {
                ApplicationArea = Basic, Suite;
                //ShowMandatory = true;
                Visible = false;
            }
            field("Purchase Order Status"; Rec."Purchase Order Status")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                Visible = false;
            }
        }
        addafter("Responsibility Center")
        {
            field("Cost Center"; Rec."Cost Center")
            {
                ApplicationArea = Basic, Suite;
                Editable = Rec.Status = Rec.Status::Open;
            }
        }
        addafter("Due Date")
        {
            field("Requisition No"; Rec."Requisition No")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
            }
        }
        addafter("Posting Description")
        {
            field("Raised By"; Rec."Raised By")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
            }
            field(Inspected; Rec.Inspected)
            {
                ApplicationArea = Basic, Suite;
            }
        }
        addbefore(Status)
        {
            field("Last Date Modified"; Rec."Last Date Modified")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
            }
        }
        //SubForm
        /*modify(PurchLines)
        {
            Editable = Rec.Status = Rec.Status::Open;
        }*/
        //FactboxesArea
        addfirst(factboxes)
        {
            part("Approval Entries"; "Customize Approval Entries")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Approval Entries';
                SubPageLink = "Table ID" = CONST(38), "Document Type" = filter(Order), "Document No." = FIELD("No.");
            }
        }
    }
    actions
    {
        // Add changes to page actions here
        modify("&Print")
        {
            visible = false;
        }
        modify(CancelApprovalRequest)
        {
            Visible = false;
        }
        addafter(CancelApprovalRequest)
        {
            action(CancelApprovalRequest_Ext)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Cancel Approval Request';
                Image = CancelApprovalRequest;
                Promoted = true;
                PromotedCategory = Category9;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Cancel the approval request..';
                Enabled = Rec.Status = Rec.Status::"Pending Approval";

                trigger OnAction()
                var
                    WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
                    ApprovalsMgt: Codeunit "Approvals Mgmt.";
                begin
                    Rec.TestField("Raised by", UserId);
                    Rec.TestField(Status, Rec.Status::"Pending Approval");
                    if Confirm(StrSubstNo(Text002, Rec."No."), false) then begin
                        ApprovalsMgt.OnCancelPurchaseApprovalRequest(Rec);
                        CurrPage.Close();
                        WorkflowWebhookMgt.FindAndCancel(Rec.RecordId);
                        CurrPage.Update(true);
                    end
                    else begin
                        exit;
                    end;
                end;
            }
        }
        modify(Approvals)
        {
            Visible = false;
        }
        addafter(CancelApprovalRequest_Ext)
        {
            action(Approvals_Ext)
            {
                ApplicationArea = Suite;
                Caption = 'Approvals';
                Image = Approvals;
                Promoted = true;
                PromotedCategory = Category9;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    ApprovalsMgmt.OpenApprovalEntriesPage(Rec.RecordId);
                end;
            }
        }
        modify(Approve)
        {
            Visible = false;
        }
        addafter(Approve)
        {
            action(Approve_Ext)
            {
                ApplicationArea = Suite;
                Caption = 'Approve';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Approve the requested changes.';
                Visible = OpenApprovalEntriesExistForCurrUser;

                trigger OnAction()
                var
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    IF CONFIRM(StrSubstNo(Text000, Rec."No."), false) = true then begin
                        ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
                        Message('Purchase Order Approved');
                        CurrPage.Update(true);
                    end
                    else begin
                        exit;
                    end;
                end;
            }
        }
        modify(Reject)
        {
            Visible = false;
        }
        addafter(Reject)
        {
            action(Reject_Ext)
            {
                ApplicationArea = Suite;
                Caption = 'Reject';
                Image = Reject;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Reject the requested changes.';
                Visible = OpenApprovalEntriesExistForCurrUser;

                trigger OnAction()
                var
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    ApprovalMgmt_Ext: Codeunit "Approval Mgmt. Ext";
                begin
                    if Confirm(StrSubstNo(Text001, Rec."No."), false) = true then begin
                        ApprovalsMgmt.RejectRecordApprovalRequest(Rec.RecordId);
                        Message('Purchase Order Rejected');
                        CurrPage.Update(true);
                    end
                    else begin
                        exit;
                    end;
                end;
            }
        }
        addbefore(Post)
        {
            action(Commit)
            {
                ApplicationArea = Basic, Suite;
                Image = Apply;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Enabled = not Rec.Committed and not Rec.Invoice;

                trigger OnAction()
                begin
                    BudgetMngt.CommitPO(Rec."No.");
                end;
            }
            action(UnCommit)
            {
                ApplicationArea = Basic, Suite;
                Image = UnApply;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Enabled = Rec.Committed and not Rec.Invoice;

                trigger OnAction()
                begin
                    BudgetMngt.UnCommitPO(Rec."No.");
                end;
            }
        }
        modify(SendApprovalRequest)
        {
            trigger OnBeforeAction()
            begin
                //Rec.Testfield("Vendor Invoice No.");
                // BudgetMngt.ConfirmBudgetAvailabilityPO(Rec);        
                // if not Rec.DocumentAttachmentsCheck then
                //     Error('Please capture the Posting Description before sending for approval.');
                //IB: 3rd Jan 2022, Check Purchase Lines with Gen. Bus. Posting Group or  Gen. Prod. Posting Group
                PurchLines.Reset();
                PurchLines.SetRange("Document No.", Rec."No.");
                PurchLines.SetRange("Document Type", PurchLines."Document Type"::Order);
                PurchLines.SetRange(Type, PurchLines.Type::"G/L Account");
                if PurchLines.FindSet() then
                    repeat
                        Rec.Testfield("Gen. Bus. Posting Group");
                        if (PurchLines."Gen. Prod. Posting Group" = '') then Error('The Gen. Prod Posting Group cannot be blank for purchase line %1 with G/L account no. %2.', PurchLines."Line No.", PurchLines."No.");
                    until PurchLines.Next() = 0;
            end;
        }
        modify(Post)
        {
            trigger OnBeforeAction()
            begin
                Rec.TestField(Inspected);
                Lines.Reset();
                Lines.SetRange("Document Type", Rec."Document Type");
                Lines.SetRange("Document No.", Rec."No.");
                if Lines.FindSet() then begin
                    repeat
                        Lines.Validate("Shortcut Dimension 1 Code");
                        Lines.Validate("Shortcut Dimension 2 Code");
                        if Lines."Qty. to Receive" = 0 then Lines."Qty. to Receive" := Lines.Quantity;
                        Lines.Validate("Qty. to Receive");
                        Lines.Modify();
                    until Lines.Next() = 0;
                end;
                Commit();
            end;

            trigger OnAfterAction()
            begin
                //Update Fixed Asset with Vendor
                FixedAssetVendor();
            end;
        }
        modify(Preview)
        {
            trigger OnBeforeAction()
            begin
                Rec.TestField(Inspected);
                Lines.Reset();
                Lines.SetRange("Document Type", Rec."Document Type");
                Lines.SetRange("Document No.", Rec."No.");
                if Lines.FindSet() then begin
                    repeat
                        Lines.Validate("Shortcut Dimension 1 Code");
                        Lines.Validate("Shortcut Dimension 2 Code");
                        if Lines."Qty. to Receive" = 0 then Lines."Qty. to Receive" := Lines.Quantity;
                        Lines.Validate("Qty. to Receive");
                        Lines.Modify();
                    until Lines.Next() = 0;
                end;
                Commit();
            end;
        }
        modify("Post and &Print")
        {
            trigger OnBeforeAction()
            begin
                Rec.TestField(Inspected);
                Lines.Reset();
                Lines.SetRange("Document Type", Rec."Document Type");
                Lines.SetRange("Document No.", Rec."No.");
                if Lines.FindSet() then begin
                    repeat
                        Lines.Validate("Shortcut Dimension 1 Code");
                        Lines.Validate("Shortcut Dimension 2 Code");
                        if Lines."Qty. to Receive" = 0 then Lines."Qty. to Receive" := Lines.Quantity;
                        Lines.Validate("Qty. to Receive");
                        Lines.Modify();
                    until Lines.Next() = 0;
                end;
                Commit();
            end;
        }
        addafter("&Print")
        {
            action("Print LPO")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Print';
                Image = Print;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.Reset();
                    Rec.SetRange("No.", Rec."No.");
                    Report.Run(Report::"Purchase Order", true, false, Rec);
                end;
            }
            action("View Requisition")
            {
                ApplicationArea = Basic, Suite;
                Image = Purchasing;
                Promoted = true;
                PromotedCategory = Category10;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Requisition.RESET;
                    Requisition.SETRANGE("No.", Rec."Requisition No");
                    PAGE.RUN(50234, Requisition);
                end;
            }
        }
        addafter("View Requisition")
        {
            action("Send for confirmation")
            {
                ApplicationArea = Basic, Suite;
                Image = ElectronicDoc;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = false;

                trigger OnAction()
                begin
                    Rec.Reset();
                    Rec.SetRange("No.", Rec."No.");
                    Report.Run(50208, true, false, Rec);
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        SetControlAppearance;
    end;

    local procedure SetControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        OpenApprovalEntriesExistForCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
    end;

    local procedure FixedAssetVendor()
    var
        FAsset: Record "Fixed Asset";
    begin
        Lines.Reset();
        Lines.SetRange("Document Type", Rec."Document Type");
        Lines.SetRange("Document No.", Rec."No.");
        Lines.SetRange(Type, Lines.Type::"Fixed Asset");
        if Lines.FindSet() then begin
            repeat
                FAsset.Reset();
                FAsset.SetRange("No.", Lines."No.");
                if FAsset.FindSet() then FAsset."Vendor No." := Rec."Buy-from Vendor No.";
                FAsset.Modify(true);
            until Lines.Next() = 0;
        end;
    end;

    var
        OpenApprovalEntriesExistForCurrUser: Boolean;
        Requisition: Record "Requisition Header";
        Lines: Record "Purchase Line";
        BudgetMngt: Codeunit "Budget Management";
        Text000: Label 'Are you sure you want to approve the Purchase Order %1. Do you want to continue?';
        Text001: Label 'Are you sure you want to reject the Purchase Order %1. Do you want to continue?';
        Text002: Label 'Are you sure you want to cancel the Purchase Order %1. Do you want to continue?';
        PurchLines: Record "Purchase Line";
}
