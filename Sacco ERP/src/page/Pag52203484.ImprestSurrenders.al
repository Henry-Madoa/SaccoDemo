page 52203484 "Imprest Surrenders"
{
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments,Navigate';
    CardPageID = "Imprest Surrender";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Request Header";
    SourceTableView = WHERE("Request Type"=const(Surrender));

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
                field("Pay Mode"; Rec."Pay Mode")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Paying Bank Code"; Rec."Paying Bank Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payment Tx No.(Cheque No.)"; Rec."Payment Tx No.(Cheque No.)")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Total Days in the Field"; Rec."Total Days in the Field")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Surrender Date"; Rec."Surrender Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Total ITO Cost"; Rec."Total Requested Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Overdue Days"; Rec."Overdue Days")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Total Request Amount"; Rec."Request Amount")
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
                }
                field("Surrender Posted By"; Rec."Surrender Posted By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Surrender Posted Date"; Rec."Surrender Posted Date")
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
                    REPORT.Run(Report::"Imprest Request Form", true, false, Rec);
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
            action("Post Surrender")
            {
                ApplicationArea = Basic, Suite;
                Image = Post;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = ((Rec.Status = Rec.Status::Approved) and (Rec.Surrendered = false));

                trigger OnAction()
                begin
                    ImprestMgt.PostImprestSurrender(Rec);
                end;
            }
            action("Reject Surrender")
            {
                ApplicationArea = Basic, Suite;
                Image = Reject;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = ((Rec.Status = Rec.Status::Approved) and (Rec.Surrendered = false));

                trigger OnAction()
                begin
                    ImprestMgt.RejectCashSurrender(Rec);
                end;
            }
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Request Type":=Rec."Request Type"::Surrender;
        Rec.Status:=Rec.Status::Open;
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
    ApprovalsMgt: Codeunit "Approval Mgmt. Ext";
    OpenApprovalEntriesExistForCurrUser: Boolean;
    OpenApprovalEntriesExist: Boolean;
    CanCancelApprovalForRecord: Boolean;
    CanRequestApprovalForFlow: Boolean;
    CanCancelApprovalForFlow: Boolean;
    IsOfficeAddin: Boolean;
    OfficeMgt: Codeunit "Office Management";
}
