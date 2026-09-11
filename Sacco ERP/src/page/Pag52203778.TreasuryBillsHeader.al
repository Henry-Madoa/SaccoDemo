page 52203778 "Treasury Bills Header"
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
                field("Investment Type"; Rec."Investment Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        FixedDeposit;
                    end;
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

                    field("Face Value"; Rec."Face Value")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Discount Amount"; Rec."Discount Amount")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field(Amount; Rec.Amount)
                    {
                        ApplicationArea = Basic, Suite;
                        Editable = false;
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
                        ApplicationArea = Basic, Suite;
                        Editable = false;
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
                        ApplicationArea = Basic, Suite;
                        Visible = false;
                    }
                    field("Reason for Termination"; Rec."Reason for Termination")
                    {
                        ApplicationArea = Basic, Suite;
                        Visible = Terminatedx;
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
            part("T bills Schedule"; "Fixed Deposit Schedule")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'T bills Schedule';
                SubPageLink = "Investment No"=FIELD("No.");
                SubPageView = WHERE("Entry Type"=CONST("Payment Due"));
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
                    Rec.Testfield(Status, Rec.Status::Approved);
                    Rec.Testfield(Terminated, false);
                    Rec.Testfield("Marked for Liquidation", false);
                    Rec.Testfield(Liquidated, false);
                    Rec.Testfield(Posted, false);
                    if not Confirm(StrSubstNo('Are you sure you want to Created Schedule for Document No. %1', Rec."No."), true)then exit;
                    // NGOManagement.CreateFDSchedule(Rec);                Message('Schedule for Fixed Deposit %1 has been Created', "No.");
                    CurrPage.Close;
                end;
            }
            action("Send Approval Request")
            {
                Image = SendApprovalRequest;
                Promoted = true;
                PromotedCategory = Category6;
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
            action("&Post")
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
                    // if not Confirm(StrSubstNo('Are you sure you want to Post Document No. %1', "FD No."), true) then
                    //     exit;
                    //InvestmentManagement1.OnPostFD(Rec);
                    CurrPage.Close;
                end;
            }
            action("&Liquidate")
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
                    if not Confirm(StrSubstNo('Are you sure you want to Liquidate Fixed Deposit No. %1', Rec."No."), true)then exit;
                    //InvestmentManagement1.OnPostLiquidation(Rec);            
                    CurrPage.Close;
                end;
            }
            action("&Terminate")
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
                    REPORT.Run(65012, true, true, Rec);
                end;
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        PostedCheck;
        Terminate;
        FixedDeposit;
        LiquidatedCheck;
    end;
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Investment Type":=Rec."Investment Type"::"Treasury Bills";
        Rec.Validate("Investment Type");
        Rec."Debit Account Type":=Rec."Debit Account Type"::"Bank Account";
        Rec."Credit Account Type":=Rec."Credit Account Type"::"G/L Account";
        Rec."Interest Type":=Rec."Interest Type"::"Straight Line";
        Rec."Receiving Account Type":=Rec."Receiving Account Type"::"Bank Account";
    end;
    trigger OnOpenPage()
    begin
        PostedCheck;
        Terminate;
        FixedDeposit;
        LiquidatedCheck;
    end;
    var //NGOManagement: Codeunit NGOManagement;
 ApprovalsMgmt: Codeunit "Approval Mgmt. Ext";
    ConfirmManagement: Codeunit "Confirm Management";
    //InvestmentManagement1: Codeunit "Investment Management";
    Postedx: Boolean;
    Terminatedx: Boolean;
    FD: Boolean;
    FDSchedule: Record "Fixed Deposit Schedule";
    Liquidate: Boolean;
    local procedure PostedCheck()
    begin
        Postedx:=true;
        if Rec.Status <> Rec.Status::Open then Postedx:=false;
    end;
    local procedure Terminate()
    begin
        Terminatedx:=false;
        if Rec.Status = Rec.Status::Terminated then Terminatedx:=true;
    end;
    local procedure FixedDeposit()
    begin
        FD:=false;
        if Rec."Investment Type" <> Rec."Investment Type"::"Treasury Bills" then FD:=true;
    end;
    local procedure LiquidatedCheck()
    begin
        Liquidate:=false;
        if Rec.Status = Rec.Status::Running then Liquidate:=true;
    end;
}
