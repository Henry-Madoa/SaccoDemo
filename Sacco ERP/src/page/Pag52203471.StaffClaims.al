page 52203471 "Staff Claims"
{
    Caption = 'Staff Claims';
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments,Navigate';
    RefreshOnActivate = true;
    CardPageID = "Staff Claim";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;
    Editable = true;
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Request Header";
    SourceTableView = WHERE("Request Type"=CONST("Staff Claim"));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = Basic, Suite;
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
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Total Surrender Amount"; Rec."Total Surrender Amount")
                {
                    Caption = 'Total Claim';
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Date; Rec.Date)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Claim Pay Mode"; Rec."Claim Pay Mode")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Claim Paying Account"; Rec."Claim Paying Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Claim Payment Tx No"; Rec."Claim Payment Tx No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = true;
                }
                field("Claim Posted"; Rec."Claim Posted")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Claim Posted By"; Rec."Claim Posted By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Claim Posted Date"; Rec."Claim Posted Date")
                {
                    ApplicationArea = Basic, Suite;
                }
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
                    REPORT.Run(Report::"Staff Claim Voucher", true, false, Rec);
                end;
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
                Visible = ((not Rec.Committed) and (not Rec."Claim Posted"));

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
                Visible = ((Rec.Status = Rec.Status::Approved) and (Rec."Claim Posted" = false));

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
            action("Post Payment")
            {
                ApplicationArea = Basic, Suite;
                Image = Post;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = ((Rec.Status = Rec.Status::Approved) and (Rec."Claim Posted" = false));

                trigger OnAction()
                begin
                    if Rec."Claim Pay Mode" = 'EFT' then begin
                        if DIALOG.Confirm('This transaction is an eft transaction, Are you sure its before implementation of EFT') <> true then begin
                            Error('You cannot post EFT Transactions from here');
                        end;
                    end
                    else
                        ImprestMgt.PostStaffClaim(Rec, false);
                end;
            }
            action("Stop Payment")
            {
                ApplicationArea = Basic, Suite;
                Image = Close;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = ((Rec.Status = Rec.Status::Approved) and (Rec."Claim Posted" = false));

                trigger OnAction()
                begin
                    if Confirm('You are about to close this Staff Claim Voucher, Be aware that you wont be able to recover this Voucher!', false) = true then begin
                        Rec.Posted:=true;
                        Rec."Posted By":=UserId;
                        Rec."Posted Date":=WorkDate;
                        Rec."Request Type":=Rec."Request Type"::Surrender;
                        Rec."Surrender Date":=WorkDate;
                        Rec.Surrendered:=true;
                        Rec."Surrender Posted By":=UserId;
                        Rec."Surrender Posted Date":=WorkDate;
                        Rec.Status:=Rec.Status::Closed;
                        Rec."Claim Posted":=true;
                        Rec."Claim Posted By":=UserId;
                        Rec."Claim Posted Date":=WorkDate;
                        Rec.Modify;
                        Message('Voucher Closed.');
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
                    Enabled = ((Rec.Status = Rec.Status::Approved) and (Rec."Claim Posted" = false));
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
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Request Type":=Rec."Request Type"::"Staff Claim";
        Rec."Surrender Date":=WorkDate;
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
        IsOfficeAddin:=OfficeMgt.IsAvailable;
    end;
    var ImprestMgt: Codeunit "Imprest Management";
    OpenApprovalEntriesExistForCurrUser: Boolean;
    OpenApprovalEntriesExist: Boolean;
    CanCancelApprovalForRecord: Boolean;
    CanRequestApprovalForFlow: Boolean;
    CanCancelApprovalForFlow: Boolean;
    BudgetMgt: Codeunit "Budget Management";
    IsOfficeAddin: Boolean;
    OfficeMgt: Codeunit "Office Management";
}
