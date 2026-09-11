page 52203771 "Fixed Deposit"
{
    PageType = Card;
    SourceTable = "Fixed Deposit Header";
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments';

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = Postedx;

                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("FD Certificate No."; Rec."FD Certificate No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Investment Institution"; Rec."Investment Institution")
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
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Investment Posting Group"; Rec."Investment Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Roll Over")
            {
                field("Rollover No."; Rec."Rollover No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                group("Debit Accounts")
                {
                    Editable = Postedx;

                    field("Debit Account Type"; Rec."Debit Account Type")
                    {
                        Editable = false;
                        ApplicationArea = Basic, Suite;
                    }
                    field("Debit Account No."; Rec."Debit Account No.")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Debit Account Name"; Rec."Debit Account Name")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                group("Credit Accounts")
                {
                    Editable = Postedx;

                    field("Credit Account Type"; Rec."Credit Account Type")
                    {
                        Editable = false;
                        ApplicationArea = Basic, Suite;
                    }
                    field("Credit Account No"; Rec."Credit Account No")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Credit Account Name"; Rec."Credit Account Name")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                group("Operating Parameters")
                {
                    Editable = Postedx;

                    field(Amount; Rec.Amount)
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Investment Date"; Rec."Investment Date")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Investment Period"; Rec."Investment Period")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Maturity Date"; Rec."Maturity Date")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Negotiated Intrest"; Rec."Negotiated Intrest")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Interest Type"; Rec."Interest Type")
                    {
                        Editable = false;
                        ApplicationArea = Basic, Suite;
                    }
                    field("Interest Receivable Account"; Rec."Interest Receivable Account")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Interest Received Account"; Rec."Interest Received Account")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("W/Tax Account"; Rec."W/Tax Account")
                    {
                        Visible = false;
                        ApplicationArea = Basic, Suite;
                    }
                    field("Reason for Termination"; Rec."Reason for Termination")
                    {
                        Visible = Terminatedx;
                        ApplicationArea = Basic, Suite;
                    }
                    field("Interest Accrued"; Rec."Interest Accrued")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Estimated Interest to Accrue"; Rec."Estimated Interest to Accrue")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
            }
            group("Liquidation Details")
            {
                Visible = Liquidate;

                field("Receiving Account Type"; Rec."Receiving Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Receiving Account No"; Rec."Receiving Account No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Receiving Date"; Rec."Receiving Date")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part(Control27; "Fixed Deposit Schedule")
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "Investment No"=FIELD("No.");
            }
            group("Audit Log")
            {
                Editable = false;

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
                field("last Updated On"; Rec."last Updated On")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Create Schedule")
            {
                Image = ApplyEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = Basic, Suite;

                trigger OnAction()
                begin
                    Rec.Testfield(Terminated, false);
                    Rec.Testfield("Marked for Liquidation", false);
                    Rec.Testfield(Liquidated, false);
                    Rec.Testfield(Posted, false);
                    if not Confirm(StrSubstNo('Are you sure you want to Created Schedule for Document No. %1', Rec."No."), true)then InvestmentMgmt.CreateSchedule(Rec);
                    CurrPage.Close;
                end;
            }
            action("Send Approval Request")
            {
                Image = SendApprovalRequest;
                Promoted = true;
                PromotedCategory = Category6;
                Enabled = NOT OpenApprovalEntriesExist AND CanRequestApprovalForFlow;
                PromotedIsBig = true;
                ApplicationArea = Basic, Suite;

                trigger OnAction()
                begin
                    Rec.Testfield(Status, Rec.Status::Open);
                    Rec.Testfield(Amount);
                    Rec.Testfield("Negotiated Intrest");
                    Rec.Testfield("Investment Date");
                    Rec.Testfield("Interest Receivable Account");
                    Rec.Testfield("Interest Received Account");
                    Rec.Testfield("Credit Account No");
                    Rec.Testfield("Debit Account No.");
                    Rec.Testfield("FD Certificate No.");
                    Rec.Testfield("Global Dimension 1 Code");
                    Rec.Testfield("Global Dimension 2 Code");
                    if not Confirm(StrSubstNo('Are you sure you want to Send Approval Request for Document No. %1', Rec."No."), true)then exit
                    else
                    begin
                        ApprovalsMgmt.OnSendFixedDepositForApproval(Rec);
                        CurrPage.Close;
                    end;
                end;
            }
            action("Cancel Approval Request")
            {
                Image = CancelApprovalRequest;
                Promoted = true;
                PromotedCategory = Category6;
                Enabled = CanCancelApprovalForRecord OR CanCancelApprovalForFlow;
                PromotedIsBig = true;
                ApplicationArea = Basic, Suite;

                trigger OnAction()
                begin
                    Rec.Testfield(Status, Rec.Status::"Pending Approval");
                    if not Confirm(StrSubstNo('Are you sure you want to Cancel Request for Document No. %1', Rec."No."), true)then exit
                    else
                    begin
                        ApprovalsMgmt.OnCancelFixedDepositApprovalRequest(Rec);
                        CurrPage.Close;
                    end;
                end;
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
            action(Post)
            {
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = Basic, Suite;

                trigger OnAction()
                begin
                    //Post
                    Rec.Testfield(Status, Rec.Status::Approved);
                    Rec.Testfield("Marked for Liquidation", false);
                    Rec.Testfield(Liquidated, false);
                    //Force user to create Schedule
                    FDSchedule.Reset;
                    FDSchedule.SetRange("Investment No", Rec."No.");
                    if not FDSchedule.FindFirst then Error('Create Schedule first');
                    //Force user to create Schedule
                    if not Confirm(StrSubstNo('Are you sure you want to Post Document No. %1', Rec."No."), true)then exit;
                    //InvestmentManagement1.OnPostFD(Rec);
                    CurrPage.Close;
                end;
            }
            action(Liquidate)
            {
                Image = PostBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = Basic, Suite;

                trigger OnAction()
                begin
                    Rec.Testfield(Status, Rec.Status::Running);
                    Rec.Testfield("Receiving Account Type");
                    Rec.Testfield("Receiving Account No");
                    Rec.Testfield("Receiving Date");
                    Rec.Testfield(Liquidated, false);
                    Rec.Validate("Global Dimension 1 Code");
                    Rec.Validate("Global Dimension 2 Code");
                    if not Confirm(StrSubstNo('Are you sure you want to Liquidate Fixed Deposit No. %1', Rec."No."), true)then exit; //InvestmentManagement1.OnPostLiquidation(Rec);                CurrPage.Close;
                end;
            }
            action(Terminate)
            {
                Image = TaxPayment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = Basic, Suite;

                trigger OnAction()
                begin
                    Rec.Testfield("Marked for Liquidation");
                    Rec.Testfield(Status, Rec.Status::Running);
                    Rec.Testfield(Liquidated, false);
                    if not Confirm(StrSubstNo('Are you sure you want to Terminate Fixed Deposit No. %1', Rec."No."), true)then exit;
                    Rec.Validate(Status, Rec.Status::Terminated);
                    Rec.Modify;
                    Message('Fixed Deposit No %1 has been Terminated', Rec."No.");
                    CurrPage.Close;
                end;
            }
            action("Report")
            {
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                ApplicationArea = Basic, Suite;

                trigger OnAction()
                begin
                    //TESTFIELD(Posted);
                    Rec.Reset;
                    Rec.SetFilter("No.", Rec."No.");
                    REPORT.Run(Report::"Fixed Deposit Print out", true, true, Rec);
                end;
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        PostedCheck;
        TerminatedCheck;
        FixedDepositCheck;
        LiquidateCheck;
    end;
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Investment Type":=Rec."Investment Type"::"Fixed Deposit";
        Rec.Validate("Investment Type");
        Rec."Debit Account Type":=Rec."Debit Account Type"::"Bank Account";
        Rec."Credit Account Type":=Rec."Credit Account Type"::"Bank Account";
        Rec."Interest Type":=Rec."Interest Type"::"Straight Line";
        Rec."Receiving Account Type":=Rec."Receiving Account Type"::"Bank Account";
    end;
    trigger OnOpenPage()
    begin
        PostedCheck;
        TerminatedCheck;
        FixedDepositCheck;
        LiquidateCheck;
    end;
    var //NGOManagement: Codeunit NGOManagement;
 ApprovalsMgmt: Codeunit "Approval Mgmt. Ext";
    ConfirmManagement: Codeunit "Confirm Management";
    InvestmentMgmt: Codeunit "Investment Mgmt";
    Postedx: Boolean;
    Terminatedx: Boolean;
    FD: Boolean;
    FDSchedule: Record "Fixed Deposit Schedule";
    Liquidate: Boolean;
    OpenApprovalEntriesExistForCurrUser: Boolean;
    OpenApprovalEntriesExist: Boolean;
    CanCancelApprovalForRecord: Boolean;
    CanRequestApprovalForFlow: Boolean;
    CanCancelApprovalForFlow: Boolean;
    local procedure PostedCheck()
    begin
        Postedx:=true;
        if Rec.Status <> Rec.Status::Open then Postedx:=false;
    end;
    local procedure TerminatedCheck()
    begin
        Terminatedx:=false;
        if Rec.Status = Rec.Status::Terminated then Terminatedx:=true;
    end;
    local procedure FixedDepositCheck()
    begin
        FD:=false;
        if Rec."Investment Type" <> Rec."Investment Type"::"Treasury Bills" then FD:=true;
    end;
    local procedure LiquidateCheck()
    begin
        Liquidate:=false;
        if Rec.Status = Rec.Status::Running then Liquidate:=true;
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
}
