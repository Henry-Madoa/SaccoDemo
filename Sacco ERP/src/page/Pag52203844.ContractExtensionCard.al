page 52203844 "Contract Extension Card"
{
    ApplicationArea = All;
    PageType = Card;
    SourceTable = "Contract Extension";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Extension No"; Rec."Extension No")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Contract No."; Rec."Contract No.")
                {
                    ApplicationArea = All;
                }
                field("Contract Title"; Rec."Contract Title")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Initial End Date"; Rec."Initial End Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Initial Period"; Rec."Initial Period")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Extension Period"; Rec."Extension Period")
                {
                    ApplicationArea = All;
                }
                field("New End Date"; Rec."New End Date")
                {
                    ApplicationArea = All;
                }
            }
            part(Control11; "Contract Extension SubForm")
            {
                ApplicationArea = All;
                SubPageLink = "Extension No"=FIELD("Extension No");
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Send Approval Request")
            {
                ApplicationArea = All;
                Image = SendApprovalRequest;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Status, Rec.Status::Open);
                    ContractExtensionMilestone.Reset;
                    ContractExtensionMilestone.SetRange("Extension No", Rec."Extension No");
                    ContractExtensionMilestone.SetFilter("New End Date", '<>%1', 0D);
                    if not ContractExtensionMilestone.FindFirst then begin
                        Error('Atleast one milestone should be afffected');
                    end;
                    ContractExtensionMilestone.Reset;
                    ContractExtensionMilestone.SetRange("Extension No", Rec."Extension No");
                    ContractExtensionMilestone.SetFilter("New End Date", '<>%1', 0D);
                    ContractExtensionMilestone.SetFilter("Reason For Extension", '=%1', '');
                    if ContractExtensionMilestone.FindFirst then Error('Reason for extension should have a value for milestone [%1]', ContractExtensionMilestone."Milestone Description");
                    if Format(Rec."Extension Period") = '' then Error('Extension Period should have a value');
                    if not Confirm('Are you sure you want to send it for approval?')then exit;
                    //           if ApprovalsMgmt.CheckContractExtensionApprovalsWorkflowEnabled(Rec) then
                    //             ApprovalsMgmt.OnSendContractExtensionForApproval(Rec);
                    CurrPage.Close();
                end;
            }
            action("Cancel Approval Request")
            {
                ApplicationArea = All;
                Image = CancelApprovalRequest;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Status, Rec.Status::"Pending Approval");
                    if not Confirm('Are you sure you want to cancel approval request?')then exit;
                    //           if ApprovalsMgmt.CheckContractExtensionApprovalsWorkflowEnabled(Rec) then
                    //             ApprovalsMgmt.OnCancelContractExtensionApprovalRequest(Rec);
                    CurrPage.Close();
                end;
            }
            action(Approve)
            {
                ApplicationArea = All;
                Caption = 'Approve';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                ToolTip = 'Approve the requested changes.';
                Visible = OpenApprovalEntriesExistCurrUser;

                trigger OnAction()
                var
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    if not Confirm('Are you sure you want to Approve the document?')then exit;
                    //            ApprovalsMgmt.ApproveRecordApprovalRequest(RecordId);
                    CurrPage.Close();
                end;
            }
            action(Reject)
            {
                ApplicationArea = All;
                Caption = 'Reject';
                Image = Reject;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                ToolTip = 'Reject the approval request.';
                Visible = OpenApprovalEntriesExistCurrUser;

                trigger OnAction()
                var
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    if not Confirm('Are you sure you want to Reject the document?')then exit;
                    //            ApprovalsMgmt.RejectRecordApprovalRequest(RecordId);
                    CurrPage.Close;
                end;
            }
            action(Delegate)
            {
                ApplicationArea = All;
                Caption = 'Delegate';
                Image = Delegate;
                Promoted = true;
                PromotedCategory = Category4;
                ToolTip = 'Delegate the approval to a substitute approver.';
                Visible = OpenApprovalEntriesExistCurrUser;

                trigger OnAction()
                var
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    if not Confirm('Are you sure you want to Approve the document?')then exit;
                    //            ApprovalsMgmt.DelegateRecordApprovalRequest(RecordId);
                    CurrPage.Close();
                end;
            }
            action(Comment)
            {
                ApplicationArea = All;
                Caption = 'Comments';
                Image = ViewComments;
                Promoted = true;
                PromotedCategory = Category4;
                ToolTip = 'View or add comments for the record.';

                trigger OnAction()
                var
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    ApprovalsMgmt.GetApprovalComment(Rec);
                end;
            }
            action(Attachments)
            {
                Image = Documents;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
            // RunObject = Page "Requisition Attachements";
            // RunPageLink = "Document No" = FIELD("No. Series");
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        SetControlAppearance();
    end;
    trigger OnOpenPage()
    begin
        SetControlAppearance();
    end;
    var ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    OpenApprovalEntriesExistCurrUser: Boolean;
    OpenApprovalEntriesExist: Boolean;
    //     IanSoftFactory: Codeunit IanSoftFactory;
    ContractExtensionMilestone: Record "Contract Extension Milestone";
    local procedure SetControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    //        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
    begin
    //        OpenApprovalEntriesExistCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(RecordId);
    //        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(RecordId);
    end;
}
