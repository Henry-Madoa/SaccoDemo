page 52203455 "Payment Voucher"
{
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments,Navigate';
    DeleteAllowed = false;
    Caption = 'Payment Voucher';
    PageType = Document;
    SourceTable = "Payment Voucher";
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = ((Rec.Status = Rec.Status::Open) AND Rec.Posted = false);

                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit then CurrPage.Update;
                    end;
                }
                field(Date; Rec.Date)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payment Type"; Rec."Payment Type")
                {
                    ApplicationArea = Basic, Suite;

                    // Editable = not Rec."From Self Service";
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ShowMandatory = true;
                    ApplicationArea = Basic, Suite;
                    MultiLine = true;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    Editable = not Rec."From Self Service";
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    Editable = not Rec."From Self Service";
                }
                field("Prepared By"; Rec."Prepared By")
                {
                    ApplicationArea = Basic, Suite;
                }
                group(PaymentSupplierDetails)
                {
                    ShowCaption = false;
                    Visible = PaymentTypeVisibility;

                    field("Purchase Invoice Amount"; Rec."Purchase Invoice Amount")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Outstanding Amount"; Rec."Outstanding Amount")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("VAT Already Charged"; Rec."VAT Already Charged")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("W\Tax Already Charged"; Rec."W\Tax Already Charged")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Gross Amount"; Rec."Gross Amount")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Total Withholding Tax"; Rec."Total Withholding Tax")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Pending Approvals"; Rec."Pending Approvals")
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnAssistEdit()
                    var
                        Entries: Record "Approval Entry";
                    begin
                        Entries.Reset();
                        Entries.SetRange("Table ID", Database::"Payment Voucher");
                        Entries.SetRange("Document No.", Rec."No.");
                        Entries.SetFilter(Status, '%1|%2', Entries.Status::Open, Entries.Status::Created);
                        Page.RunModal(Page::"Custom Approval Entries", Entries);
                    end;
                }
                field("Approvals Trail"; Rec."Approvals Trail")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;

                    trigger OnAssistEdit()
                    var
                        Entries: Record "Approval Entry";
                    begin
                        Entries.Reset();
                        Entries.SetRange("Table ID", Database::"Payment Voucher");
                        Entries.SetRange("Document No.", Rec."No.");
                        Entries.SetFilter(Status, '=%1', Entries.Status::Approved);
                        Page.RunModal(Page::"Custom Approval Entries", Entries);
                    end;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Paying Details")
            {
                Visible = PaymentTabEditability;
                Editable = ((Rec.Status = Rec.Status::Open) or (Rec.Status = Rec.Status::Approved));
                Caption = 'Paying Details (Bank to be Credited)';

                field("Pay Mode"; Rec."Pay Mode")
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Paying Bank Account"; Rec."Paying Bank Account")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field(Currency; Rec.Currency)
                {
                    ApplicationArea = Basic, Suite;
                }
                group(ChequePaymentVisibility)
                {
                    ShowCaption = false;
                    Visible = ChequePaymentVisibility;

                    field("Cheque Number"; Rec."Cheque Number")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Cheque Date"; Rec."Cheque Date")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Cheque Received By"; Rec."Cheque Received By")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
            }
            part(Control4; "Payment Voucher Lines")
            {
                Editable = ((Rec.Posted = false) and ((Rec.Status = Rec.Status::Open) or (Rec.Status = Rec.Status::Approved)));
                ApplicationArea = Basic, Suite;
                SubPageLink = "No."=FIELD("No.");
                UpdatePropagation = Both;
            }
            group("Posting Details")
            {
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Posted By"; Rec."Posted By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Posted Date"; Rec."Posted Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Time Posted"; Rec."Time Posted")
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
                SubPageLink = "Table ID"=CONST(Database::"Payment Voucher"), "No."=FIELD("No.");
            }
            part(Control27; "Pending Approval FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Table ID"=CONST(Database::"Payment Voucher"), "Document No."=FIELD("No.");
                Visible = OpenApprovalEntriesExistForCurrUser;
            }
            part("Approval Entries"; "Customize Approval Entries")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Approval Entries';
                SubPageLink = "Table ID"=CONST(Database::"Payment Voucher"), "Document No."=FIELD("No.");
            }
            part(Control1901138007; "Vendor Details FactBox")
            {
                ApplicationArea = Suite;
                SubPageLink = "No."=FIELD("Vendor No");
                Visible = Rec."Vendor No" <> '';
            }
            part(Control1904651607; "Vendor Statistics FactBox")
            {
                ApplicationArea = Suite;
                SubPageLink = "No."=FIELD("Vendor No");
                Visible = Rec."Vendor No" <> '';
            }
            part(Control1903435607; "Vendor Hist. Buy-from FactBox")
            {
                ApplicationArea = Suite;
                SubPageLink = "No."=FIELD("Vendor No");
                Visible = Rec."Vendor No" <> '';
            }
            part(Control1906949207; "Vendor Hist. Pay-to FactBox")
            {
                ApplicationArea = Suite;
                SubPageLink = "No."=FIELD("Vendor No");
                Visible = false;
            }
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
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
        area(Reporting)
        {
            action(Print)
            {
                ApplicationArea = Basic, Suite;
                Image = PrintVoucher;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Report;

                trigger OnAction()
                begin
                    Rec.Reset;
                    Rec.SetRange("No.", Rec."No.");
                    REPORT.Run(Report::"Payment Voucher", true, false, Rec);
                end;
            }
        }
        area(processing)
        {
            action("Import Schedule")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = ImportExcel;
                Visible = ((Rec."Payment Type" = Rec."Payment Type"::"Petty Cash Topup") and (Rec.Status = Rec.Status::Open) and (Rec.Posted = false));

                trigger OnAction();
                begin
                    PettyCashReimbursement.GetHeader(Rec."No.");
                    PettyCashReimbursement.Run();
                end;
            }
            action("Copy Schedule")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = SuggestPayment;
                Visible = ((Rec."Payment Type" = Rec."Payment Type"::"Petty Cash Topup") and (Rec.Status = Rec.Status::Open) and (Rec.Posted = false));

                trigger OnAction();
                begin
                    CopySchedule.PettyCashVariableSetting(Rec);
                    CopySchedule.Run();
                end;
            }
            action("View Petty Cash Reimbursment Schedule")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = ViewWorksheet;
                Visible = Rec."Payment Type" = Rec."Payment Type"::"Petty Cash Topup";
                RunObject = page "Petty Cash Reimbursement";
                RunPageLink = "PV No."=field("No.");
            }
            action(Post)
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
                        CashMgmt."Post Payment Voucher"(Rec);
                    if Rec."Payment Type" in[Rec."Payment Type"::"Staff Bulk Payment"]then CommunicationMgmt.NotificationOnPaymentVoucherDisbursement(Rec);
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
            action("Select Approvers")
            {
                ApplicationArea = Basic, Suite;
                Image = SelectLineToApply;
                Promoted = true;
                PromotedIsBig = true;
                Visible = false;

                trigger OnAction()
                begin
                    AdvancedFinanceSetup.Get;
                    AdvancedFinanceSetup.TestField("RFPY Workflow User Group");
                    Approvers.Reset;
                    Approvers.SetCurrentKey("Sequence No.");
                    Approvers.SetRange("Workflow User Group Code", AdvancedFinanceSetup."PV Workflow User Group");
                    PAGE.Run(1532, Approvers);
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
                        Rec.OnBeforeApproval;
                        ApprovalsMgt.OnSendPVForApproval(Rec)end;
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
                        ApprovalsMgt.OnCancelPVApprovalRequest(Rec);
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
                        Enabled = ((Rec.Status = Rec.Status::Approved) and (Rec.Posted = false));
                        Image = ReOpen;
                        Promoted = true;
                        PromotedCategory = Category5;
                        PromotedOnly = true;

                        trigger OnAction()
                        var
                            ReleaseCustomDocuments: Codeunit "Release Custom Documents";
                        begin
                            ReleaseCustomDocuments.PerformManualReopenPV(Rec);
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
                            ReleaseCustomDocuments.PerformManualReleasePV(Rec);
                            CurrPage.Close();
                        end;
                    }
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
    trigger OnAfterGetRecord()
    begin
        SetControlAppearance;
        SetPaymentTypeControl;
        SetPayModeControl;
    end;
    trigger OnAfterGetCurrRecord()
    begin
        SetControlAppearance;
        SetPaymentTypeControl;
        SetPayModeControl;
    end;
    trigger OnNextRecord(Steps: Integer): Integer begin
        SetPaymentTypeControl;
    end;
    trigger OnInit()
    begin
        SalaryAdvanced:=false;
        ShowEFT:=false;
        ShowMpesa:=false;
    end;
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Prepared By":=UserId;
        Rec.Status:=Rec.Status::Open;
    end;
    trigger OnOpenPage()
    begin
        SetControlAppearance;
        SetPayModeControl;
        SetPaymentTypeControl;
    end;
    local procedure SetPaymentTypeControl()
    begin
        if Rec."Payment Type" = Rec."Payment Type"::"Supplier Payment" then PaymentTypeVisibility:=true
        else
            PaymentTypeVisibility:=false;
    end;
    local procedure SetPayModeControl()
    begin
        if Rec."Pay Mode" = 'EFT' then begin
            ShowEFT:=true;
            ShowMpesa:=false;
        end
        else if Rec."Pay Mode" = 'M-PESA' then begin
                ShowEFT:=false;
                ShowMpesa:=true;
            end
            else
            begin
                ShowEFT:=true;
                ShowMpesa:=true;
            end;
        if PaymentMethod.Get(Rec."Pay Mode")then;
        if PaymentMethod.Type = PaymentMethod.Type::Cheque then ChequePaymentVisibility:=true
        else
            ChequePaymentVisibility:=false;
        if PaymentMethod.Type = PaymentMethod.Type::FOSA then FOSAPaymentEditability:=false
        else
            FOSAPaymentEditability:=true;
        if Rec."Payment Type" in[Rec."Payment Type"::"Staff Bulk Payment"]then PaymentTabEditability:=false
        else
            PaymentTabEditability:=true;
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
    var CashMgmt: Codeunit "Cash Management";
    ApprovalsMgt: Codeunit "Approval Mgmt. Ext";
    OpenApprovalEntriesExistForCurrUser: Boolean;
    OpenApprovalEntriesExist: Boolean;
    CanCancelApprovalForRecord: Boolean;
    CanRequestApprovalForFlow: Boolean;
    CanCancelApprovalForFlow: Boolean;
    SalaryAdvanced: Boolean;
    ShowEFT: Boolean;
    PaymentTypeVisibility: Boolean;
    ShowMpesa: Boolean;
    AdvancedFinanceSetup: Record "General Ledger Setup";
    Approvers: Record "Workflow User Group Member";
    CopySchedule: Report "Copy Payment Schedule";
    PettyCashReimbursement: XmlPort "Petty Cash Reimbursement";
    PaymentMethod: Record "Payment Method";
    FOSAPaymentEditability: Boolean;
    PaymentTabEditability: Boolean;
    EFTEditability: Boolean;
    ChequePaymentVisibility: Boolean;
    OfficeMgt: Codeunit "Office Management";
    IsOfficeAddin: Boolean;
    CommunicationMgmt: Codeunit "Communications Mgmt";
}
