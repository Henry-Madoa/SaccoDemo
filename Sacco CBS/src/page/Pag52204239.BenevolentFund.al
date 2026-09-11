page 52204239 "Benevolent Fund"
{
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments,Navigate';
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Benevolent Fund";

    layout
    {
        area(Content)
        {
            group("Payment Details")
            {
                Editable = Rec.Status = Rec.Status::Open;

                field("Payment Type"; Rec."Payment Type")
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Member No"; Rec."Member No.")
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Full Name"; Rec."Full Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                group("Next of Kin Details")
                {
                    Editable = Rec.Status = Rec.Status::Open;
                    Visible = Rec."Payment Type" = Rec."Payment Type"::Nominee;

                    field("KIN No."; Rec."KIN Identication No.")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Relationship"; Rec."KIN Relationship")
                    {
                        ApplicationArea = Basic, Suite;
                        Editable = false;
                    }
                    field("Kin Name"; Rec."Kin Name")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                field("Fosa Account"; Rec."Fosa Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Posting Description"; Rec."Posting Description")
                {
                    MultiLine = true;
                    ApplicationArea = Basic, Suite;
                }
                field("Payment Amount"; Rec."Payment Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Paying Details")
            {
                Visible = ((Rec.Status = Rec.Status::Approved) and (not Rec.Processed));
                Editable = ((Rec.Status = Rec.Status::Open) or (Rec.Status = Rec.Status::Approved));

                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field("Paying Account Type"; Rec."Paying Account Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                group(NonBankPayment)
                {
                    ShowCaption = false;
                    Visible = Rec."Paying Account Type" <> Rec."Paying Account Type"::"Bank Account";

                    field("Paying Account No"; Rec."Paying Account No")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                group(BankPayment)
                {
                    ShowCaption = false;
                    Visible = Rec."Paying Account Type" = Rec."Paying Account Type"::"Bank Account";

                    field("Pay Mode"; Rec."Pay Mode")
                    {
                        ApplicationArea = Basic, Suite;

                        trigger OnValidate()
                        begin
                            CurrPage.Update();
                        end;
                    }
                    field("&Paying Account No"; Rec."Paying Account No")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    group(ChequePaymentVisibility)
                    {
                        Visible = Rec."Payment Methods Types" = Rec."Payment Methods Types"::Cheque;
                        ShowCaption = false;

                        field("Cheque Number"; Rec."Cheque Number")
                        {
                            ApplicationArea = Basic, Suite;
                            ShowMandatory = true;
                        }
                        field("Cheque Date"; Rec."Cheque Date")
                        {
                            ApplicationArea = Basic, Suite;
                            ShowMandatory = true;
                        }
                        field("Cheque Received By"; Rec."Cheque Received By")
                        {
                            ApplicationArea = Basic, Suite;
                            ShowMandatory = true;
                        }
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
                field("Approval Status"; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Processed; Rec.Processed)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Processed On"; Rec."Processed On")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
        area(FactBoxes)
        {
            part(Statistics; "Member Statistics")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = field("Member No.");
            }
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(Database::"Benevolent Fund"), "No." = FIELD("No.");
            }
            part(Control27; "Pending Approval FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Table ID" = CONST(Database::"Benevolent Fund"), "Document No." = FIELD("No.");
                Visible = OpenApprovalEntriesExistForCurrUser;
            }
            part("Approval Entries"; "Customize Approval Entries")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Approval Entries';
                SubPageLink = "Table ID" = CONST(Database::"Benevolent Fund"), "Document No." = FIELD("No.");
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
                Image = Report;

                trigger OnAction()
                begin
                    Rec.Reset();
                    Rec.SetRange("No.", Rec."No.");
                    if Rec.FindFirst then REPORT.Run(Report::"Benevolent Fund", true, false, Rec);
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

                    trigger OnAction();
                    begin
                        Rec.OnBeforeSendForApproval;
                        ApprovalsMgmtExt.OnSendBenevolentFundForApproval(Rec);
                        CurrPage.Close;
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

                    trigger OnAction();
                    begin
                        ApprovalsMgmtExt.OnCancelBenevolentFundForApproval(Rec);
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
            group("Manual Approval")
            {
                Visible = NOT OpenApprovalEntriesExistForCurrUser;

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
            action("Next of Kins")
            {
                ApplicationArea = Basic, Suite;
                PromotedCategory = Process;
                Image = AccountingPeriods;
                RunObject = page "Member Nominees/Kins";
                RunPageLink = "Source Code" = field("Member No."), "Document Type" = const(Nominee);
                RunPageMode = View;
                Promoted = true;
            }
            action(Post)
            {
                ApplicationArea = Basic, Suite;
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ((not Rec.Processed) and (Rec.Status = Rec.Status::Approved));

                trigger OnAction()
                begin
                    if Confirm('Do you want to Post?') then begin
                        MemberManagement.PostFinalExpenses(Rec);
                        CurrPage.Close();
                    end;
                end;
            }
            action("Family Tree")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Sink Fund';
                Image = AddContacts;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    FamilyTree: Record "Member Nominee/Kin";
                    FTreePage: Page "Member Nominees/Kins";
                begin
                    FamilyTree.Reset();
                    FamilyTree.SetRange("Source Code", Rec."Member No.");
                    Clear(FTreePage);
                    FTreePage.Editable := false;
                    FTreePage.LookupMode := true;
                    FTreePage.SetTableView(FamilyTree);
                    FTreePage.RunModal()
                end;
            }
        }
    }
    var
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesExist: Boolean;
        CanCancelApprovalForRecord: Boolean;
        CanRequestApprovalForFlow: Boolean;
        CanCancelApprovalForFlow: Boolean;
        ApprovalsMgmtExt: Codeunit "Approval Mgmt. CBS Ext";
        MemberManagement: Codeunit "Member Management";

    trigger OnOpenPage()
    begin
        SetControlAppearance;
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
        OpenApprovalEntriesExistForCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        WorkflowWebhookMgt.GetCanRequestAndCanCancel(Rec.RecordId, CanRequestApprovalForFlow, CanCancelApprovalForFlow);
    end;
}
