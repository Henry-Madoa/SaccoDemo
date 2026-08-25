page 52204228 "Loan Moratorium"
{
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments,Navigate';
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Loan Moratorium";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Editable = Rec.Status = Rec.Status::Open;
                field("Member No"; Rec."Member No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan No"; Rec."Loan No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                group(RestructureGroup)
                {
                    ShowCaption = false;
                    Visible = Rec.Type = Rec.Type::Restructure;
                    field("Restructure Date"; Rec."Restructure Date")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field(Installments; Rec.Installments)
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("New Monthly Installment"; Rec."New Monthly Installment")
                    {
                        ApplicationArea = Basic, Suite;
                        Editable = false;
                    }
                }
                group(MoratoriumGroup)
                {
                    ShowCaption = false;
                    Visible = Rec.Type <> Rec.Type::Restructure;
                    field("Moratorium Date"; Rec."Moratorium Date")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                    field("Moratorium Period"; Rec."Moratorium Period")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Moratorium Start Date"; Rec."Moratorium Start Date")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Moratorium End Date"; Rec."Moratorium End Date")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Remaining Installments Months"; Rec."Remaining Installments Months")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("&New Monthly Installment"; Rec."New Monthly Installment")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
            }
            group("Loan Information")
            {
                Editable = false;
                field("Product Code"; Rec."Product Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Product Name"; Rec."Product Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Current Principal Balance"; Rec."Current Principal Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                group(RestructureLoanGroup)
                {
                    ShowCaption = false;
                    Visible = Rec.Type = Rec.Type::Restructure;
                    field("Repayment Start Date"; Rec."Repayment Start Date")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Repayment End Date"; Rec."Repayment End Date")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Monthly Installment"; Rec."Monthly Installment")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Repayment Period"; Rec."Repayment Period")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
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
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Posted On"; Rec."Posted On")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(Reporting)
        {
            action("Print Schedule")
            {
                ApplicationArea = Basic, Suite;
                Image = Print;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Report;

                trigger OnAction()
                var
                    Loans: Record Loans;
                begin
                    Loans.Reset();
                    Loans.SetRange("No.", Rec."Loan No.");
                    if Loans.FindSet() then
                        Report.Run(Report::"Loan Repayment Schedule", true, false, Loans);
                end;
            }
        }
        area(Processing)
        {
            group("Request Approval")
            {
                Caption = 'Request Approval';
                Visible = NOT OpenApprovalEntriesExistForCurrUser;

                action("Send Approval Request")
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
                    AboutTitle = 'Approval Request';
                    AboutText = 'Send the Application for Approval before creation of the Accounts by clicking **Send Approval Request**';

                    trigger OnAction();
                    begin
                        LoansMgt.OnBeforeSendLoanRestructureForApproval(Rec."No.");
                        ApprovalsMgmtExt.OnSendLoanRestructureForApproval(Rec);
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
                        ApprovalsMgmtExt.OnCancelLoanRestructureForApproval(Rec);
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
            action("Generate Schedule")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                Image = ApplyEntries;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = Rec.Status = Rec.Status::Open;

                trigger OnAction()
                var
                    LoansManagement: Codeunit "Loans Management";
                    Loans: Record Loans;
                begin
                    if Loans.Get(Rec."Loan No.") then
                        LoansManagement.GenerateLoanRepaymentSchedule(Loans);
                end;
            }
            action(Post)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                Image = Post;
                Visible = ((Rec.Status = Rec.Status::Approved) and (not Rec.Posted));

                trigger OnAction()
                begin
                    if Confirm('Do you want to post Moratorium?') then begin
                        LoansMgt.PostLoanMoratorium(Rec."No.");
                        CurrPage.Close;
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
        isOpen := (Rec.Status = Rec.Status::Open);
        IsWindows := GuiAllowed;
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
        isOpen, IsWindows : Boolean;
        LoansMgt: Codeunit "Loans Management";
}
