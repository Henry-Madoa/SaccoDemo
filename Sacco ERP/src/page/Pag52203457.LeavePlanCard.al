page 52203457 "Leave Plan Card"
{
    PageType = Document;
    SourceTable = "Leave Plan";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Plan No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = true;
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
                field("Global Dimension 1 Name"; Rec."Global Dimension 1 Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Global Dimension 2 Name"; Rec."Global Dimension 2 Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Leave Calender Code"; Rec."Leave Calendar Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Leave Calendar Description"; Rec."Leave Calendar Description")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Leave Calendar Start Date"; Rec."Leave Calendar Start Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Leave Calendar End Date"; Rec."Leave Calendar End Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
            }
            part(Control15; "Leave Plan Subform")
            {
                ApplicationArea = Basic, Suite;
                Editable = PageEditable;
                SubPageLink = "Plan No."=FIELD("No.");
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
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Status, Rec.Status::Open);
                    if not Confirm('Are you sure you want to send Leave plan ' + Format(Rec."No.") + ' for approval?')then exit
                    else
                    begin
                        ApprovalsMgmt.OnSendLeavePlanForApproval(Rec);
                        CurrPage.Close();
                    end;
                end;
            }
            action("Cancel Approval Request")
            {
                ApplicationArea = Basic, Suite;
                Image = CancelApprovalRequest;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Status, Rec.Status::"Pending Approval");
                    if not Confirm('Are you sure you want to send Leave plan ' + Format(Rec."No.") + ' for approval?')then exit
                    else
                    begin
                        ApprovalsMgmt.OnCancelLeavePlanApprovalRequest(Rec);
                        CurrPage.Close();
                    end;
                end;
            }
            action(Approve)
            {
                ApplicationArea = Basic, Suite;

                ;
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

                ;
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

                ;
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

                ;
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
        }
    }
    trigger OnOpenPage()
    begin
        SetControlAppearance;
    end;
    var ApprovalsMgmt: Codeunit "Approval Mgmt. Ext";
    OpenApprovalEntriesExist: Boolean;
    OpenApprovalEntriesExistForCurrUser: Boolean;
    PageEditable: Boolean;
    local procedure SetControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
    begin
        OpenApprovalEntriesExistForCurrUser:=ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist:=ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        if(Rec.Status in[Rec.Status::Approved]) and (not DetermineIfHod(Rec."Global Dimension 1 Code"))then PageEditable:=false
        else
            PageEditable:=true;
    end;
    local procedure DetermineIfHod(DepartmentCode: Code[50]): Boolean var
        UserSetup: Record "User Setup";
        Employee: Record Employee;
    begin
        if UserSetup.Get(UserId)then begin
            if UserSetup."Head of Department" = DepartmentCode then exit(true)
            else
                exit(false);
        end
        else
            exit(false);
    end;
}
