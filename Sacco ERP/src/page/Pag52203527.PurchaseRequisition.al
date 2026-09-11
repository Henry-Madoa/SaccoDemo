page 52203527 "Purchase Requisition"
{
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments';
    PageType = Card;
    SourceTable = "Requisition Header";
    SourceTableView = WHERE("Requisition Type"=CONST("Purchase Requisition"));

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = Rec.Status = Rec.Status::Open;

                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    MultiLine = true;
                }
                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = PageEditability;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Current Budget"; Rec."Current Budget")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Procurement Method"; Rec."Procurement Method")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("No of Approvals"; Rec."No of Approvals")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Approvers; Rec.Approvers)
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnAssistEdit()
                    var
                        Entries: Record "Approval Entry";
                    begin
                        Entries.Reset();
                        Entries.SetRange("Table ID", 50200);
                        Entries.SetRange("Document No.", Rec."No.");
                        Entries.SetFilter(Status, '=%1', Entries.Status::Approved);
                        Page.RunModal(Page::"Custom Approval Entries", Entries);
                    end;
                }
                field("Raised by"; Rec."Raised by")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Requisition Date"; Rec."Requisition Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Needed By Date"; Rec."Needed By Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
            }
            part("Purch Requisition Lines"; "Purch Requisition Lines")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Requisition No"=FIELD("No.");
            }
        }
        area(factboxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attachments';
                SubPageLink = "Table ID"=CONST(Database::"Requisition Header"), "No."=FIELD("No.");
            }
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
            group("Request Approval")
            {
                Caption = 'Request Approval';

                action("Send Approval Request")
                {
                    ApplicationArea = Basic, Suite;
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedIsBig = true;
                    //Enabled = NOT OpenApprovalEntriesExist AND CanRequestApprovalForFlow;
                    PromotedCategory = Category7;

                    trigger OnAction()
                    begin
                        Rec.TestField(Description);
                        Rec.TestField("Current Budget");
                        Rec.TestField("Global Dimension 1 Code");
                        Rec.TestField("Procurement Method");
                        //if not Rec.DocumentAttachmentsCheck then Error(Rec.ValidatorResponse);
                        Lines.Reset;
                        Lines.SetRange("Requisition No", Rec."No.");
                        if Lines.FindSet then repeat if(Lines.Type = Lines.Type::Item) and (Lines.Description = '')then Error('The Item Status of the selected item cannot be inactive for requisition line %1', Lines."Line No");
                                Lines.TestField(Quantity);
                                if(Lines."Global Dimension 1 Code" = '')then Error('The Department Code cannot be blank for requisition line %1', Lines."Line No");
                            until Lines.Next = 0;
                        ApprovalsMgmtExt.OnSendRequisitionForApproval(Rec);
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
                        ApprovalsMgmtExt.OnCancelRequisitionApprovalRequest(Rec);
                        CurrPage.Close();
                        WorkflowWebhookMgt.FindAndCancel(Rec.RecordId);
                    end;
                }
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
            action(Print)
            {
                ApplicationArea = Basic, Suite;
                Image = "Report";
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Report;

                trigger OnAction()
                begin
                    Rec.Reset;
                    Rec.SetRange("No.", Rec."No.");
                    REPORT.Run(Report::"Purchase Requisition", true, false, Rec);
                end;
            }
            action("Copy From Other PR Details")
            {
                ApplicationArea = Basic, Suite;
                Image = CopyDocument;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = Rec.Status = Rec.Status::Open;

                trigger OnAction()
                begin
                    ProcurementManagement.CopyRequisitionDetails(Rec);
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
                    RunObject = Page "Approval Comments";
                    RunPageLink = "Document No."=FIELD("No.");
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.GetApprovalComment(Rec);
                    end;
                }
            }
            action(Reopen)
            {
                ApplicationArea = Suite;
                Caption = 'Re&open';
                Enabled = Rec.Status = Rec.Status::Approved;
                Image = ReOpen;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    Rec.Validate(Status, Rec.Status::Open);
                    Rec.Modify(true);
                end;
            }
            action("Append to Order")
            {
                ApplicationArea = Basic, Suite;
                Image = Add;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = false;

                trigger OnAction()
                begin
                    ProcurementManagement.AppendRequisitionToOrder(Rec);
                end;
            }
            action("Make Order")
            {
                ApplicationArea = Basic, Suite;
                Image = MakeOrder;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = false;

                trigger OnAction()
                begin
                    ProcurementManagement.GenerateOrderFromRequisition(Rec);
                end;
            }
            action("Cancel Requisition")
            {
                ApplicationArea = Basic, Suite;
                Image = Cancel;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = Rec.Status = Rec.Status::Approved;

                trigger OnAction()
                begin
                    if Confirm('Are you sure you want to Cancel this Requisition?', false) = true then begin
                        Rec."PR Closed":=true;
                        Rec."PR Closed By":=Rec."PR Closed By"::Rejection;
                        Rec."Closed By":=UserId;
                        Rec."Closed Date":=WorkDate;
                        Rec.Modify;
                        Lines.Reset;
                        Lines.SetRange("Requisition No", Rec."No.");
                        Lines.ModifyAll(Processed, true);
                    end;
                end;
            }
            action("Create Procurement Process")
            {
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                Visible = Rec.Status = Rec.Status::Approved;

                trigger OnAction()
                begin
                    Rec.TestField(Status, Rec.Status::Approved);
                    Rec.TestField("Process Initiated", false);
                    if not Confirm('Are you sure you want to start procurement process?')then exit;
                    ProcurementNo:=ProcurementManagement.InitiateProcurementProcess(Rec);
                    Message('Procurement No. [%1] has been created', ProcurementNo);
                    CurrPage.Close();
                end;
            }
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Requisition Type":=Rec."Requisition Type"::"Purchase Requisition";
    end;
    trigger OnAfterGetRecord()
    begin
        SetControlAppearance;
    end;
    var OpenApprovalEntriesExistForCurrUser: Boolean;
    OpenApprovalEntriesExist: Boolean;
    ProcurementManagement: Codeunit "Procurement Management";
    Lines: Record "Requisition Lines";
    ProcurementNo: Code[20];
    CanCancelApprovalForRecord: Boolean;
    CanRequestApprovalForFlow: Boolean;
    CanCancelApprovalForFlow: Boolean;
    ApprovalsMgmtExt: Codeunit "Approval Mgmt. Ext";
    UserSetup: Record "User Setup";
    LoginMgmt: Codeunit "User Management Ext";
    PageEditability: Boolean;
    local procedure SetControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
    begin
        OpenApprovalEntriesExistForCurrUser:=ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist:=ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord:=ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        WorkflowWebhookMgt.GetCanRequestAndCanCancel(Rec.RecordId, CanRequestApprovalForFlow, CanCancelApprovalForFlow);
        if not LoginMgmt.IsWebServiceUser then begin
            if not UserSetup.Get(UserId)then Error('Contact Admin for your account to be setup')
            else if not UserSetup."Procurement Admin" then PageEditability:=false
                else
                    PageEditability:=true;
        end
        else
            PageEditability:=true;
    end;
}
