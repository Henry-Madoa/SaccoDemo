page 52203479 "Imprest Request"
{
    PageType = Document;
    SourceTable = "Request Header";
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments,Navigate';
    SourceTableView = WHERE("Request Type"=CONST(Imprest));

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                Editable = Rec.Status = Rec.Status::Open;

                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
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
                field("Job Title"; Rec."Job Title")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Balance; Rec.Balance)
                {
                    ApplicationArea = Basic, Suite;
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
                field("Total Days in the Field"; Rec."Total Days in the Field")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    MultiLine = true;
                }
                field("Total ITO Cost"; Rec."Total Requested Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Pending Approvals Ext"; Rec."Pending Approvals Ext")
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnAssistEdit()
                    var
                        Entries: Record "Approval Entry";
                    begin
                        Entries.Reset();
                        Entries.SetRange("Table ID", Database::"Request Header");
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
                        Entries.SetRange("Table ID", Database::"Request Header");
                        Entries.SetRange("Document No.", Rec."No.");
                        Entries.SetFilter(Status, '=%1', Entries.Status::Approved);
                        Page.RunModal(Page::"Custom Approval Entries", Entries);
                    end;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Request Posted"; Rec.Posted)
                {
                    ApplicationArea = Basic, Suite;
                    Visible = Rec.Posted;
                }
                field("Request Posted By"; Rec."Posted By")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = Rec.Posted;
                }
                field("Request Posted Date"; Rec."Posted Date")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = Rec.Posted;
                }
            }
            group("Payment Details")
            {
                Visible = Rec.Status = Rec.Status::Approved;

                //Editable = PageEditability;
                field("Pay Mode"; Rec."Pay Mode")
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate()
                    begin
                        PayModeEditability;
                    end;
                }
                field("Paying Bank Code"; Rec."Paying Bank Code")
                {
                    ApplicationArea = Basic, Suite;
                //Editable = PaymentDetailsEditability;
                }
                field("Payment Tx No.(Cheque No.)"; Rec."Payment Tx No.(Cheque No.)")
                {
                    ApplicationArea = Basic, Suite;
                //Editable = PaymentDetailsEditability;
                }
                field("Cheque Date"; Rec."Cheque Date")
                {
                    ApplicationArea = Basic, Suite;
                //Editable = PaymentDetailsEditability;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                //Editable = PaymentDetailsEditability;
                }
            }
            part(Control14; "Imprest Request Details")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No."=FIELD("No.");
                UpdatePropagation = Both;
            }
        }
        area(factboxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attachments';
                SubPageLink = "Table ID"=CONST(Database::"Request Header"), "No."=FIELD("No.");
            }
            part(Control27; "Pending Approval FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Table ID"=CONST(Database::"Request Header"), "Document No."=FIELD("No.");
                Visible = OpenApprovalEntriesExistForCurrUser;
            }
            part("Approval Entries"; "Customize Approval Entries")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Approval Entries';
                SubPageLink = "Table ID"=CONST(Database::"Request Header"), "Document No."=FIELD("No.");
            }
            systempart(Control13; Notes)
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(Navigate)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Find entries...';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Category9;
                ShortCutKey = 'Shift+Ctrl+I';
                ToolTip = 'Find entries and documents that exist for the document number and posting date on the selected document. (Formerly this action was named Navigate.)';
                Visible = not IsOfficeAddin and Rec.Posted;

                trigger OnAction()
                begin
                    Rec.Navigate;
                end;
            }
        }
        area(Reporting)
        {
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
                    REPORT.Run(Report::"Imprest Request Form", true, false, Rec);
                end;
            }
            action("Imprest Request Summary")
            {
                ApplicationArea = Basic, Suite;
                Image = "Report";
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Report;
                RunObject = report "Imprest Request Summary";
            }
        }
        area(processing)
        {
            action(Commit)
            {
                ApplicationArea = Basic, Suite;
                Image = Lock;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = ((not Rec.Committed) and (not Rec.Posted));

                trigger OnAction()
                begin
                    BudgetMgt.CommitImprest(Rec."No.");
                end;
            }
            action("Check for Cash Availability")
            {
                ApplicationArea = Basic, Suite;
                Image = CheckLedger;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = ((Rec.Status = Rec.Status::Approved) and (Rec.Posted = false));

                trigger OnAction()
                begin
                    ImprestMgt.CheckForCashAvailability(Rec);
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
            action("Issue Cash")
            {
                ApplicationArea = Basic, Suite;
                Image = Post;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = ((Rec.Status = Rec.Status::Approved) and (Rec.Posted = false));

                trigger OnAction()
                begin
                    if Rec."Pay Mode" = 'EFT' then Error('You cannot post an EFT Transaction')
                    else
                    begin
                        ImprestMgt.PostImprestRequest(Rec);
                        CommunicationsMgmt.NotificationOnImprestDisbursement(Rec);
                    //Commitments."Process UnCommitment Entry"("No.",'ITO','');
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
            group("Manual Approval")
            {
                Visible = NOT OpenApprovalEntriesExistForCurrUser;

                action(Reopen)
                {
                    ApplicationArea = Suite;
                    Caption = 'Re&open';
                    Enabled = ((Rec.Status = Rec.Status::Approved) and (Rec.Posted = false));
                    Image = ReOpen;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;

                    trigger OnAction()
                    begin
                        Rec.Validate(Status, Rec.Status::Open);
                        Rec.Modify(true);
                        CurrPage.Close;
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
                        Rec.TestField(Status, Rec.Status::Open);
                        Rec.TestField("Total Days in the Field");
                        //TestField(Description);
                        Rec.RequestedAmountValidator;
                        if Rec.AttachmentValidator()then ApprovalsMgt.OnSendRequestHeaderForApproval(Rec)
                        else
                            Error(Rec.AttachmentValidatorResponse);
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
                        ApprovalsMgt.OnCancelRequestHeaderApprovalRequest(Rec);
                        CurrPage.Close();
                        WorkflowWebhookMgt.FindAndCancel(Rec.RecordId);
                    end;
                }
            }
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Request Type":=Rec."Request Type"::Imprest;
        Rec.Status:=Rec.Status::Open;
    end;
    trigger OnAfterGetRecord()
    begin
        SetControlAppearance;
        PayModeEditability;
    end;
    trigger OnOpenPage()
    begin
        PayModeEditability;
        SetControlAppearance;
    end;
    trigger OnInit()
    begin
        PayModeEditability;
    end;
    local procedure PayModeEditability()
    begin
        if Rec."Pay Mode" = 'EFT' then EFTEditable:=false
        else
            EFTEditable:=true;
        if PaymentMethod.Get(Rec."Pay Mode")then;
        //if PaymentMethod.Type = PaymentMethod.Type::FOSA then
        if Rec.Status = Rec.Status::Approved then PaymentDetailsEditability:=false
        else
            PaymentDetailsEditability:=true;
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
        if not LoginMgmt.IsWebServiceUser then begin
            if not UserSetup.Get(UserId)then Error('Contact Admin for your account to be setup')
            else if not UserSetup."Finance Admin" then PageEditability:=false
                else
                    PageEditability:=true;
        end
        else
            PageEditability:=true;
        IsOfficeAddin:=OfficeMgt.IsAvailable;
    end;
    var ImprestMgt: Codeunit "Imprest Management";
    CommunicationsMgmt: Codeunit "Communications Mgmt";
    ApprovalsMgt: Codeunit "Approval Mgmt. Ext";
    OpenApprovalEntriesExistForCurrUser: Boolean;
    OpenApprovalEntriesExist: Boolean;
    CanCancelApprovalForRecord: Boolean;
    CanRequestApprovalForFlow: Boolean;
    CanCancelApprovalForFlow: Boolean;
    EFTEditable: Boolean;
    BudgetMgt: Codeunit "Budget Management";
    PaymentMethod: Record "Payment Method";
    PaymentDetailsEditability: Boolean;
    PageEditability: Boolean;
    LoginMgmt: Codeunit "User Management Ext";
    UserSetup: Record "User Setup";
    IsOfficeAddin: Boolean;
    OfficeMgt: Codeunit "Office Management";
}
