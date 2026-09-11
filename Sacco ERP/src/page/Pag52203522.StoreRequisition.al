page 52203522 "Store Requisition"
{
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments,Navigate';
    PageType = Card;
    SourceTable = "Requisition Header";
    SourceTableView = WHERE("Requisition Type"=FILTER("Store Requisition"));

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = ((PageEditable) and (Rec.Status = Rec.Status::Open));

                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Employee Code"; Rec."Employee No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Requisition Date"; Rec."Requisition Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
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
                        Entries.SetRange("Table ID", Database::"Requisition Header");
                        Entries.SetRange("Document No.", Rec."No.");
                        Entries.SetFilter(Status, '=%1', Entries.Status::Approved);
                        Page.RunModal(Page::"Custom Approval Entries", Entries);
                    end;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Raised by"; Rec."Raised by")
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
                    Visible = false;
                }
                field("Store Req. Qty. Issued"; Rec."Store Req. Qty. Issued")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Visible = false;
                }
            }
            group("Requisition Details")
            {
                Editable = Rec.Status = Rec.Status::Open;

                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    MultiLine = true;
                    ShowMandatory = true;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part(Control16; "Store Requisition Lines")
            {
                ApplicationArea = Basic, Suite;
                Editable = ((Rec.Status = Rec.Status::Open) or (Rec.Status = Rec.Status::"Pending Approval") or (Rec.Status = Rec.Status::Approved));
                SubPageLink = "Requisition No"=FIELD("No.");
            }
        }
        area(factboxes)
        {
            part("Approval Entries"; "Customize Approval Entries")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Approval Entries';
                SubPageLink = "Table ID"=CONST(Database::"Requisition Header"), "Document No."=FIELD("No.");
            }
            systempart(Control15; Notes)
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(Issue)
            {
                ApplicationArea = Basic, Suite;
                Image = ResetStatus;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = Rec.Status = Rec.Status::Approved;

                trigger OnAction()
                begin
                    if Confirm(StrSubstNo(Text000, Rec."Employee Name"), false) = true then begin
                        StoresMgt.IssueStoreItems(Rec);
                        CurrPage.Update(true);
                    end
                    else
                    begin
                        exit;
                    end;
                end;
            }
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
                    Enabled = NOT OpenApprovalEntriesExist AND CanRequestApprovalForFlow;
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category7;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Request approval of the document.';

                    trigger OnAction()
                    begin
                        ApprovalsMgt.OnSendRequisitionForApproval(Rec);
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
                    PromotedCategory = Category7;
                    PromotedOnly = true;
                    ToolTip = 'Cancel the approval request.';

                    trigger OnAction()
                    var
                        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
                    begin
                        Rec.TestField(Status, Rec.Status::"Pending Approval");
                        ApprovalsMgt.OnCancelRequisitionApprovalRequest(Rec);
                        CurrPage.Close();
                        WorkflowWebhookMgt.FindAndCancel(Rec.RecordId);
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
            action(Print)
            {
                ApplicationArea = Suite;
                Caption = 'Print';
                Image = PrintReport;
                Promoted = true;
                PromotedCategory = Report;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    Rec.Reset();
                    Rec.SetRange("No.", Rec."No.");
                    Report.Run(Report::"Store Requisition", true, false, Rec);
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        SetControlAppearance;
        RequisitionHeader.Reset;
        RequisitionHeader.SetRange("No.", Rec."No.");
        if RequisitionHeader.FindFirst then begin
            RequisitionHeader.CalcFields("Store Req. Qty. Issued");
            RequisitionHeader.CalcFields("Store Req. Qty. Approved");
            if(RequisitionHeader."Store Req. Qty. Issued" = RequisitionHeader."Store Req. Qty. Approved") and (RequisitionHeader."Store Req. Qty. Approved" <> 0) and (RequisitionHeader."Store Req. Qty. Issued" <> 0)then begin
                RequisitionHeader.Status:=RequisitionHeader.Status::Archived;
                RequisitionHeader.Issued:=true;
                RequisitionHeader.Modify;
            end;
        end;
    end;
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Requisition Type":=Rec."Requisition Type"::"Store Requisition";
    end;
    trigger OnOpenPage()
    begin
        SetControlAppearance;
        if not LoginMgmt.IsWebServiceUser then begin
            if not UserSetup.Get(UserId)then Error('Contact Admin for your account to be setup')
            else if not UserSetup."Procurement Admin" then PageEditable:=false
                else
                    PageEditable:=true;
        end;
    end;
    var StoresMgt: Codeunit "Stores Management";
    Text000: Label 'You are about to issue the store items to %1. Do you wish to continue?';
    RequisitionHeader: Record "Requisition Header";
    PageEditable: Boolean;
    UserSetup: Record "User Setup";
    LoginMgmt: Codeunit "User Management Ext";
    ApprovalsMgt: Codeunit "Approval Mgmt. Ext";
    OpenApprovalEntriesExistForCurrUser: Boolean;
    OpenApprovalEntriesExist: Boolean;
    CanCancelApprovalForRecord: Boolean;
    CanRequestApprovalForFlow: Boolean;
    CanCancelApprovalForFlow: Boolean;
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
