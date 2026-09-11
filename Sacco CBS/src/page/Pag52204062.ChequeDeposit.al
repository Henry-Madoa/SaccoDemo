page 52204062 "Cheque Deposit"
{
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments,Navigate';
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Cheque Deposits";
    SourceTableView = where("Document Type" = const(Deposit));

    layout
    {
        area(Content)
        {
            group(General)
            {
                Editable = Rec.Status = Rec.Status::Open;

                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Cheque Type"; Rec."Cheque Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Deposit Date"; Rec."Deposit Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Maturity Period"; Rec."Maturity Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Maturity Date"; Rec."Maturity Date")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Receiving Details")
            {
                Editable = Rec.Status = Rec.Status::Open;

                field("Member No"; Rec."Member No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Cheque Details")
            {
                Editable = Rec.Status = Rec.Status::Open;

                field("Cheque No"; Rec."Cheque No")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field("Cheque Date"; Rec."Cheque Date")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field("Express Cheque"; Rec."Express Cheque")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                group(ExpressCheque)
                {
                    ShowCaption = false;
                    Visible = Rec."Express Cheque";

                    field("Express Amount"; Rec."Express Amount")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                }
                field("Total Clearing Charges"; Rec."Total Clearing Charges")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Instructions Amount"; Rec."Instructions Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Clearing Account No."; Rec."Clearing Account No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Drawer Account Name"; Rec."Drawer Account Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Drawer Bank"; Rec."Drawer Bank")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Drawer Account No."; Rec."Drawer Account No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Drawer Branch"; Rec."Drawer Branch")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part("Cheque Instructions"; "Cheque Instructions")
            {
                Editable = Rec.Status = Rec.Status::Open;
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "Document No" = field("No.");
            }
            group("Audit Trail")
            {
                Editable = false;

                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Cleared By"; Rec."Cleared By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Clearance Date"; Rec."Clearance Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Processed; Rec.Processed)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Processed Date"; Rec."Processed Date")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
        area(FactBoxes)
        {
            part("Member Statistics"; "Member Statistics")
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "No." = field("Member No");
            }
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(Database::"Cheque Deposits"), "No." = FIELD("No.");
            }
            part(Control27; "Pending Approval FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Table ID" = CONST(Database::"Cheque Deposits"), "Document No." = FIELD("No.");
                Visible = OpenApprovalEntriesExistForCurrUser;
            }
            part("Approval Entries"; "Customize Approval Entries")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Approval Entries';
                SubPageLink = "Table ID" = CONST(Database::"Cheque Deposits"), "Document No." = FIELD("No.");
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
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
                Visible = Rec.Status <> Rec.Status::Open;

                trigger OnAction()
                begin
                    Rec.Reset;
                    Rec.SetRange("No.", Rec."No.");
                    if Rec.Findset then Report.Run(Report::"Cheque Deposit Slip", false, false, Rec);
                end;
            }
        }
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
                Visible = not IsOfficeAddin and Rec.Processed;

                trigger OnAction()
                begin
                    Rec.Navigate;
                end;
            }
        }
        area(Processing)
        {
            group("Request Approval")
            {
                Caption = 'Request Approval';
                Visible = NOT OpenApprovalEntriesExistForCurrUser;

                action(Submit)
                {
                    ApplicationArea = Basic, Suite;
                    Visible = ((Rec.Status = Rec.Status::Open) and (not Rec."In-House") and (not Rec."Express Cheque"));
                    Image = Approve;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Request approval of the document.';
                    AboutTitle = 'Approval Request';
                    AboutText = 'Send the Application for Approval before creation of the Accounts by clicking **Send Approval Request**';

                    trigger OnAction();
                    begin
                        Rec.OnBeforeSendForApproval;
                        Rec.Status := Rec.Status::Approved;
                        Rec.Modify(true);
                        CurrPage.Close();
                    end;
                }
                action("Send Approval Request")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Send A&pproval Request';
                    Visible = ((Rec.Status = Rec.Status::Open) and (Rec."In-House" or Rec."Express Cheque"));
                    Enabled = NOT OpenApprovalEntriesExist AND CanRequestApprovalForFlow;
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category7;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Request approval of the document.';
                    AboutTitle = 'Approval Request';
                    AboutText = 'Send the Application for Approval before creation of the Accounts by clicking **Send Approval Request**';

                    trigger OnAction();
                    begin
                        Rec.OnBeforeSendForApproval;
                        ApprovalsMgmtExt.OnSendChequeDepositForApproval(Rec);
                        CurrPage.Close();
                    end;
                }
                action("Cancel Approval Request")
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
                    AboutTitle = 'Cancel Approval Request';
                    AboutText = 'Incase of Corrections recall the document by clicking **Cancel Approval Request**';

                    trigger OnAction();
                    begin
                        ApprovalsMgmtExt.OnCancelChequeDepositForApproval(Rec);
                        CurrPage.Close();
                    end;
                }
                action(Reopen)
                {
                    ApplicationArea = Suite;
                    Caption = 'Re&open';
                    Enabled = ((Rec.Status = Rec.Status::Approved) and (Rec.Processed = false));
                    Image = ReOpen;
                    Promoted = true;
                    PromotedCategory = Category7;
                    PromotedOnly = true;

                    trigger OnAction()
                    begin
                        if Confirm(StrSubstNo('You are about to Re-Open %1\\Do you wish to continue?', Rec."No.")) then begin
                            Rec.Validate(Status, Rec.Status::Open);
                            Rec.Modify(true);
                            CurrPage.Close;
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
            action("Clear Cheque")
            {
                ApplicationArea = Basic, Suite;
                Image = Post;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = ((Rec.Status = Rec.Status::Approved) and (not Rec."Express Cheque"));

                trigger OnAction()
                begin
                    IF Confirm(StrSubstNo('You are about to Clear Cheque %1, Do you wish to continue?', Rec."Cheque No")) then begin
                        FosaManagement.PostCheque(Rec, PostingType::Clear);
                        CurrPage.Close;
                    end;
                end;
            }
            action("Clear Express Cheque")
            {
                ApplicationArea = Basic, Suite;
                Image = Post;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = ((Rec.Status = Rec.Status::Approved) and (Rec."Express Cheque"));

                trigger OnAction()
                begin
                    IF Confirm(StrSubstNo('You are about to Clear Express Cheque %1, Do you wish to continue?', Rec."Cheque No")) then begin
                        FosaManagement.PostCheque(Rec, PostingType::Express);
                        CurrPage.Close;
                    end;
                end;
            }
            action("&Reopen")
            {
                ApplicationArea = Basic, Suite;
                Image = ReOpen;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = Rec.Status = Rec.Status::Cleared;

                trigger OnAction()
                begin
                    IF confirm(StrSubstNo('You are about to Reopen Cheque Deposit No %1, Do you wish to continue?', Rec."No.")) then begin
                        FosaManagement.PostCheque(Rec, PostingType::Reopen);
                        CurrPage.Close;
                    end;
                end;
            }
            action(Bounce)
            {
                ApplicationArea = Basic, Suite;
                Image = CancelAllLines;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = Rec.Status = Rec.Status::Approved;

                trigger OnAction()
                begin
                    IF confirm(StrSubstNo('You are about to Bounce Cheque %1, Do you wish to continue?', Rec."Cheque No")) then begin
                        FosaManagement.PostCheque(Rec, PostingType::Bounce);
                        CurrPage.Close;
                    end;
                end;
            }
            action(Archive)
            {
                ApplicationArea = Basic, Suite;
                Image = VoidAllChecks;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = Rec.Status = Rec.Status::Approved;

                trigger OnAction()
                begin
                    IF Confirm(StrSubstNo('You are about to Archive Cheque Deposit No. %1, Do you wish to continue?', Rec."No.")) then begin
                        FosaManagement.PostCheque(Rec, PostingType::Archive);
                    end;
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        SetControlAppearance;
    end;

    trigger OnAfterGetRecord()
    begin
        SetControlAppearance;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetControlAppearance;
    end;

    local procedure SetControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
    begin
        OpenApprovalEntriesExistForCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        WorkflowWebhookMgt.GetCanRequestAndCanCancel(Rec.RecordId, CanRequestApprovalForFlow, CanCancelApprovalForFlow);
        IsOfficeAddin := OfficeMgt.IsAvailable;
    end;

    var
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesExist: Boolean;
        CanCancelApprovalForRecord: Boolean;
        CanRequestApprovalForFlow: Boolean;
        CanCancelApprovalForFlow: Boolean;
        OfficeMgt: Codeunit "Office Management";
        IsOfficeAddin: Boolean;
        ApprovalsMgmtExt: Codeunit "Approval Mgmt. CBS Ext";
        FosaManagement: Codeunit "FOSA Management";
        PostingType: Option Clear,Express,Bounce,Reopen,Archive;
}
