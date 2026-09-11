codeunit 52203425 "Workflow Event Handling Ext"
{
    var WorkflowEventHandling: Codeunit "Workflow Event Handling";
    WorkflowManagement: Codeunit "Workflow Management";
    SendForApprovalEventDescTxt: Label 'Approval for %1 Requested.';
    CancelApprovalRequestEventDescTxt: Label 'Approval request for %1 Cancelled.';
    ReleasedEventDescTxt: Label '%1 record has been released.';
    //"**************************SOFT - ADVANCED FINANCE MODULE CUSTOMIZATIONS******************"
    // "******************** Payment Voucher Approval**************************"
    procedure RunWorkflowOnSendPVForApprovalCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnSendPVForApproval'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnSendPVForApproval', '', false, false)]
    procedure RunWorkflowOnSendPVForApproval(var PV: Record "Payment Voucher")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendPVForApprovalCode, PV);
    end;
    procedure RunWorkflowOnCancelPVApprovalRequestCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnCancelPVApprovalRequest'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnCancelPVApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelPVApprovalRequest(PV: Record "Payment Voucher")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelPVApprovalRequestCode, PV);
    end;
    // "******************** Receipt Header Approval**************************"
    procedure RunWorkflowOnSendReceiptHeaderForApprovalCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnSendReceiptHeaderForApproval'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnSendReceiptHeaderForApproval', '', false, false)]
    procedure RunWorkflowOnSendReceiptHeaderForApproval(var ReceiptHeader: Record "Receipt Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendReceiptHeaderForApprovalCode, ReceiptHeader);
    end;
    procedure RunWorkflowOnCancelReceiptHeaderApprovalRequestCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnCancelReceiptHeaderApprovalRequest'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnCancelReceiptHeaderApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelReceiptHeaderApprovalRequest(ReceiptHeader: Record "Receipt Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelReceiptHeaderApprovalRequestCode, ReceiptHeader);
    end;
    // 
    // "******************** Petty Cash Approval**************************"
    procedure RunWorkflowOnSendPettyCashForApprovalCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnSendPettyCashForApproval'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnSendPettyCashForApproval', '', false, false)]
    procedure RunWorkflowOnSendPettyCashForApproval(var PettyCash: Record "Petty Cash Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendPettyCashForApprovalCode, PettyCash);
    end;
    procedure RunWorkflowOnCancelPettyCashApprovalRequestCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnCancelPettyCashApprovalRequest'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnCancelPettyCashApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelPettyCashApprovalRequest(PettyCash: Record "Petty Cash Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelPettyCashApprovalRequestCode, PettyCash);
    end;
    //
    //"******************** Request Header Approval**************************"
    procedure RunWorkflowOnSendRequestHeaderForApprovalCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnSendRequestHeaderForApproval'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnSendRequestHeaderForApproval', '', false, false)]
    procedure RunWorkflowOnSendRequestHeaderForApproval(var RequestHeader: Record "Request Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendRequestHeaderForApprovalCode, RequestHeader);
    end;
    procedure RunWorkflowOnCancelRequestHeaderApprovalRequestCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnCancelRequestHeaderApprovalRequest'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnCancelRequestHeaderApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelRequestHeaderApprovalRequest(var RequestHeader: Record "Request Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelRequestHeaderApprovalRequestCode, RequestHeader);
    end;
    // 
    // "********************Request For Payment Approval**************************"
    procedure RunWorkflowOnSendRequestForPaymentForApprovalCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnSendRequestForPaymentForApproval'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnSendRequestForPaymentForApproval', '', false, false)]
    procedure RunWorkflowOnSendRequestForPaymentForApproval(var RequestForPayment: Record "Request for Payment")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendRequestForPaymentForApprovalCode, RequestForPayment);
    end;
    procedure RunWorkflowOnCancelRequestForPaymentApprovalRequestCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnCancelRequestForPaymentApprovalRequest'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnCancelRequestForPaymentApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelRequestForPaymentApprovalRequest(var RequestForPayment: Record "Request for Payment")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelRequestForPaymentApprovalRequestCode, RequestForPayment);
    end;
    //
    // "********************Virement Budget Request Approval**************************"
    procedure RunWorkflowOnSendVirementBudgetForApprovalCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnSendVirementBudgetForApproval'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnSendVirementBudgetForApproval', '', false, false)]
    procedure RunWorkflowOnSendVirementBudgetForApproval(var VirementBudget: Record "Virement Budget Request")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendVirementBudgetForApprovalCode, VirementBudget);
    end;
    procedure RunWorkflowOnCancelVirementBudgetApprovalRequestCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnCancelVirementBudgetApprovalRequest'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnCancelVirementBudgetApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelVirementBudgetApprovalRequest(var VirementBudget: Record "Virement Budget Request")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelVirementBudgetApprovalRequestCode, VirementBudget);
    end;
    //
    // "********************Budget Plan Request Approval**************************"
    procedure RunWorkflowOnSendBudgetPlanForApprovalCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnSendBudgetPlanForApproval'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnSendBudgetPlanForApproval', '', false, false)]
    procedure RunWorkflowOnSendBudgetPlanForApproval(var BudgetPlan: Record "Budget Plan")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendBudgetPlanForApprovalCode, BudgetPlan);
    end;
    procedure RunWorkflowOnCancelBudgetPlanApprovalRequestCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnCancelBudgetPlanApprovalRequest'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnCancelBudgetPlanApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelBudgetPlanApprovalRequest(var BudgetPlan: Record "Budget Plan")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelBudgetPlanApprovalRequestCode, BudgetPlan);
    end;
    // 
    // "********************Fixed Deposit Request Approval**************************"
    procedure RunWorkflowOnSendFixedDepositForApprovalCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnSendFixedDepositForApproval'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnSendFixedDepositForApproval', '', false, false)]
    procedure RunWorkflowOnSendFixedDepositForApproval(var FixedDeposit: Record "Fixed Deposit Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendFixedDepositForApprovalCode, FixedDeposit);
    end;
    procedure RunWorkflowOnCancelFixedDepositApprovalRequestCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnCancelFixedDepositApprovalRequest'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnCancelFixedDepositApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelFixedDepositApprovalRequest(var FixedDeposit: Record "Fixed Deposit Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelFixedDepositApprovalRequestCode, FixedDeposit);
    end;
    //
    // "********************Bank Account Reconciliation Request Approval**************************"
    procedure RunWorkflowOnSendBankAccReconciliationForApprovalCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnSendBankAccReconciliationForApproval'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnSendBankAccReconciliationForApproval', '', false, false)]
    procedure RunWorkflowOnSendBankAccReconciliationForApproval(var BankAccReconciliation: Record "Bank Acc. Reconciliation")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendBankAccReconciliationForApprovalCode, BankAccReconciliation);
    end;
    procedure RunWorkflowOnCancelBankAccReconciliationApprovalRequestCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnCancelBankAccReconciliationApprovalRequest'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnCancelBankAccReconciliationApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelBankAccReconciliationApprovalRequest(var BankAccReconciliation: Record "Bank Acc. Reconciliation")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelBankAccReconciliationApprovalRequestCode, BankAccReconciliation);
    end;
    //
    // "**************************SOFT - PROCUREMENT MODULE CUSTOMIZATIONS******************"
    //"******************** Requisition Approval**************************"
    procedure RunWorkflowOnSendRequisitionForApprovalCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnSendRequisitionForApproval'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnSendRequisitionForApproval', '', false, false)]
    procedure RunWorkflowOnSendRequisitionForApproval(var Requisition: Record "Requisition Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendRequisitionForApprovalCode, Requisition);
    end;
    procedure RunWorkflowOnCancelRequisitionApprovalRequestCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnCancelRequisitionApprovalRequest'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnCancelRequisitionApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelRequisitionApprovalRequest(var Requisition: Record "Requisition Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelRequisitionApprovalRequestCode, Requisition);
    end;
    //"********************Procurement Inspection Approval**************************"
    procedure RunWorkflowOnSendProcurementInspectionForApprovalCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnSendProcurementInspectionForApproval'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnSendProcurementInspectionForApproval', '', false, false)]
    procedure RunWorkflowOnSendProcurementInspectionForApproval(var ProcurementInspection: Record "Procurement Inspection")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendProcurementInspectionForApprovalCode, ProcurementInspection);
    end;
    procedure RunWorkflowOnCancelProcurementInspectionApprovalRequestCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnCancelProcurementInspectionApprovalRequest'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnCancelProcurementInspectionApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelProcurementInspectionApprovalRequest(var ProcurementInspection: Record "Procurement Inspection")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelProcurementInspectionApprovalRequestCode, ProcurementInspection);
    end;
    //"******************** Procurement Plan Approval**************************"
    procedure RunWorkflowOnSendProcurePlanForApprovalCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnSendProcurePlanForApproval'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnSendProcurePlanForApproval', '', false, false)]
    procedure RunWorkflowOnSendProcurePlanForApproval(var ProcurePlan: Record "Procurement Plans")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendProcurePlanForApprovalCode, ProcurePlan);
    end;
    procedure RunWorkflowOnCancelProcurePlanApprovalRequestCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnCancelProcurePlanApprovalRequest'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnCancelProcurePlanApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelProcurePlanApprovalRequest(var ProcurePlan: Record "Procurement Plans")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelProcurePlanApprovalRequestCode, ProcurePlan);
    end;
    //
    //"******************RFQ Approval*************************************"
    procedure RunWorkflowOnSendRFQForApprovalCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnSendRFQForApproval'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnSendRFQForApproval', '', false, false)]
    procedure RunWorkflowOnSendRFQForApproval(var RFQ: Record "RFQ Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendRFQForApprovalCode, RFQ);
    end;
    procedure RunWorkflowOnCancelRFQApprovalRequestCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnCancelRFQApprovalRequest'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnCancelRFQApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelRFQApprovalRequest(var RFQ: Record "RFQ Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelRFQApprovalRequestCode, RFQ);
    end;
    //
    //"******************Supplier Application Approval*************************************"
    procedure RunWorkflowOnSendSupplierApplicationForApprovalCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnSupplierApplicationForApproval'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnSendSupplierApplicationForApproval', '', false, false)]
    procedure RunWorkflowOnSendSupplierApplicationForApproval(var SupplierApplication: Record "Supplier Application")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendSupplierApplicationForApprovalCode, SupplierApplication);
    end;
    procedure RunWorkflowOnCancelSupplierApplicationApprovalRequestCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnCancelSupplierApplicationApprovalRequest'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnCancelSupplierApplicationApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelSupplierApplicationApprovalRequest(var SupplierApplication: Record "Supplier Application")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelSupplierApplicationApprovalRequestCode, SupplierApplication);
    end;
    // 
    //"******************Procurement Request Approval*************************************"
    procedure RunWorkflowOnSendProcurementRequestForApprovalCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnSendProcurementRequestForApproval'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnSendProcurementRequestForApproval', '', false, false)]
    procedure RunWorkflowOnSendProcurementRequestForApproval(var ProcurementRequest: Record "Procurement Request")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendProcurementRequestForApprovalCode, ProcurementRequest);
    end;
    procedure RunWorkflowOnCancelProcurementRequestApprovalRequestCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnCancelProcurementRequestApprovalRequest'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnCancelProcurementRequestApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelProcurementRequestApprovalRequest(var ProcurementRequest: Record "Procurement Request")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelProcurementRequestApprovalRequestCode, ProcurementRequest);
    end;
    // 
    //"******************Contract Approval*************************************"
    procedure RunWorkflowOnSendContractForApprovalCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnSendContractForApproval'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnSendContractForApproval', '', false, false)]
    procedure RunWorkflowOnSendContractForApproval(var Contract: Record "Contract Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendContractForApprovalCode, Contract);
    end;
    procedure RunWorkflowOnCancelContractApprovalRequestCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnCancelContractApprovalRequest'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnCancelContractApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelContractApprovalRequest(var Contract: Record "Contract Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelContractApprovalRequestCode, Contract);
    end;
    // 
    //"******************Contract Extension Approval*************************************"
    procedure RunWorkflowOnSendContractExtensionForApprovalCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnSendContractExtensionForApproval'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnSendContractExtensionForApproval', '', false, false)]
    procedure RunWorkflowOnSendContractExtensionForApproval(var ContractExtension: Record "Contract Extension")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendContractExtensionForApprovalCode, ContractExtension);
    end;
    procedure RunWorkflowOnCancelContractExtensionApprovalRequestCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnCancelContractExtensionApprovalRequest'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnCancelContractExtensionApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelContractExtensionApprovalRequest(var ContractExtension: Record "Contract Extension")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelContractExtensionApprovalRequestCode, ContractExtension);
    end;
    //"**************************SOFT - HR MODULE CUSTOMIZATIONS******************"
    //"********************HR Jobs Approval**************************"
    procedure RunWorkflowOnSendHRJobsForApprovalCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnSendHRJobsForApproval'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnSendHRJobsForApproval', '', false, false)]
    procedure RunWorkflowOnSendHRJobForApproval(var HRJobs: Record "Company Jobs")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendHRJobsForApprovalCode, HRJobs);
    end;
    procedure RunWorkflowOnCancelHRJobsApprovalRequestCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnCancelHRJobsApprovalRequest'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnCancelHRJobsApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelHRJobsApprovalRequest(var HRJobs: Record "Company Jobs")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelHRJobsApprovalRequestCode, HRJobs);
    end;
    // 
    //"******************** Job Requisition Approval**************************"
    procedure RunWorkflowOnSendJobRequisitionForApprovalCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnSendJobRequisitionForApproval'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnSendJobRequisitionForApproval', '', false, false)]
    procedure RunWorkflowOnSendJobRequisitionForApproval(var JobRequisition: Record "Job Requisition")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendJobRequisitionForApprovalCode, JobRequisition);
    end;
    procedure RunWorkflowOnCancelJobRequisitionApprovalRequestCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnCancelJobRequisitionApprovalRequest'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnCancelJobRequisitionApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelJobRequisitionApprovalRequest(var JobRequisition: Record "Job Requisition")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelJobRequisitionApprovalRequestCode, JobRequisition);
    end;
    //
    //"******************** Employee Approval**************************"
    procedure RunWorkflowOnSendEmployeeForApprovalCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnSendEmployeeForApproval'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnSendEmployeeForApproval', '', false, false)]
    procedure RunWorkflowOnSendEmployeeForApproval(var Employee: Record Employee)
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendEmployeeForApprovalCode, Employee);
    end;
    procedure RunWorkflowOnCancelEmployeeApprovalRequestCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnCancelEmployeeApprovalRequest'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnCancelEmployeeApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelEmployeeApprovalRequest(var Employee: Record Employee)
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelEmployeeApprovalRequestCode, Employee);
    end;
    //
    //"******************** Employee Change Approval**************************"
    procedure RunWorkflowOnSendEmployeeChangeForApprovalCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnSendEmployeeChangeForApproval'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnSendEmployeeChangeForApproval', '', false, false)]
    procedure RunWorkflowOnSendEmployeeChangeForApproval(var EmployeeChange: Record "Employee Change Request")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendEmployeeChangeForApprovalCode, EmployeeChange);
    end;
    procedure RunWorkflowOnCancelEmployeeChangeApprovalRequestCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnCancelEmployeeChangeApprovalRequest'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnCancelEmployeeChangeApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelEmployeeChangeApprovalRequest(var EmployeeChange: Record "Employee Change Request")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelEmployeeChangeApprovalRequestCode, EmployeeChange);
    end;
    //
    // "********************Leave Plan Approval**************************"
    procedure RunWorkflowOnSendLeavePlanForApprovalCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnSendLeavePlanForApproval'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnSendLeavePlanForApproval', '', false, false)]
    procedure RunWorkflowOnSendLeavePlanForApproval(var LeavePlan: Record "Leave Plan")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendLeavePlanForApprovalCode, LeavePlan);
    end;
    procedure RunWorkflowOnCancelLeavePlanApprovalRequestCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnCancelLeavePlanApprovalRequest'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnCancelLeavePlanApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelLeavePlanApprovalRequest(var LeavePlan: Record "Leave Plan")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelLeavePlanApprovalRequestCode, LeavePlan);
    end;
    //
    //"******************** Leave Application Approval**************************"
    procedure RunWorkflowOnSendLeaveForApprovalCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnSendLeaveForApproval'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnSendLeaveForApproval', '', false, false)]
    procedure RunWorkflowOnSendLeaveForApproval(var Leave: Record "Leave Applications")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendLeaveForApprovalCode, Leave);
    end;
    procedure RunWorkflowOnCancelLeaveApprovalRequestCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnCancelLeaveApprovalRequest'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnCancelLeaveApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelLeaveApprovalRequest(var Leave: Record "Leave Applications")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelLeaveApprovalRequestCode, Leave);
    end;
    //
    //"******************** Leave Recall Approval**************************"
    procedure RunWorkflowOnSendLeaveRecallForApprovalCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnSendLeaveRecallForApproval'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnSendLeaveRecallForApproval', '', false, false)]
    procedure RunWorkflowOnSendLeaveRecallForApproval(var LeaveRecall: Record "Leave Recall")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendLeaveRecallForApprovalCode, LeaveRecall);
    end;
    procedure RunWorkflowOnCancelLeaveRecallApprovalRequestCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnCancelLeaveRecallApprovalRequest'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnCancelLeaveRecallApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelLeaveRecallApprovalRequest(var LeaveRecall: Record "Leave Recall")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelLeaveRecallApprovalRequestCode, LeaveRecall);
    end;
    //
    //"********************Training Needs Approval**************************"
    procedure RunWorkflowOnSendTrainingNeedsForApprovalCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnSendTrainingNeedsForApproval'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnSendTrainingNeedsForApproval', '', false, false)]
    procedure RunWorkflowOnSendTrainingNeedsForApproval(var TrainingNeeds: Record "Training Needs")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendTrainingNeedsForApprovalCode, TrainingNeeds);
    end;
    procedure RunWorkflowOnCancelTrainingNeedsApprovalRequestCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnCancelTrainingNeedsApprovalRequest'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnCancelTraininigNeedsApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelTrainingNeedsApprovalRequest(var TrainingNeeds: Record "Training Needs")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelTrainingNeedsApprovalRequestCode, TrainingNeeds);
    end;
    //
    //"********************Employee Exit Approval**************************"
    procedure RunWorkflowOnSendEmployeeExitForApprovalCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnSendEmployeeExitForApproval'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnSendEmployeeExitForApproval', '', false, false)]
    procedure RunWorkflowOnSendEmployeeExitForApproval(var EmployeeExit: Record "Employee Exit")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendEmployeeExitForApprovalCode, EmployeeExit);
    end;
    procedure RunWorkflowOnCancelEmployeeExitApprovalRequestCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnCancelEmployeeExitApprovalRequest'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnCancelEmployeeExitApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelEmployeeExitApprovalRequest(var EmployeeExit: Record "Employee Exit")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelEmployeeExitApprovalRequestCode, EmployeeExit);
    end;
    // 
    //"********************Payroll Periods Approval**************************"
    procedure RunWorkflowOnSendPayrollPeriodForApprovalCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnSendPayrollPeriodForApproval'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnSendPayrollPeriodsForApproval', '', false, false)]
    procedure RunWorkflowOnSendPayrollPeriodForApproval(var PayrollPeriods: Record "Payroll Periods")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendPayrollPeriodForApprovalCode, PayrollPeriods);
    end;
    procedure RunWorkflowOnCancelPayrollPeriodApprovalRequestCode(): Code[128]begin
        exit(UpperCase('RunWorkflowOnCancelPayrollPeriodApprovalRequest'));
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. Ext", 'OnCancelPayrollPeriodsApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelPayrollPeriodApprovalRequest(var PayrollPeriods: Record "Payroll Periods")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelPayrollPeriodApprovalRequestCode, PayrollPeriods);
    end;
    //
    //#endregion 
    //#region AddEventToLibrary
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', false, false)]
    procedure CreateEventsLibrary()
    begin
        //************************SOFT - ADVANCED FINANCE MODULE CUSTOMIZATIONS***************************
        //1. Payment Voucher:
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendPVForApprovalCode, DATABASE::"Payment Voucher", StrSubstNo(SendForApprovalEventDescTxt, 'Payment Voucher'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelPVApprovalRequestCode, DATABASE::"Payment Voucher", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Payment Voucher'), 0, false);
        //
        //2. Petty Cash:
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendPettyCashForApprovalCode, DATABASE::"Petty Cash Header", StrSubstNo(SendForApprovalEventDescTxt, 'Petty Cash'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelPettyCashApprovalRequestCode, DATABASE::"Petty Cash Header", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Petty Cash'), 0, false);
        // 
        //2. Petty Cash:
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendReceiptHeaderForApprovalCode, DATABASE::"Receipt Header", StrSubstNo(SendForApprovalEventDescTxt, 'Receipt Header'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelReceiptHeaderApprovalRequestCode, DATABASE::"Receipt Header", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Receipt Header'), 0, false);
        //
        //3. Request Header:
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendRequestHeaderForApprovalCode, DATABASE::"Request Header", StrSubstNo(SendForApprovalEventDescTxt, 'Request Header'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelRequestHeaderApprovalRequestCode, DATABASE::"Request Header", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Request Header'), 0, false);
        //
        //5. Virement Budget Request:
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendVirementBudgetForApprovalCode, DATABASE::"Virement Budget Request", StrSubstNo(SendForApprovalEventDescTxt, 'Virement Budget Request'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelVirementBudgetApprovalRequestCode, DATABASE::"Virement Budget Request", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Virement Budget Request'), 0, false);
        //
        //6. Budget Plan:
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendBudgetPlanForApprovalCode, DATABASE::"Budget Plan", StrSubstNo(SendForApprovalEventDescTxt, 'Budget Plan'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelBudgetPlanApprovalRequestCode, DATABASE::"Budget Plan", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Budget Plan'), 0, false);
        //
        //7. Fixed Deposit:
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendFixedDepositForApprovalCode, DATABASE::"Fixed Deposit Header", StrSubstNo(SendForApprovalEventDescTxt, 'Fixed Deposit Header'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelFixedDepositApprovalRequestCode, DATABASE::"Fixed Deposit Header", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Fixed Deposit Header'), 0, false);
        // 
        //8. Bank Acc Reconciliation:
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendBankAccReconciliationForApprovalCode, DATABASE::"Bank Acc. Reconciliation", StrSubstNo(SendForApprovalEventDescTxt, 'Bank Acc. Reconciliation'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelBankAccReconciliationApprovalRequestCode, DATABASE::"Bank Acc. Reconciliation", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Bank Acc. Reconciliation'), 0, false);
        //
        //************************SOFT - PROCUREMENT MODULE CUSTOMIZATIONS***************************
        //1. Requisition:
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendRequisitionForApprovalCode, DATABASE::"Requisition Header", StrSubstNo(SendForApprovalEventDescTxt, 'Requisition Header'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelRequisitionApprovalRequestCode, DATABASE::"Requisition Header", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Requisition Header'), 0, false);
        // 
        //1. Procurement Inspection:
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendProcurementInspectionForApprovalCode, DATABASE::"Procurement Inspection", StrSubstNo(SendForApprovalEventDescTxt, 'Procurement Inspection'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelProcurementInspectionApprovalRequestCode, DATABASE::"Procurement Inspection", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Procurement Inspection'), 0, false);
        //
        //2. Procurement Plan
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendProcurePlanForApprovalCode, Database::"Procurement Plans", StrSubstNo(SendForApprovalEventDescTxt, 'Procurement Plan'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelProcurePlanApprovalRequestCode, Database::"Procurement Plans", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Procurement Plan'), 0, false);
        //
        //3. RFQ
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendRFQForApprovalCode, Database::"RFQ Header", StrSubstNo(SendForApprovalEventDescTxt, 'Request For Quatation'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelRFQApprovalRequestCode, Database::"RFQ Header", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Request For Quatation'), 0, false);
        //
        //5. Supplier Application
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendSupplierApplicationForApprovalCode, Database::"Supplier Application", StrSubstNo(SendForApprovalEventDescTxt, 'Supplier Application'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelSupplierApplicationApprovalRequestCode, Database::"Supplier Application", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Supplier Application'), 0, false);
        //
        //6. Procurement Request
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendProcurementRequestForApprovalCode, Database::"Procurement Request", StrSubstNo(SendForApprovalEventDescTxt, 'Procurement Request'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelProcurementRequestApprovalRequestCode, Database::"Procurement Request", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Procurement Request'), 0, false);
        //  
        //7. Contract
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendContractForApprovalCode, Database::"Contract Header", StrSubstNo(SendForApprovalEventDescTxt, 'Contract'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelContractApprovalRequestCode, Database::"Contract Header", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Contract'), 0, false);
        //  
        //8. Contract Extension
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendContractExtensionForApprovalCode, Database::"Contract Extension", StrSubstNo(SendForApprovalEventDescTxt, 'Contract Extension'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelContractExtensionApprovalRequestCode, Database::"Contract Extension", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Contract Extension'), 0, false);
        //
        //************************SOFT - HR MODULE CUSTOMIZATIONS***************************
        //1. HR Jobs:
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendHRJobsForApprovalCode, DATABASE::"Company Jobs", StrSubstNo(SendForApprovalEventDescTxt, 'HR Job'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelHRJobsApprovalRequestCode, DATABASE::"Company Jobs", StrSubstNo(CancelApprovalRequestEventDescTxt, 'HR Job'), 0, false);
        //
        //2. Job Requisition:
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendJobRequisitionForApprovalCode, DATABASE::"Job Requisition", StrSubstNo(SendForApprovalEventDescTxt, 'Job Requisition'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelJobRequisitionApprovalRequestCode, DATABASE::"Job Requisition", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Job Requisition'), 0, false);
        // 
        //3. Employee:
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendEmployeeForApprovalCode, DATABASE::Employee, StrSubstNo(SendForApprovalEventDescTxt, 'Employee'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelEmployeeApprovalRequestCode, DATABASE::Employee, StrSubstNo(CancelApprovalRequestEventDescTxt, 'Employee'), 0, false);
        // 
        //4. Employee Change:
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendEmployeeChangeForApprovalCode, DATABASE::"Employee Change Request", StrSubstNo(SendForApprovalEventDescTxt, 'Employee Change Request'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelEmployeeChangeApprovalRequestCode, DATABASE::"Employee Change Request", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Employee Change Request'), 0, false);
        // 
        //5. Leave Plan:
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendLeavePlanForApprovalCode, DATABASE::"Leave Plan", StrSubstNo(SendForApprovalEventDescTxt, 'Leave Plan'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelLeavePlanApprovalRequestCode, DATABASE::"Leave Plan", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Leave Plan'), 0, false);
        //
        //6. Leave Application:
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendLeaveForApprovalCode, DATABASE::"Leave Applications", StrSubstNo(SendForApprovalEventDescTxt, 'Leave Application'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelLeaveApprovalRequestCode, DATABASE::"Leave Applications", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Leave Application'), 0, false);
        // 
        //7. Leave Recall:
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendLeaveRecallForApprovalCode, DATABASE::"Leave Recall", StrSubstNo(SendForApprovalEventDescTxt, 'Leave Recall'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelLeaveRecallApprovalRequestCode, DATABASE::"Leave Recall", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Leave Recall'), 0, false);
        // 
        //9. Training Needs:
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendTrainingNeedsForApprovalCode, DATABASE::"Training Needs", StrSubstNo(SendForApprovalEventDescTxt, 'Training Need'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelTrainingNeedsApprovalRequestCode, DATABASE::"Training Needs", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Training Need'), 0, false);
        // 
        //10. Employee Exit:
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendEmployeeExitForApprovalCode, DATABASE::"Employee Exit", StrSubstNo(SendForApprovalEventDescTxt, 'Employee Exit'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelEmployeeExitApprovalRequestCode, DATABASE::"Employee Exit", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Employee Exit'), 0, false);
        // 
        //11. Payroll Periods:
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendPayrollPeriodForApprovalCode, DATABASE::"Payroll Periods", StrSubstNo(SendForApprovalEventDescTxt, 'Payroll Period'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelPayrollPeriodApprovalRequestCode, DATABASE::"Payroll Periods", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Payroll Period'), 0, false);
    //
    end;
    //#endregion
    //#regions AddEventPredecessor
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventPredecessorsToLibrary', '', false, false)]
    local procedure AddEventPredecessors(EventFunctionName: Code[128])
    begin
        case EventFunctionName of //****************SOFT - ADVANCED FINANCE MODULE CUSTOMIZATIONS**************************        //1. Payment Voucher
 RunWorkflowOnCancelPVApprovalRequestCode: WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelPVApprovalRequestCode, RunWorkflowOnSendPVForApprovalCode);
        //
        //2. Petty Cash
        RunWorkflowOnCancelPettyCashApprovalRequestCode: WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelPettyCashApprovalRequestCode, RunWorkflowOnSendPettyCashForApprovalCode);
        //2. Petty Cash
        RunWorkflowOnCancelReceiptHeaderApprovalRequestCode: WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelReceiptHeaderApprovalRequestCode, RunWorkflowOnSendReceiptHeaderForApprovalCode);
        //
        //3. Request Header
        RunWorkflowOnCancelRequestHeaderApprovalRequestCode: WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelRequestHeaderApprovalRequestCode, RunWorkflowOnSendRequestHeaderForApprovalCode);
        //
        //5. Virement Budget Request
        RunWorkflowOnCancelVirementBudgetApprovalRequestCode: WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelVirementBudgetApprovalRequestCode, RunWorkflowOnSendVirementBudgetForApprovalCode);
        //
        //6. Budget Plan
        RunWorkflowOnCancelBudgetPlanApprovalRequestCode: WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelBudgetPlanApprovalRequestCode, RunWorkflowOnSendBudgetPlanForApprovalCode);
        // 
        //7. Fixed Deposit
        RunWorkflowOnCancelFixedDepositApprovalRequestCode: WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelFixedDepositApprovalRequestCode, RunWorkflowOnSendFixedDepositForApprovalCode);
        //
        //8. Bank Acc Reconciliation
        RunWorkflowOnCancelBankAccReconciliationApprovalRequestCode: WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelBankAccReconciliationApprovalRequestCode, RunWorkflowOnSendBankAccReconciliationForApprovalCode);
        //        //****************SOFT - PROCUREMENT MODULE CUSTOMIZATIONS**************************
        //1. Requisition
        RunWorkflowOnCancelRequisitionApprovalRequestCode: WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelRequisitionApprovalRequestCode, RunWorkflowOnSendRequisitionForApprovalCode);
        // 
        //1.Procurement Inspection
        RunWorkflowOnCancelProcurementInspectionApprovalRequestCode: WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelProcurementInspectionApprovalRequestCode, RunWorkflowOnSendProcurementInspectionForApprovalCode);
        //
        //2. Procurement Plan
        RunWorkflowOnCancelProcurePlanApprovalRequestCode: WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelProcurePlanApprovalRequestCode, RunWorkflowOnSendProcurePlanForApprovalCode);
        //
        //3. RFQ
        RunWorkflowOnCancelRFQApprovalRequestCode: WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelRFQApprovalRequestCode, RunWorkflowOnSendRFQForApprovalCode);
        //
        //5. Supplier Application
        RunWorkflowOnCancelSupplierApplicationApprovalRequestCode: WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelSupplierApplicationApprovalRequestCode, RunWorkflowOnSendSupplierApplicationForApprovalCode);
        //
        //6. Store Transaction
        RunWorkflowOnCancelProcurementRequestApprovalRequestCode: WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelProcurementRequestApprovalRequestCode, RunWorkflowOnSendProcurementRequestForApprovalCode);
        // 
        //7. Contract
        RunWorkflowOnCancelContractApprovalRequestCode: WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelContractApprovalRequestCode, RunWorkflowOnSendContractForApprovalCode);
        // 
        //8. Contract Extension
        RunWorkflowOnCancelContractExtensionApprovalRequestCode: WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelContractExtensionApprovalRequestCode, RunWorkflowOnSendContractExtensionForApprovalCode);
        //
        //****************SOFT - HR MODULE CUSTOMIZATIONS**************************
        //1. HR Jobs
        RunWorkflowOnCancelHRJobsApprovalRequestCode: WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelHRJobsApprovalRequestCode, RunWorkflowOnSendHRJobsForApprovalCode);
        // 
        //2. Job Requisition
        RunWorkflowOnCancelJobRequisitionApprovalRequestCode: WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelJobRequisitionApprovalRequestCode, RunWorkflowOnSendJobRequisitionForApprovalCode);
        // 
        //3. Employee
        RunWorkflowOnCancelEmployeeApprovalRequestCode: WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelEmployeeApprovalRequestCode, RunWorkflowOnSendEmployeeForApprovalCode);
        // 
        //4. Employee Change Request
        RunWorkflowOnCancelEmployeeChangeApprovalRequestCode: WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelEmployeeChangeApprovalRequestCode, RunWorkflowOnSendEmployeeChangeForApprovalCode);
        // 
        //5. Leave Plan
        RunWorkflowOnCancelLeavePlanApprovalRequestCode: WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelLeavePlanApprovalRequestCode, RunWorkflowOnSendLeavePlanForApprovalCode);
        //
        //6. Leave Application
        RunWorkflowOnCancelLeaveApprovalRequestCode: WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelLeaveApprovalRequestCode, RunWorkflowOnSendLeaveForApprovalCode);
        // 
        //7. Leave Recall
        RunWorkflowOnCancelLeaveRecallApprovalRequestCode: WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelLeaveRecallApprovalRequestCode, RunWorkflowOnSendLeaveRecallForApprovalCode);
        //
        //9. Training Needs
        RunWorkflowOnCancelTrainingNeedsApprovalRequestCode: WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelTrainingNeedsApprovalRequestCode, RunWorkflowOnSendTrainingNeedsForApprovalCode);
        //
        //10. Employee Exit
        RunWorkflowOnCancelEmployeeExitApprovalRequestCode: WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelEmployeeExitApprovalRequestCode, RunWorkflowOnSendEmployeeExitForApprovalCode);
        // 
        //11. Payroll Periods
        RunWorkflowOnCancelPayrollPeriodApprovalRequestCode: WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelPayrollPeriodApprovalRequestCode, RunWorkflowOnSendPayrollPeriodForApprovalCode);
        //
        WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode: begin
            //*****************SOFT - ADVANCED FINANCE MODULE CUSTOMIZATIONS********************
            //1. Payment Voucher
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendPVForApprovalCode);
            //
            //2. Petty Cash
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendPettyCashForApprovalCode);
            //  
            //2. Petty Cash
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendReceiptHeaderForApprovalCode);
            //
            //3. Request Header
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendRequestHeaderForApprovalCode);
            //
            //5. Virement Budget Request
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendVirementBudgetForApprovalCode);
            //
            //6. Budget Plan
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendBudgetPlanForApprovalCode);
            //
            //7. Fixed Deposit
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendFixedDepositForApprovalCode);
            //
            //8. Bank Acc Reconciliation
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendBankAccReconciliationForApprovalCode);
            //
            //*****************SOFT - PROCUREMENT MODULE CUSTOMIZATIONS********************
            //1. Requisition
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendRequisitionForApprovalCode);
            // 
            //1. Procurement Inspection
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendProcurementInspectionForApprovalCode);
            //
            //2. Procurement Plan
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendProcurePlanForApprovalCode);
            //
            //3. RFQ
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendRFQForApprovalCode);
            // 
            //5. Supplier Application
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendSupplierApplicationForApprovalCode);
            // 
            //6. Procument Request
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendProcurementRequestForApprovalCode);
            // 
            //7. Contract
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendContractForApprovalCode);
            // 
            //8. Contract Extension
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendContractExtensionForApprovalCode);
            //
            //*****************SOFT - HR MODULE CUSTOMIZATIONS********************
            //1. HR Jobs
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendHRJobsForApprovalCode);
            // 
            //2. Job Requisition
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendJobRequisitionForApprovalCode);
            //
            //3. Employee
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendEmployeeForApprovalCode);
            // 
            //4. Employee Change Request
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendEmployeeChangeForApprovalCode);
            // 
            //5. Leave Plan
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendLeavePlanForApprovalCode);
            //
            //6. Leave Application
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendLeaveForApprovalCode);
            //
            //7. Leave Recall
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendLeaveRecallForApprovalCode);
            //
            //9. Training Needs
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendTrainingNeedsForApprovalCode);
            //
            //10. Employee Exit
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendEmployeeExitForApprovalCode);
            //
            //11. Payroll Periods
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendPayrollPeriodForApprovalCode);
        // 
        end;
        WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode: begin
            //******************SOFT - ADVANCED FINANCE MODULE CUSTOMIZATIONS*********************
            //1. Payment Voucher
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendPVForApprovalCode);
            //
            //2. Petty Cash
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendPettyCashForApprovalCode);
            //
            //2. Petty Cash
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendReceiptHeaderForApprovalCode);
            //
            //3.Request Header
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendRequestHeaderForApprovalCode);
            // 
            //4. Virement Budget Request
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendVirementBudgetForApprovalCode);
            // 
            //5. Budget Plan
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendBudgetPlanForApprovalCode);
            // 
            //6. Fixed Deposit
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendFixedDepositForApprovalCode);
            //
            //7. Bank Acc Reconciliation
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendBankAccReconciliationForApprovalCode);
            //
            //******************SOFT - PROCUREMENT MODULE CUSTOMIZATIONS*********************
            //1. Requisition
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendRequisitionForApprovalCode);
            //  
            //1. Procurement Inspection
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendProcurementInspectionForApprovalCode);
            //
            //2. Procurement Plan
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendProcurePlanForApprovalCode);
            //
            //3. RFQ-RFP
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendRFQForApprovalCode);
            //
            //5. Supplier Application
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendSupplierApplicationForApprovalCode);
            // 
            //6. Procurement Request
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendProcurementRequestForApprovalCode);
            //
            //7. Contract
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendContractForApprovalCode);
            // 
            //8. Contract Extension
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendContractExtensionForApprovalCode);
            //
            //******************SOFT - HR MODULE CUSTOMIZATIONS*********************
            //1. HR Jobs
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendHRJobsForApprovalCode);
            //
            //2. Job Requisition
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendJobRequisitionForApprovalCode);
            //
            //3. Employee
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendEmployeeForApprovalCode);
            //
            //4. Employee Change Request
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendEmployeeChangeForApprovalCode);
            //
            //5. Leave Plan
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendLeavePlanForApprovalCode);
            //
            //6. Leave Application
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendLeaveForApprovalCode);
            //
            //7. Leave Recall
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendLeaveRecallForApprovalCode);
            //
            //9. Training Needs
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendTrainingNeedsForApprovalCode);
            //
            //10. Employee Exit
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendEmployeeExitForApprovalCode);
            //
            //11. Payroll Payroll
            WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendPayrollPeriodForApprovalCode);
        //
        end;
        end;
    end; //#endregion
}
