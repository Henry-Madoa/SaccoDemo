page 52204123 "Standing Orders"
{
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments,Navigate';
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Standing Order";
    SourceTableView = sorting("No.") order(descending);
    CardPageId = "Standing Order";
    ModifyAllowed = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Standing Order Class"; Rec."Standing Order Class")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Old FOSA No."; Rec."Old FOSA No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member No"; Rec."Member No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Source Account Code"; Rec."Source Account Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account No"; Rec."Account No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Amount Type"; Rec."Amount Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Salary Based"; Rec."Salary Based")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Destination Member No"; Rec."Destination Member No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Destination Name"; Rec."Destination Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Destination Account Code"; Rec."Destination Account Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Destination Account"; Rec."Destination Account")
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
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Running; Rec.Running)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employer Code"; Rec."Employer Code")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
        area(FactBoxes)
        {
            part("Member Statistics"; "Member Statistics")
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "No." = field("Member No");
            }
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(Database::"Standing Order"), "No." = FIELD("No.");
            }
            part(Control27; "Pending Approval FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Table ID" = CONST(Database::"Standing Order"), "Document No." = FIELD("No.");
                Visible = OpenApprovalEntriesExistForCurrUser;
            }
            part("Approval Entries"; "Customize Approval Entries")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Approval Entries';
                SubPageLink = "Table ID" = CONST(Database::"Standing Order"), "Document No." = FIELD("No.");
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }
    actions
    {
        area(Processing)
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
                        Rec.OnBeforeSendingForApproval;
                        ApprovalsMgmtExt.OnSendStandingOrderForApproval(Rec);
                        CurrPage.Close();
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
                        ApprovalsMgmtExt.OnCancelStandingOrderForApproval(Rec);
                        CurrPage.Close();
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
            action(Reopen)
            {
                ApplicationArea = Basic, Suite;
                Image = ReOpen;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ((Rec.Status = Rec.Status::Approved) and Rec.Running and not Rec.Terminated);

                trigger OnAction()
                begin
                    if Confirm('Do you want to reopen?') then begin
                        Rec.Status := Rec.Status::Open;
                        Rec.Running := false;
                        Rec.Modify();
                    end;
                end;
            }
            action("Validate Destination Accounts")
            {
                ApplicationArea = Basic, Suite;
                Image = ReOpen;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = false;

                trigger OnAction()
                var
                    StandingOrder: Record "Standing Order";
                begin
                    StandingOrder.Reset();
                    StandingOrder.SetRange(Status, StandingOrder.Status::Approved);
                    StandingOrder.SetFilter("Destination Account", '=%1', '');
                    if StandingOrder.FindSet then begin
                        repeat
                            if StandingOrder."Destination Member No" <> '' then begin
                                StandingOrder.Validate("Destination Account Code");
                                StandingOrder.Modify(true);
                            end;
                        until StandingOrder.Next = 0;
                    end;
                end;
            }
            action(Terminate)
            {
                ApplicationArea = Basic, Suite;
                Image = CancelAllLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ((Rec.Status = Rec.Status::Approved) and Rec.Running and not Rec.Terminated);
                trigger OnAction()
                begin
                    Rec.TestField(Rec.Running, true);
                    if Confirm('Do you want to Cancel?') then begin
                        Rec.Terminated := true;
                        Rec.Running := false;
                        Rec.modify;
                        CurrPage.Close();
                    end;
                end;
            }
            action(Freeze)
            {
                ApplicationArea = Basic, Suite;
                Image = UpdateDescription;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ((Rec.Status = Rec.Status::Approved) and Rec.Running and not Rec.Terminated);

                trigger OnAction()
                begin
                    Rec.Reset;
                    Rec.SetRange("No.", Rec."No.");
                    if Rec.Findset then Report.Run(Report::"STO Freeze Management", false, false, Rec);
                end;
            }
            action("Update Source Account")
            {
                ApplicationArea = Basic, Suite;
                Image = UpdateDescription;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                // Visible = ((Rec.Status = Rec.Status::Approved) and Rec.Running and not Rec.Terminated);
                Visible = false;

                trigger OnAction()
                var
                    StandingOrders: Record "Standing Order";
                begin
                    StandingOrders.Reset;
                    StandingOrders.SetFilter("Source Account Code", '<>%1', '');
                    if StandingOrders.Findset then
                        repeat
                            StandingOrders.Validate("Source Account Code");
                            StandingOrders.Modify(true);
                        until StandingOrders.Next = 0;
                end;
            }
            action("Update Loan No. Loan Principal+Interest")
            {
                ApplicationArea = Basic, Suite;
                Image = UpdateDescription;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                // Visible = ((Rec.Status = Rec.Status::Approved) and Rec.Running and not Rec.Terminated);
                //Visible = false;

                trigger OnAction()
                var
                    StandingOrders: Record "Standing Order";
                    CheckoffCalculation: Record "Checkoff Calculation";
                    DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
                    GLEntry: Record "G/L Entry";
                    VendorLedgerEntry: Record "Vendor Ledger Entry";
                    Window: Dialog;
                    All, Current : Integer;
                begin
                    CheckoffCalculation.Reset;
                    CheckoffCalculation.SetFilter("Document No", 'SPR00625..SPR00643');
                    CheckoffCalculation.SetRange("Entry Type", CheckoffCalculation."Entry Type"::"Standing Order");
                    if CheckoffCalculation.Findset then begin
                        All := CheckoffCalculation.Count;
                        Current := 0;
                        Window.Open('Updating \#1### \#2##');
                        repeat
                            Window.Update(1, CheckoffCalculation."Document No");
                            Window.Update(2, Format(Current) + ' of ' + Format(All));
                            Current += 1;
                            if StandingOrders.Get(CheckoffCalculation."Account No") then begin
                                If StandingOrders."Standing Order Class" = StandingOrders."Standing Order Class"::"Loan Principal+Interest" then begin
                                    DetailedVendorLedgEntry.Reset();
                                    DetailedVendorLedgEntry.SetRange("Document No.", CheckoffCalculation."Document No");
                                    DetailedVendorLedgEntry.SetRange("Member No.", CheckoffCalculation."Member No");
                                    DetailedVendorLedgEntry.SetRange("Product Posting Type", DetailedVendorLedgEntry."Product Posting Type"::"Loan Account");
                                    DetailedVendorLedgEntry.SetRange("Sacco Transaction Type", DetailedVendorLedgEntry."Sacco Transaction Type"::"Interest Paid");
                                    DetailedVendorLedgEntry.SetFilter("Posting Date", '%1..%2', DMY2Date(23, 4, 2026), DMY2Date(27, 4, 2026));
                                    if DetailedVendorLedgEntry.FindSet then begin
                                        repeat
                                            if DetailedVendorLedgEntry."Loan No." <> StandingOrders."Destination Account" then begin
                                                DetailedVendorLedgEntry."Loan No." := StandingOrders."Destination Account";
                                                DetailedVendorLedgEntry.Modify;
                                                Commit;
                                            end;
                                        until DetailedVendorLedgEntry.Next = 0;
                                    end;

                                    VendorLedgerEntry.Reset();
                                    VendorLedgerEntry.SetRange("Document No.", CheckoffCalculation."Document No");
                                    VendorLedgerEntry.SetRange("Product Posting Type", VendorLedgerEntry."Product Posting Type"::"Loan Account");
                                    VendorLedgerEntry.SetRange("Sacco Transaction Type", VendorLedgerEntry."Sacco Transaction Type"::"Interest Paid");
                                    VendorLedgerEntry.SetRange("Member No.", CheckoffCalculation."Member No");
                                    VendorLedgerEntry.SetFilter("Posting Date", '%1..%2', DMY2Date(23, 4, 2026), DMY2Date(27, 4, 2026));
                                    if VendorLedgerEntry.FindSet then begin
                                        repeat
                                            if VendorLedgerEntry."Loan No." <> StandingOrders."Destination Account" then begin
                                                VendorLedgerEntry."Loan No." := StandingOrders."Destination Account";
                                                VendorLedgerEntry.Modify;
                                                Commit;
                                            end;
                                        until VendorLedgerEntry.Next = 0;
                                    end;

                                    GLEntry.Reset();
                                    GLEntry.SetRange("Document No.", CheckoffCalculation."Document No");
                                    GLEntry.SetRange("Product Posting Type", GLEntry."Product Posting Type"::"Loan Account");
                                    GLEntry.SetRange("Sacco Transaction Type", GLEntry."Sacco Transaction Type"::"Interest Paid");
                                    GLEntry.SetRange("Member No.", CheckoffCalculation."Member No");
                                    GLEntry.SetFilter("Posting Date", '%1..%2', DMY2Date(23, 4, 2026), DMY2Date(27, 4, 2026));
                                    if GLEntry.FindSet then begin
                                        repeat
                                            if GLEntry."Loan No." <> StandingOrders."Destination Account" then begin
                                                GLEntry."Loan No." := StandingOrders."Destination Account";
                                                GLEntry.Modify;
                                                Commit;
                                            end;
                                        until GLEntry.Next = 0;
                                    end;
                                end;
                            end;
                        until CheckoffCalculation.Next = 0;
                    end;
                end;
            }
            action("Update Loan No. Loan Recoveries")
            {
                ApplicationArea = Basic, Suite;
                Image = UpdateDescription;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                // Visible = ((Rec.Status = Rec.Status::Approved) and Rec.Running and not Rec.Terminated);
                //Visible = false;

                trigger OnAction()
                var
                    StandingOrders: Record "Standing Order";
                    CheckoffCalculation: Record "Checkoff Calculation";
                    VendorLedgerEntry: array[2] of Record "Vendor Ledger Entry";
                    DetailedVendorLedgEntry: array[2] of Record "Detailed Vendor Ledg. Entry";
                    GLEntry: array[2] of Record "G/L Entry";
                    Vendor: Record Vendor;
                    Window: Dialog;
                    All, Current : Integer;
                begin
                    CheckoffCalculation.Reset;
                    CheckoffCalculation.SetFilter("Document No", 'SPR00625..SPR00643');
                    CheckoffCalculation.SetRange("Entry Type", CheckoffCalculation."Entry Type"::"Loan Recovery");
                    if CheckoffCalculation.Findset then begin
                        All := CheckoffCalculation.Count;
                        Current := 0;
                        Window.Open('Updating \#1### \#2##');
                        repeat
                            Window.Update(1, CheckoffCalculation."Document No");
                            Window.Update(2, Format(Current) + ' of ' + Format(All));
                            Current += 1;
                            if Vendor.Get(CheckoffCalculation."Account No") then begin
                                DetailedVendorLedgEntry[1].Reset();
                                DetailedVendorLedgEntry[1].SetRange("Document No.", CheckoffCalculation."Document No");
                                DetailedVendorLedgEntry[1].SetRange("Vendor No.", Vendor."No.");
                                DetailedVendorLedgEntry[1].SetRange("Member No.", CheckoffCalculation."Member No");
                                DetailedVendorLedgEntry[1].SetRange("Product Posting Type", DetailedVendorLedgEntry[1]."Product Posting Type"::"Loan Account");
                                DetailedVendorLedgEntry[1].SetRange("Sacco Transaction Type", DetailedVendorLedgEntry[1]."Sacco Transaction Type"::"Principal Paid");
                                DetailedVendorLedgEntry[1].SetFilter("Posting Date", '%1..%2', DMY2Date(23, 4, 2026), DMY2Date(27, 4, 2026));
                                if DetailedVendorLedgEntry[1].FindFirst then begin
                                    DetailedVendorLedgEntry[2].Reset();
                                    DetailedVendorLedgEntry[2].SetRange("Document No.", CheckoffCalculation."Document No");
                                    DetailedVendorLedgEntry[2].SetRange("Vendor No.", Vendor."No.");
                                    DetailedVendorLedgEntry[2].SetRange("Member No.", CheckoffCalculation."Member No");
                                    DetailedVendorLedgEntry[2].SetRange("Product Posting Type", DetailedVendorLedgEntry[2]."Product Posting Type"::"Loan Account");
                                    DetailedVendorLedgEntry[2].SetRange("Sacco Transaction Type", DetailedVendorLedgEntry[2]."Sacco Transaction Type"::"Interest Paid");
                                    DetailedVendorLedgEntry[2].SetFilter("Posting Date", '%1..%2', DMY2Date(23, 4, 2026), DMY2Date(27, 4, 2026));
                                    if DetailedVendorLedgEntry[2].FindFirst then begin
                                        DetailedVendorLedgEntry[2]."Loan No." := DetailedVendorLedgEntry[1]."Loan No.";
                                        DetailedVendorLedgEntry[2].Modify;
                                    end;
                                end;

                                VendorLedgerEntry[1].Reset();
                                VendorLedgerEntry[1].SetRange("Document No.", CheckoffCalculation."Document No");
                                VendorLedgerEntry[1].SetRange("Vendor No.", Vendor."No.");
                                VendorLedgerEntry[1].SetRange("Member No.", CheckoffCalculation."Member No");
                                VendorLedgerEntry[1].SetRange("Product Posting Type", VendorLedgerEntry[1]."Product Posting Type"::"Loan Account");
                                VendorLedgerEntry[1].SetRange("Sacco Transaction Type", VendorLedgerEntry[1]."Sacco Transaction Type"::"Principal Paid");
                                VendorLedgerEntry[1].SetFilter("Posting Date", '%1..%2', DMY2Date(23, 4, 2026), DMY2Date(27, 4, 2026));
                                if VendorLedgerEntry[1].FindFirst then begin
                                    VendorLedgerEntry[2].Reset();
                                    VendorLedgerEntry[2].SetRange("Document No.", CheckoffCalculation."Document No");
                                    VendorLedgerEntry[2].SetRange("Vendor No.", Vendor."No.");
                                    VendorLedgerEntry[2].SetRange("Member No.", CheckoffCalculation."Member No");
                                    VendorLedgerEntry[2].SetRange("Product Posting Type", VendorLedgerEntry[2]."Product Posting Type"::"Loan Account");
                                    VendorLedgerEntry[2].SetRange("Sacco Transaction Type", VendorLedgerEntry[2]."Sacco Transaction Type"::"Interest Paid");
                                    VendorLedgerEntry[2].SetFilter("Posting Date", '%1..%2', DMY2Date(23, 4, 2026), DMY2Date(27, 4, 2026));
                                    if VendorLedgerEntry[2].FindFirst then begin
                                        VendorLedgerEntry[2]."Loan No." := VendorLedgerEntry[1]."Loan No.";
                                        VendorLedgerEntry[2].Modify;
                                    end;
                                end;

                                GLEntry[1].Reset();
                                GLEntry[1].SetRange("Document No.", CheckoffCalculation."Document No");
                                GLEntry[1].SetRange("Product Posting Type", GLEntry[1]."Product Posting Type"::"Loan Account");
                                GLEntry[1].SetRange("Sacco Transaction Type", GLEntry[1]."Sacco Transaction Type"::"Principal Paid");
                                GLEntry[1].SetRange("Member No.", CheckoffCalculation."Member No");
                                GLEntry[1].SetFilter("Posting Date", '%1..%2', DMY2Date(23, 4, 2026), DMY2Date(27, 4, 2026));
                                if GLEntry[1].FindFirst then begin
                                    GLEntry[2].Reset();
                                    GLEntry[2].SetRange("Document No.", CheckoffCalculation."Document No");
                                    GLEntry[2].SetRange("Product Posting Type", GLEntry[1]."Product Posting Type"::"Loan Account");
                                    GLEntry[2].SetRange("Sacco Transaction Type", GLEntry[1]."Sacco Transaction Type"::"Interest Paid");
                                    GLEntry[2].SetRange("Member No.", CheckoffCalculation."Member No");
                                    GLEntry[2].SetFilter("Posting Date", '%1..%2', DMY2Date(23, 4, 2026), DMY2Date(27, 4, 2026));
                                    if GLEntry[2].FindFirst then begin
                                        GLEntry[2]."Loan No." := GLEntry[1]."Loan No.";
                                        GLEntry[2].Modify;
                                    end;
                                end;
                            end;
                        until CheckoffCalculation.Next = 0;
                    end;
                end;
            }
        }
    }
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
    end;

    var
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesExist: Boolean;
        CanCancelApprovalForRecord: Boolean;
        CanRequestApprovalForFlow: Boolean;
        CanCancelApprovalForFlow: Boolean;
        OfficeMgt: Codeunit "Office Management";
        IsOfficeAddin: Boolean;
        ApprovalsMgmtExt: Codeunit "Approval Mgmt. CBS Ext";
}
