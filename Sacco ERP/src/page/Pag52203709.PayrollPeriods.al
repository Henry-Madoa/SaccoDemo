page 52203709 "Payroll Periods"
{
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Payroll Periods";
    SourceTableView = sorting("Start Date") order(descending);
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Period Name"; Rec."Period Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("End Date"; Rec."End Date")
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
                field("Closed By"; Rec."Closed By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Closed On"; Rec."Closed On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Closed; Rec.Closed)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
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
            action("Close Period")
            {
                ApplicationArea = Basic, Suite;
                Image = ClosePeriod;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.Testfield(Status, Rec.Status::Approved);
                    ClosePayrollPeriod.OnClosePayrollPeriod(Rec);
                end;
            }
            action("Initialize Period")
            {
                ApplicationArea = Basic, Suite;
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Report "Initialize Payroll Period";
                Visible = InitializeVisible;
            }
            action("MailAllPayslips")
            {
                ApplicationArea = All;
                Caption = 'Mail All Payslips';
                Image = SendEmailPDF;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = Rec.Closed;

                trigger OnAction()
                var
                    EmailPayslips: Report "Email Payslips";
                begin
                    EmailPayslips.IntiateStartDate(Rec."Start Date");
                    EmailPayslips.Run;
                end;
            }
            action("Send Approval Request")
            {
                ApplicationArea = Basic, Suite;
                Image = SendApprovalRequest;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if not Confirm('Are you sure you want to send approval request?') then
                        exit
                    else begin
                        ApprovalsMgmt.OnSendPayrollPeriodsForApproval(Rec);
                        CurrPage.Close();
                    end;
                end;
            }
            action("Cancel Approval Request")
            {
                ApplicationArea = Basic, Suite;
                Image = CancelApprovalRequest;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Status, Rec.Status::"Pending Approval");
                    Rec.Testfield("Approval Opened", false);
                    if not Confirm('Are you sure you want to cancel approval request?') then
                        exit
                    else begin
                        ApprovalsMgmt.OnCancelPayrollPeriodsApprovalRequest(Rec);
                        CurrPage.Close();
                    end;
                end;
            }
            action("ReOpen Period")
            {
                ApplicationArea = Basic, Suite;
                Image = ReOpen;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if Confirm('Are you sure you want to reopen the payroll?') then exit;
                    // UserSetup.GET(USERID);
                    // UserSetup.TESTFIELD("Additional Program",TRUE);
                    Rec.Status := Rec.Status::Open;
                    Rec.Modify(true);
                    Message('Successfully Reopened');
                end;
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        if CheckIfPeriodExist then
            InitializeVisible := true
        else
            InitializeVisible := false;
    end;

    trigger OnAfterGetRecord()
    begin
        if CheckIfPeriodExist then
            InitializeVisible := true
        else
            InitializeVisible := false;
    end;

    trigger OnOpenPage()
    begin
        if CheckIfPeriodExist then
            InitializeVisible := true
        else
            InitializeVisible := false;
    end;

    var
        ClosePayrollPeriod: Codeunit "Close Payroll Period";
        InitializeVisible: Boolean;
        Employee: array[4] of Record Employee;
        Window: Dialog;
        PayrollSalaryCard: Record "Payroll Salary Card";
        AttachementFilePaths: Record "Attachement File Paths";
        ApprovalsMgmt: Codeunit "Approval Mgmt. Ext";
        Recipients: List of [Text];
        Body: Text;
        Subject: Text;
        TempBlob: Codeunit "Temp Blob";
        outStreamReport: OutStream;
        inStreamReport: InStream;
        Recordr: RecordRef;
        Mail: Codeunit "Email Message";
        Email: Codeunit Email;

    local procedure CheckIfPeriodExist(): Boolean
    var
        PayrollPeriods: Record "Payroll Periods";
    begin
        PayrollPeriods.Reset;
        exit(PayrollPeriods.IsEmpty);
    end;
}
