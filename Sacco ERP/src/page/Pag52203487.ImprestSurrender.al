page 52203487 "Imprest Surrender"
{
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments,Navigate';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Document;
    SourceTable = "Request Header";
    SourceTableView = WHERE("Request Type"=const(Surrender));

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
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    MultiLine = true;
                }
                field("Total Days in the Field"; Rec."Total Days in the Field")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Surrender Date"; Rec."Surrender Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Total ITO Cost"; Rec."Total Requested Amount")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Amount';
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
                }
                field("Request Posted By"; Rec."Posted By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Request Posted Date"; Rec."Posted Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Surrender Posted"; Rec.Surrendered)
                {
                    ApplicationArea = Basic, Suite;
                    Visible = Rec.Surrendered = true;
                }
                field("Surrender Posted By"; Rec."Surrender Posted By")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = Rec.Surrendered = true;
                }
                field("Surrender Posted Date"; Rec."Surrender Posted Date")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = Rec.Surrendered = true;
                }
            }
            group("Surrender Details")
            {
                Editable = false;

                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Overdue Days"; Rec."Overdue Days")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Request Amount"; Rec."Request Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Total Surrender Amount"; Rec."Total Surrender Amount")
                {
                    Caption = 'Surrender Amount';
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Total Claim"; Rec."Total Claim")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Total Refund"; Rec."Total Refund")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Net Refund (Net Claim)"; Rec."Net Refund (Net Claim)")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
            }
            part(Control14; "Imprest Surrender Details")
            {
                Editable = Rec.Status = Rec.Status::Open;
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
            action("Imprest Request Form")
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
            action("Imprest Surrender Form")
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
                    REPORT.Run(Report::"Imprest Surrender Form", true, false, Rec);
                end;
            }
            action("Print Refund Receipt")
            {
                ApplicationArea = Basic, Suite;
                Image = "Report";
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Report;
                Visible = Rec.Surrendered;

                trigger OnAction()
                begin
                    Rec.CalcFields("Net Refund (Net Claim)");
                    if Rec."Net Refund (Net Claim)" > 0 then begin
                        BankEntry.Reset;
                        BankEntry.SetCurrentKey("Document No.", "Posting Date");
                        BankEntry.SetRange("Document No.", Rec."No.");
                        REPORT.Run(Report::Receipt, true, false, BankEntry);
                    end
                    else
                        Error('You can only print a receipt in the case of a refund.');
                end;
            }
            action("Print Claim PV")
            {
                ApplicationArea = Basic, Suite;
                Image = "Report";
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Report;
                Visible = Rec.Surrendered;

                trigger OnAction()
                begin
                    Rec.CalcFields("Net Refund (Net Claim)");
                    if Rec."Net Refund (Net Claim)" < 0 then begin
                        Rec.Reset;
                        Rec.SetRange("No.", Rec."No.");
                        REPORT.Run(Report::"Staff Claim Voucher", true, false, Rec);
                    end
                    else
                        Error('You can only print a Payment Voucher in the case of a claim.');
                end;
            }
        }
        area(processing)
        {
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
            action("Submit Surrender")
            {
                ApplicationArea = Basic, Suite;
                Image = Post;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = ((Rec.Status = Rec.Status::Open) and (Rec.Surrendered = false));

                trigger OnAction()
                begin
                    if Rec.AttachmentValidator()then begin
                        ImprestMgt.SubmitCashSurrender(Rec);
                        CurrPage.Close;
                    end
                    else
                        Error(Rec.AttachmentValidatorResponse);
                end;
            }
            action("Post Surrender")
            {
                ApplicationArea = Basic, Suite;
                Image = Post;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = (((Rec.Status = Rec.Status::Approved) and Rec.Surrendered = false and Rec.Posted = true and FinAdmin));

                trigger OnAction()
                begin
                    ImprestMgt.PostImprestSurrender(Rec);
                    CurrPage.Close;
                end;
            }
            action("Reject Surrender")
            {
                ApplicationArea = Basic, Suite;
                Image = Reject;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Category4;
                Visible = ((Rec.Status = Rec.Status::Approved) and (Rec.Surrendered = false));

                trigger OnAction()
                begin
                    ImprestMgt.RejectCashSurrender(Rec);
                    CurrPage.Close;
                end;
            }
            action("Close Surrender")
            {
                ApplicationArea = Basic, Suite;
                Image = CloseDocument;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = (((Rec.Status = Rec.Status::Approved) and Rec.Surrendered = false and Rec.Posted = true and FinAdmin));

                trigger OnAction()
                begin
                    ImprestMgt.CloseImprestSurrender(Rec);
                    CurrPage.Close;
                end;
            }
        }
    }
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
        if not UserSetup.Get(UserId)then Error('Contact Admin for your account to be setup')
        else if not UserSetup."Finance Admin" then FinAdmin:=false
            else
                FinAdmin:=true;
        IsOfficeAddin:=OfficeMgt.IsAvailable;
    end;
    var ImprestMgt: Codeunit "Imprest Management";
    ApprovalsMgt: Codeunit "Approval Mgmt. Ext";
    OpenApprovalEntriesExistForCurrUser: Boolean;
    OpenApprovalEntriesExist: Boolean;
    CanCancelApprovalForRecord: Boolean;
    CanRequestApprovalForFlow: Boolean;
    CanCancelApprovalForFlow: Boolean;
    BankEntry: Record "Bank Account Ledger Entry";
    UserSetup: Record "User Setup";
    FinAdmin: Boolean;
    IsOfficeAddin: Boolean;
    OfficeMgt: Codeunit "Office Management";
}
