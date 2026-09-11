page 52203583 "Procurement Plans"
{
    CardPageID = "Procurement Plan";
    PromotedActionCategories = 'New,Process,Report,Approval,Request Approval';
    RefreshOnActivate = true;
    Editable = false;
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Procurement Plans";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Code"; Rec."Employee Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Name"; Rec."Employee Name")
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
                field("Procurement Date"; Rec.Date)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Raised By"; Rec."Raised By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group("Request Approval")
            {
                Caption = 'Request Approval';
                Visible = NOT OpenApprovalEntriesExistForCurrUser;

                action(SendApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Send A&pproval Request';
                    //Enabled = NOT OpenApprovalEntriesExist AND CanRequestApprovalForFlow;
                    Enabled = Rec.Status = Rec.Status::Open;
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Request approval of the document.';

                    trigger OnAction()
                    begin
                        Rec.TestField("Raised by", UserId);
                        Rec.TestField(Status, Rec.Status::Open);
                        Lines.Reset;
                        Lines.SetRange("Document No", Rec."No.");
                        if Lines.FindSet then repeat Lines.TestField(Quantity);
                            //if (Lines."Global Dimension 1 Code" = '') then
                            //  Error('The Department Code can not be blank for procurement plan lines %1', Lines."Line No");
                            until Lines.Next = 0;
                        ApprovalsMgt.OnSendProcurePlanForApproval(Rec);
                        CurrPage.Close();
                    end;
                }
                action(CancelApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cancel Approval Re&quest';
                    Enabled = CanCancelApprovalForRecord OR CanCancelApprovalForFlow;
                    Image = CancelApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'Cancel the approval request.';

                    trigger OnAction()
                    var
                        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
                    begin
                        Rec.TestField("Raised by", UserId);
                        Rec.TestField(Status, Rec.Status::"Pending Approval");
                        if Confirm(StrSubstNo(Text002, Rec."No."), false)then begin
                            ApprovalsMgt.OnCancelProcurePlanApprovalRequest(Rec);
                            CurrPage.Close();
                            WorkflowWebhookMgt.FindAndCancel(Rec.RecordId);
                            CurrPage.Update(true);
                        //Message('Procurement Plan Cancelled.');
                        end
                        else
                        begin
                            exit;
                        end;
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
                        PromotedCategory = Category5;
                        ToolTip = 'View a list of the records that are waiting to be approved. For example, you can see who requested the record to be approved, when it was sent, and when it is due to be approved.';

                        trigger OnAction()
                        var
                            ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        begin
                            ApprovalsMgmt.OpenApprovalEntriesPage(Rec.RecordId);
                        end;
                    }
                }
            }
            group("Manual Approval")
            {
                Visible = NOT OpenApprovalEntriesExistForCurrUser;

                action(Reopen)
                {
                    ApplicationArea = Suite;
                    Caption = 'Re&open';
                    Image = ReOpen;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;

                    trigger OnAction()
                    begin
                        Rec.Validate(Status, Rec.Status::Open);
                        Rec.Modify(true);
                        Message('Procurement Plan Reopened.');
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
                    begin
                        IF CONFIRM(StrSubstNo(Text000, Rec."No."), false) = true then begin
                            ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
                            CurrPage.Update(true);
                            Message('Procurement Plan Approved.');
                        end
                        else
                        begin
                            exit;
                        end;
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
                        ApprovalComments: Record "Approval Comment Line";
                    begin
                        if Confirm(StrSubstNo(Text001, Rec."No."), false) = true then begin
                            ApprovalsMgmt.RejectRecordApprovalRequest(Rec.RecordId);
                            CurrPage.Update(true);
                            Message('Procurement Plan Rejected.');
                        end
                        else
                        begin
                            exit;
                        end;
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
                    begin
                        ApprovalsMgmt.DelegateRecordApprovalRequest(Rec.RecordId);
                        Message('Procurement Plan Delegate.');
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
        }
    }
    trigger OnInit()
    begin
        GeneratePO:=false;
        ItemLocationV:=false;
    end;
    trigger OnOpenPage()
    begin
        Rec.Status:=Rec.Status::Open;
    end;
    trigger OnAfterGetRecord()
    begin
        SetControlAppearance;
    end;
    local procedure SetControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
    begin
        OpenApprovalEntriesExistForCurrUser:=ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist:=ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord:=ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        WorkflowWebhookMgt.GetCanRequestAndCanCancel(Rec.RecordId, CanRequestApprovalForFlow, CanCancelApprovalForFlow);
    end;
    var ApprovalsMgt: Codeunit "Approval Mgmt. Ext";
    OpenApprovalEntriesExistForCurrUser: Boolean;
    OpenApprovalEntriesExist: Boolean;
    CanCancelApprovalForRecord: Boolean;
    CanRequestApprovalForFlow: Boolean;
    CanCancelApprovalForFlow: Boolean;
    GeneratePO: Boolean;
    ItemLocationV: Boolean;
    Lines: Record "Procurement Plan Lines";
    Text000: Label 'Are you sure you want to approve the Procurement Plan %1. Do you want to continue?';
    Text001: Label 'Are you sure you want to reject the Procurement Plan %1. Do you want to continue?';
    Text002: Label 'Are you sure you want to cancel the Procurement Plan %1. Do you want to continue?';
}
