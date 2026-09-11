page 52203805 "Store Requisition Card"
{
    PageType = Card;
    SourceTable = "Requisition Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = Ditable;

                field("No."; Rec."No.")
                {
                    Editable = false;
                }
                field("Employee No"; Rec."Employee No.")
                {
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    Editable = false;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                }
                field(Status; Rec.Status)
                {
                    Editable = false;
                }
                field("Global Dimension 3 Code"; Rec."Global Dimension 3 Code")
                {
                    Visible = false;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    Visible = false;
                }
                field("Approval Entries"; Rec."Approval Entries")
                {
                }
                field("Store Location"; Rec."Store Location")
                {
                    Visible = false;
                }
            }
            part(Control8; "Store Requisition Subform")
            {
                SubPageLink = "Requisition No"=FIELD("No.");
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Send Approval Request")
            {
                Image = SendApprovalRequest;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Status, Rec.Status::Open);
                    Rec.TestField("Global Dimension 1 Code");
                    Rec.TestField("Global Dimension 2 Code");
                    // TESTFIELD("Store Location");
                    //TESTFIELD("Global Dimension 3 Code");
                    //Test Lease Fields if Leasing
                    RLines.Reset;
                    RLines.SetRange("Requisition No", Rec."No.");
                    RLines.SetRange(Type, RLines.Type::Item);
                    if RLines.FindSet then begin
                        repeat RLines.TestField(Quantity);
                            RLines.TestField("No.");
                            RLines.TestField("Location Code");
                            RLines.TestField(Description);
                        until RLines.Next = 0;
                    end;
                    //End of Lease Test
                    //Test Lease Fields if Leasing
                    RLines.Reset;
                    RLines.SetRange("Requisition No", Rec."No.");
                    RLines.SetRange(Type, RLines.Type::"Fixed Asset");
                    RLines.SetRange("FA Transaction Type", RLines."FA Transaction Type"::Lease);
                    if RLines.FindSet then repeat RLines.TestField("Lease Period(Months=M,Years=Y)");
                            RLines.TestField("Lease Start Date");
                        until RLines.Next = 0;
                    //End of Lease Test
                    if not Confirm('Are you sure you want to send it for approval?')then exit;
                    //       if ApprovalsMgmt.CheckRequisitionHeaderApprovalsWorkflowEnabled(Rec) then
                    //         ApprovalsMgmt.OnSendRequisitionHeaderForApproval(Rec);
                    CurrPage.Close();
                end;
            }
            action("Cancel Approval Request")
            {
                Image = CancelApprovalRequest;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Status, Rec.Status::"Pending Approval");
                    if not Confirm('Are you sure you want to cancel approval request?')then exit;
                    //        if ApprovalsMgmt.CheckRequisitionHeaderApprovalsWorkflowEnabled(Rec) then
                    //          ApprovalsMgmt.OnCancelRequisitionHeaderApprovalRequest(Rec);
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
                    //       ApprovalsMgmt.ApproveRecordApprovalRequest(RecordId);
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
                    //      ApprovalsMgmt.RejectRecordApprovalRequest(RecordId);
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
                    //       ApprovalsMgmt.DelegateRecordApprovalRequest(RecordId);
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

                trigger OnAction()
                var
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    ApprovalsMgmt.GetApprovalComment(Rec);
                end;
            }
            action(Attachments)
            {
                Image = Documents;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
            //        RunObject = Page "Requisition Attachements";
            //        RunPageLink = "Document No" = FIELD("No.");
            }
            action(Post)
            {
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Status, Rec.Status::Approved);
                    Rec.TestField(Posted, false);
                    //To be activated in live system
                    if UserSetup.Get(UserId)then begin
                        UserSetup.TestField("Is Store Admin", true);
                    end;
                    if not Confirm('Are you sure you want to post store requisition?')then exit;
                    RequisitionLinesCopy.Reset;
                    RequisitionLinesCopy.SetRange("Requisition No", Rec."No.");
                    if RequisitionLinesCopy.FindFirst then begin
                        repeat ItemLedgerEntry.Reset;
                            ItemLedgerEntry.SetRange("Item No.", RequisitionLinesCopy."No.");
                            ItemLedgerEntry.SetRange("Location Code", RequisitionLinesCopy."Location Code");
                            if ItemLedgerEntry.FindSet then begin
                                ItemLedgerEntry.CalcSums(Quantity);
                                ItemsInStock:=ItemLedgerEntry.Quantity;
                                if ItemUnitofMeasure.Get(RequisitionLinesCopy."No.", RequisitionLinesCopy."Unit of Measure")then begin
                                    StockItems:=ItemsInStock / ItemUnitofMeasure."Qty. per Unit of Measure";
                                    if StockItems - RequisitionLinesCopy.Quantity < 0 then Error('The issue of item %1 - %2 will lead to negative inventory', RequisitionLinesCopy."No.", RequisitionLinesCopy.Description);
                                end;
                            end;
                        until RequisitionLinesCopy.Next = 0;
                    end;
                    //        StoreReqManagement.IanOnPostStoreRequisition(Rec);
                    Rec."Posted By":=UserId;
                    Rec."Posting Date":=Today;
                    CurrPage.Close;
                end;
            }
            action("Store Requisition Document")
            {
                Image = "Report";
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.Reset;
                    Rec.SetFilter("No.", Rec."No.");
                    REPORT.Run(53072, true, true, Rec);
                end;
            }
            action("Confirm Receipt")
            {
                Image = Confirm;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Posted, true);
                    Rec.TestField(Status, Rec.Status::Approved);
                    if Rec."Created By" <> UserId then Error('You are not the requester');
                    if not Confirm('Are you sure you have received the said items?')then exit;
                    Rec.Status:=Rec.Status::Received;
                    if Rec.Modify then Message('The requisition has been marked as received');
                end;
            }
            action("Re-Open")
            {
                Image = ReOpen;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Posted, false);
                    RequisitionHeader.Reset;
                    RequisitionHeader.SetRange("No.", Rec."No.");
                    if RequisitionHeader.FindFirst then begin
                        RequisitionHeader.Status:=RequisitionHeader.Status::Open;
                        if RequisitionHeader.Modify(true)then begin
                            ApprovalEntry.Reset;
                            ApprovalEntry.SetRange("Document No.", RequisitionHeader."No.");
                            if ApprovalEntry.FindSet then begin
                                ApprovalEntry.DeleteAll;
                                Message('Document has been re-opened successfully');
                            end;
                        end;
                    end;
                end;
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        SetControlAppearance;
        FnEdit;
    end;
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Requisition Type":=Rec."Requisition Type"::"Store Requisition";
    // Rec."Requesting Person" := Rec."Requesting Person"::Employee;
    end;
    trigger OnOpenPage()
    begin
        SetControlAppearance;
        FnEdit;
    end;
    var ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    OpenApprovalEntriesExistCurrUser: Boolean;
    OpenApprovalEntriesExist: Boolean;
    //     IanSoftFactory: Codeunit IanSoftFactory;
    //     StoreReqManagement: Codeunit "Store Req. Management";
    RLines: Record "Requisition Lines";
    UserSetup: Record "User Setup";
    Ditable: Boolean;
    ItemLedgerEntry: Record "Item Ledger Entry";
    ItemUnitofMeasure: Record "Item Unit of Measure";
    ItemsInStock: Decimal;
    StockItems: Decimal;
    RequisitionLinesCopy: Record "Requisition Lines";
    ApprovalEntry: Record "Approval Entry";
    RequisitionHeader: Record "Requisition Header";
    local procedure SetControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    //       WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
    begin
    //       OpenApprovalEntriesExistCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(RecordId);
    //      OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(RecordId);
    end;
    local procedure FnEdit()
    begin
        Ditable:=true;
        if Rec.Status <> Rec.Status::Open then Ditable:=false;
    end;
}
