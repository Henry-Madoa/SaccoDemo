pageextension 52203445 "Purchase Invoice" extends "Purchase Invoice"
{
    layout
    {
        // Add changes to page layout here
        movebefore(Status; "Posting Description")
        modify("Buy-from Vendor Name")
        {
            Editable = false;
        }
        modify("Posting Description")
        {
            Visible = true;
            ShowMandatory = true;
        }
        modify("No.")
        {
            Editable = false;
            Visible = true;
        }
        addafter(Status)
        {
            field("Medical Claim"; Rec."Medical Claim")
            {
                ApplicationArea = All;
            }
            group(Medical_Br)
            {
                ShowCaption = false;
                Visible = Rec."Medical Claim";

                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = All;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = All;
                }
            }
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
        //FactboxesArea
        addfirst(factboxes)
        {
            part("Approval Entries"; "Customize Approval Entries")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Approval Entries';
                SubPageLink = "Table ID" = CONST(38), "Document Type" = filter(Invoice), "Document No." = FIELD("No.");
            }
        }
    }
    actions
    {
        // Add changes to page actions here
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
                        Message('Purchase Invoice Approved');
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
                        Message('Purchase Invoice Rejected');
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
            action("Validate Costs")
            {
                ApplicationArea = Basic, Suite;
                Image = ValidateEmailLoggingSetup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Lines.Reset();
                    Lines.SetRange("Document Type", Rec."Document Type");
                    Lines.SetRange("Document No.", Rec."No.");
                    if Lines.FindSet() then begin
                        repeat
                            Lines.Validate("Direct Unit Cost");
                            Lines.Modify(true);
                        until Lines.Next() = 0;
                    end;
                    Message('Complete');
                end;
            }
            action("Validate Dimensions")
            {
                ApplicationArea = Basic, Suite;
                Image = ChangeDimensions;
                Promoted = true;
                PromotedCategory = Process;
                Visible = false;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Lines.Reset();
                    Lines.SetRange("Document Type", Rec."Document Type");
                    Lines.SetRange("Document No.", Rec."No.");
                    if Lines.FindSet() then begin
                        repeat
                            Lines.Validate("Shortcut Dimension 1 Code");
                            Lines.Validate("Shortcut Dimension 2 Code");
                            Lines.Validate("Shortcut Dimension 3 Code");
                            Lines.Modify(true);
                        until Lines.Next() = 0;
                    end;
                    Message('Complete');
                end;
            }
        }
        modify(SendApprovalRequest)
        {
            trigger OnBeforeAction()
            begin
                Rec.Testfield("Vendor Invoice No.");
                BudgetMngt.ConfirmBudgetAvailabilityPO(Rec);
                if not Rec.DocumentAttachmentsCheck then If StrPos(Rec."Posting Description", Rec."No.") <> 0 then Error('Please capture the Posting Description before sending for approval.');
            end;
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

    var
        OpenApprovalEntriesExistForCurrUser: Boolean;
        Requisition: Record "Requisition Header";
        Lines: Record "Purchase Line";
        BudgetMngt: Codeunit "Budget Management";
        Selection: Integer;
        SharedCostString: Label 'Calculate, Import';
        Text000: Label 'Are you sure you want to approve the Purchase Invoice %1. Do you want to continue?';
        Text001: Label 'Are you sure you want to reject the Purchase Invoice %1. Do you want to continue?';
        Text002: Label 'Are you sure you want to cancel the Purchase Invoice %1. Do you want to continue?';
}
