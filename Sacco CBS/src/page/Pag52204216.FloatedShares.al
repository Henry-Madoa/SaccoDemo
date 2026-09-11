page 52204216 "Floated Shares"
{
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments,Navigate';
    CardPageID = "Floated Share";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Share Floating";
    Editable = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No."; Rec."Document No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member No."; Rec."Member No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Share Type"; Rec."Share Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Par Value"; Rec."Par Value")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Total Shares"; Rec."Total Shares")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Minimum Acceptable Price"; Rec."Minimum Acceptable Price")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Shares to Float"; Rec."Shares to Float")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Source; Rec.Source)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field(Published; Rec.Published)
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field("Published On"; Rec."Published On")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field("Exiry Date"; Rec."Exiry Date")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            part(Control13; "Vendor Statistics FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = FIELD("Account No.");
            }
            part(Control15; "Member Profile Picture")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = FIELD("Member No.");
            }
        }
    }
    actions
    {
        area(processing)
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

                    trigger OnAction()
                    var
                        DocumentsChecklist: Record "Doc. Attachments Checklist";
                    begin
                        Rec.TESTFIELD(Status, Rec.Status::Open);
                        Rec.TESTFIELD("Proceeds Account");
                        DocumentsChecklist.RESET;
                        DocumentsChecklist.SETRANGE(Mandatory, true);
                        DocumentsChecklist.SETRANGE(Provided, false);
                        DocumentsChecklist.SETRANGE("Application Area", DocumentsChecklist."Application Area"::"Share Transfer");
                        DocumentsChecklist.SETRANGE("Source Code", Rec."Document No");
                        if DocumentsChecklist.FINDFIRST then ERROR('Please rovide ' + DocumentsChecklist.Description);
                        Rec.CALCFIELDS("Allocated Amount", "Payment Amount");
                        //Rec.TESTFIELD("Allocated Amount","Payment Amount");
                        Rec.TESTFIELD(Published, true);
                        if not CONFIRM('Are you sure you want to send Investment Project for approval?') then exit;
                        ApprovalsMgmt.OnSendShareFloatingForApproval(Rec);
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

                    trigger OnAction()
                    begin
                        if not CONFIRM('Are you sure you want to cancel Approval request?') then exit;
                        ApprovalsMgmt.OnCancelShareFloatingForApproval(Rec);
                    end;
                }
                action("Reopen")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = (Rec.Status = Rec.Status::Approved) and not Rec.Awarded;
                    Image = ReOpen;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;

                    trigger OnAction()
                    begin
                        if not CONFIRM('Are you sure you want to Reopen Approved Member Application?') then exit;
                        Rec.Status := Rec.Status::Open;
                        Rec.Modify;
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
            action("Share Transfer Checklist")
            {
                ApplicationArea = Basic, Suite;
                Image = Apply;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Share Trading Checklist";
                RunPageLink = "Source Code" = FIELD("Document No");
            }
            action("Analyze Bids")
            {
                ApplicationArea = Basic, Suite;
                Image = Aging;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = Rec.Status = Rec.Status::Approved;

                trigger OnAction()
                begin
                    ShareTradingMgmt.AnalyseShareTrade(Rec);
                    CurrPage.UPDATE;
                end;
            }
            action("Notify Award")
            {
                ApplicationArea = Basic, Suite;
                Image = SendEmailPDF;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = Rec.Status = Rec.Status::Approved;

                trigger OnAction()
                begin
                    if CONFIRM('Do you want to Notify Winning Bid Member?') then ShareTradingMgmt.NotifyAward(Rec);
                end;
            }
            action("Post Purchase")
            {
                ApplicationArea = Basic, Suite;
                Image = PostInventoryToGL;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ((Rec.Status = Rec.Status::Approved) and not Rec.Awarded);

                trigger OnAction()
                begin
                    //Rec.TESTFIELD("Proceeds Account");
                    Rec.TESTFIELD(Status, Rec.Status::Approved);
                    if CONFIRM('Do you want to Post Purchase?') then ShareTradingMgmt.PostPurchase(Rec);
                    CurrPage.UPDATE;
                end;
            }
            action("Transfer Shares")
            {
                ApplicationArea = Basic, Suite;
                Image = Apply;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ((Rec.Status = Rec.Status::Approved) and Rec.Awarded and not Rec.Archived);

                trigger OnAction()
                begin
                    Rec.TESTFIELD("Payment Amount");
                    Rec.CALCFIELDS("Allocated Amount");
                    //Rec.TESTFIELD("Allocated Amount","Payment Amount");
                    Rec.TESTFIELD(Status, Rec.Status::Approved);
                    Rec.TESTFIELD("Proceeds Account");
                    if CONFIRM('Do you Want to Transfer Shares?') then ShareTradingMgmt.TransferShares(Rec);
                    CurrPage.CLOSE;
                end;
            }
            action("Take Down")
            {
                ApplicationArea = Basic, Suite;
                Image = CancelApprovalRequest;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ((Rec.Status = Rec.Status::Approved) and Rec.Awarded and not Rec.Archived);

                trigger OnAction()
                begin
                    if CONFIRM('Do you Want to Take Down Your Floated Shares') then begin
                        ShareTradingMgmt.TakeDownSale(Rec);
                        CurrPage.CLOSE;
                    end;
                end;
            }
            action(Payments)
            {
                ApplicationArea = Basic, Suite;
                Image = Apply;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Share Transfer Receipts";
                RunPageLink = "Document No." = FIELD("Document No");
                Visible = ((Rec.Status = Rec.Status::Approved) and Rec.Awarded);
            }
            action("Lookup Receipts")
            {
                ApplicationArea = Basic, Suite;
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ((Rec.Status = Rec.Status::Approved) and Rec.Awarded);

                trigger OnAction()
                begin
                    CLEAR(DepositsLookup);
                    ShareTradingLines.RESET;
                    ShareTradingLines.SETRANGE("Document No.", Rec."Document No");
                    ShareTradingLines.SETRANGE(Awarded, true);
                    if ShareTradingLines.FINDFIRST then begin
                        VendorLedgerEntry.RESET;
                        VendorLedgerEntry.SETRANGE("Member No.", ShareTradingLines."Member No.");
                        VendorLedgerEntry.SETFILTER("Remaining Amount", '<>%1', 0);
                        VendorLedgerEntry.SETRANGE(Positive, false);
                        if VendorLedgerEntry.FINDFIRST then begin
                            DepositsLookup.SetParameters(Rec."Document No", 1);
                            DepositsLookup.SETTABLEVIEW(VendorLedgerEntry);
                            DepositsLookup.LOOKUPMODE := true;
                            DepositsLookup.RUN;
                        end
                        else
                            MESSAGE('No Posted Receipts Found For Member %1', ShareTradingLines."Member No.");
                        CurrPage.UPDATE;
                    end
                    else
                        MESSAGE('No Award Made');
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        SetControlAppearance;
        IsPublished := false;
        IsPublished := Rec.Published;
        AcceptingPayment := false;
        AcceptingPayment := Rec.Awarded;
    end;

    trigger OnModifyRecord(): Boolean
    begin
        IsPublished := false;
        IsPublished := Rec.Published;
        AcceptingPayment := false;
        AcceptingPayment := Rec.Awarded;
    end;

    trigger OnOpenPage()
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

    var
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesExist: Boolean;
        CanCancelApprovalForRecord: Boolean;
        CanRequestApprovalForFlow: Boolean;
        CanCancelApprovalForFlow: Boolean;
        ShareTradingMgmt: Codeunit "Share Trading Mgmt";
        IsPublished: Boolean;
        AcceptingPayment: Boolean;
        ApprovalsMgmt: Codeunit "Approval Mgmt. CBS Ext";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        DepositsLookup: Page "Deposits Lookup";
        ShareTradingLines: Record "Share Trading Lines";
}
