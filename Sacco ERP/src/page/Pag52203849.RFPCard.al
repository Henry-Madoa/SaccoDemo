page 52203849 "RFP Card"
{
    ApplicationArea = All;
    PageType = Card;
    SourceTable = "Procurement Request";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field(Title; Rec.Title)
                {
                    ApplicationArea = All;
                }
                field("Requisiton No"; Rec."Requisiton No")
                {
                    ApplicationArea = All;
                }
                field("Current Budget"; Rec."Current Budget")
                {
                    ApplicationArea = All;
                }
                field("Tender Closing Date"; Rec."Tender Closing Date")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Procurement Plan"; Rec."Procurement Plan")
                {
                    ApplicationArea = All;
                }
                field("Vendor No"; Rec."Vendor No")
                {
                    ApplicationArea = All;
                }
            }
            part(Control17; "RFP Lines Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Procurement No"=FIELD("No.");
            }
        }
    }
    actions
    {
        area(processing)
        {
            group(Approvals)
            {
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
                        if not Confirm('Are you sure you want to send it for approval?')then exit;
                        //              if ApprovalsMgmt.CheckProcurementRequestApprovalsWorkflowEnabled(Rec) then
                        //                ApprovalsMgmt.OnSendProcurementRequestForApproval(Rec);
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
                        //               if ApprovalsMgmt.CheckProcurementRequestApprovalsWorkflowEnabled(Rec) then
                        //                 ApprovalsMgmt.OnSendProcurementRequestForApproval(Rec);
                        CurrPage.Close();
                    end;
                }
                action(Approve)
                {
                    ApplicationArea = All;
                    Caption = 'Approve';
                    Image = Approve;
                    Promoted = true;
                    PromotedCategory = Category4;
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
                action(Reject)
                {
                    ApplicationArea = All;
                    Caption = 'Reject';
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
                action(Comment)
                {
                    ApplicationArea = All;
                    Caption = 'Comments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'View or add comments for the record.';
                    Visible = OpenApprovalEntriesExistCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.GetApprovalComment(Rec);
                    end;
                }
            }
            group("Tender Processing")
            {
                action("Award & generate Order")
                {
                    ApplicationArea = All;
                    Image = "Order";
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        //TESTFIELD(Status,Status::Approved);
                        Rec.TestField("Vendor No");
                        if not Confirm('Are you sure you want to create purchase order for the awarded vendors?')then exit;
                        OrderNo:=ProcStoreManagement.IanCreatePurchaseHeader(Rec."Vendor No", '', Rec."Requisiton No", '', Rec."No.", '', Rec."Requires Inspection", '', '', '', Rec.Title, Rec."Delivery Period (Days)");
                        ProcurementRequestLines.Reset;
                        ProcurementRequestLines.SetRange("Procurement No", Rec."No.");
                        if ProcurementRequestLines.FindSet then begin
                            repeat ProcStoreManagement.IanCreatePurchaseLines(OrderNo, ProcurementRequestLinesCopy.Type, ProcurementRequestLinesCopy."No.", ProcurementRequestLinesCopy.Quantity, ProcurementRequestLinesCopy."Unit Price", ProcurementRequestLinesCopy."Location Code", Rec."Global Dimension 1 Code", Rec."Global Dimension 2 Code", ProcurementRequestLinesCopy.Description, 0, '', '', '', '', '', '', '', '', ProcurementRequestLinesCopy."Unit of Measure");
                                if OrderNo <> '' then begin
                                    ProcurementRequestLines."Order/Contract Created":=true;
                                    ProcurementRequestLines.Modify(true);
                                end;
                            until ProcurementRequestLines.Next = 0;
                        end;
                        ProcurementRequestLines.Reset;
                        ProcurementRequestLines.SetRange("Order/Contract Created", true);
                        if ProcurementRequestLinesCopy.FindFirst then begin
                            ProcStoreManagement.IanChangeStatusOnRFPAward(Rec, OrderNo);
                        end;
                    end;
                }
            }
        }
    }
    var ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    OpenApprovalEntriesExistCurrUser: Boolean;
    OpenApprovalEntriesExist: Boolean;
    ProcurementRequestLines: Record "Procurement Request Lines";
    ProcurementRequestLinesCopy: Record "Procurement Request Lines";
    ProcStoreManagement: Codeunit "Proc & Store Management";
    OrderNo: Code[50];
    Winner: Code[50];
    local procedure SetControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    //        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
    begin
    //       OpenApprovalEntriesExistCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(RecordId);
    //       OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(RecordId);
    end;
}
