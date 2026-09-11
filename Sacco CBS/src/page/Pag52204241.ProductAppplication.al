page 52204241 "Product Appplication"
{
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments,Navigate';
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "Products Management";
    SourceTableView = where("Document Type" = const(Application));

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
                    Importance = Additional;
                    Visible = NoFieldVisible;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then CurrPage.Update();
                    end;
                }
                field("Product Code"; Rec."Product Code")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field(Name; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field(Category; Rec.Category)
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field("Product Posting Type"; Rec."Product Posting Type")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field("Posting Group"; Rec."Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field(Prefix; Rec.Prefix)
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field(Suffix; Rec.Suffix)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Print Sequence"; Rec."Print Sequence")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Hide on Statement"; Rec."Hide on Statement")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Recovery Priority"; Rec."Loan Recovery Priority")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Account Controls")
            {
                Editable = Rec.Status = Rec.Status::Open;
                Visible = Rec."Product Posting Type" <> Rec."Product Posting Type"::"Loan Account";

                field("Business Account"; Rec."Business Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Cheque Book Allowed"; Rec."Cheque Book Allowed")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("ATM Use Allowed"; Rec."ATM Use Allowed")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Cash Deposit Allowed"; Rec."Cash Deposit Allowed")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Cash Withdraw Allowed"; Rec."Cash Withdraw Allowed")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Cash Transfer Allowed"; Rec."Cash Transfer Allowed")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("&Checkoff Product"; Rec."Checkoff Product")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Minimum Balance"; Rec."Minimum Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Maximum Balance"; Rec."Maximum Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Minimum Contribution"; Rec."Minimum Contribution")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Credit Controls")
            {
                Editable = Rec.Status = Rec.Status::Open;
                Visible = Rec."Product Posting Type" = Rec."Product Posting Type"::"Loan Account";

                field("Max. Running Loans"; Rec."Max. Running Loans")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Multiplier"; Rec."Loan Multiplier")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Maximum Loan Multiplier"; Rec."Maximum Loan Multiplier")
                {
                    ApplicationArea = Basic, Suite;
                }
                Field("Minimum Loan Amount"; Rec."Minimum Loan Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Maximum Loan Amount"; Rec."Maximum Loan Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Boost Deposits"; Rec."Boost Deposits")
                {
                    ApplicationArea = Basic, Suite;
                }
                group(Boosting)
                {
                    Visible = Rec."Boost Deposits";
                    ShowCaption = false;

                    field("Max. NWD Boost"; Rec."Max. NWD Boost")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Max. NWD Boost %"; Rec."Max. NWD Boost %")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                field("Minimum Deposit Balance"; Rec."Minimum Deposit Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                Field("Minimum Deposit Contribution"; Rec."Minimum Deposit Contribution")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Discounting %"; Rec."Bridging Commision %")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Recovery Commission %"; Rec."Boosting Commission %")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Max. Bridging Commission"; Rec."Max. Bridging Commission")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Commission Account"; Rec."Commission Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Processing Fee Acc."; Rec."Processing Fee Acc.")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field("Repayment Cutoff Date"; Rec."Repayment Cutoff Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Checkoff Product"; Rec."Checkoff Product")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Unsecured Product"; Rec."Unsecured Product")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Exclude Billing & Interest"; Rec."Exclude Billing & Interest")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Appraise with 0 Deposits"; Rec."Appraise with 0 Deposits")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Special Loan Multiplier"; Rec."Special Loan Multiplier")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("View Online"; Rec."View Online")
                {
                    ApplicationArea = Basic, Suite;
                }
                label("*****Interest Control*****")
                {
                    Style = Favorable;
                }
                field("Charge UpFront Interest"; Rec."Charge UpFront Interest")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Due Account"; Rec."Interest Due Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Paid Account"; Rec."Interest Paid Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Bands"; Rec."Interest Bands")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Rate"; Rec."Interest Rate")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Repayment Method"; Rec."Interest Repayment Method")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Rate Type"; Rec."Rate Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                label("*****Penalty*****")
                {
                    Style = Favorable;
                }
                field("Penalty Rate"; Rec."Penalty Rate")
                {
                    ApplicationArea = All;
                }
                field("Penalty Due Account"; Rec."Penalty Due Account")
                {
                    ApplicationArea = All;
                }
                field("Penalty Paid Account"; Rec."Penalty Paid Account")
                {
                    ApplicationArea = All;
                }
                label("*****FOSA Salary Appraisal*****")
                {
                    Style = Favorable;
                }
                field("Dividend Based"; Rec."Dividend Based")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Salary Based"; Rec."Salary Based")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Min. Salary Count"; Rec."Min. Salary Count")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Salary %"; Rec."Salary %")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Salary Appraisal Type"; Rec."Salary Appraisal Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                label("*****Insurance Control*****")
                {
                    Style = Favorable;
                }
                field("Insurance Rate"; Rec."Insurance Rate")
                {
                    MaxValue = 100;
                    ApplicationArea = Basic, Suite;
                }
                field("Insurance Account"; Rec."Insurance Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Insurance Factor"; Rec."Insurance Factor")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Insurance Income %"; Rec."Insurance Income %")
                {
                    MaxValue = 100;
                    ApplicationArea = Basic, Suite;
                }
                field("Insurance Income Account"; Rec."Insurance Income Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                label("*****Disbursement*****")
                {
                    Style = Favorable;
                }
                field("Mode of Disbursement"; Rec."Mode of Disbursement")
                {
                    ApplicationArea = Basic, Suite;
                }
                group("ModeOfDisbursement")
                {
                    ShowCaption = false;
                    Visible = ((Rec."Mode of Disbursement" <> Rec."Mode of Disbursement"::"FOSA (Full)") and (Rec."Mode of Disbursement" <> Rec."Mode of Disbursement"::"FOSA (Partial)"));

                    field("Disbursement Account"; Rec."Disbursement Account")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                }
                label("*****Installments*****")
                {
                    Style = Favorable;
                }
                field("Minimum Installments"; Rec."Minimum Installments")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Maximum Installments"; Rec."Maximum Installments")
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate()
                    begin
                        Rec."Ordinary Default Intallments" := Rec."Maximum Installments";
                    end;
                }
                field("Ordinary Default Intallments"; Rec."Ordinary Default Intallments")
                {
                    ApplicationArea = Basic, Suite;
                }
                label("*****Mobile Controls*****")
                {
                    Style = Favorable;
                }
                field("Mobile Loan"; Rec."Mobile Loan")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Mobile Appraisal Type"; Rec."Mobile Appraisal Type")
                {
                    ApplicationArea = Basic, Suite;
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
                    Style = StrongAccent;
                }
                group(Processed_Grp)
                {
                    Visible = Rec.Processed;
                    ShowCaption = false;

                    field(Processed; Rec.Processed)
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Processed By"; Rec."Processed By")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Processed On"; Rec."Processed On")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
            }
        }
        area(FactBoxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(Database::"Products Management"), "No." = FIELD("No.");
            }
            part(Control27; "Pending Approval FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Table ID" = CONST(Database::"Products Management"), "Document No." = FIELD("No.");
                Visible = OpenApprovalEntriesExistForCurrUser;
            }
            part("Approval Entries"; "Customize Approval Entries")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Approval Entries';
                SubPageLink = "Table ID" = CONST(Database::"Products Management"), "Document No." = FIELD("No.");
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
            action(Process)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                Image = Post;
                Scope = Repeater;
                Ellipsis = true;
                Visible = ((Rec.Status = Rec.Status::Approved) and not Rec.Processed);

                trigger OnAction()
                begin
                    ProductManagement.ProcessProductApplication(Rec);
                    CurrPage.Close;
                end;
            }
            action(Charges)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = SuggestFinancialCharge;
                RunObject = page "Product Charge Setup";
                RunPageLink = "Source Code" = field("No.");
                Visible = Rec."Product Posting Type" = Rec."Product Posting Type"::"Loan Account";
            }
            action("Loan Interest Bands")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Loaner;
                RunObject = page "Loan Interest Bands";
                RunPageLink = "Source Code" = field("No.");
                Visible = Rec."Product Posting Type" = Rec."Product Posting Type"::"Loan Account";
            }
            action("Linked Products")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                Image = LinkAccount;
                RunObject = page "Linked Products";
                RunPageLink = "Source Code" = field("No.");
                Scope = Repeater;
                Ellipsis = true;
                Visible = Rec."Product Posting Type" = Rec."Product Posting Type"::"Loan Account";
            }
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
                        ApprovalsMgmtExt.OnSendProductsManagementForApproval(Rec);
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
                        ApprovalsMgmtExt.OnCancelProductsManagementForApproval(Rec);
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
        }
    }
    var
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesExist: Boolean;
        CanCancelApprovalForRecord: Boolean;
        CanRequestApprovalForFlow: Boolean;
        CanCancelApprovalForFlow: Boolean;
        ApprovalsMgmtExt: Codeunit "Approval Mgmt. CBS Ext";
        NoFieldVisible: Boolean;
        ProductManagement: Codeunit "Product Management";

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

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Document Type" := Rec."Document Type"::Application;
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
        NoFieldVisible := Rec.DocumentNoIsVisible;
    end;
}
