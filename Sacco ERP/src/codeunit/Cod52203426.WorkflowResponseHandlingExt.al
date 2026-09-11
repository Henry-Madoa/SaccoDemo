codeunit 52203426 "Workflow Response Handling Ext"
{
    //#region AddResponsePredecessor
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsePredecessorsToLibrary', '', true, true)]
    local procedure AddResponsePredecessors(ResponseFunctionName: Code[128])
    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling Ext";
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
    begin
        case ResponseFunctionName of
            WorkflowResponseHandling.SetStatusToPendingApprovalCode:
                begin
                    //**********************SOFT - ADVANCED FINANCE MODULE CUSTOMIZATIONS****************************
                    //1. Payment Voucher
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendPVForApprovalCode);
                    //
                    //2. Petty Cash
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendReceiptHeaderForApprovalCode);
                    // 
                    //2. Petty Cash
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendPettyCashForApprovalCode);
                    //3. Request Header
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendRequestHeaderForApprovalCode);
                    // 
                    //4. Virement Budget Request
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendVirementBudgetForApprovalCode);
                    //
                    //5. Budget Plan
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendBudgetPlanForApprovalCode);
                    // 
                    //6. Fixed Deposit
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendFixedDepositForApprovalCode);
                    //
                    //7. Bank Acc Reconciliation
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendBankAccReconciliationForApprovalCode);
                    //
                    //**********************SOFT - PROCUREMENT MODULE CUSTOMIZATIONS****************************
                    //1. Requisition
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendRequisitionForApprovalCode);
                    //
                    //1. Procurement Inspection
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendProcurementInspectionForApprovalCode);
                    //
                    //2. Procurement Plan
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendProcurePlanForApprovalCode);
                    //
                    //3. RFQ
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendRFQForApprovalCode);
                    //
                    //5. Supplier Application
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendSupplierApplicationForApprovalCode);
                    // 
                    //6. Procurement Request
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendProcurementRequestForApprovalCode);
                    //  
                    //7. Contract
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendContractForApprovalCode);
                    // 
                    //8. Contract Extension
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendContractForApprovalCode);
                    //
                    //**********************SOFT - HR MODULE CUSTOMIZATIONS****************************
                    //1. HR Jobs
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendHRJobsForApprovalCode);
                    //
                    //2. Job Requisition
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendJobRequisitionForApprovalCode);
                    //
                    //3. Employee
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendEmployeeForApprovalCode);
                    //
                    //4. Employee Change
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendEmployeeChangeForApprovalCode);
                    //
                    //5. Leave Plan
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendLeavePlanForApprovalCode);
                    //
                    //6. Leave Application
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendLeaveForApprovalCode);
                    // 
                    //7. Leave Recall
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendLeaveRecallForApprovalCode);
                    //
                    //9. Training Needs
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendTrainingNeedsForApprovalCode);
                    //
                    //10. Employee Exit
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendEmployeeExitForApprovalCode);
                    //
                    //11. Payroll Periods
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendPayrollPeriodForApprovalCode);
                    //
                end;
            WorkflowResponseHandling.CreateApprovalRequestsCode:
                begin
                    //**********************SOFT - ADVANCED FINANCE MODULE CUSTOMIZATIONS****************************
                    //1. Payment Voucher
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendPVForApprovalCode);
                    //
                    //2. Petty Cash
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendReceiptHeaderForApprovalCode);
                    //  
                    //2. Petty Cash
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendPettyCashForApprovalCode);
                    //3. Request Header
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendRequestHeaderForApprovalCode);
                    //
                    //4. Virement Budget Request
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendVirementBudgetForApprovalCode);
                    // 
                    //5. Budget Plan
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendBudgetPlanForApprovalCode);
                    // 
                    //6. Fixed Deposit
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendFixedDepositForApprovalCode);
                    //
                    //7. Bank Acc Reconciliation
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendBankAccReconciliationForApprovalCode);
                    //
                    //**********************SOFT - PROCUREMENT MODULE CUSTOMIZATIONS****************************
                    //1. Requisition
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendRequisitionForApprovalCode);
                    //  
                    //1. Procurement Inspection
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendProcurementInspectionForApprovalCode);
                    //  
                    //2. Procurement Plan
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendProcurePlanForApprovalCode);
                    //
                    //3. RFQ
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendRFQForApprovalCode);
                    //
                    //5. SupplierApplication
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendSupplierApplicationForApprovalCode);
                    //
                    //6. Procurement Request
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendProcurementRequestForApprovalCode);
                    //
                    //7. Contract
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendContractForApprovalCode);
                    //
                    //8. Contract Extension
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendContractExtensionForApprovalCode);
                    //
                    //**********************SOFT - HR MODULE CUSTOMIZATIONS****************************
                    //1. HR Jobs
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendHRJobsForApprovalCode);
                    //
                    //2. Job Requisitions
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendJobRequisitionForApprovalCode);
                    //
                    //3. Employee
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendEmployeeForApprovalCode);
                    //
                    //4. Employee Change
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendEmployeeChangeForApprovalCode);
                    //
                    //5. Leave Plan
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendLeavePlanForApprovalCode);
                    //
                    //6. Leave Application
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendLeaveForApprovalCode);
                    // 
                    //7. Leave Recall
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendLeaveRecallForApprovalCode);
                    //
                    //9. Training Needs
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendTrainingNeedsForApprovalCode);
                    // 
                    //10. Employee Exit
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendEmployeeExitForApprovalCode);
                    // 
                    //11. Payroll Periods
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendPayrollPeriodForApprovalCode);
                    //
                    //**********************CREDIT MODULE****************************
                end;
            WorkflowResponseHandling.SendApprovalRequestForApprovalCode:
                begin
                    //*****************************SOFT - ADVANCED FINANCE MODULE CUSTOMIZATIONS*************************
                    //1. Payment Voucher
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendPVForApprovalCode);
                    //
                    //2. Petty Cash
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendReceiptHeaderForApprovalCode);
                    // 
                    //2. Petty Cash
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendPettyCashForApprovalCode);
                    //
                    //3. Request Header
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendRequestHeaderForApprovalCode);
                    //
                    //4. Budget Plan
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendBudgetPlanForApprovalCode);
                    //
                    //5. Virement Budget Request
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendVirementBudgetForApprovalCode);
                    // 
                    //6. Fixed Deposit
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendFixedDepositForApprovalCode);
                    //
                    //7. Bank Acc Reconciliation
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendBankAccReconciliationForApprovalCode);
                    //
                    //*****************************SOFT - PROCUREMENT MODULE CUSTOMIZATIONS*************************
                    //1. Requisition
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendRequisitionForApprovalCode);
                    //  
                    //1. Procurement Inspection
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendProcurementInspectionForApprovalCode);
                    // 
                    //2. Procurement Plan
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendProcurePlanForApprovalCode);
                    //
                    //3. RFQ
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendRFQForApprovalCode);
                    //
                    //5. Supplier Application
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendSupplierApplicationForApprovalCode);
                    // 
                    //6. Procurement Request
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendProcurementRequestForApprovalCode);
                    //
                    //7. Contract
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendContractForApprovalCode);
                    // 
                    //8. Contract Extension
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendContractExtensionForApprovalCode);
                    //
                    //*****************************SOFT - HR MODULE CUSTOMIZATIONS*************************
                    //1. Hr Job
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendHRJobsForApprovalCode);
                    //
                    //2. Job Requisition
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendJobRequisitionForApprovalCode);
                    //
                    //3. Employee
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendEmployeeForApprovalCode);
                    //
                    //4. Employee Change Request
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendEmployeeChangeForApprovalCode);
                    //
                    //5. Leave Plan
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendLeavePlanForApprovalCode);
                    //
                    //6. Leave Application
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendLeaveForApprovalCode);
                    // 
                    //7. Leave Recall
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendLeaveRecallForApprovalCode);
                    //
                    //9. Training Needs
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendTrainingNeedsForApprovalCode);
                    //
                    //10. Employee Exit
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendEmployeeExitForApprovalCode);
                    //
                    //11. Training Needs
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendPayrollPeriodForApprovalCode);
                    //  
                end;
            WorkflowResponseHandling.OpenDocumentCode:
                begin
                    //*********************************SOFT - ADVANCED FINANCE MODULE CUSTOMIZATIONS*************************
                    //1. Payment Voucher
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelPVApprovalRequestCode);
                    //
                    //2. Petty Cash
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelReceiptHeaderApprovalRequestCode);
                    //
                    //2. Petty Cash
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelPettyCashApprovalRequestCode);
                    //
                    //3. Request Header
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelRequestHeaderApprovalRequestCode);
                    //
                    //4. Virement Budget Request
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelVirementBudgetApprovalRequestCode);
                    //
                    //5. Budget Plan
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelBudgetPlanApprovalRequestCode);
                    //
                    //6. Fixed Deposit
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelFixedDepositApprovalRequestCode);
                    // 
                    //7. Bank Acc Reconciliation
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelBankAccReconciliationApprovalRequestCode);
                    //
                    //*********************************SOFT - PROCUREMENT MODULE CUSTOMIZATIONS*************************
                    //1. Requisition
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelRequisitionApprovalRequestCode);
                    // 
                    //1. Procurement Inspection
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelProcurementInspectionApprovalRequestCode);
                    //
                    //2. Procurement Plan
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelProcurePlanApprovalRequestCode);
                    //
                    //3. RFQ
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelRFQApprovalRequestCode);
                    //
                    //5. Supplier Application
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelSupplierApplicationApprovalRequestCode);
                    //
                    //6. Procurement Request
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelProcurementRequestApprovalRequestCode);
                    //
                    //7. Contract
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelContractApprovalRequestCode);
                    //
                    //8. Contract Extension
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelContractExtensionApprovalRequestCode);
                    //
                    //*********************************SOFT - HR MODULE CUSTOMIZATIONS*************************
                    //1. HR Jobs
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelHRJobsApprovalRequestCode);
                    // 
                    //2. Job Requisition
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelJobRequisitionApprovalRequestCode);
                    //
                    //3. Employee
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelEmployeeApprovalRequestCode);
                    // 
                    //4. Employee Change Request
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelEmployeeChangeApprovalRequestCode);
                    // 
                    //5. Leave Plan
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelLeavePlanApprovalRequestCode);
                    //
                    //6. Leave Application
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelLeaveApprovalRequestCode);
                    //  
                    //7. Leave Recalls
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelLeaveRecallApprovalRequestCode);
                    //
                    //9. Training Needs
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelTrainingNeedsApprovalRequestCode);
                    // 
                    //10. Employee Exit
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelEmployeeExitApprovalRequestCode);
                    // 
                    //11. Payroll Periods
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelPayrollPeriodApprovalRequestCode);
                    // 
                end;
            WorkflowResponseHandling.CancelAllApprovalRequestsCode:
                begin
                    //***************************SOFT - ADVANCED FINANCE MODULE CUSTOMIZATIONS******************************
                    //1. Payment Voucher
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelPVApprovalRequestCode);
                    //
                    //2. Petty Cash
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelReceiptHeaderApprovalRequestCode);
                    //
                    //2. Petty Cash
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelPettyCashApprovalRequestCode);
                    //3. Request Header
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelRequestHeaderApprovalRequestCode);
                    //
                    //4. Virement Budget Request
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelVirementBudgetApprovalRequestCode);
                    //
                    //5. Budget Plan
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelBudgetPlanApprovalRequestCode);
                    // 
                    //6. Fixed Deposit
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelFixedDepositApprovalRequestCode);
                    // 
                    //7. Bank Acc Reconciliation
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelBankAccReconciliationApprovalRequestCode);
                    //
                    //***************************SOFT - PROCUREMENT MODULE CUSTOMIZATIONS******************************
                    //1. Requisition
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelRequisitionApprovalRequestCode);
                    //  
                    //1. Procurement Inspection
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelProcurementInspectionApprovalRequestCode);
                    // 
                    //2. Procurement Plan
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelProcurePlanApprovalRequestCode);
                    //
                    //3. RFQ
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelRFQApprovalRequestCode);
                    // 
                    //5. Supplier Application
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelSupplierApplicationApprovalRequestCode);
                    //  
                    //6. Procurement Request
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelProcurementRequestApprovalRequestCode);
                    // 
                    //7. Contract
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelContractApprovalRequestCode);
                    //  
                    //8. Contract Extension
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelContractExtensionApprovalRequestCode);
                    //
                    //***************************SOFT - HR MODULE CUSTOMIZATIONS******************************
                    //1. HR Jobs
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelHRJobsApprovalRequestCode);
                    // 
                    //2. Job Requisition
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelJobRequisitionApprovalRequestCode);
                    // 
                    //3. Employee
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelEmployeeApprovalRequestCode);
                    // 
                    //4. Employee Change
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelEmployeeChangeApprovalRequestCode);
                    //
                    //5. Leave Plan
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelLeavePlanApprovalRequestCode);
                    //
                    //6. Leave Application
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelLeaveApprovalRequestCode);
                    //  
                    //7.Leave Recall
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelLeaveRecallApprovalRequestCode);
                    //
                    //9. Training Needs
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelTrainingNeedsApprovalRequestCode);
                    // 
                    //10. Employee Exit
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelEmployeeExitApprovalRequestCode);
                    //
                    //11. Payroll Periods
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelPayrollPeriodApprovalRequestCode);
                    //
                end;
        end;
    end;
    //#endregion
    //#region OnReleaseDocument
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', true, true)]
    local procedure ReleaseDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        ApprovalEntry: Record "Approval Entry";
        WorkflowWebhookEntry: Record "Workflow Webhook Entry";
        TargetRecRef: RecordRef; //**********Finance**********
        PV: Record "Payment Voucher";
        ReceiptHeader: Record "Receipt Header";
        RequestHeader: Record "Request Header";
        PettyCash: Record "Petty Cash Header";
        VirementBudget: Record "Virement Budget Request";
        BudgetPlan: Record "Budget Plan";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        FixedDeposit: Record "Fixed Deposit Header";
        CompanyDocuments: Record "Company Documents";
        //**********Procurement**********
        Requisition: Record "Requisition Header";
        ProcurementInspection: Record "Procurement Inspection";
        RFQ: Record "RFQ Header";
        ProcurePlan: Record "Procurement Plans";
        SupplierApplication: Record "Supplier Application";
        ProcurementRequest: Record "Procurement Request";
        Contract: Record "Contract Header";
        ContractExtension: Record "Contract Extension"; //**********Human Resource**********
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
        ProcurementMgmt: Codeunit "Procurement Management";
        HumanResourceMgt: Codeunit "Human Resource Management";
    begin
        case RecRef.Number of //*******************SOFT - ADVANCED FINANCE MODULE CUSTOMIZATIONS**********************
                              //1. Payment Voucher
            DATABASE::"Payment Voucher":
                begin
                    RecRef.SetTable(PV);
                    PV.Validate(Status, PV.Status::Approved);
                    PV.Modify(true);
                    Handled := true;
                end;
            //
            //2. Petty Cash
            DATABASE::"Receipt Header":
                begin
                    RecRef.SetTable(ReceiptHeader);
                    ReceiptHeader.Validate(Status, ReceiptHeader.Status::Approved);
                    ReceiptHeader.Modify(true);
                    Handled := true;
                end;
            //
            //2. Petty Cash
            DATABASE::"Petty Cash Header":
                begin
                    RecRef.SetTable(PettyCash);
                    PettyCash.Validate(Status, PettyCash.Status::Approved);
                    PettyCash.Modify(true);
                    Handled := true;
                end;
            //
            //3. Request Header
            DATABASE::"Request Header":
                begin
                    RecRef.SetTable(RequestHeader);
                    RequestHeader.Validate(Status, RequestHeader.Status::Approved);
                    RequestHeader.Modify(true);
                    Handled := true;
                end;
            //
            //4. Virement Budget Request
            DATABASE::"Virement Budget Request":
                begin
                    RecRef.SetTable(VirementBudget);
                    VirementBudget.Validate(Status, VirementBudget.Status::Approved);
                    VirementBudget.Modify(true);
                    Handled := true;
                end;
            // 
            //5. Budget Plan
            DATABASE::"Budget Plan":
                begin
                    RecRef.SetTable(BudgetPlan);
                    BudgetPlan.Validate(Status, BudgetPlan.Status::Approved);
                    BudgetPlan.Modify(true);
                    Handled := true;
                end;
            //
            //6. Fixed Deposit
            DATABASE::"Fixed Deposit Header":
                begin
                    RecRef.SetTable(FixedDeposit);
                    FixedDeposit.Validate(Status, FixedDeposit.Status::Approved);
                    FixedDeposit.Modify(true);
                    Handled := true;
                end;
            // 
            //7. Bank Acc Reconciliation
            DATABASE::"Bank Acc. Reconciliation":
                begin
                    RecRef.SetTable(BankAccReconciliation);
                    BankAccReconciliation.Validate(Status, BankAccReconciliation.Status::Approved);
                    BankAccReconciliation.Modify(true);
                    Handled := true;
                end;
            //
            //*******************SOFT - PROCUREMENT MODULE CUSTOMIZATIONS**********************
            //1. Requisition
            DATABASE::"Requisition Header":
                begin
                    RecRef.SetTable(Requisition);
                    Requisition.Validate(Status, Requisition.Status::Approved);
                    Requisition.Modify(true);
                    Handled := true;
                end;
            // 
            //1. Procurement Inspection
            DATABASE::"Procurement Inspection":
                begin
                    RecRef.SetTable(ProcurementInspection);
                    ProcurementInspection.Validate(Status, ProcurementInspection.Status::Approved);
                    ProcurementInspection.Modify(true);
                    Handled := true;
                end;
            // 
            //2. Procurement Plan
            DATABASE::"Procurement Plans":
                begin
                    RecRef.SetTable(ProcurePlan);
                    ProcurePlan.Validate(Status, ProcurePlan.Status::Approved);
                    ProcurePlan.Modify(true);
                    Handled := true;
                    ProcurementMgmt.NotifyCEOonProcurementPlanApproval;
                end;
            //
            //3. RFQ
            DATABASE::"RFQ Header":
                begin
                    RecRef.SetTable(RFQ);
                    RFQ.Validate(Status, RFQ.Status::Approved);
                    RFQ.Modify(true);
                    Handled := true;
                end;
            // 
            //5. Supplier Application
            Database::"Supplier Application":
                begin
                    RecRef.SetTable(SupplierApplication);
                    SupplierApplication.Validate(Status, SupplierApplication.Status::Approved);
                    SupplierApplication.Modify(true);
                    Handled := true;
                end;
            // 
            //6. Procurement Request
            Database::"Procurement Request":
                begin
                    RecRef.SetTable(ProcurementRequest);
                    ProcurementRequest.Validate(Status, ProcurementRequest.Status::Approved);
                    ProcurementRequest.Modify(true);
                    Handled := true;
                end;
            //
            //7. Contract
            Database::"Contract Header":
                begin
                    RecRef.SetTable(Contract);
                    Contract.Validate(Status, Contract.Status::Approved);
                    Contract.Modify(true);
                    Handled := true;
                end;
            // 
            //8. Store Transaction
            Database::"Contract Extension":
                begin
                    RecRef.SetTable(ContractExtension);
                    ContractExtension.Validate(Status, ContractExtension.Status::Approved);
                    ContractExtension.Modify(true);
                    Handled := true;
                end;
            //
            //*******************SOFT - HR MODULE CUSTOMIZATIONS**********************
            //1. HR Jobs
            DATABASE::"Company Jobs":
                begin
                    RecRef.SetTable(HRJobs);
                    HRJobs.Validate(Status, HRJobs.Status::Approved);
                    HRJobs.Modify(true);
                    Handled := true;
                end;
            //  
            //2. Job Requisition
            DATABASE::"Job Requisition":
                begin
                    RecRef.SetTable(JobRequisition);
                    JobRequisition.Validate(Status, JobRequisition.Status::Approved);
                    JobRequisition.Modify(true);
                    Handled := true;
                end;
            //  
            //3. Employee
            DATABASE::Employee:
                begin
                    RecRef.SetTable(Employee);
                    Employee.Validate("Employee Status", Employee."Employee Status"::Active);
                    Employee.Modify(true);
                    Handled := true;
                end;
            // 
            //4. Employee Change
            DATABASE::"Employee Change Request":
                begin
                    RecRef.SetTable(EmployeeChange);
                    EmployeeChange.Validate(Status, EmployeeChange.Status::Approved);
                    EmployeeChange.Modify(true);
                    Handled := true;
                end;
            // 
            //5. Leave Plan
            DATABASE::"Leave Plan":
                begin
                    RecRef.SetTable(LeavePlan);
                    LeavePlan.Validate(Status, LeavePlan.Status::Approved);
                    LeavePlan.Modify(true);
                    Handled := true;
                end;
            //    
            //6. Leave Application
            DATABASE::"Leave Applications":
                begin
                    RecRef.SetTable(Leave);
                    Leave.Validate(Status, Leave.Status::Approved);
                    Leave.Modify(true);
                    Handled := true;
                end;
            //
            //7. Leave Recall
            DATABASE::"Leave Recall":
                begin
                    RecRef.SetTable(LeaveRecall);
                    LeaveRecall.Validate(Status, LeaveRecall.Status::Approved);
                    LeaveRecall.Modify(true);
                    Handled := true;
                end;
            //
            //9. Training Needs
            DATABASE::"Training Needs":
                begin
                    RecRef.SetTable(TrainingNeeds);
                    TrainingNeeds.Validate(Status, TrainingNeeds.Status::Approved);
                    TrainingNeeds.Modify(true);
                    Handled := true;
                end;
            //
            //10. Employee Exit
            DATABASE::"Employee Exit":
                begin
                    RecRef.SetTable(EmployeeExit);
                    EmployeeExit.Validate(Status, EmployeeExit.Status::Approved);
                    EmployeeExit.Modify(true);
                    Handled := true;
                end;
            // 
            //11. Payroll Periods
            DATABASE::"Payroll Periods":
                begin
                    RecRef.SetTable(PayrollPeriod);
                    PayrollPeriod.Validate(Status, PayrollPeriod.Status::Approved);
                    PayrollPeriod.Modify(true);
                    Handled := true;
                end;
        //
        end;
    end;
    //#endregion
    //#region OnOpenDocument
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', true, true)]
    local procedure OpenDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        ApprovalEntry: Record "Approval Entry";
        WorkflowWebhookEntry: Record "Workflow Webhook Entry";
        TargetRecRef: RecordRef; //**********Finance**********
        PV: Record "Payment Voucher";
        ReceiptHeader: Record "Receipt Header";
        RequestHeader: Record "Request Header";
        PettyCash: Record "Petty Cash Header";
        VirementBudget: Record "Virement Budget Request";
        BudgetPlan: Record "Budget Plan";
        FixedDeposit: Record "Fixed Deposit Header";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        CompanyDocuments: Record "Company Documents";
        //**********Procurement**********
        Requisition: Record "Requisition Header";
        ProcurementInspection: Record "Procurement Inspection";
        RFQ: Record "RFQ Header";
        ProcurePlan: Record "Procurement Plans";
        SupplierApplication: Record "Supplier Application";
        ProcurementRequest: Record "Procurement Request";
        Contract: Record "Contract Header";
        ContractExtension: Record "Contract Extension"; //**********Human Resource**********
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
        case RecRef.Number of //***********SOFT - ADVANCED FINANCE MODULE CUSTOMIZATIONS*************
                              //1. Payment Voucher
            DATABASE::"Payment Voucher":
                begin
                    RecRef.SetTable(PV);
                    PV.Validate(Status, PV.Status::Open);
                    PV.Modify(true);
                    Handled := true;
                end;
            //
            //2. Petty Cash
            DATABASE::"Receipt Header":
                begin
                    RecRef.SetTable(ReceiptHeader);
                    ReceiptHeader.Validate(Status, ReceiptHeader.Status::Open);
                    ReceiptHeader.Modify(true);
                    Handled := true;
                end;
            //
            //2. Petty Cash
            DATABASE::"Petty Cash Header":
                begin
                    RecRef.SetTable(PettyCash);
                    PettyCash.Validate(Status, PettyCash.Status::Open);
                    PettyCash.Modify(true);
                    Handled := true;
                end;
            //
            //3. Request Header
            DATABASE::"Request Header":
                begin
                    RecRef.SetTable(RequestHeader);
                    RequestHeader.Validate(Status, RequestHeader.Status::Open);
                    RequestHeader.Modify(true);
                    Handled := true;
                end;
            //  
            //4. Virement Budget Request 
            DATABASE::"Virement Budget Request":
                begin
                    RecRef.SetTable(VirementBudget);
                    VirementBudget.Validate(Status, VirementBudget.Status::Open);
                    VirementBudget.Modify(true);
                    Handled := true;
                end;
            // 
            //5. Budget Plan 
            DATABASE::"Budget Plan":
                begin
                    RecRef.SetTable(BudgetPlan);
                    BudgetPlan.Validate(Status, BudgetPlan.Status::Open);
                    BudgetPlan.Modify(true);
                    Handled := true;
                end;
            //
            //6. Fixed Deposit
            DATABASE::"Fixed Deposit Header":
                begin
                    RecRef.SetTable(FixedDeposit);
                    FixedDeposit.Validate(Status, FixedDeposit.Status::Open);
                    FixedDeposit.Modify(true);
                    Handled := true;
                end;
            // 
            //7. Bank Acc Reconciliation
            DATABASE::"Bank Acc. Reconciliation":
                begin
                    RecRef.SetTable(BankAccReconciliation);
                    BankAccReconciliation.Validate(Status, BankAccReconciliation.Status::Open);
                    BankAccReconciliation.Modify(true);
                    Handled := true;
                end;
            //
            //***********SOFT - PROCUREMENT MODULE CUSTOMIZATIONS*************
            //1. Requisition
            DATABASE::"Requisition Header":
                begin
                    RecRef.SetTable(Requisition);
                    Requisition.Validate(Status, Requisition.Status::Open);
                    Requisition.Modify(true);
                    Handled := true;
                end;
            //
            //2. Procurement Inspection
            DATABASE::"Procurement Inspection":
                begin
                    RecRef.SetTable(ProcurementInspection);
                    ProcurementInspection.Validate(Status, ProcurementInspection.Status::Open);
                    ProcurementInspection.Modify(true);
                    Handled := true;
                end;
            // 
            //2. Procurement Plan
            DATABASE::"Procurement Plans":
                begin
                    RecRef.SetTable(ProcurePlan);
                    ProcurePlan.Validate(Status, ProcurePlan.Status::Open);
                    ProcurePlan.Modify(true);
                    Handled := true;
                end;
            //
            //3. RFQ
            DATABASE::"RFQ Header":
                begin
                    RecRef.SetTable(RFQ);
                    RFQ.Validate(Status, RFQ.Status::Open);
                    RFQ.Modify(true);
                    Handled := true;
                end;
            // 
            //5. Supplier Application
            DATABASE::"Supplier Application":
                begin
                    RecRef.SetTable(SupplierApplication);
                    SupplierApplication.Validate(Status, SupplierApplication.Status::Open);
                    SupplierApplication.Modify(true);
                    Handled := true;
                end;
            //
            //6. Procurement Request
            DATABASE::"Procurement Request":
                begin
                    RecRef.SetTable(ProcurementRequest);
                    ProcurementRequest.Validate(Status, ProcurementRequest.Status::Open);
                    ProcurementRequest.Modify(true);
                    Handled := true;
                end;
            //
            //7. Contract
            DATABASE::"Contract Header":
                begin
                    RecRef.SetTable(Contract);
                    Contract.Validate(Status, Contract.Status::Open);
                    Contract.Modify(true);
                    Handled := true;
                end;
            //
            //8. Contract Extension
            DATABASE::"Contract Extension":
                begin
                    RecRef.SetTable(ContractExtension);
                    ContractExtension.Validate(Status, ContractExtension.Status::Open);
                    ContractExtension.Modify(true);
                    Handled := true;
                end;
            //
            //***********SOFT - HR MODULE CUSTOMIZATIONS*************
            //1. HR Jobs
            DATABASE::"Company Jobs":
                begin
                    RecRef.SetTable(HRJobs);
                    HRJobs.Validate(Status, HRJobs.Status::Open);
                    HRJobs.Modify(true);
                    Handled := true;
                end;
            //  
            //2. Job Requisition
            DATABASE::"Job Requisition":
                begin
                    RecRef.SetTable(JobRequisition);
                    JobRequisition.Validate(Status, JobRequisition.Status::Open);
                    JobRequisition.Modify(true);
                    Handled := true;
                end;
            // 
            //3. Employee
            DATABASE::Employee:
                begin
                    RecRef.SetTable(Employee);
                    Employee.Validate("Employee Status", Employee."Employee Status"::New);
                    Employee.Modify(true);
                    Handled := true;
                end;
            //  
            //4. Employee Change
            DATABASE::"Employee Change Request":
                begin
                    RecRef.SetTable(EmployeeChange);
                    EmployeeChange.Validate(Status, EmployeeChange.Status::Open);
                    EmployeeChange.Modify(true);
                    Handled := true;
                end;
            //  
            //5. Leave Plan
            DATABASE::"Leave Plan":
                begin
                    RecRef.SetTable(LeavePlan);
                    LeavePlan.Validate(Status, LeavePlan.Status::Open);
                    LeavePlan.Modify(true);
                    Handled := true;
                end;
            //
            //6. Leave Application
            DATABASE::"Leave Applications":
                begin
                    RecRef.SetTable(Leave);
                    Leave.Validate(Status, Leave.Status::Open);
                    Leave.Modify(true);
                    Handled := true;
                end;
            // 
            //6. Leave Recall
            DATABASE::"Leave Recall":
                begin
                    RecRef.SetTable(LeaveRecall);
                    LeaveRecall.Validate(Status, LeaveRecall.Status::Open);
                    LeaveRecall.Modify(true);
                    Handled := true;
                end;
            //
            //8. Training Needs
            DATABASE::"Training Needs":
                begin
                    RecRef.SetTable(TrainingNeeds);
                    TrainingNeeds.Validate(Status, TrainingNeeds.Status::Open);
                    TrainingNeeds.Modify(true);
                    Handled := true;
                end;
            //
            //9. Employee Exit
            DATABASE::"Employee Exit":
                begin
                    RecRef.SetTable(EmployeeExit);
                    EmployeeExit.Validate(Status, EmployeeExit.Status::Open);
                    EmployeeExit.Modify(true);
                    Handled := true;
                end;
            // 
            //10. 
            DATABASE::"Payroll Periods":
                begin
                    RecRef.SetTable(PayrollPeriod);
                    PayrollPeriod.Validate(Status, PayrollPeriod.Status::Open);
                    PayrollPeriod.Modify(true);
                    Handled := true;
                end;
        // 
        end;
    end;
    //#endregion
}
