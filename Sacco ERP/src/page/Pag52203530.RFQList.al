page 52203530 "RFQ List"
{
    CardPageID = "RFQ Header";
    Caption = 'RFQ/RFP';
    PromotedActionCategories = 'New,Process,Report,Approval,Request Approval';
    DeleteAllowed = false;
    Editable = false;
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "RFQ Header";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(No; Rec."No.")
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
                field("RFP/RFQ Type"; Rec."RFP/RFQ Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Expected Opening Date"; Rec."Expected Opening Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Expected Closing Date"; Rec."Expected Closing Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
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
                SubPageLink = "Table ID"=CONST(50205), "No."=FIELD("No.");
            }
            systempart(Control13; Notes)
            {
                ApplicationArea = Basic, Suite;
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

                action(SendApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Send A&pproval Request';
                    Enabled = NOT OpenApprovalEntriesExist AND CanRequestApprovalForFlow;
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Request approval of the document.';

                    trigger OnAction()
                    begin
                        //Check attach document
                        if Rec."RFP/RFQ Type" = Rec."RFP/RFQ Type"::RFP then begin
                            Attach.Reset();
                            Attach.SetRange("No.", Rec."No.");
                            if Attach.FindFirst()then if(Attach."File Name" = '')then Error('You have not attach your RFP document''s');
                        end
                        else
                            ApprovalsMgt.OnSendRFQForApproval(Rec);
                        CurrPage.Close();
                    end;
                }
                action(CancelApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cancel Approval Re&quest';
                    Enabled = CanCancelApprovalForRecord OR CanCancelApprovalForFlow;
                    Image = CancelApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'Cancel the approval request.';

                    trigger OnAction()
                    var
                        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
                    begin
                        Rec.TestField(Status, Rec.Status::"Pending Approval");
                        IF CONFIRM('Are you sure you want to cancel the RFQ-RFP %1. Do you want to continue?', FALSE, Rec."No.")THEN ApprovalsMgt.OnCancelRFQApprovalRequest(Rec);
                        CurrPage.Close();
                        WorkflowWebhookMgt.FindAndCancel(Rec.RecordId);
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
                        PromotedCategory = Category5;
                        ToolTip = 'View a list of the records that are waiting to be approved. For example, you can see who requested the record to be approved, when it was sent, and when it is due to be approved.';

                        trigger OnAction()
                        var
                            ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        begin
                            ApprovalsMgmt.OpenApprovalEntriesPage(Rec.RecordId);
                        end;
                    }
                }
            }
            group("Manual Approval")
            {
                Visible = NOT OpenApprovalEntriesExistForCurrUser;

                action(Reopen)
                {
                    ApplicationArea = Suite;
                    Caption = 'Re&open';
                    Enabled = Rec.Status = Rec.Status::Approved;
                    Image = ReOpen;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;

                    trigger OnAction()
                    begin
                        Rec.Validate(Status, Rec.Status::Open);
                        Rec.Modify(true);
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
                    begin
                        IF CONFIRM('Are you sure you want to approve the Procurement Plan %1. Do you want to continue?', FALSE, Rec."No.")THEN ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
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
                    begin
                        IF CONFIRM('Are you sure you want to reject the Procurement Plan %1. Do you want to continue?', FALSE, Rec."No.")THEN ApprovalsMgmt.RejectRecordApprovalRequest(Rec.RecordId);
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
                action("View Quotes")
                {
                    ApplicationArea = Basic, Suite;
                    Image = View;
                    Promoted = true;
                    PromotedIsBig = true;
                    Visible = false;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        RFQVendors.Reset;
                        RFQVendors.SetRange("RFQ No", Rec."No.");
                        if RFQVendors.FindSet then begin
                            repeat QuoteRec.Reset;
                                if QuoteRec.Get(QuoteRec."Document Type"::Quote, RFQVendors."Quote No")then PAGE.Run(49, QuoteRec)
                                else
                                    Error('A quote has not been generated for %1', RFQVendors.Name);
                            until RFQVendors.Next = 0;
                        end
                        else
                            Error('No vendors have been assigned for this RFQ.');
                    end;
                }
                action("Generate RFQ")
                {
                    ApplicationArea = Basic, Suite;
                    Image = "Report";
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    Visible = (Rec.Status = Rec.Status::Approved);

                    trigger OnAction()
                    begin
                        RFQVendors.Reset;
                        RFQVendors.SetRange("RFQ No", Rec."No.");
                        if RFQVendors.Find('-')then begin
                            repeat QuoteRec.Reset;
                                QuoteRec.SetRange("No.", RFQVendors."Quote No");
                                if QuoteRec.FindLast then begin
                                    REPORT.Run(50203, true, false, QuoteRec);
                                end;
                            until RFQVendors.Next = 0;
                        end;
                    end;
                }
                action("Quote Analysis")
                {
                    ApplicationArea = Basic, Suite;
                    Image = "Report";
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    Visible = (Rec.Status = Rec.Status::Approved);

                    trigger OnAction()
                    begin
                        RFQLines.Reset;
                        RFQLines.SetRange("RFQ No", Rec."No.");
                        REPORT.Run(50201, true, false, RFQLines);
                    end;
                }
                action("Send RFQ via Email")
                {
                    ApplicationArea = Basic, Suite;
                    Image = ElectronicDoc;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    Visible = (Rec.Status = Rec.Status::Approved);

                    trigger OnAction()
                    begin
                        RFQVendors.Reset;
                        RFQVendors.SetRange("RFQ No", Rec."No.");
                        if RFQVendors.Find('-')then begin
                            repeat QuoteRec.Reset;
                                QuoteRec.SetRange("No.", RFQVendors."Quote No");
                                if QuoteRec.FindLast then begin
                                    REPORT.Run(50204, false, false, QuoteRec);
                                end;
                            until RFQVendors.Next = 0;
                        end;
                    end;
                }
                action(Print)
                {
                    ApplicationArea = Suite;
                    Caption = 'Print';
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Report;
                    PromotedOnly = true;

                    trigger OnAction()
                    begin
                        Rec.RESET;
                        Rec.SetRange("No.", Rec."No.");
                        REPORT.RUN(Report::"Request For Quatation", TRUE, FALSE, Rec);
                    end;
                }
            }
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
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
    end;
    var RFQLines: Record "RFQ Lines";
    RFQVendors: Record "RFQ Vendors";
    QuoteRec: Record "Purchase Header";
    ApprovalsMgt: Codeunit "Approval Mgmt. Ext";
    OpenApprovalEntriesExistForCurrUser: Boolean;
    OpenApprovalEntriesExist: Boolean;
    CanCancelApprovalForRecord: Boolean;
    CanRequestApprovalForFlow: Boolean;
    CanCancelApprovalForFlow: Boolean;
    Attach: Record "Document Attachment";
}
