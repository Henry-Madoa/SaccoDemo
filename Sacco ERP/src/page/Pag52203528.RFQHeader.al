page 52203528 "RFQ Header"
{
    Caption = 'RFQ/RFP';
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments';
    RefreshOnActivate = true;
    PageType = Card;
    SourceTable = "RFQ Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = Rec.Status = Rec.Status::Open;

                field(No; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the number of the purchase document. The field is only visible if you have not set up a number series for the type of rfq/rfp document, or if the Manual Nos. field is selected for the number series.';
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Department';
                }
                field("RFP/RFQ Type"; Rec."RFP/RFQ Type")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'RFP/RFQ';
                    ShowMandatory = true;
                    ToolTip = 'Specifies between the rfp/rfq';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    MultiLine = true;
                    ShowMandatory = true;
                    ToolTip = 'Enter the description/ brief of the rfp/rfq''s.';
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Enter the remark''s .';
                }
                field("Expected Opening Date"; Rec."Expected Opening Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Enter the date of the expected opening date.';
                }
                field("Expected Closing Date"; Rec."Expected Closing Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Enter the date of the expected closing date.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Enter a code for the location where you want the items to be placed when they are received.';
                }
                field("Pending Approvals"; Rec."Pending Approvals")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;

                    trigger OnAssistEdit()
                    var
                        Entries: Record "Approval Entry";
                    begin
                        Entries.Reset();
                        Entries.SetRange("Table ID", 50205);
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
                        Entries.SetRange("Table ID", 50205);
                        Entries.SetRange("Document No.", Rec."No.");
                        Entries.SetFilter(Status, '=%1', Entries.Status::Approved);
                        Page.RunModal(Page::"Custom Approval Entries", Entries);
                    end;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    //Visible = false;
                    Editable = false;
                    ToolTip = 'Specifies whether the record is open, waiting to be approved, invoiced for prepayment, or released to the next stage of processing.';
                }
            }
            part(Control16; "RFQ Lines")
            {
                Editable = Rec.Status = Rec.Status::Open;
                ApplicationArea = Basic, Suite;
                SubPageLink = "RFQ No"=FIELD("No.");
                Caption = 'RFQ/RFP Lines';
            //Visible = (Type = type::RFQ);
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
            part("Approval Entries"; "Customize Approval Entries")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Approval Entries';
                SubPageLink = "Table ID"=CONST(50205), "Document No."=FIELD("No.");
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
            action("Get Requisitions")
            {
                ApplicationArea = Basic, Suite;
                Image = GetLines;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    ProcurementManagement.GetRequisitionsToRFQ(Rec);
                end;
            }
            action("Assign Vendor(s)")
            {
                ApplicationArea = Basic, Suite;
                Image = Allocate;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                RunObject = Page "RFQ Vendors";
                RunPageLink = "RFQ No"=FIELD("No.");
            }
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
                    PromotedCategory = Category6;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Request approval of the document.';

                    trigger OnAction()
                    begin
                        //Check empty line
                        Rec.TestField(Description);
                        /*CalcFields("Empty No.");
                        if "Empty No." = true then
                            Error('The No. must be filled on the lines.');*/
                        //RFP
                        if Rec."RFP/RFQ Type" = Rec."RFP/RFQ Type"::RFP then begin
                            //Check attach document
                            Attach.Reset();
                            Attach.SetRange("No.", Rec."No.");
                            if Attach.FindFirst()then begin
                                ApprovalsMgt.OnSendRFQForApproval(Rec);
                                CurrPage.Close();
                            end
                            else if(Attach."File Name" = '')then Error('You have not attach your RFP document''s');
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
                    PromotedCategory = Category6;
                    PromotedOnly = true;
                    ToolTip = 'Cancel the approval request.';

                    trigger OnAction()
                    var
                        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
                    begin
                        Rec.TestField("Created By", UserId);
                        Rec.TestField(Status, Rec.Status::"Pending Approval");
                        if Confirm(StrSubstNo(Text002, Rec."No."), false)then begin
                            ApprovalsMgt.OnCancelRFQApprovalRequest(Rec);
                            CurrPage.Close();
                            WorkflowWebhookMgt.FindAndCancel(Rec.RecordId);
                            CurrPage.Update(true);
                        end
                        else
                        begin
                            exit;
                        end;
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
                        PromotedCategory = Category4;
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
                    Enabled = ((Rec.Status = Rec.Status::Approved));
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
                action("Manual Approve")
                {
                    ApplicationArea = Suite;
                    Caption = 'Manual Approve';
                    Enabled = ((Rec.Status <> Rec.Status::Approved));
                    Image = Approve;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                        RFQVendors: Record "RFQ Vendors";
                    begin
                        Rec.TestField("Expected Opening Date");
                        Rec.TestField("Expected Closing Date");
                        rec.TestField(Description);
                        RFQVendors.Reset();
                        RFQVendors.SetRange("RFQ No", Rec."No.");
                        if RFQVendors.IsEmpty then begin
                            Error('You have to assign vendors before approval');
                        end;
                        Rec.Validate(Status, Rec.Status::Approved);
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
                        IF CONFIRM(StrSubstNo(Text000, Rec."No."), false) = true then begin
                            ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
                            CurrPage.Update(true);
                        end
                        else
                        begin
                            exit;
                        end;
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
                        ApprovalComments: Record "Approval Comment Line";
                    begin
                        if Confirm(StrSubstNo(Text001, Rec."No."), false) = true then begin
                            // //CheckcommentbeforeRejecting
                            ApprovalComments.Reset;
                            ApprovalComments.SetRange("Table ID", Rec.RecordID.TableNo);
                            ApprovalComments.SetRange("User ID", UserId);
                            ApprovalComments.SetFilter(Comment, '<>%1', '');
                            if not ApprovalComments.FindFirst then Error('Please comment first before rejecting')
                            else
                            begin
                                //Reject function
                                ApprovalsMgmt.RejectRecordApprovalRequest(Rec.RecordId);
                                CurrPage.Update(true);
                            end;
                        end
                        else
                        begin
                            exit;
                        end;
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
                    Visible = (Rec.Status = Rec.Status::Approved);
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        RFQVendors.Reset;
                        RFQVendors.SetRange("RFQ No", Rec."No.");
                        if RFQVendors.FindSet then begin
                            repeat QuoteRec.Reset;
                                if QuoteRec.Get(QuoteRec."Document Type"::Quote, RFQVendors."Quote No")then PAGE.Run(Page::"Purchase Quote", QuoteRec)
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

                    trigger OnAction()
                    begin
                        RFQVendors.Reset;
                        RFQVendors.SetRange("RFQ No", Rec."No.");
                        if RFQVendors.Find('-')then begin
                            repeat QuoteRec.Reset;
                                QuoteRec.SetRange("No.", RFQVendors."Quote No");
                                if QuoteRec.FindLast then begin
                                    REPORT.Run(Report::RFQ, true, false, QuoteRec);
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
                        REPORT.Run(Report::"Quote Analysis", true, false, RFQLines);
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
                            if QuoteRec."RFQ Status" = QuoteRec."RFQ Status"::Created then QuoteRec."RFQ Status":=QuoteRec."RFQ Status"::Sent;
                        end;
                        Message('RFQ has been sent to vendor''s.');
                        if Rec."RFQ Status" = Rec."RFQ Status"::Created then Rec."RFQ Status":=Rec."RFQ Status"::Sent;
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
    var ProcurementManagement: Codeunit "Procurement Management";
    RFQLines: Record "RFQ Lines";
    RFQVendors: Record "RFQ Vendors";
    QuoteRec: Record "Purchase Header";
    NoSeriesMgt: Codeunit NoSeriesManagement;
    ApprovalsMgt: Codeunit "Approval Mgmt. Ext";
    OpenApprovalEntriesExistForCurrUser: Boolean;
    OpenApprovalEntriesExist: Boolean;
    CanCancelApprovalForRecord: Boolean;
    CanRequestApprovalForFlow: Boolean;
    CanCancelApprovalForFlow: Boolean;
    Attach: Record "Document Attachment";
    Text000: Label 'Are you sure you want to approve the RFQ-RFP %1. Do you want to continue?';
    Text001: Label 'Are you sure you want to reject the RFQ-RFP %1. Do you want to continue?';
    Text002: Label 'Are you sure you want to cancel the RFQ-RFP %1. Do you want to continue?';
}
