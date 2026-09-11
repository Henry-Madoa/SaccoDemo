page 52203486 "Leave Recall"
{
    PageType = Card;
    SourceTable = "Leave Recall";
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Recall No"; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Leave No.To Recall"; Rec."Leave No.To Recall")
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
                    Editable = false;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Days Applied"; Rec."Days Applied")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Days To Recall"; Rec."Days To Recall")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Leave balance"; Rec."Leave balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Total No Of Days"; Rec."Total No Of Days")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Holidays; Rec.Holidays)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Weekend Days"; Rec."Weekend Days")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Days; Rec.Days)
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field("Balance After"; Rec."Balance After")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Return Date"; Rec."Return Date")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field("Reporting Date"; Rec."Reporting Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Leave Status"; Rec."Leave Status")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Comments; Rec.Comments)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Supervisor Code"; Rec."Supervisor Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Reliever; Rec.Reliever)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Reliever Name"; Rec."Reliever Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Posted; Rec.Posted)
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
            action("Send Approval Request")
            {
                ApplicationArea = Basic, Suite;
                Image = SendApprovalRequest;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                Enabled = NOT OpenApprovalEntriesExist AND CanRequestApprovalForFlow;

                trigger OnAction()
                begin
                    Rec.TestField("Days To Recall");
                    Rec.TestField(Status, Rec.Status::Open);
                    if not Confirm('Are you sure you want to send leave application for approval?')then exit
                    else
                    begin
                        ApprovalsMgmtExt.OnSendLeaveRecallForApproval(Rec);
                        CurrPage.Close();
                    end;
                end;
            }
            action("Cancel Approval Request")
            {
                ApplicationArea = Basic, Suite;
                Image = Cancel;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                Enabled = CanCancelApprovalForRecord OR CanCancelApprovalForFlow;

                trigger OnAction()
                begin
                    Rec.TestField(Status, Rec.Status::"Pending Approval");
                    if not Confirm('Are you sure you want to Reopen leave application?')then exit
                    else
                    begin
                        ApprovalsMgmtExt.OnCancelLeaveRecallApprovalRequest(Rec);
                        CurrPage.Close();
                    end;
                end;
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
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
    //"Application Type" := "Application Type"::"1";
    end;
    trigger OnAfterGetRecord()
    begin
        SetControlAppearance();
    end;
    trigger OnOpenPage()
    begin
        SetControlAppearance();
    end;
    var Employee: Record Employee;
    LeaveTypes: Record "Leave Types";
    LeaveEntries: Record "Leave Ledger Entries";
    LineNO: Integer;
    OpenApprovalEntriesExistForCurrUser: Boolean;
    OpenApprovalEntriesExist: Boolean;
    CanCancelApprovalForRecord: Boolean;
    CanRequestApprovalForFlow: Boolean;
    CanCancelApprovalForFlow: Boolean;
    HumanResourceMgmt: Codeunit "Human Resource Management";
    ApprovalEntry: Record "Approval Entry";
    ApprovalsMgmtExt: Codeunit "Approval Mgmt. Ext";
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
}
