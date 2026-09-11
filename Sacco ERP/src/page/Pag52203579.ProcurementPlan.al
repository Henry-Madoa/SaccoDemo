page 52203579 "Procurement Plan"
{
    DeleteAllowed = false;
    Caption = 'Procurement Plan';
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Procurement Plans";
    PromotedActionCategories = 'New,Process,Report,Approval,Request Approval,Attachments';
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Editable = (Rec.Status = Rec.Status::Open);

                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Employee Code"; Rec."Employee Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Global Dimension 3 Code"; Rec."Global Dimension 3 Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Procurement Date"; Rec.Date)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    //ShowMandatory = true;
                    Importance = Promoted;
                }
                field("Raised By"; Rec."Raised By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Pending Approvals"; Rec."Pending Approvals")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;

                    trigger OnAssistEdit()
                    var
                        Entries: Record "Approval Entry";
                    begin
                        Entries.Reset();
                        Entries.SetRange("Table ID", 50931);
                        Entries.SetRange("Document No.", Rec."No.");
                        Entries.SetFilter(Status, '%1|%2', Entries.Status::Open, Entries.Status::Created);
                        Page.RunModal(Page::"Custom Approval Entries", Entries);
                    end;
                }
                field(Approvers; Rec.Approvers)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;

                    trigger OnAssistEdit()
                    var
                        Entries: Record "Approval Entry";
                    begin
                        Entries.Reset();
                        Entries.SetRange("Table ID", 50931);
                        Entries.SetRange("Document No.", Rec."No.");
                        Entries.SetFilter(Status, '=%1', Entries.Status::Approved);
                        Page.RunModal(Page::"Custom Approval Entries", Entries);
                    end;
                }
                field(status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
            }
            part(Control4; "Procurement Plan Lines")
            {
                Editable = Rec.Status = Rec.Status::Open;
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "Document No"=FIELD("No.");
            }
        }
        area(factboxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attachments';
                SubPageLink = "Table ID"=CONST(50931), "No."=FIELD("No.");
            }
            part("Approval Entries"; "Customize Approval Entries")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Approval Entries';
                SubPageLink = "Table ID"=CONST(50931), "Document No."=FIELD("No.");
            }
            systempart(Control1; Notes)
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
    actions
    {
        area(Reporting)
        {
            action(Print)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                Image = Print;

                trigger OnAction()
                begin
                    Rec.Reset;
                    Rec.SetRange("No.", Rec."No.");
                    Report.Run(Report::"Procurement Plan", true, false, Rec);
                end;
            }
        }
        area(Processing)
        {
            action("Clear Details")
            {
                ApplicationArea = Basic, Suite;
                Visible = Rec.Status = Rec.Status::Open;
                Caption = 'Clear Details';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = ClearLog;

                trigger OnAction()
                begin
                    Rec.TestField("Raised by", UserId);
                    ProcurementList.Reset;
                    ProcurementList.Setrange("Document No", Rec."No.");
                    ProcurementList.DeleteAll;
                    Message('Details Cleared');
                end;
            }
            action(Post)
            {
                ApplicationArea = Basic, Suite;
                Visible = ((Rec.Status = Rec.Status::Approved) and (not Rec.Posted));
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Post;

                trigger OnAction()
                begin
                    ProcurementManagement.UpdateItemBudgetEntries(Rec);
                    Message('Plan Mergered');
                    CurrPage.Close();
                end;
            }
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
                                Lines.TestField(Date);
                            // if (Lines."Global Dimension 1 Code" = '') then
                            //   Error('The Department Code can not be blank for procurement plan lines %1', Lines."Line No");
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
                        if Rec.Modify(true)then begin
                            ApprovalEntry.Reset();
                            ApprovalEntry.SetRange("Document No.", Rec."No.");
                            if ApprovalEntry.FindSet()then begin
                                ApprovalEntry.DeleteAll();
                                Message('Procurement Plan Reopened.');
                            end;
                        end;
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
    trigger OnOpenPage()
    begin
        Rec.Status:=Rec.Status::Open;
    end;
    trigger OnNewRecord(BelowxRec: Boolean)
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
    var ProcurementPlan: Record "Procurement Plans";
    ProcurementList: Record "Procurement Plan Lines";
    NoSeriesMgt: Codeunit NoSeriesManagement;
    ApprovalsMgt: Codeunit "Approval Mgmt. Ext";
    ProcurementManagement: Codeunit "Procurement Management";
    OpenApprovalEntriesExistForCurrUser: Boolean;
    OpenApprovalEntriesExist: Boolean;
    CanCancelApprovalForRecord: Boolean;
    CanRequestApprovalForFlow: Boolean;
    CanCancelApprovalForFlow: Boolean;
    Lines: Record "Procurement Plan Lines";
    ApprovalEntry: Record "Approval Entry";
    Text000: Label 'Are you sure you want to approve the Procurement Plan %1. Do you want to continue?';
    Text001: Label 'Are you sure you want to reject the Procurement Plan %1. Do you want to continue?';
    Text002: Label 'Are you sure you want to cancel the Procurement Plan %1. Do you want to continue?';
}
