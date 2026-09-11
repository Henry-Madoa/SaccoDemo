page 52203808 "Purchase Requisition Card"
{
    PageType = Card;
    SourceTable = "Requisition Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Employee No"; Rec."Employee No.")
                {
                    ApplicationArea = All;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Title; Rec.Title)
                {
                    ApplicationArea = All;
                    Caption = 'Activity';
                    Editable = CtrlEditable;
                }
                field("Requested Delivery Date"; Rec."Requested Delivery Date")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Editable = CtrlEditable;
                }
                field(Currency; Rec.Currency)
                {
                    ApplicationArea = All;
                }
                field("Requisition Date"; Rec."Created On")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Approval Entries"; Rec."Approval Entries")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            part(Control8; "Purchase Request Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Requisition No"=FIELD("No.");
            }
        }
        area(factboxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID"=CONST(66080), "No."=FIELD("No.");
            }
        }
    }
    actions
    {
        area(processing)
        {
            group(Approvals)
            {
                action("Manual Approve")
                {
                    ApplicationArea = All;
                    Caption = 'Manual Approve';
                    Enabled = Rec.Status <> Rec.Status::Approved;
                    Image = Approve;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                        RequisitionLines: Record "Requisition Lines";
                    begin
                        RequisitionLines.Reset();
                        RequisitionLines.SetRange("Requisition No", Rec."No.");
                        if RequisitionLines.FindFirst()then begin
                            repeat RequisitionLines.TestField("No.");
                                RequisitionLines.TestField(Quantity);
                                RequisitionLines.TestField("Unit Price");
                            until RequisitionLines.Next() = 0;
                        end;
                        Rec.Status:=Rec.Status::Approved;
                        Rec.Modify(true);
                    end;
                }
                action("Send Approval Request")
                {
                    ApplicationArea = All;
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        Rec.TestField(Status, Rec.Status::Open);
                        Rec.TestField(Title);
                        Rec.TestField("Global Dimension 1 Code");
                        Rec.TestField("Global Dimension 2 Code");
                        Rec.TestField(Currency);
                        Rec.TestField("Global Dimension 2 Code");
                        if not Confirm('Are you sure you want to send it for approval?')then exit;
                        RequisitionLines.Reset;
                        RequisitionLines.SetRange("Requisition No", Rec."No.");
                        if RequisitionLines.FindFirst then begin
                            LocaleCode:=RequisitionLines."Location Code";
                            repeat RequisitionLines.TestField("No.");
                                RequisitionLines.TestField("Location Code");
                                RequisitionLines.TestField("Location Code", LocaleCode);
                                RequisitionLines.TestField("Unit of Measure");
                                RequisitionLines.TestField("Global Dimension 1 Code");
                                RequisitionLines.TestField("Global Dimension 2 Code");
                                // RequisitionLines.TestField("Grant No.");
                                // RequisitionLines.TestField("Objective Code");
                                // RequisitionLines.TestField("Activity Code");
                                RequisitionLines.TestField(Description);
                                RequisitionLines.TestField(Quantity);
                                RequisitionLines.TestField("Unit Price");
                            // RequisitionLines.TestField("Grant No.");
                            // if RequisitionLines."Car Repair/Maintenance" then
                            //     RequisitionLines.TestField("Asset No.");
                            until RequisitionLines.Next = 0;
                        end;
                        //            if ApprovalsMgmt.CheckRequisitionHeaderApprovalsWorkflowEnabled(Rec) then
                        //              ApprovalsMgmt.OnSendRequisitionHeaderForApproval(Rec);
                        CurrPage.Close();
                    end;
                }
                action("Cancel Approval Request")
                {
                    ApplicationArea = All;
                    Image = CancelApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        Rec.TestField(Status, Rec.Status::"Pending Approval");
                        if not Confirm('Are you sure you want to cancel approval request?')then exit;
                        //            if ApprovalsMgmt.CheckRequisitionHeaderApprovalsWorkflowEnabled(Rec) then
                        //              ApprovalsMgmt.OnCancelRequisitionHeaderApprovalRequest(Rec);
                        CurrPage.Close();
                    end;
                }
                action("Re-Open Document")
                {
                    ApplicationArea = All;
                    Image = ReOpen;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        Rec.TestField(Status, Rec.Status::Approved);
                        Rec.TestField("Process Initiated", false);
                        ApprovalEntry.Reset;
                        ApprovalEntry.SetRange("Document No.", Rec."No.");
                        if ApprovalEntry.FindSet then begin
                            ApprovalEntry.DeleteAll;
                            Rec.Status:=Rec.Status::Open;
                            Rec."Approval Entries":=0;
                            Rec.Modify(true);
                        end;
                    end;
                }
                action(Approve)
                {
                    ApplicationArea = All;
                    Caption = 'Approve';
                    Image = Approve;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Approve the requested changes.';
                    Visible = OpenApprovalEntriesExistCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        if not Confirm('Are you sure you want to Approve the document?')then exit;
                        //               ApprovalsMgmt.ApproveRecordApprovalRequest(RecordId);
                        CurrPage.Close();
                    end;
                }
                action("Cancel Document")
                {
                    ApplicationArea = All;
                    Caption = 'Reject Document';
                    Image = Cancel;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ToolTip = 'Approve the requested changes.';
                    Visible = OpenApprovalEntriesExistCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        if not Confirm('Are you sure you want to Cancel the document?')then exit;
                        Rec.Reset;
                        Rec.SetRange("No.", Rec."No.");
                        if Rec.FindFirst then begin
                            Rec.Status:=Rec.Status::Open;
                            Rec."Approval Entries":=0;
                            if Rec.Modify(true)then Message('Successfuly Rejected');
                        end;
                        CurrPage.Close();
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = All;
                    Caption = 'Send Back To User';
                    Image = Reject;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ToolTip = 'Reject the approval request.';
                    Visible = OpenApprovalEntriesExistCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        if not Confirm('Are you sure you want to Reject the document?')then exit;
                        //            ApprovalsMgmt.RejectRecordApprovalRequest(RecordId);
                        CurrPage.Close;
                    end;
                }
                action(Delegate)
                {
                    ApplicationArea = All;
                    Caption = 'Delegate';
                    Image = Delegate;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'Delegate the approval to a substitute approver.';
                    Visible = OpenApprovalEntriesExistCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        if not Confirm('Are you sure you want to Approve the document?')then exit;
                        //            ApprovalsMgmt.DelegateRecordApprovalRequest(RecordId);
                        CurrPage.Close();
                    end;
                }
                action("Print Approved purchase requisition")
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
                        REPORT.Run(Report::"Purchase Requisition", true, false, Rec);
                    end;
                }
                action(Comment)
                {
                    ApplicationArea = All;
                    Caption = 'Comments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'View or add comments for the record.';

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.GetApprovalComment(Rec);
                    end;
                }
                action(Attachments)
                {
                    ApplicationArea = All;
                    Image = Documents;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                // RunObject = Page "Requisition Attachements";
                // RunPageLink = "Document No" = FIELD("No.");
                }
                action("Print Out")
                {
                    ApplicationArea = All;
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        Rec.Reset;
                        Rec.SetRange("No.", Rec."No.");
                        REPORT.Run(53071, true, false, Rec);
                    end;
                }
            }
            group(Processing_)
            {
                action("Create Procurement Process")
                {
                    ApplicationArea = All;
                    Image = Start;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = Visible;

                    trigger OnAction()
                    begin
                        Rec.TestField(Status, Rec.Status::Approved);
                        Rec.TestField("Process Initiated", false);
                        ProcLines.Reset;
                        ProcLines.SetRange("Requisition No", Rec."No.");
                        if ProcLines.FindSet then repeat ProcLines.TestField("Total Amount");
                            until ProcLines.Next = 0;
                        //Test Procurement Threshold Amounts
                        if not Confirm('Are you sure you want to start procurement process?')then exit;
                        ProcurementNo:=ProcStoreManagement.InitiateProcurementProcess(Rec);
                        Message('Procurement No. [%1] has been created', ProcurementNo);
                        if ProcurementNo <> '' then begin
                            Rec."Process Initiated":=true;
                            Rec.Modify(true);
                        end;
                        CurrPage.Close();
                    end;
                }
                action("Import Items")
                {
                    Image = Excel;
                    Promoted = true;

                    trigger OnAction()
                    begin
                    // Rec.TestField(Status, Rec.Status::New);
                    // ImportPurchaseRequisition.GetRecHeader(Rec);
                    // ImportPurchaseRequisition.Run;
                    end;
                }
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        FnEditable;
        SetControlAppearance;
    end;
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean begin
        Rec."Created On":=Today;
    end;
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Requisition Type":=Rec."Requisition Type"::"Purchase Requisition";
    end;
    trigger OnOpenPage()
    begin
        FnEditable;
        SetControlAppearance;
    end;
    var ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    OpenApprovalEntriesExistCurrUser: Boolean;
    OpenApprovalEntriesExist: Boolean;
    ProcStoreManagement: Codeunit "Procurement Management";
    ProcurementNo: Code[50];
    RequisitionLines: Record "Requisition Lines";
    Visible: Boolean;
    CtrlEditable: Boolean;
    ProcSetup: Record "Purchases & Payables Setup";
    ProcLines: Record "Requisition Lines";
    // IanSoftFactory: Codeunit IanSoftFactory;
    ApprovalEntry: Record "Approval Entry";
    // ImportPurchaseRequisition: Report "Import Purchase Requisition";
    LocaleCode: Code[50];
    RequisitionLinesCopy: Record "Requisition Lines";
    local procedure SetControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    //       WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
    begin
    //       OpenApprovalEntriesExistCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(RecordId);
    //       OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(RecordId);
    end;
    procedure FnEditable()
    begin
        Visible:=true;
        CtrlEditable:=true;
        if Rec.Status <> Rec.Status::Approved then Visible:=false;
        if Rec.Status <> Rec.Status::Open then CtrlEditable:=true;
    end;
}
