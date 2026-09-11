pageextension 52203470 "Bank Acc. Reconciliation" extends "Bank Acc. Reconciliation"
{
    PromotedActionCategories = 'New,Process,Report,Bank,Matching,Posting,Workflow,Attachments';

    layout
    {
        // Add changes to page layout here  
        addafter(StatementEndingBalance)
        {
            field(Status; Rec.Status)
            {
                Editable = false;
            }
        }
        addafter(Control1905767507)
        {
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }
    actions
    {
        addafter("P&osting")
        {
            action(DocAttach)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attachments';
                Image = Attach;
                Promoted = true;
                PromotedCategory = Category8;
                ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';

                trigger OnAction()
                var
                    DocumentAttachmentDetails: Page "Document Attachment Details";
                    RecRef: RecordRef;
                begin
                    RecRef.GetTable(Rec);
                    DocumentAttachmentDetails.OpenForRecRef(RecRef);
                    DocumentAttachmentDetails.RunModal;
                end;
            }
            group("Approval Details")
            {
                Visible = NOT OpenApprovalEntriesExistForCurrUser;
                Caption = 'Approvals';

                action(Approvals)
                {
                    //AccessByPermission = TableData "Approval Entry" = R;
                    ApplicationArea = Suite;
                    Caption = 'Approvals';
                    Image = Approvals;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category7;
                    ToolTip = 'View a list of the records that are waiting to be approved. For example, you can see who requested the record to be approved, when it was sent, and when it is due to be approved.';

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.OpenApprovalEntriesPage(Rec.RecordId);
                    end;
                }
            }
            group(ActionGroup32)
            {
                Caption = 'Approvals';

                action("Send Approval Request")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Send A&pproval Request';
                    Enabled = NOT OpenApprovalEntriesExist AND CanRequestApprovalForFlow;
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category7;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Request approval of the document.';

                    trigger OnAction()
                    begin
                        Rec.Testfield(Status, Rec.Status::Open);
                        if not Confirm('Are you sure you want to send Statement No. %1 for Approval?', true, Rec."Statement No.") then
                            exit
                        else begin
                            ApprovalsMgmt.OnSendBankAccReconciliationForApproval(Rec);
                            CurrPage.Close();
                        end;
                    end;
                }
                action("Cancel Approval Request")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cancel Approval Re&quest';
                    Enabled = CanCancelApprovalForRecord OR CanCancelApprovalForFlow;
                    Image = CancelApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category7;
                    PromotedOnly = true;
                    ToolTip = 'Cancel the approval request.';

                    trigger OnAction()
                    begin
                        Rec.TestField(Status, Rec.Status::"Pending Approval");
                        if not Confirm('Are you sure you want to Cancel Approval Request for Statement No. %1?', true, Rec."Statement No.") then
                            exit
                        else begin
                            ApprovalsMgmt.OnCancelBankAccReconciliationApprovalRequest(Rec);
                            BankAccReconciliation.Reset;
                            BankAccReconciliation.SetRange("Bank Account No.", Rec."Bank Account No.");
                            BankAccReconciliation.SetRange("Statement No.", Rec."Statement No.");
                            if BankAccReconciliation.FindFirst then begin
                                BankAccReconciliation.Status := BankAccReconciliation.Status::Open;
                                BankAccReconciliation.Modify;
                                //
                                ApprovalEntry.Reset;
                                ApprovalEntry.SetRange("Document No.", BankAccReconciliation."Bank Account No.");
                                if ApprovalEntry.FindFirst then begin
                                    ApprovalEntry.DeleteAll;
                                end;
                            end;
                            Message('The document has been Succesfully Cancelled');
                        end;
                    end;
                }
            }
            group("Manual Approval")
            {
                Visible = NOT OpenApprovalEntriesExistForCurrUser;

                action("Re-Open")
                {
                    ApplicationArea = Basic, Suite;
                    Image = ReopenCancelled;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        Rec.Testfield(Status, Rec.Status::Approved);
                        if not Confirm('Are you sure you want to Re-Open this Reconciliation?', true) then exit;
                        BankAccReconciliation.Reset;
                        BankAccReconciliation.SetRange("Bank Account No.", Rec."Bank Account No.");
                        BankAccReconciliation.SetRange("Statement No.", Rec."Statement No.");
                        if BankAccReconciliation.FindFirst then begin
                            BankAccReconciliation.Status := BankAccReconciliation.Status::Open;
                            BankAccReconciliation.Modify;
                            //
                            ApprovalEntry.Reset;
                            ApprovalEntry.SetRange("Document No.", BankAccReconciliation."Bank Account No.");
                            ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Approved);
                            if ApprovalEntry.FindFirst then begin
                                ApprovalEntry.DeleteAll;
                            end;
                        end;
                        Message('Reconciliation Successfully Reopened');
                    end;
                }
                action("Approve Manually")
                {
                    ApplicationArea = Suite;
                    Image = Approve;
                    Promoted = true;
                    PromotedCategory = Category7;
                    PromotedOnly = true;

                    trigger OnAction()
                    begin
                        Rec.Validate(Status, Rec.Status::Approved);
                        Rec.Modify(true);
                    end;
                }
            }
            group(Approval)
            {
                Caption = 'Approval';

                action(Approve)
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
                        Text001: Label 'You are about to approve the document, Do you wish to continue';
                        Text002: Label 'You have approved the document';
                    begin
                        if Confirm(Text001, false) = true then begin
                            ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
                            Message(Text002);
                            CurrPage.Close();
                        end
                        else
                            exit;
                    end;
                }
                action(Reject)
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
                        Text001: Label 'You are about to Reject the document, Do you wish to continue';
                        Text002: Label 'You have rejected the document';
                    begin
                        if Confirm(Text001, false) = true then begin
                            ApprovalsMgmt.RejectRecordApprovalRequest(Rec.RecordId);
                            Message(Text002);
                            CurrPage.Close();
                        end
                        else
                            exit;
                    end;
                }
                action(Delegate)
                {
                    ApplicationArea = Suite;
                    Caption = 'Delegate';
                    Image = Delegate;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    ToolTip = 'Delegate the requested changes to the substitute approver.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        Text001: Label 'You are about to Delegate the document, Do you wish to continue';
                        Text002: Label 'You have delegated the document';
                    begin
                        if Confirm(Text001, false) = true then begin
                            ApprovalsMgmt.DelegateRecordApprovalRequest(Rec.RecordId);
                            Message(Text002);
                            CurrPage.Close();
                        end
                        else
                            exit;
                    end;
                }
                action(Comment)
                {
                    ApplicationArea = Suite;
                    Caption = 'Comments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    ToolTip = 'View or add comments for the record.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.GetApprovalComment(Rec);
                    end;
                }
            }
            action("Unreconciling Report")
            {
                ApplicationArea = Basic, Suite;
                Image = Print;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    BankAccReconciliation.Reset;
                    BankAccReconciliation.SetRange("Bank Account No.", Rec."Bank Account No.");
                    BankAccReconciliation.SetRange("Statement No.", Rec."Statement No.");
                    if BankAccReconciliation.FindFirst then REPORT.Run(Report::"Bank Rec-Unreconciling Entries", true, false, BankAccReconciliation);
                end;
            }
            action("Reconciling Report")
            {
                ApplicationArea = Basic, Suite;
                Image = PrintForm;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    BankAccReconciliation.Reset;
                    BankAccReconciliation.SetRange("Bank Account No.", Rec."Bank Account No.");
                    BankAccReconciliation.SetRange("Statement No.", Rec."Statement No.");
                    if BankAccReconciliation.FindFirst then REPORT.Run(Report::"Bank Rec-Reconciling Entries", true, false, BankAccReconciliation);
                end;
            }
        }
    }
    var
        ApprovalsMgmt: Codeunit "Approval Mgmt. Ext";
        ApprovalEntry: Record "Approval Entry";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        Postx: Boolean;
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesExist: Boolean;
        CanCancelApprovalForRecord: Boolean;
        CanRequestApprovalForFlow: Boolean;
        CanCancelApprovalForFlow: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        Post;
    end;

    trigger OnOpenPage()
    begin
        Post;
    end;

    local procedure Post()
    begin
        Postx := false;
        if Rec.Status = Rec.Status::Approved then Postx := true;
    end;

    local procedure SetControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
    begin
        OpenApprovalEntriesExistForCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        WorkflowWebhookMgt.GetCanRequestAndCanCancel(Rec.RecordId, CanRequestApprovalForFlow, CanCancelApprovalForFlow);
    end;
}
