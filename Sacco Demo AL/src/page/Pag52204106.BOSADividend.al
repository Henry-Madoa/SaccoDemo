page 52204106 "BOSA Dividend"
{
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments,Navigate';
    PageType = Card;
    SourceTable = "Dividend Header";
    SourceTableView = where("Document Type" = const(BOSA));
    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = Rec.Status = Rec.Status::Open;

                field("Dividend Code"; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    MultiLine = true;
                    ShowMandatory = true;
                }
                field("Progression Computation Type"; Rec."Progression Computation Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Transaction Code"; Rec."Transaction Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Last Updated By"; Rec."Last Updated By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Last Updated On"; Rec."Last Updated On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Expense Account No."; Rec."Expense Account No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payable Account No."; Rec."Payable Account No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Recover Loans"; Rec."Recover Loans")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Posting Type"; Rec."Posting Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Posting Description"; Rec."Posting Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Balances"; Rec."Member Balances")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Total Earned Amount"; Rec."Total Earned Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Boost Amount"; Rec."Boost Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loans Recoveries"; Rec."Loans Recoveries")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Charges; Rec.Charges)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Total Net Amount"; Rec."Total Net Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Boost to Minimum"; Rec."Boost to Minimum")
                {
                    ApplicationArea = Basic, Suite;
                }
                group(Minimum)
                {
                    ShowCaption = false;
                    Visible = Rec."Boost to Minimum";

                    field("Maximum Boost Amount"; Rec."Maximum Boost Amount")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                field("Preferential Boost"; Rec."Preferential Boost")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part(Control12; "Dividend Calculation Setup")
            {
                ApplicationArea = Basic, Suite;
                Editable = Rec.Status = Rec.Status::Open;
                SubPageLink = "Dividend Code" = FIELD("No.");
            }
            part(Control11; "Dividend Lines")
            {
                ApplicationArea = Basic, Suite;
                Editable = Rec.Status = Rec.Status::Open;
                SubPageLink = "Dividend Code" = FIELD("No.");
            }
        }
    }
    actions
    {
        area(Reporting)
        {
            action("Preview Slipts")
            {
                ApplicationArea = Basic, Suite;
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    DividendHeader.RESET;
                    DividendHeader.SETRANGE("No.", Rec."No.");
                    if DividendHeader.FINDFIRST then Report.Run(Report::"Dividend Slipt", true, false, DividendHeader);
                end;
            }
        }
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
                    AboutTitle = 'Approval Request';
                    AboutText = 'Send the Application for Approval before creation of the Accounts by clicking **Send Approval Request**';

                    trigger OnAction();
                    begin
                        Rec.OnBeforeSendForApproval;
                        if CONFIRM('Are you sure you want to send it for approval?') then begin
                            ApprovalsMgmt.OnSendDividendHeaderForApproval(Rec);
                            CurrPage.CLOSE();
                        end;
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
                        Rec.TESTFIELD(Status, Rec.Status::"Pending Approval");
                        if CONFIRM('Are you sure you want to cancel approval request?') then begin
                            ApprovalsMgmt.OnCancelDividendHeaderForApproval(Rec);
                            CurrPage.CLOSE();
                        end;
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
            action("Calculate Dividend")
            {
                ApplicationArea = Basic, Suite;
                Image = Calculate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = Rec.Status = Rec.Status::Open;

                trigger OnAction()
                begin
                    Rec.TESTFIELD(Status, Rec.Status::Open);
                    Rec.TESTFIELD("Progression Computation Type");
                    if CONFIRM('Do you Want to Calculate', true) then begin
                        DividendManagement.CalculateDividend(Rec);
                    end;
                end;
            }
            action("Post Dividend")
            {
                ApplicationArea = Basic, Suite;
                Image = PostBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ((Rec.Status = Rec.Status::Approved) and (not Rec.Posted));

                trigger OnAction()
                begin
                    Rec.TESTFIELD(Status, Rec.Status::Approved);
                    if CONFIRM('Do you want to Post?') then begin
                        DividendManagement.PostDividend(Rec, false);
                        CurrPage.CLOSE;
                    end;
                end;
            }
            action(Members)
            {
                ApplicationArea = Basic, Suite;
                Image = Customer;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Dividend Member List";
                RunPageLink = "Dividend Code" = FIELD("No.");
            }
            action(Schedule)
            {
                ApplicationArea = Basic, Suite;
                Image = JobResponsibility;
                Promoted = true;
                PromotedCategory = Process;
                Visible = ((Rec.Status = Rec.Status::Approved) and (not Rec.Posted));

                trigger OnAction()
                begin
                    if CONFIRM('Do you want to Schedule a Monthly Processing?') then begin
                        Rec.TESTFIELD("Next Run Date");
                        Rec.Scheduled := (not Rec.Scheduled);
                        Rec.MODIFY;
                        COMMIT;
                    end;
                end;
            }
            action("Import Balances")
            {
                ApplicationArea = Basic, Suite;
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                Visible = Rec.Status = Rec.Status::Open;

                trigger OnAction()
                begin
                    DividendDetEntries.RESET;
                    DividendDetEntries.SETRANGE("Dividend Code", Rec."No.");
                    if DividendDetEntries.FINDFIRST then begin
                        if CONFIRM('Do you want to Ovewrite?') then
                            DividendDetEntries.DELETEALL;
                    end;

                    COMMIT;
                    CLEAR(DividendUpload);
                    DividendUpload.SetDivCode(Rec."No.");
                    DividendUpload.RUN;
                end;
            }
            action("Import Calculations")
            {
                ApplicationArea = Basic, Suite;
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                Visible = Rec.Status = Rec.Status::Open;

                trigger OnAction()
                begin
                    DividendDetEntries.RESET;
                    DividendDetEntries.SETRANGE("Dividend Code", Rec."No.");
                    if DividendDetEntries.FINDFIRST then
                        DividendDetEntries.DELETEALL;
                    COMMIT;
                    CLEAR(DividendUploadCalculated);
                    DividendUploadCalculated.SetDivCode(Rec."No.");
                    DividendUploadCalculated.RUN;
                end;
            }
            action("Import Withdrawn List")
            {
                ApplicationArea = Basic, Suite;
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                Visible = Rec.Status = Rec.Status::Open;

                trigger OnAction()
                begin
                    CLEAR(DividendWithdrawnMembers);
                    DividendWithdrawnMembers.SetDivCode(Rec."No.");
                    DividendWithdrawnMembers.RUN;
                end;
            }
            action("Import Member Earning")
            {
                ApplicationArea = Basic, Suite;
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                Visible = Rec.Status = Rec.Status::Open;

                trigger OnAction()
                begin
                    CLEAR(DividendMemberEarnings);
                    DividendMemberEarnings.Intialise(Rec."No.");
                    DividendMemberEarnings.RUN;
                end;
            }
            action(Recoveries)
            {
                ApplicationArea = Basic, Suite;
                Image = WIPEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Dividend Recoveries";
                RunPageLink = "Dividend Code" = FIELD("No."), Amount = FILTER(<> 0);
            }
            action("Send SMS Notifications")
            {
                ApplicationArea = Basic, Suite;
                Image = Email;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = Rec.Status = Rec.Status::Approved;
                trigger OnAction()
                begin
                    if CONFIRM('Do you want to Send SMS Notifications?') then
                        DividendManagement.SendSMSNotifications(Rec);
                end;
            }
            action("Withdrawn Members")
            {
                ApplicationArea = Basic, Suite;
                Image = Customer;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Dividend Withdrawn Members";
                RunPageLink = "Dividend Header" = FIELD("No.");
            }
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Document Type" := Rec."Document Type"::BOSA;
    end;

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
        if Rec.Scheduled = true then
            IsScheduled := false
        else
            IsScheduled := true;
    end;

    var
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesExist: Boolean;
        CanCancelApprovalForRecord: Boolean;
        CanRequestApprovalForFlow: Boolean;
        CanCancelApprovalForFlow: Boolean;
        OfficeMgt: Codeunit "Office Management";
        IsOfficeAddin: Boolean;
        DividendManagement: Codeunit "Dividend Management";
        DividendHeader: Record "Dividend Header";
        IsScheduled: Boolean;
        DividendUpload: XMLport "Dividend Upload";
        DividendDetEntries: Record "Dividend Det. Entries";
        DividendUploadCalculated: XMLport "Dividend Upload Calculated";
        DividendWithdrawnMembers: XMLport "Dividend Withdrawn Members";
        DividendMemberEarnings: XMLport "Dividend Member Earnings";
        ApprovalsMgmt: Codeunit "Approval Mgmt. CBS Ext";
}
