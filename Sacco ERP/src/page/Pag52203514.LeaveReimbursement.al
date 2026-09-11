page 52203514 "Leave Reimbursement"
{
    PageType = Card;
    SourceTable = "Leave Applications";
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments';
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = ApprovalLevelEditable;

                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("<Global Dimension 1 Code>"; Rec."Global Dimension 1 Code")
                {
                    Caption = 'Global Dimension 1 Code';
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Application Date"; Rec."Application Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Leave Code"; Rec."Leave Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Leave Type Decription"; Rec."Leave Type Decription")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Days Droped"; Rec."Days Droped")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Days To Reimburse"; Rec."Days To Reimburse")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Leave balance"; Rec."Leave balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Balance After"; Rec."Balance After")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Comments; Rec.Comments)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("E-Mail Address"; Rec."E-Mail Address")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Grade; Rec.Grade)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Approval Entries"; Rec."Approval Entries")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
            }
        }
        area(factboxes)
        {
            part(Control30; "Leave Statistics")
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "No."=FIELD("Employee No");
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(Post)
            {
                ApplicationArea = Basic, Suite;
                Image = PostingEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = (not Rec.Posted and (Rec.Status = Rec.Status::Approved));

                trigger OnAction()
                var
                    HumanResourceMgt: Codeunit "Human Resource Management";
                begin
                    if Rec.Status = Rec.Status::Approved then begin
                        HumanResourceMgt.PostLeaveAfterApproval(Rec);
                    end;
                end;
            }
            action("Send Approval Request")
            {
                ApplicationArea = Basic, Suite;
                Image = SendApprovalRequest;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                Visible = ControlSendApprovalActionVisibility;

                trigger OnAction()
                begin
                    Rec.TestField(Status, Rec.Status::Open);
                    Rec.TestField(Posted, false);
                    Rec.TestField(Comments);
                    Rec.TestField("Phone No.");
                    Rec.TestField("E-Mail Address");
                    if not Confirm('Are you sure you want to send leave reimbursement for approval?')then exit
                    else
                    begin
                        ApprovalsMgmtExt.OnSendLeaveForApproval(Rec);
                        CurrPage.Close();
                    end;
                end;
            }
            action("Cancel Approval Request")
            {
                ApplicationArea = Basic, Suite;
                Image = CancelApprovalRequest;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                Visible = ControlCancelApprovalActionVisibility;

                trigger OnAction()
                begin
                    Rec.TestField(Posted, false);
                    if not Confirm('Are you sure you want to cancel Approval request?')then exit
                    else
                    begin
                        ApprovalsMgmtExt.OnCancelLeaveApprovalRequest(Rec);
                        CurrPage.Close();
                    end;
                end;
            }
            action(Approve)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Approve';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                ToolTip = 'Approve the requested changes.';
                Visible = OpenApprovalEntriesExistForCurrUser;

                trigger OnAction()
                var
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    if not Confirm('Are you sure you want to Approve the document?')then exit;
                    ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
                    CurrPage.Close();
                end;
            }
            action(Reject)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Reject';
                Image = Reject;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                ToolTip = 'Reject the approval request.';
                Visible = OpenApprovalEntriesExistForCurrUser;

                trigger OnAction()
                var
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    if not Confirm('Are you sure you want to Reject the document?')then exit;
                    ApprovalsMgmt.RejectRecordApprovalRequest(Rec.RecordId);
                    CurrPage.Close;
                end;
            }
            action(Delegate)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Delegate';
                Image = Delegate;
                Promoted = true;
                PromotedCategory = Category4;
                ToolTip = 'Delegate the approval to a substitute approver.';
                Visible = OpenApprovalEntriesExistForCurrUser;

                trigger OnAction()
                var
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    if not Confirm('Are you sure you want to Approve the document?')then exit;
                    ApprovalsMgmt.DelegateRecordApprovalRequest(Rec.RecordId);
                    CurrPage.Close();
                end;
            }
            action(Comment)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Comments';
                Image = ViewComments;
                Promoted = true;
                PromotedCategory = Category4;
                ToolTip = 'View or add comments for the record.';
                Visible = OpenApprovalEntriesExistForCurrUser;

                trigger OnAction()
                var
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    ApprovalsMgmt.GetApprovalComment(Rec);
                end;
            }
            action(Attachments)
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
        }
    }
    trigger OnAfterGetRecord()
    begin
        ControlAppearance();
    end;
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Nature of Application":=Rec."Nature of Application"::"Leave Reimbursement";
    end;
    trigger OnOpenPage()
    begin
        ControlAppearance();
    end;
    var Employee: Record Employee;
    DocumentType: Option " ", "Purchase Requisition", "Transfer Order", Imprest, Surrender, "Fleet Request", "Payment Voucher", "Bank Transfer", SAF, "Service Order", GRV, GIV, Appraisal, Leave, Safari, "Store Requisition", Claim, GRN;
    LeaveTypes: Record "Leave Types";
    LeaveEntries: Record "Leave Ledger Entries";
    LineNO: Integer;
    ApprovalsMgmtExt: Codeunit "Approval Mgmt. Ext";
    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    ApprovalLevelEditable: Boolean;
    ControlCancelApprovalActionVisibility: Boolean;
    ControlSendApprovalActionVisibility: Boolean;
    OpenApprovalEntriesExistForCurrUser: Boolean;
    OpenApprovalEntriesExist: Boolean;
    CanCancelApprovalForRecord: Boolean;
    local procedure ControlAppearance()
    begin
        ApprovalLevelEditable:=true;
        ControlCancelApprovalActionVisibility:=false;
        ControlSendApprovalActionVisibility:=false;
        if not(Rec.Status in[Rec.Status::Open])then begin
            ApprovalLevelEditable:=false;
            ControlSendApprovalActionVisibility:=false;
        end;
        if Rec.Status in[Rec.Status::Open]then begin
            ControlSendApprovalActionVisibility:=true;
            ControlCancelApprovalActionVisibility:=false;
        end;
        if Rec.Status in[Rec.Status::"Pending Approval"]then begin
            ControlSendApprovalActionVisibility:=false;
            ControlCancelApprovalActionVisibility:=true;
        end;
        OpenApprovalEntriesExistForCurrUser:=ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist:=ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord:=ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
    end;
    local procedure SetControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
    begin
        OpenApprovalEntriesExistForCurrUser:=ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist:=ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
    end;
}
