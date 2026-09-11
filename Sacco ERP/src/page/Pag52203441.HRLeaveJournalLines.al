page 52203441 "HR Leave Journal Lines"
{
    DelayedInsert = false;
    PageType = Worksheet;
    PromotedActionCategories = 'New,Process,Report,Functions,Approvals';
    RefreshOnActivate = true;
    SaveValues = false;
    SourceTable = "Leave Journal Line";

    layout
    {
        area(content)
        {
            field(CurrentJnlBatchName; CurrentJnlBatchName)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Batch Name';
                Lookup = true;

                trigger OnLookup(var Text: Text): Boolean begin
                    CurrPage.SaveRecord;
                    //Rec.RESET;              
                    InsuranceJnlManagement.LookupName(CurrentJnlBatchName, Rec);
                    CurrPage.Update(false);
                end;
                trigger OnValidate()
                begin
                    InsuranceJnlManagement.CheckName(CurrentJnlBatchName, Rec);
                    CurrentJnlBatchNameOnAfterVali;
                end;
            }
            repeater(Control1102755000)
            {
                ShowCaption = false;

                field("Leave Calendar Code"; Rec."Leave Calendar Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = true;
                }
                field("Staff No."; Rec."Staff No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = true;
                }
                field("Staff Name"; Rec."Staff Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Leave Type"; Rec."Leave Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = true;
                }
                field("Leave Entry Type"; Rec."Leave Entry Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = true;
                }
                field("No. of Days"; Rec."No. of Days")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = true;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = true;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = true;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    Enabled = true;
                }
            }
        }
    }
    actions
    {
        area(navigation)
        {
            group(ActionGroup1102755006)
            {
                action("<Action1102756003>")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Approvals';
                    Image = Approvals;
                    Promoted = true;
                    PromotedCategory = Category4;
                    Visible = false;

                    trigger OnAction()
                    var
                        DocumentType: Option Quote, "Order", Invoice, "Credit Memo", "Blanket Order", "Return Order", "None", "Payment Voucher", "Petty Cash", Imprest, Requisition, ImprestSurrender, Interbank, Receipt, "Staff Claim", "Staff Advance", AdvanceSurrender, "Store Requisition", "Employee Requisition", "Leave Application", "Transport Requisition", "Training Requisition", "Job Approval", JV;
                    begin
                    end;
                }
                action("<Action1102756005>")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Send Approval Request';
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category4;
                    Visible = false;

                    trigger OnAction()
                    var
                        GenLedgSetup: Record "General Ledger Setup";
                        NoSeriesMgt: Codeunit NoSeriesManagement;
                        Text001: Label 'This batch is already pending approval';
                    begin
                    end;
                }
                action("<Action1102756006>")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cancel Approval Request';
                    Image = Cancel;
                    Promoted = true;
                    PromotedCategory = Category4;
                    Visible = false;
                }
            }
        }
    }
    trigger OnOpenPage()
    var
        JnlSelected: Boolean;
        InsuranceJnlManagement: Codeunit "HR Leave Jnl Management";
    begin
        OpenedFromBatch:=(Rec."Journal Batch Name" <> '') and (Rec."Journal Template Name" = '');
        if OpenedFromBatch then begin
            CurrentJnlBatchName:=Rec."Journal Batch Name";
            InsuranceJnlManagement.OpenJournal(CurrentJnlBatchName, Rec);
            exit;
        end;
        //InsuranceJnlManagement.TemplateSelection(PAGE::Page39003944, Rec, JnlSelected);
        if not JnlSelected then Error('');
        InsuranceJnlManagement.OpenJournal(CurrentJnlBatchName, Rec);
    end;
    var HRLeaveTypes: Record "Leave Types";
    HREmp: Record Employee;
    HRLeaveLedger: Record "Leave Ledger Entries";
    InsuranceJnlManagement: Codeunit "HR Leave Jnl Management";
    ReportPrint: Codeunit "Test Report-Print";
    CurrentJnlBatchName: Code[10];
    InsuranceDescription: Text[30];
    FADescription: Text[30];
    ShortcutDimCode: array[8]of Code[20];
    OpenedFromBatch: Boolean;
    AllocationDone: Boolean;
    HRJournalBatch: Record "Leave Journal Batch";
    OK: Boolean;
    ApprovalEntries: Record "Approval Entry";
    LLE: Record "Leave Ledger Entries";
    HRLeaveCal: Record "Leave Calendar";
    HrLeaveJournal: Record "Leave Journal Line";
    procedure CheckGender(Emp: Record Employee; LeaveType: Record "Leave Types")Allocate: Boolean begin
        if Emp.Gender = Emp.Gender::Female then begin
            if LeaveType.Gender = LeaveType.Gender::Male then Allocate:=true;
        end;
        if Emp.Gender = Emp.Gender::Male then begin
            if LeaveType.Gender = LeaveType.Gender::Female then Allocate:=true;
        end;
        if LeaveType.Gender = LeaveType.Gender::Both then Allocate:=true;
        exit(Allocate);
    end;
    local procedure CurrentJnlBatchNameOnAfterVali()
    begin
        CurrPage.SaveRecord;
        InsuranceJnlManagement.SetName(CurrentJnlBatchName, Rec);
        CurrPage.Update(false);
    end;
    procedure AllocateLeave1()
    begin
    end;
    procedure AllocateLeave2()
    begin
    end;
}
