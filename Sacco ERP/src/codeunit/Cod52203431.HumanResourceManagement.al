codeunit 52203431 "Human Resource Management"
{
    procedure BuildLeaveJournal(JournalTemplate: Code[50]; JournalBatch: Code[50]; LineNo: Integer; LeaveCalenderCode: Code[20]; EmployeeCode: Code[20]; PostingDate: Date; LeaveEntryType: Option Positive,Negative,Reimbursement; DocNo: Code[20]; NoDays: Decimal; DescriptionPar: Text; Dim1: Code[20]; Dim2: Code[20]; LeaveType: Code[20]; StartDate: Date; EndDate: Date; ApplicationNo: Code[20])
    var
        LeaveJournal: Record "Leave Journal Line";
    begin
        with LeaveJournal do begin
            "Journal Template Name" := JournalTemplate;
            "Journal Batch Name" := JournalBatch;
            "Line No." := LineNo;
            "Leave Calendar Code" := LeaveCalenderCode;
            Validate("Staff No.", EmployeeCode);
            "Posting Date" := PostingDate;
            "Leave Type" := LeaveType;
            "Leave Entry Type" := LeaveEntryType;
            "Document No." := DocNo;
            "No. of Days" := NoDays;
            Description := DescriptionPar;
            "Global Dimension 1 Code" := Dim1;
            "Global Dimension 2 Code" := Dim2;
            "Leave Period Start Date" := StartDate;
            "Leave Period End Date" := EndDate;
            "Start Date" := StartDate;
            "End Date" := EndDate;
            "Leave Application No." := ApplicationNo;
            if "No. of Days" <> 0 then Insert;
        end;
    end;

    procedure DeleteLeaveJournalLines(JournalTemplate: Code[20]; JournalBatch: Code[20])
    var
        LeaveJournalLine: Record "Leave Journal Line";
    begin
        LeaveJournalLine.Reset;
        LeaveJournalLine.SetRange("Journal Template Name", JournalTemplate);
        LeaveJournalLine.SetRange("Journal Batch Name", JournalBatch);
        if LeaveJournalLine.FindSet then LeaveJournalLine.DeleteAll;
    end;

    procedure PostLeaveJournalLines(JournalTemplate: Code[20]; JournalBatch: Code[20])
    var
        LeaveJournalLine: Record "Leave Journal Line";
    begin
        LeaveJournalLine.Reset;
        LeaveJournalLine.SetRange("Journal Template Name", JournalTemplate);
        LeaveJournalLine.SetRange("Journal Batch Name", JournalBatch);
        if LeaveJournalLine.FindSet then CODEUNIT.Run(CODEUNIT::"HR Leave Jnl.- Post Batch", LeaveJournalLine);
    end;

    procedure CreateLeaveJournalBatch(JournalTemplate: Code[20]; JournalBatch: Code[20])
    var
        LeaveJournalLine: Record "Leave Journal Line";
        LeaveJournalBatch: Record "Leave Journal Batch";
    begin
        LeaveJournalBatch.Reset;
        LeaveJournalBatch.SetRange("Journal Template Name", JournalTemplate);
        LeaveJournalBatch.SetRange(Name, JournalBatch);
        if LeaveJournalBatch.FindFirst then
            exit
        else begin
            with LeaveJournalBatch do begin
                "Journal Template Name" := JournalTemplate;
                Name := UserId;
                Description := 'Leave Batch For ' + Format(JournalBatch);
                Insert;
            end;
        end;
    end;

    procedure PostLeaveJournalLinesAccrual(JournalTemplate: Code[20]; JournalBatch: Code[20])
    var
        LeaveJournalLine: Record "Leave Journal Line";
    begin
        LeaveJournalLine.Reset;
        LeaveJournalLine.SetRange("Journal Template Name", JournalTemplate);
        LeaveJournalLine.SetRange("Journal Batch Name", JournalBatch);
        if LeaveJournalLine.FindSet then CODEUNIT.Run(CODEUNIT::"HR Leave Post Batch Accrual", LeaveJournalLine);
    end;

    procedure GetLeaveBalance(EmployeeCode: Code[50]; LeaveType: Code[50]; LeaveCalendar: Code[50]): Decimal
    var
        LeaveLedgerEntries: Record "Leave Ledger Entries";
    begin
        LeaveLedgerEntries.Reset;
        LeaveLedgerEntries.SetRange("Leave Type", LeaveType);
        LeaveLedgerEntries.SetRange("Employee No.", EmployeeCode);
        LeaveLedgerEntries.SetRange("Leave Year Code", LeaveCalendar);
        if LeaveLedgerEntries.FindSet then begin
            LeaveLedgerEntries.CalcSums(Quantity);
            exit(LeaveLedgerEntries.Quantity);
        end;
    end;

    procedure CreateLeaveApplication(EmployeeNo: Code[50]; LeaveType: Code[50]): Boolean
    var
        leaveApplication: Record "Leave Applications";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        LeaveNo: Code[50];
        LeaveSetup: Record "Leave Setup";
        LeaveCalendar: Record "Leave Calendar";
    begin
        with leaveApplication do begin
            LeaveSetup.Get;
            Init;
            LeaveNo := NoSeriesManagement.GetNextNo(LeaveSetup."Leave Application Nos.", 0D, true);
            "No." := LeaveNo;
            "System Entry" := true;
            "Employee No" := EmployeeNo;
            Validate("Employee No");
            "Leave Code" := LeaveType;
            "Created By" := UserId;
            "Created On" := WorkDate;
            "Application Date" := WorkDate;
            LeaveCalendar.Reset;
            LeaveCalendar.SetRange("Current Leave Calendar", true);
            if LeaveCalendar.FindFirst then "Leave Calender Code" := LeaveCalendar."Calendar Code";
            if Insert then Message('Leave No. %1 has been initiated', LeaveNo);
        end;
    end;

    procedure CheckIfItsSickLeave(LeaveCode: Code[20]): Boolean
    var
        LeaveTypes: Record "Leave Types";
    begin
        LeaveTypes.Reset;
        LeaveTypes.SetRange("Unlimited Days", true);
        LeaveTypes.SetRange(Code, LeaveCode);
        exit(LeaveTypes.FindFirst);
    end;

    [IntegrationEvent(false, false)]
    procedure OnConvertOvertimeToLeave(Employee: Record Employee)
    begin
    end;

    procedure DeleteGeneralJournalLines(JournalTemplate: Code[20]; JournalBatch: Code[20])
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.SetRange("Journal Template Name", JournalTemplate);
        GenJournalLine.SetRange("Journal Batch Name", JournalBatch);
        if GenJournalLine.FindSet then GenJournalLine.DeleteAll;
    end;

    procedure PostGeneralJournalLines(JournalTemplate: Code[20]; JournalBatch: Code[20])
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.Reset;
        GenJournalLine.SetRange("Journal Template Name", JournalTemplate);
        GenJournalLine.SetRange("Journal Batch Name", JournalBatch);
        if GenJournalLine.FindSet then CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post", GenJournalLine);
    end;

    procedure CreateGeneralJournalBatch(JournalTemplate: Code[20]; JournalBatch: Code[20]; ApprovalRequired: Boolean)
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        GenJournalBatch.Reset;
        GenJournalBatch.SetRange("Journal Template Name", JournalTemplate);
        GenJournalBatch.SetRange(Name, JournalBatch);
        if GenJournalBatch.FindFirst then
            exit
        else begin
            with GenJournalBatch do begin
                "Journal Template Name" := JournalTemplate;
                Name := JournalBatch;
                "Approval Required" := ApprovalRequired;
                Description := 'Batch For ' + Format(JournalBatch);
                Insert;
            end;
        end;
    end;

    local procedure CreateReasonCode("Code": Code[20]; Description: Text)
    var
        ReasonCode: Record "Reason Code";
    begin
        ReasonCode.Init;
        ReasonCode.Code := Code;
        ReasonCode.Description := Description;
        if not ReasonCode.Get(Code) then ReasonCode.Insert;
    end;

    procedure CheckOverdrawal(BankN: Code[20]; BalanceN: Decimal)
    var
        BankAccount: Record "Bank Account";
    begin
        if BankAccount.Get(BankN) then begin
            BankAccount.CalcFields(Balance);
            if BankAccount.Balance < BalanceN then Error('The System can not allow overdrawing of cash book %1 by %2', BankAccount.Name, BankAccount.Balance - BalanceN);
        end;
    end;

    procedure CreateGnlJournalLineInv(TemplateName: Text; BatchName: Text; DocumentNo: Code[30]; LineNo: Integer; AccountType: Option "G/L Account",Customer,Vendor,"Bank Account","Fixed Asset","IC Partner"; AccountNo: Code[50]; TransactionDate: Date; TransactionAmount: Decimal; Dimension1: Code[40]; Dimension2: Code[40]; ExternalDocumentNo: Code[50]; TransactionDescription: Text; PaymentMethod: Code[50]; Currency: Code[10]; AppliesToDocType: Option " ",Payment,Invoice,"Credit Memo","Finance Charge Memo",Reminder,Refund; AppliesToDocNo: Code[50]; CurrencyFactor: Decimal; SourceNo: Code[100]; BudgetCode: Code[20])
    var
        GenJournalLine: Record "Gen. Journal Line";
        Employee: Record Employee;
        RequestHeader: Record "Request Header";
        FAsset: Record "Fixed Asset";
        FADepreciationBook: Record "FA Depreciation Book";
    begin
        GenJournalLine.Init;
        GenJournalLine."Journal Template Name" := TemplateName;
        GenJournalLine."Journal Batch Name" := BatchName;
        GenJournalLine."Document No." := DocumentNo;
        GenJournalLine."Line No." := LineNo;
        GenJournalLine."Account Type" := AccountType;
        GenJournalLine."Account No." := AccountNo;
        GenJournalLine.Validate(GenJournalLine."Account No.");
        if FAsset.Get(AccountNo) then GenJournalLine."FA Posting Type" := GenJournalLine."FA Posting Type"::"Acquisition Cost";
        FADepreciationBook.Reset;
        FADepreciationBook.SetRange("FA No.", AccountNo);
        if FADepreciationBook.FindFirst then GenJournalLine."Depreciation Book Code" := FADepreciationBook."Depreciation Book Code";
        GenJournalLine."Posting Date" := TransactionDate;
        GenJournalLine."Currency Code" := Currency;
        GenJournalLine."Currency Factor" := CurrencyFactor;
        GenJournalLine.Validate(GenJournalLine."Currency Code");
        GenJournalLine.Description := TransactionDescription;
        GenJournalLine.Amount := TransactionAmount;
        GenJournalLine.Validate(Amount);
        GenJournalLine."External Document No." := ExternalDocumentNo;
        GenJournalLine.Validate(GenJournalLine.Amount);
        GenJournalLine."Shortcut Dimension 1 Code" := Dimension1;
        GenJournalLine."Shortcut Dimension 2 Code" := Dimension2;
        GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
        GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
        GenJournalLine."Applies-to Doc. Type" := AppliesToDocType;
        GenJournalLine."Applies-to Doc. No." := AppliesToDocNo;
        GenJournalLine."Payment Method Code" := PaymentMethod;
        GenJournalLine."Source No." := SourceNo;
        GenJournalLine."Budget Code" := BudgetCode;
        if Employee.Get(SourceNo) then GenJournalLine."Source Type" := GenJournalLine."Source Type"::Employee;
        if RequestHeader.Get(DocumentNo) then begin
            if RequestHeader."Request Type" in [RequestHeader."Request Type"::"Salary Advance"] then begin
                CreateReasonCode('SALADV', 'Salary Advance');
                GenJournalLine."Reason Code" := 'SALADV';
            end;
            if RequestHeader."Request Type" in [RequestHeader."Request Type"::Imprest] then begin
                CreateReasonCode('IMPREST', 'Staff Imprest');
                GenJournalLine."Reason Code" := 'IMPREST';
            end;
        end;
        //GenJournalLine.VALIDATE("Dimension Set ID",PassedDimensionSetID);
        if GenJournalLine.Amount <> 0 then GenJournalLine.Insert;
    end;

    procedure CreateGnlJournalLineJournal(TemplateName: Text; BatchName: Text; DocumentNo: Code[30]; LineNo: Integer; AccountType: Option "G/L Account",Customer,Vendor,"Bank Account","Fixed Asset","IC Partner"; AccountNo: Code[50]; TransactionDate: Date; TransactionAmount: Decimal; Dimension1: Code[40]; Dimension2: Code[40]; ExternalDocumentNo: Code[50]; TransactionDescription: Text; PaymentMethod: Code[50]; Currency: Code[10]; AppliesToDocType: Option " ",Payment,Invoice,"Credit Memo","Finance Charge Memo",Reminder,Refund; AppliesToDocNo: Code[50]; SourceNo: Code[100]; BudgetCode: Code[20]; DimsetID: Integer; Donor: Code[20]; Project: Code[20])
    var
        GenJournalLine: Record "Gen. Journal Line";
        Employee: Record Employee;
        RequestHeader: Record "Request Header";
        FAsset: Record "Fixed Asset";
        FADepreciationBook: Record "FA Depreciation Book";
    begin
        GenJournalLine.Init;
        GenJournalLine."Journal Template Name" := TemplateName;
        GenJournalLine."Journal Batch Name" := BatchName;
        GenJournalLine."Document No." := DocumentNo;
        GenJournalLine."Line No." := LineNo;
        GenJournalLine."Account Type" := AccountType;
        GenJournalLine."Account No." := AccountNo;
        GenJournalLine.Validate(GenJournalLine."Account No.");
        if FAsset.Get(AccountNo) then GenJournalLine."FA Posting Type" := GenJournalLine."FA Posting Type"::"Acquisition Cost";
        FADepreciationBook.Reset;
        FADepreciationBook.SetRange("FA No.", AccountNo);
        if FADepreciationBook.FindFirst then GenJournalLine."Depreciation Book Code" := FADepreciationBook."Depreciation Book Code";
        GenJournalLine."Posting Date" := TransactionDate;
        GenJournalLine."Currency Code" := Currency;
        GenJournalLine.Validate(GenJournalLine."Currency Code");
        GenJournalLine.Description := TransactionDescription;
        GenJournalLine.Amount := TransactionAmount;
        GenJournalLine.Validate(Amount);
        GenJournalLine."External Document No." := ExternalDocumentNo;
        GenJournalLine.Validate(GenJournalLine.Amount);
        GenJournalLine."Shortcut Dimension 1 Code" := Dimension1;
        GenJournalLine."Shortcut Dimension 2 Code" := Dimension2;
        GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
        GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
        //GenJournalLine.VALIDATE("Dimension Set ID",DimsetID);
        GenJournalLine."Applies-to Doc. Type" := AppliesToDocType;
        GenJournalLine."Applies-to Doc. No." := AppliesToDocNo;
        GenJournalLine."Payment Method Code" := PaymentMethod;
        GenJournalLine."Source No." := SourceNo;
        GenJournalLine."Budget Code" := BudgetCode;
        GenJournalLine."Job No." := Donor;
        GenJournalLine."Job Task No." := Project;
        if Employee.Get(SourceNo) then GenJournalLine."Source Type" := GenJournalLine."Source Type"::Employee;
        if RequestHeader.Get(DocumentNo) then begin
            if RequestHeader."Request Type" in [RequestHeader."Request Type"::"Salary Advance"] then begin
                CreateReasonCode('SALADV', 'Salary Advance');
                GenJournalLine."Reason Code" := 'SALADV';
            end;
            if RequestHeader."Request Type" in [RequestHeader."Request Type"::Imprest] then begin
                CreateReasonCode('IMPREST', 'Staff Imprest');
                GenJournalLine."Reason Code" := 'IMPREST';
            end;
        end;
        //GenJournalLine.VALIDATE("Dimension Set ID",PassedDimensionSetID);
        if GenJournalLine.Amount <> 0 then GenJournalLine.Insert;
    end;

    procedure HasOpenApprovalEntries(RecordID: RecordID; DocumentNo: Code[20]): Boolean
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        ApprovalEntry.Reset;
        ApprovalEntry.SetRange("Table ID", RecordID.TableNo);
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        ApprovalEntry.SetRange("Approver ID", UserId);
        ApprovalEntry.SetRange("Document No.", DocumentNo);
        exit(ApprovalEntry.FindFirst);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Leave Recall", 'OnLeaveRecallApproval', '', false, false)]
    procedure PostLeaveRecallAfterApproval(var LeaveRecall: Record "Leave Recall")
    var
        LeaveSetUp: Record "Leave Setup";
        LeaveJournal: Code[20];
        LeaveJournalLine: Record "Leave Journal Line";
        LeaveBatch: Code[30];
    begin
        LeaveSetUp.Get;
        LeaveJournal := LeaveSetUp."Leave Journal Template";
        LeaveBatch := LeaveSetUp."Leave Journal Batch";
        CreateLeaveJournalBatch(LeaveJournal, LeaveBatch);
        DeleteLeaveJournalLines(LeaveJournal, LeaveBatch);
        with LeaveRecall do begin
            BuildLeaveJournal(LeaveJournal, LeaveBatch, 1, LeaveRecall."Leave Calender Code", LeaveRecall."Employee No", Today, LeaveJournalLine."Leave Entry Type"::Reimbursement, LeaveRecall."No.", LeaveRecall."Days To Recall", LeaveRecall.Comments, LeaveRecall."Global Dimension 1 Code", '', LeaveRecall."Leave Code", LeaveRecall."Start Date", LeaveRecall."End Date", LeaveRecall."No.");
        end;
        PostLeaveJournalLines(LeaveJournal, LeaveBatch);
    end;
    //  [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Leave Application", 'OnAfterReleaseLeave', '', false, false)]
    procedure PostLeaveAfterApproval(var LeaveApp: Record "Leave Applications")
    var
        LeaveSetUp: Record "Leave Setup";
        LeaveJournal: Code[20];
        LeaveJournalLine: Record "Leave Journal Line";
        LeaveBatch: Code[30];
        PayrollPeriods: Record "Payroll Periods";
        PayrollTransactionCode: Record "Payroll Transaction Code";
        Employee: Record Employee;
        PayrollEmployeeTransaction: Record "Payroll Employee Transaction";
        EmployeePayrollScales: Record "Employee Payroll Scales";
    begin
        LeaveSetUp.Get;
        LeaveJournal := LeaveSetUp."Leave Journal Template";
        LeaveBatch := LeaveSetUp."Leave Journal Batch";
        CreateLeaveJournalBatch(LeaveJournal, LeaveBatch);
        DeleteLeaveJournalLines(LeaveJournal, LeaveBatch);
        with LeaveApp do begin
            if LeaveApp."Nature of Application" = LeaveApp."Nature of Application"::"Leave Application" then begin
                BuildLeaveJournal(LeaveJournal, LeaveBatch, 1, LeaveApp."Leave Calender Code", LeaveApp."Employee No", Today, LeaveJournalLine."Leave Entry Type"::Negative, LeaveApp."No.", LeaveApp."Days Applied", LeaveApp.Comments, LeaveApp."Global Dimension 1 Code", '', LeaveApp."Leave Code", LeaveApp."Start Date", LeaveApp."End Date", LeaveApp."No.");
                if LeaveApp."Leave Allowance Payable" = LeaveApp."Leave Allowance Payable"::Yes then begin
                    PayrollPeriods.RESET;
                    PayrollPeriods.SETRANGE(Closed, FALSE);
                    IF NOT PayrollPeriods.FINDFIRST THEN ERROR('No open payroll period was found');
                    PayrollTransactionCode.RESET;
                    PayrollTransactionCode.SETRANGE("P10 Allowance Type", PayrollTransactionCode."P10 Allowance Type"::Leave);
                    IF NOT PayrollTransactionCode.FINDFIRST THEN
                        ERROR('No leave allowance transaction code was found Kindly contact payroll admin for assistance');
                    Employee.GET("Employee No");
                    Employee.TestField("Job Scale");
                    PayrollEmployeeTransaction.INIT;
                    PayrollEmployeeTransaction.VALIDATE("Employee Code", "Employee No");
                    PayrollEmployeeTransaction.VALIDATE("Payroll Period", PayrollPeriods."Start Date");
                    PayrollEmployeeTransaction."Period Month" := PayrollPeriods."Period Month";
                    PayrollEmployeeTransaction."Period Year" := PayrollPeriods."Period Year";
                    PayrollEmployeeTransaction.VALIDATE("Transaction Code", PayrollTransactionCode.Code);
                    if EmployeePayrollScales.Get(Employee."Job Scale") then begin
                        EmployeePayrollScales.TestField("Leave Allowance Amount");
                        PayrollEmployeeTransaction.Amount := EmployeePayrollScales."Leave Allowance Amount";
                    end;
                    PayrollEmployeeTransaction."Temporary Transaction" := true;
                    if not PayrollEmployeeTransaction.GET(LeaveApp."Employee No", PayrollTransactionCode.Code, PayrollPeriods."Start Date", PayrollPeriods."Period Month", PayrollPeriods."Period Year") then
                        PayrollEmployeeTransaction.Insert
                    else begin
                        if PayrollEmployeeTransaction.GET(LeaveApp."Employee No", PayrollTransactionCode.Code, PayrollPeriods."Start Date", PayrollPeriods."Period Month", PayrollPeriods."Period Year") THEN PayrollEmployeeTransaction.Modify;
                    end;
                end;
            end
            else if LeaveApp."Nature of Application" = LeaveApp."Nature of Application"::"Leave Reimbursement" then begin
                BuildLeaveJournal(LeaveJournal, LeaveBatch, 1, LeaveApp."Leave Calender Code", LeaveApp."Employee No", Today, LeaveJournalLine."Leave Entry Type"::Reimbursement, LeaveApp."No.", LeaveApp."Days To Reimburse", LeaveApp.Comments, LeaveApp."Global Dimension 1 Code", '', LeaveApp."Leave Code", LeaveApp."Start Date", LeaveApp."End Date", LeaveApp."No.");
            end;
        end;
        PostLeaveJournalLines(LeaveJournal, LeaveBatch);
        LeaveApp.Posted := true;
        LeaveApp."Posting Date" := WorkDate;
        LeaveApp.Modify(true);
        if ((LeaveApp."Nature of Application" = LeaveApp."Nature of Application"::"Leave Application") and (LeaveApp."Leave Allowance Payable" = LeaveApp."Leave Allowance Payable"::Yes)) then Message('Leave Application No. %1 has been successfully and transferred to payroll', LeaveApp."No.");
        if ((LeaveApp."Nature of Application" = LeaveApp."Nature of Application"::"Leave Application") and (LeaveApp."Leave Allowance Payable" = LeaveApp."Leave Allowance Payable"::No)) then Message('Leave Application No. %1 has been successfully posted', LeaveApp."No.");
        if LeaveApp."Nature of Application" = LeaveApp."Nature of Application"::"Leave Reimbursement" then Message('Leave Reimbersement No. %1 has been successfully posted', LeaveApp."No.")
    end;
}
