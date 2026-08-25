codeunit 52204002 "Workflow Response Handling Cxt"
{
    //#region AddResponsePredecessor
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsePredecessorsToLibrary', '', true, true)]
    local procedure AddResponsePredecessors(ResponseFunctionName: Code[128])
    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling C_Ext";
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
    begin
        case ResponseFunctionName of
            WorkflowResponseHandling.SetStatusToPendingApprovalCode:
                begin
                    //**********************CREDIT MODULE****************************
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendLoanApplicationForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendProductsManagementForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendLoanDisbursementForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendLoanRestructureForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendCollateralApplicationForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendCollateralReleaseForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendMemberApplicationForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendMemberEditingForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendPaymentVoucherForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendJournalVoucherForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendTellerTransactionForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendLienForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendStandingOrderForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendMemberFixedDepositForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendBankersChequeForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendATMApplicationForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendMobileApplicationForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendLoanBatchForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendMemberExitForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendBenevolentFundForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendGuarantorMgtForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendLoanRecoveryForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendMemberActivationForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendCheckOffForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendChequeBookApplicationForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendChequeBookTransactionForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendInterAccountTransferForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendAccountOpeningForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendMemberAccountMgmtForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendDividendHeaderForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendReceiptForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendFOSATransactionForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendChequeDepositForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendMoneyLaundaryCheckForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnSendShareFloatingForApprovalCode);
                end;
            WorkflowResponseHandling.CreateApprovalRequestsCode:
                begin
                    //**********************CREDIT MODULE****************************
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendLoanApplicationForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendProductsManagementForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendLoanDisbursementForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendLoanRestructureForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendCollateralApplicationForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendCollateralReleaseForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendMemberApplicationForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendMemberEditingForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendPaymentVoucherForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendJournalVoucherForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendTellerTransactionForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendLienForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendStandingOrderForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendMemberFixedDepositForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendBankersChequeForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendATMApplicationForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendMobileApplicationForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendLoanBatchForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendMemberExitForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendBenevolentFundForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendGuarantorMgtForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendLoanRecoveryForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendMemberActivationForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendCheckOffForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendChequeBookApplicationForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendChequeBookTransactionForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendInterAccountTransferForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendAccountOpeningForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendMemberAccountMgmtForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendDividendHeaderForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendReceiptForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendFOSATransactionForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendChequeDepositForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendMoneyLaundaryCheckForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnSendShareFloatingForApprovalCode);
                end;
            WorkflowResponseHandling.SendApprovalRequestForApprovalCode:
                begin
                    //**********************CREDIT MODULE**************************** 
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendLoanApplicationForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendProductsManagementForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendLoanDisbursementForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendLoanRestructureForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendCollateralApplicationForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendCollateralReleaseForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendMemberApplicationForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendMemberEditingForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendPaymentVoucherForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendJournalVoucherForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendTellerTransactionForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendLienForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendStandingOrderForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendMemberFixedDepositForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendBankersChequeForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendATMApplicationForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendMobileApplicationForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendLoanBatchForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendMemberExitForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendBenevolentFundForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendGuarantorMgtForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendLoanRecoveryForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendMemberActivationForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendCheckOffForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendChequeBookApplicationForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendChequeBookTransactionForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendInterAccountTransferForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendAccountOpeningForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendMemberAccountMgmtForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendDividendHeaderForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendReceiptForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendFOSATransactionForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendChequeDepositForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendMoneyLaundaryCheckForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, WorkflowEventHandling.RunWorkflowOnSendShareFloatingForApprovalCode);
                end;
            WorkflowResponseHandling.OpenDocumentCode:
                begin
                    //**********************CREDIT MODULE**************************** 
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelLoanApplicationApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelProductsManagementApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelLoanDisbursementApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelLoanRestructureApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelCollateralApplicationApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelCollateralReleaseApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelMemberApplicationApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelMemberEditingApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelPaymentVoucherApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelJournalVoucherApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelTellerTransactionApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelLienApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelStandingOrderApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelMemberFixedDepositApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelBankersChequeApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelATMApplicationApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelMobileApplicationApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelLoanBatchApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelMemberExitApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelBenevolentFundApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelGuarantorMgtApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelLoanRecoveryApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelMemberActivationApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelCheckOffApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelChequeBookApplicationApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelChequeBookTransactionApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelinterAccountTransferApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelAccountOpeningApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelMemberAccountMgmtApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelDividendHeaderApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelReceiptApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelFOSATransactionApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelChequeDepositApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelMoneyLaundaryCheckApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, WorkflowEventHandling.RunWorkflowOnCancelShareFloatingApprovalCode);
                end;
            WorkflowResponseHandling.CancelAllApprovalRequestsCode:
                begin
                    //**********************CREDIT MODULE****************************
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelLoanApplicationApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelProductsManagementApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelLoanDisbursementApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelLoanRestructureApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelCollateralApplicationApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelCollateralReleaseApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelMemberApplicationApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelMemberEditingApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelPaymentVoucherApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelJournalVoucherApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelTellerTransactionApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelLienApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelStandingOrderApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelMemberFixedDepositApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelBankersChequeApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelATMApplicationApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelMobileApplicationApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelLoanBatchApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelMemberExitApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelBenevolentFundApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelGuarantorMgtApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelLoanRecoveryApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelMemberActivationApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelCheckOffApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelChequeBookApplicationApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelChequeBookTransactionApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelInterAccountTransferApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelAccountOpeningApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelMemberAccountMgmtApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelDividendHeaderApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelReceiptApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelFOSATransactionApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelChequeDepositApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelMoneyLaundaryCheckApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelShareFloatingApprovalCode);
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
        TargetRecRef: RecordRef;
        Loans: Record Loans;
        ProductsManagement: Record "Products Management";
        LoanDisbursement: Record "Loan Disbursement";
        LoanRestructure: Record "Loan Moratorium";
        CollateralApplication: Record "Collateral Application";
        CollateralRelease: Record "Collateral Release";
        MemberApplication: Record "Member Application";
        MemberEditing: Record "Member Editing";
        JournalVoucher: Record "Journal Voucher Header";
        TellerTransaction: Record "Teller Transactions";
        Lien: Record Lien;
        StandingOrder: Record "Standing Order";
        FixedDepositRegister: Record "Member Fixed Deposits";
        FDManagement: Codeunit "Fixed Deposit Mgt.";
        BankersCheque: Record "Bankers Cheque";
        ATMApplication: Record "ATM Application";
        MobileApplication: Record "Mobile Application";
        LoanBatch: Record "Loan Batch Header";
        MemberExit: Record "Member Withdrawal";
        BenevolentFund: Record "Benevolent Fund";
        Member: Record Members;
        GuarantorMgt: Record "Loan Security Mgmt";
        LoanRecovery: Record "Loan Recovery Header";
        MemberActivation: Record "Member Activations";
        Checkoff: Record "Checkoff Header";
        ChequeBookApplication: Record "Cheque Book Applications";
        InterAccountTransfer: Record "Inter Account Transfer";
        AccountOpening: Record "Account Opening";
        MemberAccountMgmt: Record "Member Accounts Mgmt.";
        DividendHeader: Record "Dividend Header";
        FOSATransaction: Record "FOSA Transactions";
        ChequeDeposit: Record "Cheque Deposits";
        MoneyLaundaryCheck: Record "Money Laundary Check";
        ShareFloating: Record "Share Floating";
        MemberMgt: Codeunit "Member Management";
    begin
        case RecRef.Number of //*******************CREDIT MODULE**********************
            Database::"Collateral Application":
                begin
                    RecRef.SetTable(CollateralApplication);
                    CollateralApplication.Status := CollateralApplication.Status::Approved;
                    CollateralApplication.Modify;
                    Handled := true;
                end;
            Database::"Collateral Release":
                begin
                    RecRef.SetTable(CollateralRelease);
                    CollateralRelease.Status := CollateralRelease.Status::Approved;
                    CollateralRelease.Modify;
                    Handled := true;
                end;
            Database::Loans:
                begin
                    RecRef.SetTable(Loans);
                    Loans.Status := Loans.Status::Approved;
                    Loans."Appraisal Commited" := true;
                    Loans.Modify;
                    Handled := true;
                end;
            Database::"Products Management":
                begin
                    RecRef.SetTable(ProductsManagement);
                    ProductsManagement.Status := ProductsManagement.Status::Approved;
                    ProductsManagement.Modify;
                    Handled := true;
                end;
            Database::"Loan Disbursement":
                begin
                    RecRef.SetTable(LoanDisbursement);
                    LoanDisbursement.Status := LoanDisbursement.Status::Approved;
                    LoanDisbursement.Modify;
                    Handled := true;
                end;
            Database::"Loan Moratorium":
                begin
                    RecRef.SetTable(LoanRestructure);
                    LoanRestructure.Status := LoanRestructure.Status::Approved;
                    LoanRestructure.Modify;
                    Handled := true;
                end;
            Database::"Member Application":
                begin
                    RecRef.SetTable(MemberApplication);
                    MemberApplication.Status := MemberApplication.Status::Approved;
                    MemberApplication.Modify;
                    Handled := true;
                end;
            Database::"Member Editing":
                begin
                    RecRef.SetTable(MemberEditing);
                    MemberEditing.Status := MemberEditing.Status::Approved;
                    MemberEditing.Modify;
                    Handled := true;
                end;
            Database::"Journal Voucher Header":
                begin
                    RecRef.SetTable(JournalVoucher);
                    JournalVoucher.Status := JournalVoucher.Status::Approved;
                    JournalVoucher.Modify;
                    Handled := true;
                end;
            Database::"Teller Transactions":
                begin
                    RecRef.SetTable(TellerTransaction);
                    TellerTransaction.Status := TellerTransaction.Status::Approved;
                    TellerTransaction.Modify;
                    Handled := true;
                end;
            Database::Lien:
                begin
                    RecRef.SetTable(Lien);
                    Lien.Status := Lien.Status::Approved;
                    Lien.Modify;
                    Handled := true;
                end;
            Database::"Standing Order":
                begin
                    RecRef.SetTable(StandingOrder);
                    StandingOrder.Status := StandingOrder.Status::Approved;
                    StandingOrder.Running := true;
                    StandingOrder.Modify;
                    Handled := true;
                end;
            Database::"Member Fixed Deposits":
                begin
                    RecRef.SetTable(FixedDepositRegister);
                    FixedDepositRegister.Status := FixedDepositRegister.Status::Approved;
                    FixedDepositRegister.Modify(true);
                    Handled := true;
                end;
            Database::"Bankers Cheque":
                begin
                    RecRef.SetTable(BankersCheque);
                    BankersCheque.Status := BankersCheque.Status::Approved;
                    BankersCheque.Modify();
                    Handled := true;
                end;
            Database::"ATM Application":
                begin
                    RecRef.SetTable(ATMApplication);
                    ATMApplication.Status := ATMApplication.Status::Approved;
                    ATMApplication.Modify();
                    Handled := true;
                end;
            Database::"Mobile Application":
                begin
                    RecRef.SetTable(MobileApplication);
                    MobileApplication.Status := MobileApplication.Status::Approved;
                    MobileApplication.Modify();
                    Handled := true;
                end;
            Database::"Loan Batch Header":
                begin
                    RecRef.SetTable(LoanBatch);
                    LoanBatch.Status := LoanBatch.Status::Approved;
                    LoanBatch.Modify();
                    Handled := true;
                end;
            Database::"Member Withdrawal":
                begin
                    RecRef.SetTable(MemberExit);
                    MemberExit.Status := MemberExit.Status::Approved;
                    MemberMgt.OnMemberExitApproval(MemberExit);
                    MemberExit.Modify();
                    Handled := true;
                end;
            Database::"Benevolent Fund":
                begin
                    RecRef.SetTable(BenevolentFund);
                    BenevolentFund.Status := BenevolentFund.Status::Approved;
                    BenevolentFund.Modify();
                    Handled := true;
                end;
            Database::"Loan Security Mgmt":
                begin
                    RecRef.SetTable(GuarantorMgt);
                    GuarantorMgt.Status := GuarantorMgt.Status::Approved;
                    GuarantorMgt.Modify();
                    Handled := true;
                end;
            Database::"Loan Recovery Header":
                begin
                    RecRef.SetTable(LoanRecovery);
                    LoanRecovery.Status := LoanRecovery.Status::Approved;
                    LoanRecovery.Modify();
                    Handled := true;
                end;
            Database::"Member Activations":
                begin
                    RecRef.SetTable(MemberActivation);
                    MemberActivation.Status := MemberActivation.Status::Approved;
                    MemberActivation.Modify();
                    Handled := true;
                end;
            Database::"Checkoff Header":
                begin
                    RecRef.SetTable(Checkoff);
                    Checkoff.Status := Checkoff.Status::Approved;
                    Checkoff.Modify();
                    Handled := true;
                end;
            Database::"Cheque Book Applications":
                begin
                    RecRef.SetTable(ChequeBookApplication);
                    ChequeBookApplication.Status := ChequeBookApplication.Status::Approved;
                    ChequeBookApplication.Modify();
                    Handled := true;
                end;
            Database::"Inter Account Transfer":
                begin
                    RecRef.SetTable(InterAccountTransfer);
                    InterAccountTransfer.Status := InterAccountTransfer.Status::Approved;
                    InterAccountTransfer.Modify();
                    Handled := true;
                end;
            Database::"Account Opening":
                begin
                    RecRef.SetTable(AccountOpening);
                    AccountOpening.Status := AccountOpening.Status::Approved;
                    AccountOpening.Processed := true;
                    AccountOpening.Modify();
                    AccountOpening."Account No." := MemberMgt.OpenAccounts(AccountOpening."No.");
                    Handled := true;
                end;
            Database::"Member Accounts Mgmt.":
                begin
                    RecRef.SetTable(MemberAccountMgmt);
                    MemberAccountMgmt.Validate(Status, MemberAccountMgmt.Status::Approved);
                    MemberAccountMgmt.Modify();
                    Handled := true;
                end;
            Database::"Dividend Header":
                begin
                    RecRef.SetTable(DividendHeader);
                    DividendHeader.Validate(Status, DividendHeader.Status::Approved);
                    DividendHeader.Modify();
                    Handled := true;
                end;
            Database::"FOSA Transactions":
                begin
                    RecRef.SetTable(FOSATransaction);
                    FOSATransaction.Validate(Status, FOSATransaction.Status::Approved);
                    FOSATransaction.CalcFields("Source Balance");
                    if FOSATransaction."Source Balance" < FOSATransaction.Amount then Error('You cannot Overdraw the Source Account');
                    FOSATransaction.Modify();
                    Handled := true;
                end;
            Database::"Cheque Deposits":
                begin
                    RecRef.SetTable(ChequeDeposit);
                    ChequeDeposit.Validate(Status, ChequeDeposit.Status::Approved);
                    ChequeDeposit.Modify();
                    Handled := true;
                end;
            Database::"Money Laundary Check":
                begin
                    RecRef.SetTable(MoneyLaundaryCheck);
                    MoneyLaundaryCheck.Validate(Status, MoneyLaundaryCheck.Status::Approved);
                    MoneyLaundaryCheck.Modify();
                    Handled := true;
                end;
            Database::"Share Floating":
                begin
                    RecRef.SetTable(ShareFloating);
                    ShareFloating.Validate(Status, ShareFloating.Status::Approved);
                    ShareFloating.Modify();
                    Handled := true;
                end;
        end;
    end;
    //#endregion
    //#region OnOpenDocument
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', true, true)]
    local procedure OpenDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        ApprovalEntry: Record "Approval Entry";
        WorkflowWebhookEntry: Record "Workflow Webhook Entry";
        TargetRecRef: RecordRef;
        Loans: Record Loans;
        ProductsManagement: Record "Products Management";
        LoanDisbursement: Record "Loan Disbursement";
        LoanRestructure: Record "Loan Moratorium";
        CollateralApplication: Record "Collateral Application";
        CollateralRelease: Record "Collateral Release";
        MemberApplication: Record "Member Application";
        MemberEditing: Record "Member Editing";
        JournalVoucher: Record "Journal Voucher Header";
        TellerTransaction: Record "Teller Transactions";
        Lien: Record Lien;
        StandingOrder: Record "Standing Order";
        FixedDepositRegister: Record "Member Fixed Deposits";
        BankersCheque: Record "Bankers Cheque";
        ATMApplication: Record "ATM Application";
        MobileApplication: Record "Mobile Application";
        LoanBatch: Record "Loan Batch Header";
        MemberExit: Record "Member Withdrawal";
        BenevolentFund: Record "Benevolent Fund";
        Member: Record Members;
        GuarantorMgt: Record "Loan Security Mgmt";
        LoanRecovery: Record "Loan Recovery Header";
        MemberActivation: Record "Member Activations";
        CheckOff: Record "Checkoff Header";
        ChequeBookApplication: Record "Cheque Book Applications";
        InterAccountTransfer: Record "Inter Account Transfer";
        AccountOpening: Record "Account Opening";
        MemberAccountMgmt: Record "Member Accounts Mgmt.";
        DividendHeader: Record "Dividend Header";
        FOSATransaction: Record "FOSA Transactions";
        ChequeDeposit: Record "Cheque Deposits";
        MoneyLaundaryCheck: Record "Money Laundary Check";
        ShareFloating: Record "Share Floating";
        MemberMgt: Codeunit "Member Management";
    begin
        case RecRef.Number of //***********CREDIT MODULE*************
            Database::"Collateral Application":
                begin
                    RecRef.SetTable(CollateralApplication);
                    CollateralApplication.Status := CollateralApplication.Status::Open;
                    CollateralApplication.Modify;
                    Handled := true;
                end;
            Database::"Collateral Release":
                begin
                    RecRef.SetTable(CollateralRelease);
                    CollateralRelease.Status := CollateralRelease.Status::Open;
                    CollateralRelease.Modify;
                    Handled := true;
                end;
            Database::Loans:
                begin
                    RecRef.SetTable(Loans);
                    Loans.Status := Loans.Status::Open;
                    Loans."Appraisal Commited" := false;
                    Loans.Modify;
                    Handled := true;
                end;
            Database::"Products Management":
                begin
                    RecRef.SetTable(ProductsManagement);
                    ProductsManagement.Status := ProductsManagement.Status::Open;
                    ProductsManagement.Modify;
                    Handled := true;
                end;
            Database::"Loan Disbursement":
                begin
                    RecRef.SetTable(LoanDisbursement);
                    LoanDisbursement.Status := LoanDisbursement.Status::Open;
                    LoanDisbursement.Modify;
                    Handled := true;
                end;
            Database::"Loan Moratorium":
                begin
                    RecRef.SetTable(LoanRestructure);
                    LoanRestructure.Status := LoanRestructure.Status::Open;
                    LoanRestructure.Modify;
                    Handled := true;
                end;
            Database::"Member Application":
                begin
                    RecRef.SetTable(MemberApplication);
                    MemberApplication.Status := MemberApplication.Status::Open;
                    MemberApplication.Modify();
                    Handled := true;
                end;
            Database::"Member Editing":
                begin
                    RecRef.SetTable(MemberEditing);
                    MemberEditing.Status := MemberEditing.Status::Open;
                    MemberEditing.Modify();
                    Handled := true;
                end;
            Database::"Journal Voucher Header":
                begin
                    RecRef.SetTable(JournalVoucher);
                    JournalVoucher.Status := JournalVoucher.Status::Open;
                    JournalVoucher.Modify();
                    Handled := true;
                end;
            Database::"Teller Transactions":
                begin
                    RecRef.SetTable(TellerTransaction);
                    TellerTransaction.Status := TellerTransaction.Status::Open;
                    TellerTransaction.Modify();
                    Handled := true;
                end;
            Database::Lien:
                begin
                    RecRef.SetTable(Lien);
                    Lien.Status := Lien.Status::Open;
                    Lien.Modify();
                    Handled := true;
                end;
            Database::"Standing Order":
                begin
                    RecRef.SetTable(StandingOrder);
                    StandingOrder.Status := StandingOrder.Status::Open;
                    StandingOrder.Modify();
                    Handled := true;
                end;
            Database::"Member Fixed Deposits":
                begin
                    RecRef.SetTable(FixedDepositRegister);
                    FixedDepositRegister.Status := FixedDepositRegister.Status::Open;
                    FixedDepositRegister.Modify();
                    Handled := true;
                end;
            Database::"Bankers Cheque":
                begin
                    RecRef.SetTable(BankersCheque);
                    BankersCheque.Status := BankersCheque.Status::Open;
                    BankersCheque.Modify();
                    Handled := true;
                end;
            Database::"ATM Application":
                begin
                    RecRef.SetTable(ATMApplication);
                    ATMApplication.Status := ATMApplication.Status::Open;
                    MemberMgt.ReverseAtmLien(ATMApplication."No.");
                    ATMApplication.Modify();
                    Handled := true;
                end;
            Database::"Mobile Application":
                begin
                    RecRef.SetTable(MobileApplication);
                    MobileApplication.Status := MobileApplication.Status::Open;
                    MemberMgt.ReverseAtmLien(MobileApplication."No.");
                    MobileApplication.Modify();
                    Handled := true;
                end;
            Database::"Loan Batch Header":
                begin
                    RecRef.SetTable(LoanBatch);
                    LoanBatch.Status := LoanBatch.Status::Open;
                    LoanBatch.Modify();
                    Handled := true;
                end;
            Database::"Member Withdrawal":
                begin
                    RecRef.SetTable(MemberExit);
                    MemberExit.Status := MemberExit.Status::Open;
                    MemberExit.Modify();
                    Handled := true;
                end;
            Database::"Benevolent Fund":
                begin
                    RecRef.SetTable(BenevolentFund);
                    BenevolentFund.Status := BenevolentFund.Status::Open;
                    BenevolentFund.Modify();
                    Handled := true;
                end;
            Database::"Loan Security Mgmt":
                begin
                    RecRef.SetTable(GuarantorMgt);
                    GuarantorMgt.Status := GuarantorMgt.Status::Open;
                    GuarantorMgt.Modify();
                    Handled := true;
                end;
            Database::"Loan Recovery Header":
                begin
                    RecRef.SetTable(LoanRecovery);
                    LoanRecovery.Status := LoanRecovery.Status::Open;
                    LoanRecovery.Modify();
                    Handled := true;
                end;
            Database::"Member Activations":
                begin
                    RecRef.SetTable(MemberActivation);
                    MemberActivation.Status := MemberActivation.Status::Open;
                    MemberActivation.Modify();
                    Handled := true;
                end;
            Database::"Checkoff Header":
                begin
                    RecRef.SetTable(CheckOff);
                    CheckOff.Status := CheckOff.Status::Open;
                    CheckOff.Modify();
                    Handled := true;
                end;
            Database::"Cheque Book Applications":
                begin
                    RecRef.SetTable(ChequeBookApplication);
                    ChequeBookApplication.Status := ChequeBookApplication.Status::Open;
                    ChequeBookApplication.Modify();
                    Handled := true;
                end;
            Database::"Inter Account Transfer":
                begin
                    RecRef.SetTable(InterAccountTransfer);
                    InterAccountTransfer.Status := InterAccountTransfer.Status::Open;
                    InterAccountTransfer.Modify();
                    Handled := true;
                end;
            Database::"Account Opening":
                begin
                    RecRef.SetTable(AccountOpening);
                    AccountOpening.Status := AccountOpening.Status::Open;
                    AccountOpening.Modify();
                    Handled := true;
                end;
            Database::"Member Accounts Mgmt.":
                begin
                    RecRef.SetTable(MemberAccountMgmt);
                    MemberAccountMgmt.Validate(Status, MemberAccountMgmt.Status::Open);
                    MemberAccountMgmt.Modify();
                    Handled := true;
                end;
            Database::"Dividend Header":
                begin
                    RecRef.SetTable(DividendHeader);
                    DividendHeader.Validate(Status, DividendHeader.Status::Open);
                    DividendHeader.Modify();
                    Handled := true;
                end;
            Database::"FOSA Transactions":
                begin
                    RecRef.SetTable(FOSATransaction);
                    FOSATransaction.Status := FOSATransaction.Status::Open;
                    FOSATransaction.Modify();
                    Handled := true;
                end;
            Database::"Cheque Deposits":
                begin
                    RecRef.SetTable(ChequeDeposit);
                    ChequeDeposit.Status := ChequeDeposit.Status::Open;
                    ChequeDeposit.Modify();
                    Handled := true;
                end;
            Database::"Money Laundary Check":
                begin
                    RecRef.SetTable(MoneyLaundaryCheck);
                    MoneyLaundaryCheck.Status := MoneyLaundaryCheck.Status::Open;
                    MoneyLaundaryCheck.Modify();
                    Handled := true;
                end;
            Database::"Share Floating":
                begin
                    RecRef.SetTable(ShareFloating);
                    ShareFloating.Status := ShareFloating.Status::Open;
                    ShareFloating.Modify();
                    Handled := true;
                end;
        end;
    end;
    //#endregion
}
