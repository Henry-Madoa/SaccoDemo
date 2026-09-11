page 52203931 "Job Requisitions"
{
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments,Navigate';
    CardPageID = "Job Requisition";
    Editable = false;
    ModifyAllowed = false;
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Job Requisition";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Job ID"; Rec."Job ID")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Profession; Rec.Profession)
                {
                    ApplicationArea = All;
                }
                field(Objective; Rec.Objective)
                {
                    ApplicationArea = All;
                }
                field(Date; Rec.Date)
                {
                    ApplicationArea = All;
                }
                field(Priority; Rec.Priority)
                {
                    ApplicationArea = All;
                }
                field(Positions; Rec.Positions)
                {
                    ApplicationArea = All;
                }
                field(Approved; Rec.Approved)
                {
                    ApplicationArea = All;
                }
                field("Date Approved"; Rec."Date Approved")
                {
                    ApplicationArea = All;
                }
                field("Advertisement Type"; Rec."Advertisement Type")
                {
                    ApplicationArea = All;
                }
                field("Advertisement Status"; Rec."Advertisement Status")
                {
                    ApplicationArea = All;
                }
                field("Advertisement Date"; Rec."Advertisement Date")
                {
                    ApplicationArea = All;
                }
                field("Advertisement Close Date"; Rec."Advertisement Close Date")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID"=CONST(Database::"Job Requisition"), "No."=FIELD("No.");
            }
            part(Control27; "Pending Approval FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Table ID"=CONST(Database::"Job Requisition"), "Document No."=FIELD("No.");
                Visible = OpenApprovalEntriesExistForCurrUser;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("&Requirements")
            {
                ApplicationArea = All;
                Image = AbsenceCategory;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Job Requirements";
                RunPageLink = "Job Id"=field("Job ID");
            }
            action("&Responsibilities")
            {
                ApplicationArea = All;
                Image = Responsibility;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "&Job Responsibilities";
                RunPageLink = "Job Id"=field("Job ID");
            }
            action("&Competencies")
            {
                ApplicationArea = All;
                Image = CompleteLine;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Job Compitencies";
                RunPageLink = "Job Id"=field("Job ID");
            }
            action("&Professional Certificates")
            {
                ApplicationArea = All;
                Image = JobListSetup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Job Professional Certs";
                RunPageLink = "Job Id"=field("Job ID");
            }
            action("&Professional Bodies")
            {
                ApplicationArea = All;
                Image = BOM;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Job Professional Bodies";
                RunPageLink = "Job Id"=field("Job ID");
            }
            action(DocAttach)
            {
                ApplicationArea = All;
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
            group("Request Approval")
            {
                Caption = 'Request Approval';
                Visible = NOT OpenApprovalEntriesExistForCurrUser;

                action(SendApprovalRequest)
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
                        ApprovalsMgt.OnSendJobRequisitionForApproval(Rec);
                    end;
                }
                action(CancelApprovalRequest)
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
                    var
                        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
                    begin
                        Rec.TestField(Rec.Status, Rec.Status::"Pending Approval");
                        ApprovalsMgt.OnCancelJobRequisitionApprovalRequest(Rec);
                        CurrPage.Close();
                        WorkflowWebhookMgt.FindAndCancel(Rec.RecordId);
                    end;
                }
                group("Manual Approval")
                {
                    Visible = NOT OpenApprovalEntriesExistForCurrUser;

                    action(Reopen)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Re&open';
                        Enabled = Rec.Status = Rec.Status::Approved;
                        Image = ReOpen;
                        Promoted = true;
                        PromotedCategory = Category7;
                        PromotedOnly = true;

                        trigger OnAction()
                        begin
                            Rec.Status:=Rec.Status::Approved;
                            Rec.Approved:=true;
                            Rec.Validate(Approved);
                            Rec.Modify;
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
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        SetControlAppearance;
    end;
    trigger OnAfterGetCurrRecord()
    begin
        SetControlAppearance;
    end;
    trigger OnOpenPage()
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
    var OpenApprovalEntriesExistForCurrUser: Boolean;
    OpenApprovalEntriesExist: Boolean;
    CanCancelApprovalForRecord: Boolean;
    CanRequestApprovalForFlow: Boolean;
    CanCancelApprovalForFlow: Boolean;
    ApprovalsMgt: Codeunit "Approval Mgmt. Ext";
}
