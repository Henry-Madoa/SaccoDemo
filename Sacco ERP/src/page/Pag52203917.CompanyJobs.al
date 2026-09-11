page 52203917 "Company Jobs"
{
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments,Navigate';
    CardPageID = "Company Job";
    PageType = List;
    ApplicationArea = All;
    Editable = false;
    UsageCategory = Lists;
    SourceTable = "Company Jobs";

    layout
    {
        area(content)
        {
            repeater(Control5)
            {
                ShowCaption = false;

                field("Job ID"; Rec."Job ID")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Profession; Rec.Profession)
                {
                    ApplicationArea = All;
                }
                field("No of Posts"; Rec."No of Posts")
                {
                    ApplicationArea = All;
                }
                field("Vacant Posistions"; Rec."Vacant Posistions")
                {
                    ApplicationArea = All;
                }
                field("Occupied Position"; Rec."Occupied Position")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
        }
        area(processing)
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
            group("Request Approval")
            {
                Caption = 'Request Approval';
                Visible = NOT OpenApprovalEntriesExistForCurrUser;

                action(SendApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Send A&pproval Request';
                    Visible = Rec.Status = Rec.Status::Open;
                    Enabled = NOT OpenApprovalEntriesExist AND CanRequestApprovalForFlow;
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category7;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Request approval of the document.';

                    trigger OnAction()
                    begin
                        ApprovalsMgt.OnSendHrJobsForApproval(Rec)end;
                }
                action(CancelApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cancel Approval Re&quest';
                    Visible = Rec.Status = Rec.Status::"Pending Approval";
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
                        Rec.TestField(Status, Rec.Status::"Pending Approval");
                        ApprovalsMgt.OnCancelHrJobsApprovalRequest(Rec);
                        WorkflowWebhookMgt.FindAndCancel(Rec.RecordId);
                        CurrPage.Close;
                    end;
                }
                group("Manual Approval")
                {
                    Visible = NOT OpenApprovalEntriesExistForCurrUser;

                    action(Reopen)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Re&open';
                        Enabled = ((Rec.Status = Rec.Status::Approved));
                        Image = ReOpen;
                        Promoted = true;
                        PromotedCategory = Category5;
                        PromotedOnly = true;

                        trigger OnAction()
                        var
                            ReleaseCustomDocuments: Codeunit "Release Custom Documents";
                        begin
                            //ReleaseCustomDocuments.PerformManualReopenPV(Rec);
                            CurrPage.Close();
                        end;
                    }
                    action(Release)
                    {
                        ApplicationArea = Suite;
                        Enabled = Rec.Status = Rec.Status::Open;
                        Image = ReleaseDoc;
                        Promoted = true;
                        PromotedCategory = Category5;
                        PromotedOnly = true;

                        trigger OnAction()
                        var
                            ReleaseCustomDocuments: Codeunit "Release Custom Documents";
                        begin
                            //ReleaseCustomDocuments.PerformManualReleasePV(Rec);
                            CurrPage.Close();
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
    trigger OnInit()
    begin
        SalaryAdvanced:=false;
        ShowEFT:=false;
        ShowMpesa:=false;
    end;
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.Status:=Rec.Status::Open;
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
        IsOfficeAddin:=OfficeMgt.IsAvailable;
    end;
    var ApprovalsMgt: Codeunit "Approval Mgmt. Ext";
    OpenApprovalEntriesExistForCurrUser: Boolean;
    OpenApprovalEntriesExist: Boolean;
    CanCancelApprovalForRecord: Boolean;
    CanRequestApprovalForFlow: Boolean;
    CanCancelApprovalForFlow: Boolean;
    SalaryAdvanced: Boolean;
    ShowEFT: Boolean;
    ShowMpesa: Boolean;
    OfficeMgt: Codeunit "Office Management";
    IsOfficeAddin: Boolean;
}
