codeunit 52203440 "Portal Approval Mgmt."
{
    var
        ApprovalsMgmtExt: Codeunit "Approval Mgmt. Ext";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        LeaveTypes: Record "Leave Types";
        LeaveEntries: Record "Leave Ledger Entries";
        LeaveCalendar: Record "Leave Calendar";
        Employee: Record Employee;
        LeaveBalance: Decimal;
        DocumentAttachment: Record "Document Attachment";
        ApproveOnlyOpenRequestsErr: Label 'You can only approve open approval requests.';
        ApprovalsDelegatedMsg: Label 'The selected approval requests have been delegated.';
        DelegateOnlyOpenRequestsErr: Label 'You can only delegate open approval requests.';
        ApproverUserIdNotInSetupErr: Label 'You must set up an approver for user ID %1 in the Approval User Setup window.', Comment = 'You must set up an approver for user ID NAVUser in the Approval User Setup window.';
        SubstituteNotFoundErr: Label 'There is no substitute, direct approver, or approval administrator for user ID %1 in the Approval User Setup window.', Comment = 'There is no substitute for user ID NAVUser in the Approval User Setup window.';
        RejectOnlyOpenRequestsErr: Label 'You can only reject open approval entries.';
        NoReqToApproveErr: Label 'There is no approval request to approve.';
        NoReqToRejectErr: Label 'There is no approval request to reject.';
        NoReqToDelegateErr: Label 'There is no approval request to delegate.';

    [Scope('Cloud')]
    procedure SendDocumentApproval(RecordID: RecordId)
    var
        RecRef: RecordRef;
        HRSetup: Record "Human Resources Setup";
        RequestLines: Record "Request Lines";
        GeneralLedgerSetup: Record "General Ledger Setup";
        RHeader: Record "Request Header";
        LeaveTypes: Record "Leave Types";
        RLines: Record "Requisition Lines";
        //**********Finance**********
        PV: array[2] of Record "Payment Voucher";
        RequestHeader: array[2] of Record "Request Header";
        PettyCash: array[2] of Record "Petty Cash Header";
        VirementBudget: array[2] of Record "Virement Budget Request";
        BudgetPlan: array[2] of Record "Budget Plan";
        BankAccReconciliation: array[2] of Record "Bank Acc. Reconciliation";
        FixedDeposit: array[2] of Record "Fixed Deposit Header";
        CompanyDocuments: array[2] of Record "Company Documents";
        //**********Procurement**********
        Requisition: array[2] of Record "Requisition Header";
        RFQ: array[2] of Record "RFQ Header";
        BudgetPlanHeader: array[2] of Record "Budget Plan";
        VirementBudgetRequest: array[2] of Record "Virement Budget Request";
        ProcurePlan: array[2] of Record "Procurement Plans";
        //**********Human Resource**********
        LeaveApplication: array[2] of Record "Leave Applications";
        Training: array[2] of Record "Training Application";
        TrainingNeeds: array[2] of Record "Training Needs";
        LeavePlan: array[2] of Record "Leave Plan";
        Appraisal: array[2] of Record "Appraisal Header";
        HrJobs: array[2] of Record "Company Jobs";
        JobRequisition: array[2] of Record "Job Requisition";
        EmployeeChange: array[2] of Record "Employee Change Request";
        LeaveRecall: array[2] of Record "Leave Recall";
        EmployeeExit: array[2] of Record "Employee Exit";
        PayrollPeriod: array[2] of Record "Payroll Periods";
    begin
        RecRef := RecordID.GetRecord;
        case RecRef.Number of //***********************SOFT - ADVANCED FINANCE MODULE CUSTOMIZATIONS***************************
                              //1. Payment Voucher
            DATABASE::"Payment Voucher":
                begin
                    RecRef.SetTable(PV[1]);
                    PV[2].Get(PV[1]."No.");
                    ApprovalsMgmtExt.OnSendPVForApproval(PV[2]);
                end;
            //
            //2. Petty Cash
            DATABASE::"Petty Cash Header":
                begin
                    RecRef.SetTable(PettyCash[1]);
                    PettyCash[2].Get(PettyCash[1]."No.");
                    ApprovalsMgmtExt.OnSendPettyCashForApproval(PettyCash[2]);
                end;
            //3. Request Header
            DATABASE::"Request Header":
                begin
                    RecRef.SetTable(RequestHeader[1]);
                    RequestHeader[2].Get(RequestHeader[1]."No.");
                    if RequestHeader[2]."Request Type" in [RequestHeader[2]."Request Type"::Imprest] then begin
                        HRSetup.Get;
                        RequestHeader[2].CalcFields("Request Amount");
                        RequestHeader[2].TestField("Request Amount");
                        if RequestHeader[2]."Request Amount" > HRSetup."Maximum Imprest Amount" then Error('%1 can not Apply imprest more than %2', RequestHeader[2]."Employee Name", HRSetup."Maximum Imprest Amount");
                        //Maximum Imprests at a time
                        GeneralLedgerSetup.Get;
                        GeneralLedgerSetup.TestField("Max No Outstanding Imprests");
                        RHeader.Reset;
                        RHeader.SetRange("Employee No.", RequestHeader[2]."Employee No.");
                        RHeader.SetRange("Request Type", RHeader."Request Type"::Imprest);
                        RHeader.SetRange(Posted, true);
                        RHeader.SetRange(Surrendered, false);
                        //RequestHeader.SETFILTER(Status,'%1',RequestHeader.Status::Rejected);
                        if RHeader.FindSet then begin
                            if RHeader.Count >= GeneralLedgerSetup."Max No Outstanding Imprests" then Error('You have %1 unsurrendered imprest', RHeader.Count);
                        end;
                        //Maximum Imprests at a time
                    end;
                    if RequestHeader[2]."Request Type" in [RequestHeader[2]."Request Type"::Surrender] then begin
                        RequestHeader[2].Reset;
                        RequestHeader[2].SetRange("No.", RequestHeader[2]."No.");
                        RequestHeader[2].SetFilter(Status, '%1|%2', RequestHeader[2].Status::"Pending Approval", RequestHeader[2].Status::Approved);
                        if RequestHeader[2].FindFirst then begin
                            Error('The Imprest No %1 has already been surrendered', RequestHeader[2]."No.");
                        end;
                        RequestHeader[2].CalcFields("Total Surrender Amount");
                        RequestHeader[2].TestField("Total Surrender Amount");
                    end;
                    if RequestHeader[2]."Request Type" = RequestHeader[2]."Request Type"::"Salary Advance" then begin
                        RequestHeader[2].Validate("Request Amount");
                        RequestHeader[2].TestField(Purpose);
                        RequestHeader[2].TestField("Request Amount");
                        if Date2DMY(Today, 1) > 17 then Error('You can not apply Salary advance for this month,wait until next month');
                    end;
                    ApprovalsMgmtExt.OnSendRequestHeaderForApproval(RequestHeader[2]);
                end;
            //
            //5. Virement Budget Request
            DATABASE::"Virement Budget Request":
                begin
                    RecRef.SetTable(VirementBudget[1]);
                    VirementBudget[2].Get(VirementBudget[1]."No.");
                    ApprovalsMgmtExt.OnSendVirementBudgetForApproval(VirementBudget[2]);
                end;
            // 
            //6. Budget Plan
            DATABASE::"Budget Plan":
                begin
                    RecRef.SetTable(BudgetPlan[1]);
                    BudgetPlan[2].Get(BudgetPlan[1]."No.");
                    ApprovalsMgmtExt.OnSendBudgetPlanForApproval(BudgetPlan[2]);
                end;
            //
            //7. Fixed Deposit
            DATABASE::"Fixed Deposit Header":
                begin
                    RecRef.SetTable(FixedDeposit[1]);
                    FixedDeposit[2].Get(FixedDeposit[1]."No.");
                    ApprovalsMgmtExt.OnSendFixedDepositForApproval(FixedDeposit[2]);
                end;
            // 
            //8. Bank Account Reconciliation
            DATABASE::"Bank Acc. Reconciliation":
                begin
                    RecRef.SetTable(BankAccReconciliation[1]);
                    BankAccReconciliation[2].Get(BankAccReconciliation[1]."Reconciliation No.");
                    ApprovalsMgmtExt.OnSendBankAccReconciliationForApproval(BankAccReconciliation[2]);
                end;
            //
            //***********************SOFT - REQUISITION MODULE CUSTOMIZATIONS***************************
            //1. Requisition
            DATABASE::"Requisition Header":
                begin
                    RecRef.SetTable(Requisition[1]);
                    Requisition[2].Get(Requisition[1]."No.");
                    RLines.Reset;
                    RLines.SetRange("Requisition No", Requisition[2]."No.");
                    RLines.SetRange(Type, RLines.Type::Item);
                    RLines.SetFilter("Requisition No", '<>%1', '');
                    if RLines.FindSet then begin
                        repeat
                            RLines.TestField(Quantity);
                            RLines.TestField("Location Code");
                        until RLines.Next = 0;
                    end;
                    ApprovalsMgmtExt.OnSendRequisitionForApproval(Requisition[2]);
                end;
            // 
            //3. Procurement Plan
            Database::"Procurement Plans":
                begin
                    RecRef.SetTable(ProcurePlan[1]);
                    ProcurePlan[2].Get(ProcurePlan[1]."No.");
                    ApprovalsMgmtExt.OnSendProcurePlanForApproval(ProcurePlan[2]);
                end;
            //
            //6. RFQ 
            Database::"RFQ Header":
                begin
                    RecRef.SetTable(RFQ[1]);
                    RFQ[2].Get(RFQ[1]."No.");
                    ApprovalsMgmtExt.OnSendRFQForApproval(RFQ[2]);
                end;
            //
            //***********************SOFT - HR MODULE CUSTOMIZATIONS***************************
            //1. HR Jobs
            DATABASE::"Company Jobs":
                begin
                    RecRef.SetTable(HrJobs[1]);
                    HrJobs[2].Get(HrJobs[1]."Job ID");
                    ApprovalsMgmtExt.OnSendHRJobsForApproval(HrJobs[2]);
                end;
            // 
            //2. Job Requisitions
            DATABASE::"Job Requisition":
                begin
                    RecRef.SetTable(JobRequisition[1]);
                    JobRequisition[2].Get(JobRequisition[1]."No.");
                    ApprovalsMgmtExt.OnSendJobRequisitionForApproval(JobRequisition[2]);
                end;
            //   
            //4. Employee Change Request
            DATABASE::"Employee Change Request":
                begin
                    RecRef.SetTable(EmployeeChange[1]);
                    EmployeeChange[2].Get(EmployeeChange[1]."No.");
                    ApprovalsMgmtExt.OnSendEmployeeChangeForApproval(EmployeeChange[2]);
                end;
            //
            //5. Leave Plan
            DATABASE::"Leave Plan":
                begin
                    RecRef.SetTable(LeavePlan[1]);
                    LeavePlan[2].Get(LeavePlan[1]."No.");
                    ApprovalsMgmtExt.OnSendLeavePlanForApproval(LeavePlan[2]);
                end;
            //6. Leave
            DATABASE::"Leave Applications":
                begin
                    RecRef.SetTable(LeaveApplication[1]);
                    LeaveApplication[2].Get(LeaveApplication[1]."No.");
                    LeaveApplication[2].TestField(Reliever);
                    LeaveApplication[2].TestField("Start Date");
                    LeaveApplication[2].TestField("Days Applied");
                    LeaveApplication[2].TestField("Leave Code");
                    LeaveApplication[2].TestField(Status, LeaveApplication[2].Status::Open);
                    LeaveApplication[2].TestField(Posted, false);
                    LeaveApplication[2].TestField("Phone No.");
                    LeaveTypes.Get(LeaveApplication[2]."Leave Code");
                    if LeaveTypes."Requires Attachment" then begin
                        DocumentAttachment.Reset;
                        DocumentAttachment.SetRange("No.", LeaveApplication[2]."No.");
                        if not DocumentAttachment.FindFirst then Error('Kindly add an attachment');
                    end;
                    ApprovalsMgmtExt.OnSendLeaveForApproval(LeaveApplication[2]);
                end;
            //
            //7. Leave Recall
            DATABASE::"Leave Recall":
                begin
                    RecRef.SetTable(LeaveRecall[1]);
                    LeaveRecall[2].Get(LeaveRecall[1]."No.");
                    ApprovalsMgmtExt.OnSendLeaveRecallForApproval(LeaveRecall[2]);
                end;
            //   
            //9. Training Needs
            DATABASE::"Training Needs":
                begin
                    RecRef.SetTable(TrainingNeeds[1]);
                    TrainingNeeds[2].Get(TrainingNeeds[1].Code);
                    ApprovalsMgmtExt.OnSendTrainingNeedsForApproval(TrainingNeeds[2]);
                end;
            // 
            //10. Employee Exit
            DATABASE::"Employee Exit":
                begin
                    RecRef.SetTable(EmployeeExit[1]);
                    EmployeeExit[2].Get(EmployeeExit[1]."No.");
                    EmployeeExit[2].TestField("Date of Exit");
                    EmployeeExit[2].TestField("Date Of Notice");
                    EmployeeExit[2].TestField("Reason For Exit");
                    ApprovalsMgmtExt.OnSendEmployeeExitForApproval(EmployeeExit[2]);
                end;
        // 
        end;
    end;

    [Scope('Cloud')]
    procedure CancelDocumentApproval(RecordID: RecordId)
    var
        RecRef: RecordRef;
        //**********Finance**********
        PV: array[2] of Record "Payment Voucher";
        RequestHeader: array[2] of Record "Request Header";
        PettyCash: array[2] of Record "Petty Cash Header";
        VirementBudget: array[2] of Record "Virement Budget Request";
        BudgetPlan: array[2] of Record "Budget Plan";
        BankAccReconciliation: array[2] of Record "Bank Acc. Reconciliation";
        FixedDeposit: array[2] of Record "Fixed Deposit Header";
        CompanyDocuments: array[2] of Record "Company Documents";
        //**********Procurement**********
        Requisition: array[2] of Record "Requisition Header";
        RFQ: array[2] of Record "RFQ Header";
        BudgetPlanHeader: array[2] of Record "Budget Plan";
        VirementBudgetRequest: array[2] of Record "Virement Budget Request";
        ProcurePlan: array[2] of Record "Procurement Plans";
        //**********Human Resource**********
        LeaveApplication: array[2] of Record "Leave Applications";
        Training: array[2] of Record "Training Application";
        TrainingNeeds: array[2] of Record "Training Needs";
        LeavePlan: array[2] of Record "Leave Plan";
        Appraisal: array[2] of Record "Appraisal Header";
        HRJobs: array[2] of Record "Company Jobs";
        JobRequisition: array[2] of Record "Job Requisition";
        EmployeeChange: array[2] of Record "Employee Change Request";
        LeaveRecall: array[2] of Record "Leave Recall";
        EmployeeExit: array[2] of Record "Employee Exit";
        PayrollPeriod: array[2] of Record "Payroll Periods";
    begin
        RecRef := RecordID.GetRecord;
        case RecRef.Number of //***********************SOFT - ADVANCED FINANCE MODULE CUSTOMIZATIONS***************************
                              //1. Payment Voucher
            DATABASE::"Payment Voucher":
                begin
                    RecRef.SetTable(PV[1]);
                    PV[2].Get(PV[1]."No.");
                    ApprovalsMgmtExt.OnCancelPVApprovalRequest(PV[2]);
                end;
            //
            //2. Petty Cash
            DATABASE::"Petty Cash Header":
                begin
                    RecRef.SetTable(PettyCash[1]);
                    PettyCash[2].Get(PettyCash[1]."No.");
                    ApprovalsMgmtExt.OnCancelPettyCashApprovalRequest(PettyCash[2]);
                end;
            //3. Request Header
            DATABASE::"Request Header":
                begin
                    RecRef.SetTable(RequestHeader[1]);
                    RequestHeader[2].Get(RequestHeader[1]."No.");
                    ApprovalsMgmtExt.OnCancelRequestHeaderApprovalRequest(RequestHeader[2]);
                end;
            //
            //5. Virement Budget Request
            DATABASE::"Virement Budget Request":
                begin
                    RecRef.SetTable(VirementBudget[1]);
                    VirementBudget[2].Get(VirementBudget[1]."No.");
                    ApprovalsMgmtExt.OnCancelVirementBudgetApprovalRequest(VirementBudget[2]);
                end;
            // 
            //6. Budget Plan
            DATABASE::"Budget Plan":
                begin
                    RecRef.SetTable(BudgetPlan[1]);
                    BudgetPlan[2].Get(BudgetPlan[1]."No.");
                    ApprovalsMgmtExt.OnCancelBudgetPlanApprovalRequest(BudgetPlan[2]);
                end;
            //
            //7. Fixed Deposit
            DATABASE::"Fixed Deposit Header":
                begin
                    RecRef.SetTable(FixedDeposit[1]);
                    FixedDeposit[2].Get(FixedDeposit[1]."No.");
                    ApprovalsMgmtExt.OnCancelFixedDepositApprovalRequest(FixedDeposit[2]);
                end;
            // 
            //8. Bank Account Reconciliation
            DATABASE::"Bank Acc. Reconciliation":
                begin
                    RecRef.SetTable(BankAccReconciliation[1]);
                    BankAccReconciliation[2].Get(BankAccReconciliation[1]."Reconciliation No.");
                    ApprovalsMgmtExt.OnCancelBankAccReconciliationApprovalRequest(BankAccReconciliation[2]);
                end;
            //
            //***********************SOFT - REQUISITION MODULE CUSTOMIZATIONS***************************
            //1. Requisition
            DATABASE::"Requisition Header":
                begin
                    RecRef.SetTable(Requisition[1]);
                    Requisition[2].Get(Requisition[1]."No.");
                    ApprovalsMgmtExt.OnCancelRequisitionApprovalRequest(Requisition[2]);
                end;
            // 
            //3. Procurement Plan
            Database::"Procurement Plans":
                begin
                    RecRef.SetTable(ProcurePlan[1]);
                    ProcurePlan[2].Get(ProcurePlan[1]."No.");
                    ApprovalsMgmtExt.OnCancelProcurePlanApprovalRequest(ProcurePlan[2]);
                end;
            //
            //6. RFQ 
            Database::"RFQ Header":
                begin
                    RecRef.SetTable(RFQ[1]);
                    RFQ[2].Get(RFQ[1]."No.");
                    ApprovalsMgmtExt.OnCancelRFQApprovalRequest(RFQ[2]);
                end;
            //
            //***********************SOFT - HR MODULE CUSTOMIZATIONS***************************
            //1. HR Jobs
            DATABASE::"Company Jobs":
                begin
                    RecRef.SetTable(HRJobs[1]);
                    HRJobs[2].Get(HRJobs[1]."Job ID");
                    ApprovalsMgmtExt.OnCancelHRJobsApprovalRequest(HRJobs[2]);
                end;
            // 
            //2. Job Requisitions
            DATABASE::"Job Requisition":
                begin
                    RecRef.SetTable(JobRequisition[1]);
                    JobRequisition[2].Get(JobRequisition[1]."No.");
                    ApprovalsMgmtExt.OnCancelJobRequisitionApprovalRequest(JobRequisition[2]);
                end;
            //   
            //4. Employee Change Request
            DATABASE::"Employee Change Request":
                begin
                    RecRef.SetTable(EmployeeChange[1]);
                    EmployeeChange[2].Get(EmployeeChange[1]."No.");
                    ApprovalsMgmtExt.OnCancelEmployeeChangeApprovalRequest(EmployeeChange[2]);
                end;
            //
            //5. Leave Plan
            DATABASE::"Leave Plan":
                begin
                    RecRef.SetTable(LeavePlan[1]);
                    LeavePlan[2].Get(LeavePlan[1]."No.");
                    ApprovalsMgmtExt.OnCancelLeavePlanApprovalRequest(LeavePlan[2]);
                end;
            //6. Leave
            DATABASE::"Leave Applications":
                begin
                    RecRef.SetTable(LeaveApplication[1]);
                    LeaveApplication[2].Get(LeaveApplication[1]."No.");
                    ApprovalsMgmtExt.OnCancelLeaveApprovalRequest(LeaveApplication[2]);
                end;
            //
            //7. Leave Recall
            DATABASE::"Leave Recall":
                begin
                    RecRef.SetTable(LeaveRecall[1]);
                    LeaveRecall[2].Get(LeaveRecall[1]."No.");
                    ApprovalsMgmtExt.OnCancelLeaveRecallApprovalRequest(LeaveRecall[2]);
                end;
            //        //9. Training Needs
            DATABASE::"Training Needs":
                begin
                    RecRef.SetTable(TrainingNeeds[1]);
                    TrainingNeeds[2].Get(TrainingNeeds[1].Code);
                    ApprovalsMgmtExt.OnCancelTraininigNeedsApprovalRequest(TrainingNeeds[2]);
                end;
            // 
            //10. Employee Exit
            DATABASE::"Employee Exit":
                begin
                    RecRef.SetTable(EmployeeExit[1]);
                    EmployeeExit[2].Get(EmployeeExit[1]."No.");
                    ApprovalsMgmtExt.OnCancelEmployeeExitApprovalRequest(EmployeeExit[2]);
                end;
        // 
        end;
    end;

    procedure ApproveDocument(RecordID: RecordId)
    begin
        ApproveRecordApprovalRequest(RecordID);
    end;

    procedure DelegateDocument(RecordID: RecordId)
    begin
        DelegateRecordApprovalRequest(RecordID);
    end;

    procedure RejectDocument(RecordID: RecordId)
    begin
        RejectRecordApprovalRequest(RecordID);
    end;

    procedure FindOpenApprovalEntryForCurrUser(var ApprovalEntry: Record "Approval Entry"; RecordID: RecordID): Boolean
    begin
        ApprovalEntry.SetRange("Table ID", RecordID.TableNo);
        ApprovalEntry.SetRange("Record ID to Approve", RecordID);
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        ApprovalEntry.SetRange("Related to Change", false);
        exit(ApprovalEntry.FindFirst);
    end;
    //Document Approval
    procedure ApproveRecordApprovalRequest(RecordID: RecordID)
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        if not FindOpenApprovalEntryForCurrUser(ApprovalEntry, RecordID) then Error(NoReqToApproveErr);
        ApprovalEntry.SetRecFilter;
        ApprovalsMgmt.ApproveApprovalRequests(ApprovalEntry);
    end;
    //End Of Document Approval
    //Document Delagation
    procedure DelegateRecordApprovalRequest(RecordID: RecordID)
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        if not FindOpenApprovalEntryForCurrUser(ApprovalEntry, RecordID) then Error(NoReqToDelegateErr);
        ApprovalEntry.SetRecFilter;
        ApprovalsMgmt.DelegateApprovalRequests(ApprovalEntry);
    end;
    //End of Document Delagation
    //Document Rejection
    procedure RejectRecordApprovalRequest(RecordID: RecordID)
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        if not FindOpenApprovalEntryForCurrUser(ApprovalEntry, RecordID) then Error(NoReqToRejectErr);
        ApprovalEntry.SetRecFilter;
        ApprovalsMgmt.RejectApprovalRequests(ApprovalEntry);
    end;
    //End of Document Rejection
    [Scope('Cloud')]
    procedure GetLeaveBalanceForSelectedLeave(LeaveTpe: Code[25]; EmployeeNo: Code[25]; var DaysAppliedFor: Integer) AvailableLeaveBalance: Decimal
    begin
        if LeaveTypes.Get(LeaveTpe) then begin
            if Employee.Get(EmployeeNo) then begin
                if (LeaveTypes.Gender in [LeaveTypes.Gender::Female]) and (Employee.Gender in [Employee.Gender::Male]) then Error('This Leave type is only applicable by %1', LeaveTypes.Gender);
                if (LeaveTypes.Gender in [LeaveTypes.Gender::Male]) and (Employee.Gender in [Employee.Gender::Female]) then Error('This Leave type is only applicable by %1', LeaveTypes.Gender);
            end;
            LeaveCalendar.Reset;
            LeaveCalendar.SetRange("Current Leave Calendar", true);
            if LeaveCalendar.FindFirst then begin
                LeaveEntries.Reset;
                LeaveEntries.SetRange("Employee No.", EmployeeNo);
                LeaveEntries.SetRange("Leave Type", LeaveTpe);
                LeaveEntries.SetRange(Closed, false);
                if LeaveEntries.FindFirst then begin
                    LeaveEntries.CalcSums(Quantity);
                    LeaveBalance := LeaveEntries.Quantity;
                end;
            end
        end;
        AvailableLeaveBalance := LeaveBalance;
    end;

    [Scope('Cloud')]
    procedure IsAllowedToApplyForLeave(LeaveType: Code[25]; EmployeeNo: Code[25])
    begin
        if LeaveTypes.Get(LeaveType) then begin
            if Employee.Get(EmployeeNo) then begin
                if (LeaveTypes.Gender in [LeaveTypes.Gender::Female]) and (Employee.Gender in [Employee.Gender::Male]) then Error('This Leave type is only applicable by %1', LeaveTypes.Gender);
                if (LeaveTypes.Gender in [LeaveTypes.Gender::Male]) and (Employee.Gender in [Employee.Gender::Female]) then Error('This Leave type is only applicable by %1', LeaveTypes.Gender);
            end;
        end;
    end;

    procedure GetDocumentType(RecordID: RecordId) DocumentType: Text[50]
    var
        RecRef: RecordRef;
        RequestHeader: array[2] of Record "Request Header";
        RequisitionHeader: array[2] of Record "Requisition Header";
        LeaveApplication: array[2] of Record "Leave Applications";
    begin
        RecRef := RecordID.GetRecord;
        case RecRef.Number of //**********Finance**********
            DATABASE::"Payment Voucher":
                begin
                    exit('PV');
                end;
            DATABASE::"Request Header":
                begin
                    RecRef.SetTable(RequestHeader[1]);
                    RequestHeader[2].Get(RequestHeader[1]."No.");
                    case RequestHeader[2]."Request Type" of
                        RequestHeader[2]."Request Type"::Imprest:
                            exit('ImprestRequest');
                        RequestHeader[2]."Request Type"::"Staff Claim":
                            exit('StaffClaim');
                        RequestHeader[2]."Request Type"::"Salary Advance":
                            exit('SalaryAdvance');
                    end;
                end;
            DATABASE::"Petty Cash Header":
                begin
                    exit('Petty Cash');
                end;
            DATABASE::"Budget Plan":
                begin
                    exit('Budget Plan')
                end;
            DATABASE::"Virement Budget Request":
                begin
                    exit('Virement');
                end;
            DATABASE::"Fixed Deposit Header":
                begin
                    exit('FixedDeposit');
                end;
            DATABASE::"Bank Acc. Reconciliation":
                begin
                    exit('BankAccReconciliation');
                end;
            //**********Procurement**********
            DATABASE::"Requisition Header":
                begin
                    RecRef.SetTable(RequisitionHeader[1]);
                    RequisitionHeader[2].Get(RequisitionHeader[1]."No.");
                    case RequisitionHeader[2]."Document Type" of
                        RequisitionHeader[2]."Document Type"::"Purchase Requisition":
                            exit('PurchaseRequisition');
                        RequisitionHeader[2]."Document Type"::"Store Requisition":
                            exit('StoreRequisition');
                    end;
                end;
            DATABASE::"RFQ Header":
                begin
                    exit('RFQ');
                end;
            DATABASE::"Procurement Plans":
                begin
                    exit('ProcurePlan');
                end;
            //**********Human Resource**********
            DATABASE::"Leave Plan":
                begin
                    exit('LeavePlan');
                end;
            DATABASE::"Leave Applications":
                begin
                    RecRef.SetTable(LeaveApplication[1]);
                    if LeaveApplication[2].Get(LeaveApplication[1]."No.") then;
                    case LeaveApplication[2]."Nature of Application" of
                        LeaveApplication[2]."Nature of Application"::"Leave Application":
                            exit('LeaveApplication');
                        LeaveApplication[2]."Nature of Application"::"Leave Reimbursement":
                            exit('LeaveReimbursement');
                    end;
                end;
            DATABASE::"Leave Recall":
                begin
                    exit('LeaveRecall');
                end;
            DATABASE::"Training Application":
                begin
                    exit('Training');
                end;
            DATABASE::"Training Needs":
                begin
                    exit('TrainingNeeds');
                end;
            DATABASE::"Appraisal Header":
                begin
                    exit('Appraisal');
                end;
            DATABASE::"Company Jobs":
                begin
                    exit('HrJobs');
                end;
            DATABASE::"Job Requisition":
                begin
                    exit('JobRequisition');
                end;
            DATABASE::"Employee Change Request":
                begin
                    exit('EmployeeChange');
                end;
            DATABASE::"Employee Exit":
                begin
                    exit('EmployeeExit');
                end;
            DATABASE::"Payroll Periods":
                begin
                    exit('PayrollPeriod');
                end;
        end;
    end;

    procedure ApprovalComment(RecordID: RecordId; DocNo: Code[20]; UserID: Code[50]; Comment: Text[80])
    var
        ApprovalComment: Record "Approval Comment Line";
        RecRef: RecordRef;
    begin
        RecRef := RecordID.GetRecord;
        ApprovalComment.Init;
        ApprovalComment."Entry No." := ApprovalComment.GetLastEntryNo() + 1;
        ApprovalComment."Table ID" := RecRef.Number;
        ApprovalComment."Document Type" := ApprovalComment."Document Type"::Quote;
        ApprovalComment."Document No." := DocNo;
        ApprovalComment."User ID" := UserID;
        ApprovalComment."Date and Time" := CurrentDateTime;
        ApprovalComment.Comment := Comment;
        ApprovalComment."Record ID to Approve" := RecordID;
        ApprovalComment.Insert;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnApproveApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRejectApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDelegateApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    begin
    end;
}
