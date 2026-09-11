page 52204082 "Teller Transaction"
{
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments,Navigate';
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Teller Transactions";

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
                    StyleExpr = StyleText;
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    StyleExpr = StyleText;

                    trigger OnValidate()
                    begin
                        isVisible := (Rec."Transaction Type" = Rec."Transaction Type"::"Cash Deposit");
                        CurrPage.Update();
                    end;
                }
                group(Narration)
                {
                    ShowCaption = false;
                    Visible = Rec."Transaction Type" = Rec."Transaction Type"::"Cash Deposit";

                    field(Description; Rec.Description)
                    {
                        StyleExpr = StyleText;
                        ApplicationArea = Basic, Suite;
                        MultiLine = true;
                        ShowMandatory = true;
                    }
                }
                field("Member No"; Rec."Member No.")
                {
                    StyleExpr = StyleText;
                    ApplicationArea = Basic, Suite;
                }
                field("Account No"; Rec."Account No")
                {
                    StyleExpr = StyleText;
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    StyleExpr = StyleText;
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Charge Code"; Rec."Charge Code")
                {
                    StyleExpr = StyleText;
                    ApplicationArea = Basic, Suite;
                }
                field("Transacted By Name"; Rec."Transacted By Name")
                {
                    StyleExpr = StyleText;
                    ApplicationArea = Basic, Suite;
                    Editable = isVisible;
                    ShowMandatory = True;
                }
                field("Transacted By ID No"; Rec."Transacted By ID No")
                {
                    StyleExpr = StyleText;
                    ApplicationArea = Basic, Suite;
                    Editable = isVisible;
                    ShowMandatory = True;
                }
                group("Document Dimensions")
                {
                    Editable = false;
                    ShowCaption = false;

                    field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                    {
                        StyleExpr = StyleText;
                        ApplicationArea = Basic, Suite;
                    }
                    field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                    {
                        StyleExpr = StyleText;
                        ApplicationArea = Basic, Suite;
                    }
                }
                field("Till Balance"; Rec."Till Balance")
                {
                    StyleExpr = StyleText;
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Statistics Information")
            {
                Editable = false;

                field("Book Balance"; Rec."Book Balance")
                {
                    StyleExpr = StyleText;
                    ApplicationArea = Basic, Suite;
                }
                field("Available Balance"; Rec."Available Balance")
                {
                    StyleExpr = StyleText;
                    ApplicationArea = Basic, Suite;
                }
                field("Member Name"; Rec."Member Name")
                {
                    StyleExpr = StyleText;
                    ApplicationArea = Basic, Suite;
                }
                field("Account Name"; Rec."Account Name")
                {
                    StyleExpr = StyleText;
                    ApplicationArea = Basic, Suite;
                }
            }
            part(Denominations; "Transaction Denominations")
            {
                Editable = not Rec.Posted;
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "Document Type" = const("Teller Transactions"), "No." = field("No.");
            }
            group("Audit Trail")
            {
                field("Posting Date"; Rec."Posting Date")
                {
                    StyleExpr = StyleText;
                    ApplicationArea = Basic, Suite;
                }
                field("Approval Required"; Rec."Approval Required")
                {
                    StyleExpr = StyleText;
                    ApplicationArea = Basic, Suite;
                }
                field(Posted; Rec.Posted)
                {
                    StyleExpr = StyleText;
                    ApplicationArea = Basic, Suite;
                }
                field("Posted On"; Rec."Posted On")
                {
                    StyleExpr = StyleText;
                    ApplicationArea = Basic, Suite;
                }
                field("Posted By"; Rec."Posted By")
                {
                    StyleExpr = StyleText;
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    StyleExpr = StyleText;
                    ApplicationArea = Basic, Suite;
                }
            }
        }
        area(FactBoxes)
        {
            part("Account Instructions"; "Member Account Instructions")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                UpdatePropagation = Both;
                SubPageLink = "Source Code" = field("Member No.");
            }
            part(Images; "Member Images Factbox")
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "No." = field("Member No.");
            }
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(Database::"Teller Transactions"), "No." = FIELD("No.");
            }
            part(Control27; "Pending Approval FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Table ID" = CONST(Database::"Teller Transactions"), "Document No." = FIELD("No.");
                Visible = OpenApprovalEntriesExistForCurrUser and Rec."Approval Required";
            }
            part("Approval Entries"; "Customize Approval Entries")
            {
                ApplicationArea = Basic, Suite;
                Visible = Rec."Approval Required";
                Caption = 'Approval Entries';
                SubPageLink = "Table ID" = CONST(Database::"Teller Transactions"), "Document No." = FIELD("No.");
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
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
                    Visible = (Rec."Approval Required" or Rec.Dormant);
                    Enabled = NOT OpenApprovalEntriesExist AND CanRequestApprovalForFlow;
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category7;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Request approval of the document.';
                    AboutTitle = 'Approval Request';
                    AboutText = 'Send the Application for Approval before creation of the Accounts by clicking **Send Approval Request**';

                    trigger OnAction()
                    var
                        FOSATrans: Codeunit "FOSA Management";
                    begin
                        FOSATrans.PrecheckTellerTransasction(Rec);
                        ApprovalsMgmtExt.OnSendTellerTransactionForApproval(Rec);
                        CurrPage.Close();
                    end;
                }
                action("Cancel Approval Request")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cancel Approval Re&quest';
                    Visible = Rec."Approval Required";
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
                        ApprovalsMgmtExt.OnCancelTellerTransactionForApproval(Rec);
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
                    Visible = Rec."Approval Required";
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
            action("Veiw Member Image")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                Image = StepInto;
                PromotedCategory = Process;
                RunObject = page "Member Images";
                RunPageLink = "No." = field("Member No.");
            }
            action(Post)
            {
                ApplicationArea = Basic, Suite;
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                Visible = (((Rec.Status = Rec.Status::Approved) or not Rec."Approval Required") and not Rec.Posted);

                trigger OnAction()
                var
                    FOSATrans: Codeunit "FOSA Management";
                begin
                    FOSATrans.PrecheckTellerTransasction(Rec);
                    if not confirm('Do you want to Post?') then
                        CurrPage.Close();
                    FOSATrans.PostTellerTransaction(Rec);
                    Commit;
                    CurrPage.Close;
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
        if Rec."Transaction Type" = Rec."Transaction Type"::"Cash Deposit" then
            StyleText := 'Favorable'
        else
            StyleText := 'Unfavorable';
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
        isVisible: Boolean;
        StyleText: Text;
}
