codeunit 52203423 "Approval Mgmt. Ext"
{
    var
        WorkflowManagement: Codeunit "Workflow Management";
        WorkflowEventHandling: Codeunit "Workflow Event Handling Ext";
        ApprovalMgmt: Codeunit "Approvals Mgmt.";
        ApprovalEntry: Record "Approval Entry";
        UserSetup: Record "User Setup";
        NoWFUserGroupMembersErr: Label 'A Workflow User Group with at least one member must be set up.';
    //#region Approval Methods
    local procedure "*****************SOFT - ADVANCED FINANCE MODULE CUSTOMIZATIONS*********************"()
    begin
    end;

    local procedure "***********************Payment Voucher******************************************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendPVForApproval(var PV: Record "Payment Voucher")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelPVApprovalRequest(var PV: Record "Payment Voucher")
    begin
    end;

    procedure CheckPVApprovalsWorkflowEnable(var PV: Record "Payment Voucher"): Boolean
    begin
        if IsPVApprovalWorkflowEnabled(PV) then exit(true);
    end;

    procedure IsPVApprovalWorkflowEnabled(var PV: Record "Payment Voucher"): Boolean
    begin
        exit(WorkflowManagement.CanExecuteWorkflow(PV, WorkflowEventHandling.RunWorkflowOnSendPVForApprovalCode()))
    end;

    local procedure "***********************Receipt******************************************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendReceiptHeaderForApproval(var ReceiptHeader: Record "Receipt Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelReceiptHeaderApprovalRequest(var ReceiptHeader: Record "Receipt Header")
    begin
    end;

    local procedure "***********************Petty Cash******************************************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendPettyCashForApproval(var PettyCash: Record "Petty Cash Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelPettyCashApprovalRequest(var PettyCash: Record "Petty Cash Header")
    begin
    end;

    local procedure "***********************Request Header******************************************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendRequestHeaderForApproval(var RequestHeader: Record "Request Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelRequestHeaderApprovalRequest(var RequestHeader: Record "Request Header")
    begin
    end;

    local procedure "***********************Request For Payement Request******************************************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendRequestForPaymentForApproval(var RequestForPayment: Record "Request for Payment")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelRequestForPaymentApprovalRequest(var RequestForPayment: Record "Request for Payment")
    begin
    end;

    local procedure "***********************Virement Budget Request******************************************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendVirementBudgetForApproval(var VirementBudget: Record "Virement Budget Request")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelVirementBudgetApprovalRequest(var VirementBudget: Record "Virement Budget Request")
    begin
    end;

    local procedure "***********************Budget Plan******************************************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendBudgetPlanForApproval(var BudgetPlan: Record "Budget Plan")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelBudgetPlanApprovalRequest(var BudgetPlan: Record "Budget Plan")
    begin
    end;

    local procedure "***********************Fixed Deposit******************************************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendFixedDepositForApproval(var FixedDeposit: Record "Fixed Deposit Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelFixedDepositApprovalRequest(var FixedDeposit: Record "Fixed Deposit Header")
    begin
    end;

    local procedure "***********************Bank Reconciliation******************************************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendBankAccReconciliationForApproval(var BankAccReconciliation: Record "Bank Acc. Reconciliation")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelBankAccReconciliationApprovalRequest(var BankAccReconciliation: Record "Bank Acc. Reconciliation")
    begin
    end;

    local procedure "*****************SOFT - PROCUREMENT MODULE CUSTOMIZATIONS*********************"()
    begin
    end;

    local procedure "***********************Requisitions******************************************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendRequisitionForApproval(var Requisition: Record "Requisition Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelRequisitionApprovalRequest(var Requisition: Record "Requisition Header")
    begin
    end;

    local procedure "***********************Procurement Inspection******************************************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendProcurementInspectionForApproval(var ProcurementInspection: Record "Procurement Inspection")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelProcurementInspectionApprovalRequest(var ProcurementInspection: Record "Procurement Inspection")
    begin
    end;

    local procedure "***********************Procurement Plans******************************************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendProcurePlanForApproval(var ProcurePlan: Record "Procurement Plans")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelProcurePlanApprovalRequest(var ProcurePlan: Record "Procurement Plans")
    begin
    end;
    //
    local procedure "***********************RFQ Header******************************************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendRFQForApproval(var RFQ: Record "RFQ Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelRFQApprovalRequest(var RFQ: Record "RFQ Header")
    begin
    end;

    local procedure "***********************Supplier Application******************************************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendSupplierApplicationForApproval(var SupplierApplication: Record "Supplier Application")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelSupplierApplicationApprovalRequest(var SupplierApplication: Record "Supplier Application")
    begin
    end;

    local procedure "***********************Procurement Request******************************************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendProcurementRequestForApproval(var ProcurementRequest: Record "Procurement Request")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelProcurementRequestApprovalRequest(var ProcurementRequest: Record "Procurement Request")
    begin
    end;

    local procedure "***********************Contract******************************************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendContractForApproval(var Contract: Record "Contract Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelContractApprovalRequest(var Contract: Record "Contract Header")
    begin
    end;

    local procedure "***********************Contract Extension******************************************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendContractExtensionForApproval(var ContractExtension: Record "Contract Extension")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelContractExtensionApprovalRequest(var ContractExtension: Record "Contract Extension")
    begin
    end;
    //
    local procedure "*****************SOFT - HR MODULE CUSTOMIZATIONS*********************"()
    begin
    end;

    local procedure "***********************HR Jobs Request******************************************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendHRJobsForApproval(var HRJobs: Record "Company Jobs")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelHRJobsApprovalRequest(var HRJobs: Record "Company Jobs")
    begin
    end;

    local procedure "***********************Job Requisition Request******************************************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendJobRequisitionForApproval(var JobRequisition: Record "Job Requisition")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelJobRequisitionApprovalRequest(var JobRequisition: Record "Job Requisition")
    begin
    end;

    local procedure "***********************Employee Creation Request******************************************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendEmployeeForApproval(var Employee: Record Employee)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelEmployeeApprovalRequest(var Employee: Record Employee)
    begin
    end;

    local procedure "***********************Employee Change Request******************************************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendEmployeeChangeForApproval(var EmployeeChange: Record "Employee Change Request")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelEmployeeChangeApprovalRequest(var EmployeeChange: Record "Employee Change Request")
    begin
    end;

    local procedure "***********************Leave Plan Request******************************************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendLeavePlanForApproval(var LeavePlan: Record "Leave Plan")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelLeavePlanApprovalRequest(var LeavePlan: Record "Leave Plan")
    begin
    end;

    local procedure "***********************Leave Application******************************************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendLeaveForApproval(var Leave: Record "Leave Applications")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelLeaveApprovalRequest(var Leave: Record "Leave Applications")
    begin
    end;

    local procedure "***********************Leave Recall Request******************************************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendLeaveRecallForApproval(var LeaveRecall: Record "Leave Recall")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelLeaveRecallApprovalRequest(var LeaveRecall: Record "Leave Recall")
    begin
    end;

    local procedure "***********************Training******************************************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendTrainingForApproval(var Training: Record "Training Application")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelTraininigApprovalRequest(var Training: Record "Training Application")
    begin
    end;

    local procedure "***********************Training Needs******************************************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendTrainingNeedsForApproval(var TrainingNeeds: Record "Training Needs")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelTraininigNeedsApprovalRequest(var TrainingNeeds: Record "Training Needs")
    begin
    end;

    local procedure "*********************** Appraisal Request******************************************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendAppraisalForApproval(var Appraisal: Record "Appraisal Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelAppraisalApprovalRequest(var Appraisal: Record "Appraisal Header")
    begin
    end;

    local procedure "***********************Employee Exit******************************************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendEmployeeExitForApproval(var EmployeeExit: Record "Employee Exit")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelEmployeeExitApprovalRequest(var EmployeeExit: Record "Employee Exit")
    begin
    end;

    local procedure "***********************Payroll Periods******************************************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendPayrollPeriodsForApproval(var PayrollPeriods: Record "Payroll Periods")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelPayrollPeriodsApprovalRequest(var PayrollPeriods: Record "Payroll Periods")
    begin
    end;
    //#endregion
    //#region SetStatusToPending
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', true, true)]
    local procedure SetStatusToPendingApproval(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    var
        PV: Record "Payment Voucher";
        ReceiptHeader: Record "Receipt Header";
        PettyCash: Record "Petty Cash Header";
        RequestHeader: Record "Request Header";
        VirementBudget: Record "Virement Budget Request";
        BudgetPlan: Record "Budget Plan";
        FDHeader: Record "Fixed Deposit Header";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        Requisition: Record "Requisition Header";
        ProcurementInspection: Record "Procurement Inspection";
        ProcurePlan: Record "Procurement Plans";
        RFQ: Record "RFQ Header";
        SupplierApplication: Record "Supplier Application";
        ProcurementRequest: Record "Procurement Request";
        Contract: Record "Contract Header";
        ContractExtension: Record "Contract Extension";
        Leave: Record "Leave Applications";
        Training: Record "Training Application";
        TrainingNeeds: Record "Training Needs";
        LeavePlan: Record "Leave Plan";
        Appraisal: Record "Appraisal Header";
        HrJobs: Record "Company Jobs";
        JobRequisition: Record "Job Requisition";
        Employee: Record Employee;
        EmployeeChange: Record "Employee Change Request";
        LeaveRecall: Record "Leave Recall";
        EmployeeExit: Record "Employee Exit";
        PayrollPeriod: Record "Payroll Periods";
    begin
        case RecRef.Number of //***********************SOFT - ADVANCED FINANCE MODULE CUSTOMIZATIONS***************************
                              //1. Payment Voucher
            DATABASE::"Payment Voucher":
                begin
                    RecRef.SetTable(PV);
                    PV.Validate(Status, PV.Status::"Pending Approval");
                    PV.Modify(true);
                    IsHandled := true;
                end;
            //
            DATABASE::"Receipt Header":
                begin
                    RecRef.SetTable(ReceiptHeader);
                    ReceiptHeader.Validate(Status, ReceiptHeader.Status::"Pending Approval");
                    ReceiptHeader.Modify(true);
                    IsHandled := true;
                end; //
                     //2. Petty Cash
            DATABASE::"Petty Cash Header":
                begin
                    RecRef.SetTable(PettyCash);
                    PettyCash.Validate(Status, PettyCash.Status::"Pending Approval");
                    PettyCash.Modify(true);
                    IsHandled := true;
                end;
            //3. Request Header
            DATABASE::"Request Header":
                begin
                    RecRef.SetTable(RequestHeader);
                    RequestHeader.Validate(Status, RequestHeader.Status::"Pending Approval");
                    RequestHeader.Modify(true);
                    IsHandled := true;
                end;
            //
            //5. Virement Budget Request
            DATABASE::"Virement Budget Request":
                begin
                    RecRef.SetTable(VirementBudget);
                    VirementBudget.Validate(Status, VirementBudget.Status::"Pending Approval");
                    VirementBudget.Modify(true);
                    IsHandled := true;
                end;
            // 
            //6. Budget Plan
            DATABASE::"Budget Plan":
                begin
                    RecRef.SetTable(BudgetPlan);
                    BudgetPlan.Validate(Status, BudgetPlan.Status::"Pending Approval");
                    BudgetPlan.Modify(true);
                    IsHandled := true;
                end;
            //
            //7. Fixed Deposit
            DATABASE::"Fixed Deposit Header":
                begin
                    RecRef.SetTable(FDHeader);
                    FDHeader.Validate(Status, FDHeader.Status::"Pending Approval");
                    FDHeader.Modify(true);
                    IsHandled := true;
                end;
            // 
            //8. Bank Account Reconciliation
            DATABASE::"Bank Acc. Reconciliation":
                begin
                    RecRef.SetTable(BankAccReconciliation);
                    BankAccReconciliation.Validate(Status, BankAccReconciliation.Status::"Pending Approval");
                    BankAccReconciliation.Modify(true);
                    IsHandled := true;
                end;
            //
            //***********************SOFT - REQUISITION MODULE CUSTOMIZATIONS***************************
            //1. Requisition
            DATABASE::"Requisition Header":
                begin
                    RecRef.SetTable(Requisition);
                    Requisition.Validate(Status, Requisition.Status::"Pending Approval");
                    Requisition.Modify(true);
                    IsHandled := true;
                end;
            // 
            //1. Requisition
            DATABASE::"Procurement Inspection":
                begin
                    RecRef.SetTable(ProcurementInspection);
                    ProcurementInspection.Validate(Status, ProcurementInspection.Status::"Pending Approval");
                    ProcurementInspection.Modify(true);
                    IsHandled := true;
                end;
            // 
            //2. Procurement Plan
            Database::"Procurement Plans":
                begin
                    RecRef.SetTable(ProcurePlan);
                    ProcurePlan.Validate(Status, ProcurePlan.Status::"Pending Approval");
                    ProcurePlan.Modify(true);
                    IsHandled := true;
                end;
            //
            //3. RFQ 
            Database::"RFQ Header":
                begin
                    RecRef.SetTable(RFQ);
                    RFQ.Validate(Status, RFQ.Status::"Pending Approval");
                    RFQ.Modify(true);
                    IsHandled := true;
                end;
            //
            //5. Supplier Application
            Database::"Supplier Application":
                begin
                    RecRef.SetTable(SupplierApplication);
                    SupplierApplication.Validate(Status, SupplierApplication.Status::"Pending Approval");
                    SupplierApplication.Modify(true);
                    IsHandled := true;
                end;
            //
            //6. Procurement Request
            Database::"Procurement Request":
                begin
                    RecRef.SetTable(ProcurementRequest);
                    ProcurementRequest.Validate(Status, ProcurementRequest.Status::"Pending Approval");
                    ProcurementRequest.Modify(true);
                    IsHandled := true;
                end;
            //
            //7. Contract Header
            Database::"Contract Header":
                begin
                    RecRef.SetTable(Contract);
                    Contract.Validate(Status, Contract.Status::"Pending Approval");
                    Contract.Modify(true);
                    IsHandled := true;
                end;
            //
            //8. Contract Extension
            Database::"Contract Extension":
                begin
                    RecRef.SetTable(ContractExtension);
                    ContractExtension.Validate(Status, ContractExtension.Status::"Pending Approval");
                    ContractExtension.Modify(true);
                    IsHandled := true;
                end;
            //
            //***********************SOFT - HR MODULE CUSTOMIZATIONS***************************        //1. HR Jobs
            DATABASE::"Company Jobs":
                begin
                    RecRef.SetTable(HrJobs);
                    HrJobs.Validate(Status, HrJobs.Status::"Pending Approval");
                    HrJobs.Modify(true);
                    IsHandled := true;
                end;
            // 
            //2. Job Requisitions
            DATABASE::"Job Requisition":
                begin
                    RecRef.SetTable(JobRequisition);
                    JobRequisition.Validate(Status, JobRequisition.Status::"Pending Approval");
                    JobRequisition.Modify(true);
                    IsHandled := true;
                end;
            // 
            //3. Employee
            DATABASE::Employee:
                begin
                    RecRef.SetTable(Employee);
                    Employee.Validate("Employee Status", Employee."Employee Status"::"Pending Approval");
                    Employee.Modify(true);
                    IsHandled := true;
                end;
            //  
            //4. Employee Change Request
            DATABASE::"Employee Change Request":
                begin
                    RecRef.SetTable(EmployeeChange);
                    EmployeeChange.Validate(Status, EmployeeChange.Status::"Pending Approval");
                    EmployeeChange.Modify(true);
                    IsHandled := true;
                end;
            //
            //5. Leave Plan
            DATABASE::"Leave Plan":
                begin
                    RecRef.SetTable(LeavePlan);
                    LeavePlan.Validate(Status, LeavePlan.Status::"Pending Approval");
                    LeavePlan.Modify(true);
                    IsHandled := true;
                end;
            //6. Leave
            DATABASE::"Leave Applications":
                begin
                    RecRef.SetTable(Leave);
                    Leave.Validate(Status, Leave.Status::"Pending Approval");
                    Leave.Modify(true);
                    IsHandled := true;
                end;
            //
            //7. Leave Recall
            DATABASE::"Leave Recall":
                begin
                    RecRef.SetTable(LeaveRecall);
                    LeaveRecall.Validate(Status, LeaveRecall.Status::"Pending Approval");
                    LeaveRecall.Modify(true);
                    IsHandled := true;
                end;
            //9. Training Needs
            DATABASE::"Training Needs":
                begin
                    RecRef.SetTable(TrainingNeeds);
                    TrainingNeeds.Validate(Status, TrainingNeeds.Status::"Pending Approval");
                    TrainingNeeds.Modify(true);
                    IsHandled := true;
                end;
            // 
            //10. Employee Exit
            DATABASE::"Employee Exit":
                begin
                    RecRef.SetTable(EmployeeExit);
                    EmployeeExit.Validate(Status, EmployeeExit.Status::"Pending Approval");
                    EmployeeExit.Modify(true);
                    IsHandled := true;
                end;
            // 
            //11. Payroll Periods
            DATABASE::"Payroll Periods":
                begin
                    RecRef.SetTable(PayrollPeriod);
                    PayrollPeriod.Validate(Status, PayrollPeriod.Status::"Pending Approval");
                    PayrollPeriod.Modify(true);
                    IsHandled := true;
                end;
        //
        end;
    end;
    //#endregion
    //#region PopulateApprovalEntryArgument
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', true, true)]
    local procedure PopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry")
    var
        PV: Record "Payment Voucher";
        ReceiptHeader: Record "Receipt Header";
        PettyCash: Record "Petty Cash Header";
        RequestHeader: Record "Request Header";
        RequestForPayment: Record "Request for Payment";
        VirementBudget: Record "Virement Budget Request";
        BudgetPlan: Record "Budget Plan";
        FDHeader: Record "Fixed Deposit Header";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        Requisition: Record "Requisition Header";
        ProcurementInspection: Record "Procurement Inspection";
        ProcurePlan: Record "Procurement Plans";
        RFQ: Record "RFQ Header";
        SupplierApplication: Record "Supplier Application";
        ProcurementRequest: Record "Procurement Request";
        Contract: Record "Contract Header";
        ContractExtension: Record "Contract Extension";
        Leave: Record "Leave Applications";
        Training: Record "Training Application";
        TrainingNeeds: Record "Training Needs";
        LeavePlan: Record "Leave Plan";
        Appraisal: Record "Appraisal Header";
        Payroll: Record "Payroll Periods";
        HrJobs: Record "Company Jobs";
        JobRequisition: Record "Job Requisition";
        Employee: Record Employee;
        EmployeeChange: Record "Employee Change Request";
        LeaveRecall: Record "Leave Recall";
        EmployeeExit: Record "Employee Exit";
    begin
        case RecRef.Number of //**********************SOFT - ADVANCED FINANCE MODULE CUSTOMIZATIONS**************************
                              //1. Payment Voucher
            DATABASE::"Payment Voucher":
                BEGIN
                    PV.CALCFIELDS("Total Amount");
                    RecRef.SETTABLE(PV);
                    ApprovalEntryArgument."Document No." := PV."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                    ApprovalEntryArgument.Amount := PV."Total Amount";
                    ApprovalEntryArgument."Amount (LCY)" := PV."Total Amount";
                    ApprovalEntryArgument."Currency Code" := PV.Currency;
                end;
            //
            //2. Petty Cash
            DATABASE::"Receipt Header":
                BEGIN
                    ReceiptHeader.CALCFIELDS(Amount);
                    RecRef.SETTABLE(ReceiptHeader);
                    ApprovalEntryArgument."Document No." := ReceiptHeader."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                    ApprovalEntryArgument.Amount := ReceiptHeader.Amount;
                    ApprovalEntryArgument."Amount (LCY)" := ReceiptHeader.Amount;
                end;
            //            //2. Petty Cash
            DATABASE::"Petty Cash Header":
                BEGIN
                    PettyCash.CALCFIELDS("Total Amount");
                    RecRef.SETTABLE(PettyCash);
                    ApprovalEntryArgument."Document No." := PettyCash."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                    ApprovalEntryArgument.Amount := PettyCash."Total Amount";
                    ApprovalEntryArgument."Amount (LCY)" := PettyCash."Total Amount";
                end;
            //
            //3. Request Header
            DATABASE::"Request Header":
                BEGIN
                    RequestHeader.CALCFIELDS("Request Amount");
                    RequestHeader.CALCFIELDS("Total Surrender Amount");
                    RecRef.SETTABLE(RequestHeader);
                    ApprovalEntryArgument."Document No." := RequestHeader."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                    if RequestHeader."Request Type" = RequestHeader."Request Type"::Imprest then begin
                        ApprovalEntryArgument.Amount := RequestHeader."Total Requested Amount";
                        ApprovalEntryArgument."Amount (LCY)" := RequestHeader."Total Requested Amount";
                    end;
                    if RequestHeader."Request Type" = RequestHeader."Request Type"::"Staff Claim" then begin
                        ApprovalEntryArgument.Amount := RequestHeader."Total Surrender Amount";
                        ApprovalEntryArgument."Amount (LCY)" := RequestHeader."Total Surrender Amount";
                    end;
                    if RequestHeader."Request Type" = RequestHeader."Request Type"::"Salary Advance" then begin
                        ApprovalEntryArgument.Amount := RequestHeader."Amount Requested";
                        ApprovalEntryArgument."Amount (LCY)" := RequestHeader."Amount Requested";
                    end;
                end;
            //
            //4. Virement Budget Request
            DATABASE::"Virement Budget Request":
                BEGIN
                    VirementBudget.CalcFields(Amount);
                    RecRef.SETTABLE(VirementBudget);
                    ApprovalEntryArgument."Document No." := VirementBudget."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                    ApprovalEntryArgument.Amount := VirementBudget.Amount;
                    ApprovalEntryArgument."Amount (LCY)" := VirementBudget.Amount;
                end;
            //
            //5. Budget Plan
            DATABASE::"Budget Plan":
                BEGIN
                    BudgetPlan.CalcFields(Amount);
                    RecRef.SETTABLE(BudgetPlan);
                    ApprovalEntryArgument."Document No." := BudgetPlan."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                    ApprovalEntryArgument.Amount := BudgetPlan.Amount;
                    ApprovalEntryArgument."Amount (LCY)" := BudgetPlan.Amount;
                end;
            //
            //6. Fixed Deposit
            DATABASE::"Fixed Deposit Header":
                BEGIN
                    FDHeader.CalcFields(Amount);
                    RecRef.SETTABLE(FDHeader);
                    ApprovalEntryArgument."Document No." := FDHeader."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                    ApprovalEntryArgument.Amount := FDHeader.Amount;
                    ApprovalEntryArgument."Amount (LCY)" := FDHeader.Amount;
                end;
            // 
            //7. Bank Acc Reconciliation
            DATABASE::"Bank Acc. Reconciliation":
                BEGIN
                    RecRef.SETTABLE(BankAccReconciliation);
                    ApprovalEntryArgument."Document No." := BankAccReconciliation."Reconciliation No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                    ApprovalEntryArgument.Amount := BankAccReconciliation."Statement Ending Balance";
                    ApprovalEntryArgument."Amount (LCY)" := BankAccReconciliation."Statement Ending Balance";
                end;
            //        //**********************SOFT - PROCUREMENT MODULE CUSTOMIZATIONS**************************
            //1. Requisition
            DATABASE::"Requisition Header":
                BEGIN
                    RecRef.SETTABLE(Requisition);
                    ApprovalEntryArgument."Document No." := Requisition."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            // 
            //1. Requisition
            DATABASE::"Procurement Inspection":
                BEGIN
                    RecRef.SETTABLE(ProcurementInspection);
                    ApprovalEntryArgument."Document No." := ProcurementInspection."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            //
            //2. Procurement Plan
            DATABASE::"Procurement Plans":
                BEGIN
                    RecRef.SETTABLE(ProcurePlan);
                    ApprovalEntryArgument."Document No." := ProcurePlan."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            //
            //3. RFQ
            DATABASE::"RFQ Header":
                BEGIN
                    RecRef.SETTABLE(RFQ);
                    ApprovalEntryArgument."Document No." := RFQ."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            //
            //5. Supplier Application
            Database::"Supplier Application":
                begin
                    RecRef.SETTABLE(SupplierApplication);
                    ApprovalEntryArgument."Document No." := SupplierApplication."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            //
            //6. Procurement Request
            Database::"Procurement Request":
                begin
                    RecRef.SETTABLE(ProcurementRequest);
                    ApprovalEntryArgument."Document No." := ProcurementRequest."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            //
            //7. Contract Header
            Database::"Contract Header":
                begin
                    RecRef.SETTABLE(Contract);
                    ApprovalEntryArgument."Document No." := Contract."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            //
            //8. Contract Extension
            Database::"Contract Extension":
                begin
                    RecRef.SETTABLE(ContractExtension);
                    ApprovalEntryArgument."Document No." := ContractExtension."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            //
            //***********************SOFT - HR MODULE CUSTOMIZATIONS***************************
            //1. HR Jobs
            DATABASE::"Company Jobs":
                begin
                    RecRef.SETTABLE(HrJobs);
                    ApprovalEntryArgument."Document No." := HrJobs."Job ID";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            // 
            //2. Job Requisition
            DATABASE::"Job Requisition":
                begin
                    RecRef.SETTABLE(JobRequisition);
                    ApprovalEntryArgument."Document No." := JobRequisition."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            //
            //3. Employee
            DATABASE::Employee:
                begin
                    RecRef.SetTable(Employee);
                    ApprovalEntryArgument."Document No." := Employee."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            //
            //4. Employee Change Request
            DATABASE::"Employee Change Request":
                begin
                    RecRef.SetTable(EmployeeChange);
                    ApprovalEntryArgument."Document No." := EmployeeChange."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            //
            //5. Leave Plan
            DATABASE::"Leave Plan":
                begin
                    RecRef.SetTable(LeavePlan);
                    ApprovalEntryArgument."Document No." := LeavePlan."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            //
            //6. Leave Appliucation
            DATABASE::"Leave Applications":
                begin
                    RecRef.SetTable(Leave);
                    ApprovalEntryArgument."Document No." := Leave."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            // 
            //7. Leave Recall
            DATABASE::"Leave Recall":
                begin
                    RecRef.SetTable(LeaveRecall);
                    ApprovalEntryArgument."Document No." := LeaveRecall."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            //
            //8. Training 
            DATABASE::"Training Application":
                begin
                    RecRef.SetTable(Training);
                    ApprovalEntryArgument."Document No." := Training."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            //
            //9. Appraisal
            DATABASE::"Appraisal Header":
                BEGIN
                    RecRef.SETTABLE(Appraisal);
                    ApprovalEntryArgument."Document No." := Appraisal."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            // 
            //10. Employee Exit
            DATABASE::"Employee Exit":
                BEGIN
                    RecRef.SETTABLE(EmployeeExit);
                    ApprovalEntryArgument."Document No." := EmployeeExit."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            // 
            //11. Payroll
            DATABASE::"Payroll Periods":
                BEGIN
                    RecRef.SETTABLE(Payroll);
                    ApprovalEntryArgument."Document No." := Format(Payroll."Start Date");
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
        //
        end;
    end;
    //#endregion
    //#region ShowApprovalComments
    //
    //[EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'GetApprovalComment', '', true, true)]
    local procedure ShowApprovalComments(Variant: Variant; WorkflowStepInstanceID: Guid)
    var
        ApprovalCommentLine: Record "Approval Comment Line";
        ApprovalEntry: Record "Approval Entry";
        ApprovalComments: Page "Approval Comments";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Variant);
        if RecRef.Number = DATABASE::"Approval Entry" then begin
            ApprovalEntry := Variant;
            RecRef.Get(ApprovalEntry."Record ID to Approve");
            ApprovalCommentLine.SetRange("Table ID", RecRef.Number);
            ApprovalCommentLine.SetRange("Record ID to Approve", ApprovalEntry."Record ID to Approve");
        end
        else begin
            ApprovalCommentLine.SetRange("Table ID", RecRef.Number);
            ApprovalCommentLine.SetRange("Record ID to Approve", RecRef.RecordId);
            ApprovalMgmt.FindApprovalEntryForCurrUser(ApprovalEntry, RecRef.RecordId);
        end;
        if IsNullGuid(WorkflowStepInstanceID) and (not IsNullGuid(ApprovalEntry."Workflow Step Instance ID")) then ApprovalComments.SetTableView(ApprovalCommentLine);
        ApprovalComments.SetWorkflowStepInstanceID(WorkflowStepInstanceID);
        ApprovalComments.Run;
    end;
    //#endregion
    procedure GetRecordApprover(RecordID: RecordID): Code[50]
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        ApprovalEntry.SetRange("Table ID", RecordID.TableNo);
        ApprovalEntry.SetRange("Record ID to Approve", RecordID);
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        ApprovalEntry.SetRange("Related to Change", false);
        if ApprovalEntry.FindFirst() then begin
            exit(ApprovalEntry."Approver ID");
        end;
    end;

    local procedure CreateApprovalEntry(ApprovalEntryArgument: Record "Approval Entry"; SequenceNo: Integer; SenderUsername: Code[50]; ApproverUsername: Code[50]; WorkflowStepArgument: Record "Workflow Step Argument"; EmpNo: Code[20])
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        with ApprovalEntry do begin
            "Table ID" := ApprovalEntryArgument."Table ID";
            "Document Type" := ApprovalEntryArgument."Document Type";
            "Document No." := ApprovalEntryArgument."Document No.";
            "Salespers./Purch. Code" := ApprovalEntryArgument."Salespers./Purch. Code";
            "Sequence No." := SequenceNo;
            "Sender ID" := SenderUsername;
            Amount := ApprovalEntryArgument.Amount;
            "Amount (LCY)" := ApprovalEntryArgument."Amount (LCY)";
            "Currency Code" := ApprovalEntryArgument."Currency Code";
            "Approver ID" := ApproverUsername;
            "Workflow Step Instance ID" := ApprovalEntryArgument."Workflow Step Instance ID";
            if ApproverUsername = UserId then
                Validate(Status, Status::Approved)
            else
                Validate(Status, Status::Created);
            "Date-Time Sent for Approval" := CreateDateTime(Today, Time);
            "Last Date-Time Modified" := CreateDateTime(Today, Time);
            "Last Modified By User ID" := UserId;
            "Due Date" := CalcDate(WorkflowStepArgument."Due Date Formula", Today);
            case WorkflowStepArgument."Delegate After" of
                WorkflowStepArgument."Delegate After"::Never:
                    Evaluate("Delegation Date Formula", '');
                WorkflowStepArgument."Delegate After"::"1 day":
                    Evaluate("Delegation Date Formula", '<1D>');
                WorkflowStepArgument."Delegate After"::"2 days":
                    Evaluate("Delegation Date Formula", '<2D>');
                WorkflowStepArgument."Delegate After"::"5 days":
                    Evaluate("Delegation Date Formula", '<5D>');
                else
                    Evaluate("Delegation Date Formula", '');
            end;
            "Available Credit Limit (LCY)" := ApprovalEntryArgument."Available Credit Limit (LCY)";
            SetApproverType(WorkflowStepArgument, ApprovalEntry);
            SetLimitType(WorkflowStepArgument, ApprovalEntry);
            "Record ID to Approve" := ApprovalEntryArgument."Record ID to Approve";
            "Approval Code" := ApprovalEntryArgument."Approval Code";
            OnBeforeApprovalEntryInsert(ApprovalEntry, ApprovalEntryArgument);
            Insert(true);
        end;
    end;

    local procedure SetApproverType(WorkflowStepArgument: Record "Workflow Step Argument"; var ApprovalEntry: Record "Approval Entry")
    begin
        case WorkflowStepArgument."Approver Type" of
            WorkflowStepArgument."Approver Type"::"Salesperson/Purchaser":
                ApprovalEntry."Approval Type" := ApprovalEntry."Approval Type"::"Sales Pers./Purchaser";
            WorkflowStepArgument."Approver Type"::Approver:
                ApprovalEntry."Approval Type" := ApprovalEntry."Approval Type"::Approver;
            WorkflowStepArgument."Approver Type"::"Workflow User Group":
                ApprovalEntry."Approval Type" := ApprovalEntry."Approval Type"::"Workflow User Group";
        end;
        OnAfterSetApproverType(WorkflowStepArgument, ApprovalEntry);
    end;

    local procedure SetLimitType(WorkflowStepArgument: Record "Workflow Step Argument"; var ApprovalEntry: Record "Approval Entry")
    begin
        case WorkflowStepArgument."Approver Limit Type" of
            WorkflowStepArgument."Approver Limit Type"::"Approver Chain", WorkflowStepArgument."Approver Limit Type"::"First Qualified Approver":
                ApprovalEntry."Limit Type" := ApprovalEntry."Limit Type"::"Approval Limits";
            WorkflowStepArgument."Approver Limit Type"::"Direct Approver":
                ApprovalEntry."Limit Type" := ApprovalEntry."Limit Type"::"No Limits";
            WorkflowStepArgument."Approver Limit Type"::"Specific Approver":
                ApprovalEntry."Limit Type" := ApprovalEntry."Limit Type"::"No Limits";
        end;
        if ApprovalEntry."Approval Type" = ApprovalEntry."Approval Type"::"Workflow User Group" then ApprovalEntry."Limit Type" := ApprovalEntry."Limit Type"::"No Limits";
    end;

    procedure GetEmployeeNoFromTable(TableID: Integer; "DocumentNo.": Code[20]): Code[50]
    var
        //**********Finance**********
        PV: Record "Payment Voucher";
        RequestHeader: Record "Request Header";
        ReceiptHeader: Record "Receipt Header";
        PettyCash: Record "Petty Cash Header";
        VirementBudget: Record "Virement Budget Request";
        BudgetPlan: Record "Budget Plan";
        FixedDeposit: Record "Fixed Deposit Header";
        //**********Procurement**********
        RequisitionHeader: Record "Requisition Header";
        RFQ: Record "RFQ Header";
        ProcurePlan: Record "Procurement Plans";
        SupplierApplication: Record "Supplier Application";
        ProcurementRequest: Record "Procurement Request";
        Contract: Record "Contract Header";
        ContractExtension: Record "Contract Extension";
        //**********Human Resource**********
        LeaveApp: Record "Leave Applications";
        TrainingApp: Record "Training Application";
        TrainingNeeds: Record "Training Needs";
        LeavePlan: Record "Leave Plan";
        Appraisal: Record "Appraisal Header";
        HRJobs: Record "Company Jobs";
        JobRequisition: Record "Job Requisition";
        EmployeeChange: Record "Employee Change Request";
        LeaveRecall: Record "Leave Recall";
        EmployeeExit: Record "Employee Exit";
        PayrollPeriod: Record "Payroll Periods";
    begin
        case TableID of //**********Finance**********       
            DATABASE::"Payment Voucher":
                begin
                    if PV.Get("DocumentNo.") then exit(GetUserEmployeeNo(PV."Prepared By"));
                end;
            DATABASE::"Request Header":
                begin
                    if RequestHeader.Get("DocumentNo.") then exit(RequestHeader."Employee No.");
                end;
            DATABASE::"Petty Cash Header":
                begin
                    if PettyCash.Get("DocumentNo.") then exit(PettyCash."Employee No.");
                end;
            DATABASE::"Budget Plan":
                begin
                    if BudgetPlan.Get("DocumentNo.") then exit(GetUserEmployeeNo(BudgetPlan."Created By"));
                end;
            DATABASE::"Virement Budget Request":
                begin
                    if VirementBudget.Get("DocumentNo.") then exit(GetUserEmployeeNo(VirementBudget."Created By"));
                end;
            DATABASE::"Fixed Deposit Header":
                begin
                    if FixedDeposit.Get("DocumentNo.") then exit(GetUserEmployeeNo(FixedDeposit."Created By"));
                end;
            //**********Procurement**********
            DATABASE::"Requisition Header":
                begin
                    if RequisitionHeader.Get("DocumentNo.") then exit(GetUserEmployeeNo(RequisitionHeader."Raised by"));
                end;
            DATABASE::"RFQ Header":
                begin
                    if RFQ.Get("DocumentNo.") then exit(GetUserEmployeeNo(RFQ."Created By"));
                end;
            DATABASE::"Procurement Plans":
                begin
                    if ProcurePlan.Get("DocumentNo.") then exit(GetUserEmployeeNo(ProcurePlan."Raised by"));
                end;
            DATABASE::"Procurement Request":
                begin
                    if ProcurementRequest.Get("DocumentNo.") then exit(GetUserEmployeeNo(ProcurementRequest."Created By"));
                end;
            DATABASE::"Contract Extension":
                begin
                    if ContractExtension.Get("DocumentNo.") then exit(GetUserEmployeeNo(ContractExtension."Created By"));
                end;
            //**********Human Resource**********
            DATABASE::"Leave Plan":
                begin
                    if LeavePlan.Get("DocumentNo.") then exit(LeavePlan."Employee No.");
                end;
            DATABASE::"Leave Applications":
                begin
                    if LeaveApp.Get("DocumentNo.") then exit(LeaveApp."Employee No");
                end;
            DATABASE::"Leave Recall":
                begin
                    if LeaveRecall.Get("DocumentNo.") then exit(LeaveRecall."Employee No");
                end;
            DATABASE::"Training Application":
                begin
                    if TrainingApp.Get("DocumentNo.") then exit(TrainingApp."Employee No");
                end;
            DATABASE::"Training Needs":
                begin
                    if TrainingNeeds.Get("DocumentNo.") then exit(TrainingNeeds."Employee No");
                end;
            DATABASE::"Appraisal Header":
                begin
                    if Appraisal.Get("DocumentNo.") then exit(Appraisal."Employee No");
                end;
            DATABASE::"Company Jobs":
                begin
                    //if HRJobs.Get("DocumentNo.") then exit(GetUserEmployeeNo(HRJobs."Created By"));
                end;
            DATABASE::"Job Requisition":
                begin
                    //if JobRequisition.Get("DocumentNo.") then exit(GetUserEmployeeNo(JobRequisition."Created By"));
                end;
            DATABASE::"Employee Change Request":
                begin
                    if EmployeeChange.Get("DocumentNo.") then exit(EmployeeChange."Employee No");
                end;
            DATABASE::"Employee Exit":
                begin
                    if EmployeeExit.Get("DocumentNo.") then exit(EmployeeExit."Employee No");
                end;
        end;
    end;

    local procedure GetUserEmployeeNo(var UserID: Code[50]): Code[20]
    begin
        UserSetup.Get(UserID);
        exit(UserSetup."Employee No.");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeApprovalEntryInsert(var ApprovalEntry: Record "Approval Entry"; ApprovalEntryArgument: Record "Approval Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetApproverType(WorkflowStepArgument: Record "Workflow Step Argument"; var ApprovalEntry: Record "Approval Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetLimitType(WorkflowStepArgument: Record "Workflow Step Argument"; var ApprovalEntry: Record "Approval Entry")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnApproveApprovalRequest', '', false, false)]
    [Scope('Cloud')]
    procedure FnflagOtherApprovals(var ApprovalEntry: Record "Approval Entry")
    var
        Approvers: Integer;
        Approved: Integer;
        ApprovalVar: array[3] of Record "Approval Entry";
    begin
        if ApprovalEntry."Approval Type" = ApprovalEntry."Approval Type"::"Workflow User Group" then begin
            ApprovalVar[1].RESET;
            ApprovalVar[1].SETRANGE("Document No.", ApprovalEntry."Document No.");
            ApprovalVar[1].SETRANGE("Record ID to Approve", ApprovalEntry."Record ID to Approve");
            ApprovalVar[1].SETRANGE("Sequence No.", ApprovalEntry."Sequence No.");
            ApprovalVar[1].SetFilter("Approver ID", '<>%1', ApprovalEntry."Approver ID");
            if ApprovalVar[1].FindFirst() then ApprovalVar[1].DeleteAll(true);
            ApprovalVar[2].RESET;
            ApprovalVar[2].SETRANGE("Document No.", ApprovalEntry."Document No.");
            ApprovalVar[2].SETRANGE("Sequence No.", ApprovalEntry."Sequence No." + 1);
            ApprovalVar[2].SETRANGE(Status, ApprovalEntry.Status::Created);
            if ApprovalVar[2].FINDSET then begin
                repeat
                    ApprovalVar[2].VALIDATE(Status, ApprovalVar[2].Status::Open);
                    ApprovalVar[2].MODIFY;
                until ApprovalVar[2].NEXT = 0;
            end;
            ApprovalVar[3].Reset();
            ApprovalVar[3].SETRANGE("Document No.", ApprovalEntry."Document No.");
            ApprovalVar[3].SetFilter(Status, '%1|%2', ApprovalVar[3].Status::Open, ApprovalVar[3].Status::Created);
            if not ApprovalVar[3].FindFirst then begin
                ReleaseDocument(ApprovalEntry."Table ID", ApprovalEntry."Document No.", ApprovalEntry."Document Type");
            end;
        end;
    end;

    local procedure ReleaseDocument(TableId: Integer; DocNo: Code[20]; DocType: Enum "Approval Document Type")
    var
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
        PV: Record "Payment Voucher";
        ReceiptHeader: Record "Receipt Header";
        RequestHeader: Record "Request Header";
        PettyCash: Record "Petty Cash Header";
        VirementBudget: Record "Virement Budget Request";
        BudgetPlan: Record "Budget Plan";
        FixedDeposit: Record "Fixed Deposit Header";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        CompanyDocuments: Record "Company Documents";
        Requisition: Record "Requisition Header";
        ProcurementInspection: Record "Procurement Inspection";
        RFQ: Record "RFQ Header";
        ProcurePlan: Record "Procurement Plans";
        SupplierApplication: Record "Supplier Application";
        ProcurementRequest: Record "Procurement Request";
        Contract: Record "Contract Header";
        ContractExtension: Record "Contract Extension";
        Leave: Record "Leave Applications";
        Training: Record "Training Application";
        TrainingNeeds: Record "Training Needs";
        LeavePlan: Record "Leave Plan";
        Appraisal: Record "Appraisal Header";
        HrJobs: Record "Company Jobs";
        JobRequisition: Record "Job Requisition";
        Employee: Record Employee;
        EmployeeChange: Record "Employee Change Request";
        LeaveRecall: Record "Leave Recall";
        EmployeeExit: Record "Employee Exit";
        PayrollPeriod: Record "Payroll Periods";
        StartDate: Date;
        HumanResourceMgt: Codeunit "Human Resource Management";
    begin
        case TableId of
            DATABASE::"Purchase Header":
                begin
                    PurchaseHeader.Get(DocType, DocNo);
                    PurchaseHeader.Validate(Status, PurchaseHeader.Status::Released);
                    PurchaseHeader.Modify(true);
                end;
            DATABASE::"Sales Header":
                begin
                    SalesHeader.Get(DocType, DocNo);
                    SalesHeader.Validate(Status, SalesHeader.Status::Released);
                    SalesHeader.Modify(true);
                end;
            DATABASE::"Payment Voucher":
                begin
                    PV.Get(DocNo);
                    PV.Validate(Status, PV.Status::Approved);
                    PV.Modify(true);
                end;
            DATABASE::"Receipt Header":
                begin
                    ReceiptHeader.Get(DocNo);
                    ReceiptHeader.Validate(Status, ReceiptHeader.Status::Approved);
                    ReceiptHeader.Modify(true);
                end;
            DATABASE::"Petty Cash Header":
                begin
                    PettyCash.Get(DocNo);
                    PettyCash.Validate(Status, PettyCash.Status::Approved);
                    PettyCash.Modify(true);
                end;
            DATABASE::"Request Header":
                begin
                    RequestHeader.Get(DocNo);
                    RequestHeader.Validate(Status, RequestHeader.Status::Approved);
                    RequestHeader.Modify(true);
                end;
            DATABASE::"Virement Budget Request":
                begin
                    VirementBudget.Get(DocNo);
                    VirementBudget.Validate(Status, VirementBudget.Status::Approved);
                    VirementBudget.Modify(true);
                end;
            DATABASE::"Budget Plan":
                begin
                    BudgetPlan.Get(DocNo);
                    BudgetPlan.Validate(Status, BudgetPlan.Status::Approved);
                    BudgetPlan.Modify(true);
                end;
            DATABASE::"Fixed Deposit Header":
                begin
                    FixedDeposit.Get(DocNo);
                    FixedDeposit.Validate(Status, FixedDeposit.Status::Approved);
                    FixedDeposit.Modify(true);
                end;
            DATABASE::"Bank Acc. Reconciliation":
                begin
                    BankAccReconciliation.Get(DocNo);
                    BankAccReconciliation.Validate(Status, BankAccReconciliation.Status::Approved);
                    BankAccReconciliation.Modify(true);
                end;
            DATABASE::"Requisition Header":
                begin
                    Requisition.Get(DocNo);
                    Requisition.Validate(Status, Requisition.Status::Approved);
                    Requisition.Modify(true);
                end;
            DATABASE::"Procurement Inspection":
                begin
                    ProcurementInspection.Get(DocNo);
                    ProcurementInspection.Validate(Status, ProcurementInspection.Status::Approved);
                    ProcurementInspection.Modify(true);
                end;
            DATABASE::"Procurement Plans":
                begin
                    ProcurePlan.Get(DocNo);
                    ProcurePlan.Validate(Status, ProcurePlan.Status::Approved);
                    ProcurePlan.Modify(true);
                end;
            DATABASE::"RFQ Header":
                begin
                    RFQ.Get(DocNo);
                    RFQ.Validate(Status, RFQ.Status::Approved);
                    RFQ.Modify(true);
                end;
            DATABASE::"Supplier Application":
                begin
                    SupplierApplication.Get(DocNo);
                    SupplierApplication.Validate(Status, SupplierApplication.Status::Approved);
                    SupplierApplication.Modify(true);
                end;
            DATABASE::"Procurement Request":
                begin
                    ProcurementRequest.Get(DocNo);
                    ProcurementRequest.Validate(Status, ProcurementRequest.Status::Approved);
                    ProcurementRequest.Modify(true);
                end;
            DATABASE::"Contract Header":
                begin
                    Contract.Get(DocNo);
                    Contract.Validate(Status, Contract.Status::Approved);
                    Contract.Modify(true);
                end;
            DATABASE::"Contract Extension":
                begin
                    ContractExtension.Get(DocNo);
                    ContractExtension.Validate(Status, ContractExtension.Status::Approved);
                    ContractExtension.Modify(true);
                end;
            DATABASE::"Company Jobs":
                begin
                    HRJobs.Get(DocNo);
                    HRJobs.Validate(Status, HRJobs.Status::Approved);
                    HRJobs.Modify(true);
                end;
            DATABASE::"Job Requisition":
                begin
                    JobRequisition.Get(DocNo);
                    JobRequisition.Validate(Status, JobRequisition.Status::Approved);
                    JobRequisition.Modify(true);
                end;
            DATABASE::Employee:
                begin
                    Employee.Get(DocNo);
                    Employee.Validate("Employee Status", Employee."Employee Status"::Active);
                    Employee.Modify(true);
                end;
            DATABASE::"Employee Change Request":
                begin
                    EmployeeChange.Get(DocNo);
                    EmployeeChange.Validate(Status, EmployeeChange.Status::Approved);
                    EmployeeChange.Modify(true);
                end;
            DATABASE::"Leave Plan":
                begin
                    LeavePlan.Get(DocNo);
                    LeavePlan.Validate(Status, LeavePlan.Status::Approved);
                    LeavePlan.Modify(true);
                end;
            DATABASE::"Leave Applications":
                begin
                    Leave.Get(DocNo);
                    Leave.Validate(Status, Leave.Status::Approved);
                    Leave.Modify(true);
                end;
            DATABASE::"Leave Recall":
                begin
                    LeaveRecall.Get(DocNo);
                    LeaveRecall.Validate(Status, LeaveRecall.Status::Approved);
                    LeaveRecall.Modify(true);
                end;
            DATABASE::"Training Needs":
                begin
                    TrainingNeeds.Get(DocNo);
                    TrainingNeeds.Validate(Status, TrainingNeeds.Status::Approved);
                    TrainingNeeds.Modify(true);
                end;
            DATABASE::"Employee Exit":
                begin
                    EmployeeExit.Get(DocNo);
                    EmployeeExit.Validate(Status, EmployeeExit.Status::Approved);
                    EmployeeExit.Modify(true);
                end;
            DATABASE::"Payroll Periods":
                begin
                    Evaluate(StartDate, DocNo);
                    PayrollPeriod.Get(StartDate);
                    PayrollPeriod.Validate(Status, PayrollPeriod.Status::Approved);
                    PayrollPeriod.Modify(true);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnRejectApprovalRequest', '', false, false)]
    local procedure IanCheckForRejectionComments(var ApprovalEntry: Record "Approval Entry")
    var
        ApprovalCommentLine: Record "Approval Comment Line";
        Approvers: Integer;
        Approved: Integer;
        ApprovalVar: Record "Approval Entry";
    begin
        ApprovalEntry.CalcFields(Comment);
        if not ApprovalEntry.Comment then Error('Please comment first before rejecting');
        if ApprovalEntry."Approval Type" = ApprovalEntry."Approval Type"::"Workflow User Group" then begin
            ApprovalVar.Reset();
            ApprovalVar.SetFilter("Entry No.", '<>%1', ApprovalEntry."Entry No.");
            ApprovalVar.SETRANGE("Document No.", ApprovalEntry."Document No.");
            if ((ApprovalEntry."Table ID" <> Database::"Purchase Header") and (ApprovalEntry."Table ID" <> Database::"Sales Header")) then ApprovalVar.SetFilter(status, '<>%1|<>%2', ApprovalEntry.Status::Rejected, ApprovalEntry.Status::Canceled);
            ApprovalVar.DeleteAll(true);
            ReopenDocument(ApprovalEntry."Table ID", ApprovalEntry."Document No.", ApprovalEntry."Document Type");
        end;
    end;

    local procedure ReopenDocument(TableId: Integer; DocNo: Code[20]; DocType: Enum "Approval Document Type")
    var
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
        PV: Record "Payment Voucher";
        ReceiptHeader: Record "Receipt Header";
        RequestHeader: Record "Request Header";
        PettyCash: Record "Petty Cash Header";
        VirementBudget: Record "Virement Budget Request";
        BudgetPlan: Record "Budget Plan";
        FixedDeposit: Record "Fixed Deposit Header";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        CompanyDocuments: Record "Company Documents";
        Requisition: Record "Requisition Header";
        ProcurementInspection: Record "Procurement Inspection";
        RFQ: Record "RFQ Header";
        ProcurePlan: Record "Procurement Plans";
        SupplierApplication: Record "Supplier Application";
        ProcurementRequest: Record "Procurement Request";
        Contract: Record "Contract Header";
        ContractExtension: Record "Contract Extension";
        Leave: Record "Leave Applications";
        Training: Record "Training Application";
        TrainingNeeds: Record "Training Needs";
        LeavePlan: Record "Leave Plan";
        Appraisal: Record "Appraisal Header";
        HrJobs: Record "Company Jobs";
        JobRequisition: Record "Job Requisition";
        Employee: Record Employee;
        EmployeeChange: Record "Employee Change Request";
        LeaveRecall: Record "Leave Recall";
        EmployeeExit: Record "Employee Exit";
        PayrollPeriod: Record "Payroll Periods";
        StartDate: Date;
    begin
        case TableId of
            DATABASE::"Purchase Header":
                begin
                    PurchaseHeader.Get(DocType, DocNo);
                    PurchaseHeader.Validate(Status, PurchaseHeader.Status::Open);
                    HrJobs.Modify(true);
                end;
            DATABASE::"Sales Header":
                begin
                    SalesHeader.Get(DocType, DocNo);
                    SalesHeader.Validate(Status, SalesHeader.Status::Open);
                    SalesHeader.Modify(true);
                end;
            DATABASE::"Payment Voucher":
                begin
                    PV.Get(DocNo);
                    PV.Validate(Status, PV.Status::Open);
                    PV.Modify(true);
                end;
            DATABASE::"Receipt Header":
                begin
                    ReceiptHeader.Get(DocNo);
                    ReceiptHeader.Validate(Status, ReceiptHeader.Status::Open);
                    ReceiptHeader.Modify(true);
                end;
            DATABASE::"Petty Cash Header":
                begin
                    PettyCash.Get(DocNo);
                    PettyCash.Validate(Status, PettyCash.Status::Open);
                    PettyCash.Modify(true);
                end;
            DATABASE::"Request Header":
                begin
                    RequestHeader.Get(DocNo);
                    RequestHeader.Validate(Status, RequestHeader.Status::Open);
                    RequestHeader.Modify(true);
                end;
            DATABASE::"Virement Budget Request":
                begin
                    VirementBudget.Get(DocNo);
                    VirementBudget.Validate(Status, VirementBudget.Status::Open);
                    VirementBudget.Modify(true);
                end;
            DATABASE::"Budget Plan":
                begin
                    BudgetPlan.Get(DocNo);
                    BudgetPlan.Validate(Status, BudgetPlan.Status::Open);
                    BudgetPlan.Modify(true);
                end;
            DATABASE::"Fixed Deposit Header":
                begin
                    FixedDeposit.Get(DocNo);
                    FixedDeposit.Validate(Status, FixedDeposit.Status::Open);
                    FixedDeposit.Modify(true);
                end;
            DATABASE::"Bank Acc. Reconciliation":
                begin
                    BankAccReconciliation.Get(DocNo);
                    BankAccReconciliation.Validate(Status, BankAccReconciliation.Status::Open);
                    BankAccReconciliation.Modify(true);
                end;
            DATABASE::"Requisition Header":
                begin
                    Requisition.Get(DocNo);
                    Requisition.Validate(Status, Requisition.Status::Open);
                    Requisition.Modify(true);
                end;
            DATABASE::"Procurement Inspection":
                begin
                    ProcurementInspection.Get(DocNo);
                    ProcurementInspection.Validate(Status, ProcurementInspection.Status::Open);
                    ProcurementInspection.Modify(true);
                end;
            DATABASE::"Procurement Plans":
                begin
                    ProcurePlan.Get(DocNo);
                    ProcurePlan.Validate(Status, ProcurePlan.Status::Open);
                    ProcurePlan.Modify(true);
                end;
            DATABASE::"RFQ Header":
                begin
                    RFQ.Get(DocNo);
                    RFQ.Validate(Status, RFQ.Status::Open);
                    RFQ.Modify(true);
                end;
            DATABASE::"Supplier Application":
                begin
                    SupplierApplication.Get(DocNo);
                    SupplierApplication.Validate(Status, SupplierApplication.Status::Open);
                    SupplierApplication.Modify(true);
                end;
            DATABASE::"Procurement Request":
                begin
                    ProcurementRequest.Get(DocNo);
                    ProcurementRequest.Validate(Status, ProcurementRequest.Status::Open);
                    ProcurementRequest.Modify(true);
                end;
            DATABASE::"Contract Header":
                begin
                    Contract.Get(DocNo);
                    Contract.Validate(Status, Contract.Status::Open);
                    Contract.Modify(true);
                end;
            DATABASE::"Contract Extension":
                begin
                    ContractExtension.Get(DocNo);
                    ContractExtension.Validate(Status, ContractExtension.Status::Open);
                    ContractExtension.Modify(true);
                end;
            DATABASE::"Company Jobs":
                begin
                    HRJobs.Get(DocNo);
                    HRJobs.Validate(Status, HRJobs.Status::Open);
                    HRJobs.Modify(true);
                end;
            DATABASE::"Job Requisition":
                begin
                    JobRequisition.Get(DocNo);
                    JobRequisition.Validate(Status, JobRequisition.Status::Open);
                    JobRequisition.Modify(true);
                end;
            DATABASE::Employee:
                begin
                    Employee.Get(DocNo);
                    Employee.Validate("Employee Status", Employee."Employee Status"::Active);
                    Employee.Modify(true);
                end;
            DATABASE::"Employee Change Request":
                begin
                    EmployeeChange.Get(DocNo);
                    EmployeeChange.Validate(Status, EmployeeChange.Status::Open);
                    EmployeeChange.Modify(true);
                end;
            DATABASE::"Leave Plan":
                begin
                    LeavePlan.Get(DocNo);
                    LeavePlan.Validate(Status, LeavePlan.Status::Open);
                    LeavePlan.Modify(true);
                end;
            DATABASE::"Leave Applications":
                begin
                    Leave.Get(DocNo);
                    Leave.Validate(Status, Leave.Status::Open);
                    Leave.Modify(true);
                end;
            DATABASE::"Leave Recall":
                begin
                    LeaveRecall.Get(DocNo);
                    LeaveRecall.Validate(Status, LeaveRecall.Status::Open);
                    LeaveRecall.Modify(true);
                end;
            DATABASE::"Training Needs":
                begin
                    TrainingNeeds.Get(DocNo);
                    TrainingNeeds.Validate(Status, TrainingNeeds.Status::Open);
                    TrainingNeeds.Modify(true);
                end;
            DATABASE::"Employee Exit":
                begin
                    EmployeeExit.Get(DocNo);
                    EmployeeExit.Validate(Status, EmployeeExit.Status::Open);
                    EmployeeExit.Modify(true);
                end;
            DATABASE::"Payroll Periods":
                begin
                    Evaluate(StartDate, DocNo);
                    PayrollPeriod.Get(StartDate);
                    PayrollPeriod.Validate(Status, PayrollPeriod.Status::Open);
                    PayrollPeriod.Modify(true);
                end;
        end;
    end;
}
