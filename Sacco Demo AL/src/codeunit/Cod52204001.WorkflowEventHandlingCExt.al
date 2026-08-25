codeunit 52204001 "Workflow Event Handling C_Ext"
{
    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowManagement: Codeunit "Workflow Management";
        SendForApprovalEventDescTxt: Label 'Approval for %1 Requested.';
        CancelApprovalRequestEventDescTxt: Label 'Approval request for %1 Cancelled.';
        ReleasedEventDescTxt: Label '%1 record has been released.';
    //"********************CREDIT MODULE**************************"
    procedure RunWorkflowOnSendLoanApplicationForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendLoanApplicationForApproval'));
    end;

    procedure RunWorkflowOnSendProductsManagementForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendProductsManagementForApproval'));
    end;

    procedure RunWorkflowOnSendLoanDisbursementForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendLoanDisbursementForApproval'));
    end;

    procedure RunWorkflowOnSendLoanRestructureForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendLoanRestructureForApproval'));
    end;

    procedure RunWorkflowOnSendCollateralApplicationForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendCollateralApplicationForApproval'));
    end;

    procedure RunWorkflowOnSendCollateralReleaseForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendCollateralReleaseForApproval'));
    end;

    procedure RunWorkflowOnSendMemberApplicationForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendMemberApplicationForApproval'));
    end;

    procedure RunWorkflowOnSendMemberEditingForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendMemberEditingForApproval'));
    end;

    procedure RunWorkflowOnSendPaymentVoucherForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendPaymentVoucherForApproval'));
    end;

    procedure RunWorkflowOnSendJournalVoucherForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendJournalVoucherForApproval'));
    end;

    procedure RunWorkflowOnSendTellerTransactionForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendTellerTransactionForApproval'));
    end;

    procedure RunWorkflowOnSendLienForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendLienForApproval'));
    end;

    procedure RunWorkflowOnSendStandingOrderForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendStandingOrderForApproval'));
    end;

    procedure RunWorkflowOnSendMemberFixedDepositForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendMemberFixedDepositForApproval'));
    end;

    procedure RunWorkflowOnSendBankersChequeForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendBankersChequeForApproval'));
    end;

    procedure RunWorkflowOnSendATMApplicationForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendATMApplicationForApproval'));
    end;

    procedure RunWorkflowOnSendMobileApplicationForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendMobileApplicationForApproval'));
    end;

    procedure RunWorkflowOnSendLoanBatchForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendLoanBatchForApproval'));
    end;

    procedure RunWorkflowOnSendMemberExitForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendMemberExitForApproval'));
    end;

    procedure RunWorkflowOnSendBenevolentFundForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendBenevolentFundForApproval'));
    end;

    procedure RunWorkflowOnSendGuarantorMgtForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendGuarantorMgtForApproval'));
    end;

    procedure RunWorkflowOnSendLoanRecoveryForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendLoanRecoveryForApproval'));
    end;

    procedure RunWorkflowOnSendMemberActivationForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendMemberActivationForApproval'));
    end;

    procedure RunWorkflowOnSendCheckOffForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendCheckOffForApproval'));
    end;

    procedure RunWorkflowOnSendChequeBookApplicationForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendChequeBookApplicationForApproval'));
    end;

    procedure RunWorkflowOnSendChequeBookTransactionForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendChequeBookTransactionForApproval'));
    end;

    procedure RunWorkflowOnSendInterAccountTransferForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendInterAccountTransferForApproval'));
    end;

    procedure RunWorkflowOnSendAccountOpeningForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendAccountOpeningForApproval'));
    end;

    procedure RunWorkflowOnSendMemberAccountMgmtForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendMemberAccountMgmtForApproval'));
    end;

    procedure RunWorkflowOnSendDividendHeaderForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendDividendHeaderForApproval'));
    end;

    procedure RunWorkflowOnSendReceiptForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendReceiptForApproval'));
    end;

    procedure RunWorkflowOnSendFOSATransactionForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendFOSATransactionForApproval'));
    end;

    procedure RunWorkflowOnSendChequeDepositForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendChequeDepositForApproval'));
    end;

    procedure RunWorkflowOnSendMoneyLaundaryCheckForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendMoneyLaundaryCheckForApproval'));
    end;

    procedure RunWorkflowOnSendShareFloatingForApprovalCode(): code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendShareFloatingForApproval'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendLoanApplicationForApproval', '', true, true)]
    procedure RunWorkflowOnSendLoanApplicationForApproval(var Loans: Record Loans)
    var
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendLoanApplicationForApprovalCode, Loans);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendProductsManagementForApproval', '', true, true)]
    procedure RunWorkflowOnSendProductsManagementForApproval(var ProductsManagement: Record "Products Management")
    var
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendProductsManagementForApprovalCode, ProductsManagement);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendLoanDisbursementForApproval', '', true, true)]
    procedure RunWorkflowOnSendLoanDisbursementForApproval(var LoanDisbursement: Record "Loan Disbursement")
    var
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendLoanDisbursementForApprovalCode, LoanDisbursement);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendLoanRestructureForApproval', '', true, true)]
    procedure RunWorkflowOnSendLoanRestructureForApproval(var LoanRestructure: Record "Loan Moratorium")
    var
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendLoanRestructureForApprovalCode, LoanRestructure);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendCollateralApplicationForApproval', '', true, true)]
    procedure RunWorkflowOnSendCollateralApplicationForApproval(var CollateralApplication: Record "Collateral Application")
    var
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendCollateralApplicationForApprovalCode, CollateralApplication);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendCollateralReleaseForApproval', '', true, true)]
    procedure RunWorkflowOnSendCollateralReleaseForApproval(var CollateralRelease: Record "Collateral Release")
    var
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendCollateralReleaseForApprovalCode, CollateralRelease);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendMemberApplicationForApproval', '', true, true)]
    procedure RunWorkflowOnSendMemberApplicationForApproval(var MemberApplication: Record "Member Application")
    var
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendMemberApplicationForApprovalCode, MemberApplication);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendMemberEditingForApproval', '', true, true)]
    procedure RunWorkflowOnSendMemberEditingForApproval(var MemberEditing: Record "Member Editing")
    var
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendMemberEditingForApprovalCode, MemberEditing);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendJournalVoucherForApproval', '', true, true)]
    procedure RunWorkflowOnSendJournalVoucherForApproval(var JournalVoucher: Record "Journal Voucher Header")
    var
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendJournalVoucherForApprovalCode, JournalVoucher);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendTellerTransactionForApproval', '', true, true)]
    procedure RunWorkflowOnSendTellerTransactionForApproval(var TellerTransaction: Record "Teller Transactions")
    var
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendTellerTransactionForApprovalCode, TellerTransaction);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendLienForApproval', '', true, true)]
    procedure RunWorkflowOnSendTellerLienForApproval(var Lien: Record Lien)
    var
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendLienForApprovalCode, Lien);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendStandingOrderForApproval', '', true, true)]
    procedure RunWorkflowOnSendStandingOrderForApproval(var StandingOrder: Record "Standing Order")
    var
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendStandingOrderForApprovalCode, StandingOrder);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendMemberFixedDepositForApproval', '', true, true)]
    procedure RunWorkflowOnSendMemberFixedDepositForApproval(var FixedDeposit: Record "Member Fixed Deposits")
    var
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendMemberFixedDepositForApprovalCode, FixedDeposit);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendBankersChequeForApproval', '', true, true)]
    procedure RunWorkflowOnSendBankersChequeForApproval(var BankersCheque: Record "Bankers Cheque")
    var
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendBankersChequeForApprovalCode, BankersCheque);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendATMApplicationForApproval', '', true, true)]
    procedure RunWorkflowOnSendATMApplicationForApproval(var ATMApplication: Record "ATM Application")
    var
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendATMApplicationForApprovalCode, ATMApplication);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendMobileApplicationForApproval', '', true, true)]
    procedure RunWorkflowOnSendMobileApplicationForApproval(var MobileApplication: Record "Mobile Application")
    var
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendMobileApplicationForApprovalCode, MobileApplication);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendLoanBatchForApproval', '', true, true)]
    procedure RunWorkflowOnSendLoanBatchForApproval(var LoanBatch: Record "Loan Batch Header")
    var
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendLoanBatchForApprovalCode, LoanBatch);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendMemberExitForApproval', '', true, true)]
    procedure RunWorkflowOnSendMemberExitForApproval(var MemberExit: Record "Member Withdrawal")
    var
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendMemberExitForApprovalCode, MemberExit);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendBenevolentFundForApproval', '', true, true)]
    procedure RunWorkflowOnSendBenevolentFundForApproval(var BenevolentFund: Record "Benevolent Fund")
    var
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendBenevolentFundForApprovalCode, BenevolentFund);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendGuarantorMgtForApproval', '', true, true)]
    procedure RunWorkflowOnSendGuarantorMgtForApproval(var GuarantorMgt: Record "Loan Security Mgmt")
    var
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendGuarantorMgtForApprovalCode, GuarantorMgt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendLoanRecoveryForApproval', '', true, true)]
    procedure RunWorkflowOnSendLoanRecoveryForApproval(var LoanRecovery: Record "Loan Recovery Header")
    var
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendLoanRecoveryForApprovalCode, LoanRecovery);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendMemberActivationForApproval', '', true, true)]
    procedure RunWorkflowOnSendMemberActivationForApproval(var MemberActivation: Record "Member Activations")
    var
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendMemberActivationForApprovalCode, MemberActivation);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendCheckOffForApproval', '', true, true)]
    procedure RunWorkflowOnCheckOffForApproval(CheckOff: Record "Checkoff Header");
    var
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendCheckOffForApprovalCode, CheckOff);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendChequeBookApplicationForApproval', '', true, true)]
    procedure RunWorkflowOnChequeBookApplicationForApproval(ChequeBookApplication: Record "Cheque Book Applications");
    var
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendChequeBookApplicationForApprovalCode, ChequeBookApplication);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendInterAccountTransferForApproval', '', true, true)]
    procedure RunWorkflowOnInterAccountTransferForApproval(InterAccountTransfer: Record "Inter Account Transfer");
    var
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendInterAccountTransferForApprovalCode, InterAccountTransfer);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendAccountOpeningForApproval', '', true, true)]
    procedure RunWorkflowOnAccountOpeningForApproval(AccountOpening: Record "Account Opening");
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendAccountOpeningForApprovalCode, AccountOpening);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendMemberAccountMgmtForApproval', '', true, true)]
    procedure RunWorkflowOnMemberAccountMgmtForApproval(MemberAccountMgmt: Record "Member Accounts Mgmt.");
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendMemberAccountMgmtForApprovalCode, MemberAccountMgmt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendDividendHeaderForApproval', '', true, true)]
    procedure RunWorkflowOnDividendHeaderForApproval(DividendHeader: Record "Dividend Header");
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendDividendHeaderForApprovalCode, DividendHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendFOSATransactionForApproval', '', true, true)]
    procedure RunWorkflowOnFOSATransactionForApproval(FOSATransaction: Record "FOSA Transactions");
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendFOSATransactionForApprovalCode, FOSATransaction);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendChequeDepositForApproval', '', true, true)]
    procedure RunWorkflowOnChequeDepositForApproval(ChequeDeposit: Record "Cheque Deposits");
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendChequeDepositForApprovalCode, ChequeDeposit);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendMoneyLaundaryCheckForApproval', '', true, true)]
    procedure RunWorkflowOnMoneyLaundaryCheckForApproval(MoneyLaundaryCheck: Record "Money Laundary Check");
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendMoneyLaundaryCheckForApprovalCode, MoneyLaundaryCheck);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnSendShareFloatingForApproval', '', true, true)]
    procedure RunWorkflowOnShareFloatingForApproval(ShareFloating: Record "Share Floating");
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnSendShareFloatingForApprovalCode, ShareFloating);
    end;

    procedure RunWorkflowOnCancelLoanApplicationApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelLoanApplicationForApproval'));
    end;

    procedure RunWorkflowOnCancelProductsManagementApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelProductsManagementForApproval'));
    end;

    procedure RunWorkflowOnCancelLoanDisbursementApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelLoanDisbursementForApproval'));
    end;

    procedure RunWorkflowOnCancelLoanRestructureApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelLoanRestructureForApproval'));
    end;

    procedure RunWorkflowOnCancelCollateralApplicationApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelCollateralApplicationForApproval'));
    end;

    procedure RunWorkflowOnCancelCollateralReleaseApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelCollateralReleaseForApproval'));
    end;

    procedure RunWorkflowOnCancelMemberApplicationApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelMemberApplicationForApproval'));
    end;

    procedure RunWorkflowOnCancelMemberEditingApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelMemberEditingForApproval'));
    end;

    procedure RunWorkflowOnCancelPaymentVoucherApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelPaymentVoucherForApproval'));
    end;

    procedure RunWorkflowOnCancelJournalVoucherApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelJournalVoucherForApproval'));
    end;

    procedure RunWorkflowOnCancelTellerTransactionApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelTellerTransactionForApproval'));
    end;

    procedure RunWorkflowOnCancelLienApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelLienForApproval'));
    end;

    procedure RunWorkflowOnCancelStandingOrderApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelStandingOrderForApproval'));
    end;

    procedure RunWorkflowOnCancelMemberFixedDepositApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelMemberFixedDepositForApproval'));
    end;

    procedure RunWorkflowOnCancelBankersChequeApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelBankersChequeForApproval'));
    end;

    procedure RunWorkflowOnCancelATMApplicationApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelATMApplicationForApproval'));
    end;

    procedure RunWorkflowOnCancelMobileApplicationApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelMobileApplicationForApproval'));
    end;

    procedure RunWorkflowOnCancelLoanBatchApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelLoanBatchForApproval'));
    end;

    procedure RunWorkflowOnCancelMemberExitApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelMemberExitForApproval'));
    end;

    procedure RunWorkflowOnCancelBenevolentFundApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelBenevolentFundForApproval'));
    end;

    procedure RunWorkflowOnCancelGuarantorMgtApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelGuarantorMgtForApproval'));
    end;

    procedure RunWorkflowOnCancelLoanRecoveryApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelLoanRecoveryForApproval'));
    end;

    procedure RunWorkflowOnCancelMemberActivationApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelMemberActivationForApproval'));
    end;

    procedure RunWorkflowOnCancelCheckOffApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelCheckOffForApproval'));
    end;

    procedure RunWorkflowOnCancelChequeBookApplicationApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelChequeBookApplicationForApproval'));
    end;

    procedure RunWorkflowOnCancelChequeBookTransactionApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelChequeBookTransactionForApproval'));
    end;

    procedure RunWorkflowOnCancelInterAccountTransferApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelInterAccountTransferForApproval'));
    end;

    procedure RunWorkflowOnCancelAccountOpeningApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelAccountOpeningForApproval'));
    end;

    procedure RunWorkflowOnCancelMemberAccountMgmtApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelMemberAccountMgmtForApproval'));
    end;

    procedure RunWorkflowOnCancelDividendHeaderApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelDividendHeaderForApproval'));
    end;

    procedure RunWorkflowOnCancelReceiptApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelReceiptForApproval'));
    end;

    procedure RunWorkflowOnCancelFOSATransactionApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelFOSATransactionForApproval'));
    end;

    procedure RunWorkflowOnCancelChequeDepositApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelChequeDepositForApproval'));
    end;

    procedure RunWorkflowOnCancelMoneyLaundaryCheckApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelMoneyLaundaryCheckForApproval'));
    end;

    procedure RunWorkflowOnCancelShareFloatingApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelShareFloatingForApproval'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelLoanApplicationForApproval', '', true, true)]
    procedure RunWorkflowOnCancelLoanApplicationForApproval(var Loans: Record Loans)
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelLoanApplicationApprovalCode, Loans);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelProductsManagementForApproval', '', true, true)]
    procedure RunWorkflowOnCancelProductsManagementForApproval(var ProductsManagement: Record "Products Management")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelProductsManagementApprovalCode, ProductsManagement);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelLoanDisbursementForApproval', '', true, true)]
    procedure RunWorkflowOnCancelLoanDisbursementForApproval(var LoanDisbursement: Record "Loan Disbursement")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelLoanDisbursementApprovalCode, LoanDisbursement);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelLoanRestructureForApproval', '', true, true)]
    procedure RunWorkflowOnCancelLoanRestructureForApproval(var LoanRestructure: Record "Loan Moratorium")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelLoanRestructureApprovalCode, LoanRestructure);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelCollateralApplicationForApproval', '', true, true)]
    procedure RunWorkflowOnCancelCollateralApplicationForApproval(var CollateralApplication: Record "Collateral Application")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelCollateralApplicationApprovalCode, CollateralApplication);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelCollateralReleaseForApproval', '', true, true)]
    procedure RunWorkflowOnCancelCollateralReleaseForApproval(var CollateralRelease: Record "Collateral Release")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelCollateralReleaseApprovalCode, CollateralRelease);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelMemberApplicationForApproval', '', true, true)]
    procedure RunWorkflowOnCancelMemberApplicationForApproval(var MemberApplication: Record "Member Application")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelMemberApplicationApprovalCode, MemberApplication);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelMemberEditingForApproval', '', true, true)]
    procedure RunWorkflowOnCancelMemberEditingForApproval(var MemberEditing: Record "Member Editing")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelMemberEditingApprovalCode, MemberEditing);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelJournalVoucherForApproval', '', true, true)]
    procedure RunWorkflowOnCancelJournalVoucherForApproval(var JournalVoucher: Record "Journal Voucher Header")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelJournalVoucherApprovalCode, JournalVoucher);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelTellerTransactionForApproval', '', true, true)]
    procedure RunWorkflowOnCancelTellerTransactionForApproval(var TellerTransaction: Record "Teller Transactions")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelTellerTransactionApprovalCode, TellerTransaction);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelLienForApproval', '', true, true)]
    procedure RunWorkflowOnCancelLienForApproval(var Lien: Record Lien)
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelLienApprovalCode, Lien);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelStandingOrderForApproval', '', true, true)]
    procedure RunWorkflowOnCancelStandingOrderForApproval(var StandingOrder: Record "Standing Order")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelStandingOrderApprovalCode, StandingOrder);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelMemberFixedDepositForApproval', '', true, true)]
    procedure RunWorkflowOnCancelMemberFixedDepositForApproval(var FixedDeposit: Record "Member Fixed Deposits")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelMemberFixedDepositApprovalCode, FixedDeposit);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelBankersChequeForApproval', '', true, true)]
    procedure RunWorkflowOnCancelBankersCheuqueForApproval(var BankersCheque: Record "Bankers Cheque")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelBankersChequeApprovalCode, BankersCheque);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelATMApplicationForApproval', '', true, true)]
    procedure RunWorkflowOnCancelATMApplicationForApproval(var ATMApplication: Record "ATM Application")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelATMApplicationApprovalCode, ATMApplication);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelMobileApplicationForApproval', '', true, true)]
    procedure RunWorkflowOnCancelMobileApplicationForApproval(var MobileApplication: Record "Mobile Application")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelMobileApplicationApprovalCode, MobileApplication);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelLoanBatchForApproval', '', true, true)]
    procedure RunWorkflowOnCancelLoanBatchForApproval(var LoanBatch: Record "Loan Batch Header")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelLoanBatchApprovalCode, LoanBatch);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelMemberExitForApproval', '', true, true)]
    procedure RunWorkflowOnCancelMemberExitForApproval(var MemberExit: Record "Member Withdrawal")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelMemberExitApprovalCode, MemberExit);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelBenevolentFundForApproval', '', true, true)]
    procedure RunWorkflowOnCancelBenevolentFundForApproval(var BenevolentFund: Record "Benevolent Fund")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelBenevolentFundApprovalCode, BenevolentFund);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelGuarantorMgtForApproval', '', true, true)]
    procedure RunWorkflowOnCancelGuarantorMgtForApproval(var GuarantorMgt: Record "Loan Security Mgmt")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelGuarantorMgtApprovalCode, GuarantorMgt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelLoanRecoveryForApproval', '', true, true)]
    procedure RunWorkflowOnCancelLoanRecoveryForApproval(var LoanRecovery: Record "Loan Recovery Header")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelLoanRecoveryApprovalCode, LoanRecovery);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelMemberActivationForApproval', '', true, true)]
    procedure RunWorkflowOnCancelMemberActivationForApproval(var MemberActivation: Record "Member Activations")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelMemberActivationApprovalCode, MemberActivation);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelCheckOffForApproval', '', true, true)]
    procedure RunWorkflowOnCancelCheckOffForApproval(var CheckOff: Record "Checkoff Header")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelCheckOffApprovalCode, CheckOff);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelChequeBookApplicationForApproval', '', true, true)]
    procedure RunWorkflowOnCancelChequeBookApplicationForApproval(var ChequeBookApplication: Record "Cheque Book Applications")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelChequeBookApplicationApprovalCode, ChequeBookApplication);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelInterAccountTransferForApproval', '', true, true)]
    procedure RunWorkflowOnCancelInterAccountTransferForApproval(var InterAccountTransfer: Record "Inter Account Transfer")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelInterAccountTransferApprovalCode, InterAccountTransfer);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelAccountOpeningForApproval', '', true, true)]
    procedure RunWorkflowOnCancelAccountOpeningForApproval(var AccountOpening: Record "Account Opening")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelAccountOpeningApprovalCode, AccountOpening);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelMemberAccountMgmtForApproval', '', true, true)]
    procedure RunWorkflowOnCancelMemberAccountMgmtForApproval(var MemberAccountMgmt: Record "Member Accounts Mgmt.")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelMemberAccountMgmtApprovalCode, MemberAccountMgmt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelDividendHeaderForApproval', '', true, true)]
    procedure RunWorkflowOnCancelDividendHeaderForApproval(var DividendHeader: Record "Dividend Header")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelDividendHeaderApprovalCode, DividendHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelFOSATransactionForApproval', '', true, true)]
    procedure RunWorkflowOnCancelFOSATransactionForApproval(var FOSATransaction: Record "FOSA Transactions")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelFOSATransactionApprovalCode, FOSATransaction);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelChequeDepositForApproval', '', true, true)]
    procedure RunWorkflowOnCancelChequeDepositForApproval(var ChequeDeposit: Record "Cheque Deposits")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelChequeDepositApprovalCode, ChequeDeposit);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelMoneyLaundaryCheckForApproval', '', true, true)]
    procedure RunWorkflowOnCancelMoneyLaundaryCheckForApproval(var MoneyLaundaryCheck: Record "Money Laundary Check")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelMoneyLaundaryCheckApprovalCode, MoneyLaundaryCheck);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt. CBS Ext", 'OnCancelShareFloatingForApproval', '', true, true)]
    procedure RunWorkflowOnCancelShareFloatingForApproval(var ShareFloating: Record "Share Floating")
    begin
        WorkFlowManagement.HandleEvent(RunWorkflowOnCancelShareFloatingApprovalCode, ShareFloating);
    end;
    //#endregion 
    //#region AddEventToLibrary
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', false, false)]
    procedure CreateEventsLibrary()
    begin
        //************************CREDIT MODULE***************************
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendLoanApplicationForApprovalCode, Database::Loans, StrSubstNo(SendForApprovalEventDescTxt, 'Loan Application'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelLoanApplicationApprovalCode, Database::Loans, StrSubstNo(CancelApprovalRequestEventDescTxt, 'Loan Application'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendProductsManagementForApprovalCode, Database::"Products Management", StrSubstNo(SendForApprovalEventDescTxt, 'Products Management'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelProductsManagementApprovalCode, Database::"Products Management", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Products Management'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendLoanDisbursementForApprovalCode, Database::"Loan Disbursement", StrSubstNo(SendForApprovalEventDescTxt, 'Loan Disbursement'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelLoanDisbursementApprovalCode, Database::"Loan Disbursement", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Loan Disbursement'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendLoanRestructureForApprovalCode, Database::"Loan Moratorium", StrSubstNo(SendForApprovalEventDescTxt, 'Loan Restructure'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelLoanRestructureApprovalCode, Database::"Loan Moratorium", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Loan Restructure'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendCollateralApplicationForApprovalCode, Database::"Collateral Application", StrSubstNo(SendForApprovalEventDescTxt, 'Collateral Application'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelCollateralApplicationApprovalCode, Database::"Collateral Application", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Collateral Application'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendCollateralReleaseForApprovalCode, Database::"Collateral Release", StrSubstNo(SendForApprovalEventDescTxt, 'Collateral Release'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelCollateralReleaseApprovalCode, Database::"Collateral Release", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Collateral Release'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendMemberApplicationForApprovalCode, Database::"Member Application", StrSubstNo(SendForApprovalEventDescTxt, 'Member Application'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelMemberApplicationApprovalCode, Database::"Member Application", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Member Application'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendMemberEditingForApprovalCode, Database::"Member Editing", StrSubstNo(SendForApprovalEventDescTxt, 'Member Update'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelMemberEditingApprovalCode, Database::"Member Editing", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Member Update'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendJournalVoucherForApprovalCode, Database::"Journal Voucher Header", StrSubstNo(SendForApprovalEventDescTxt, 'Journal Voucher Header'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelJournalVoucherApprovalCode, Database::"Journal Voucher Header", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Journal Voucher Header'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendTellerTransactionForApprovalCode, Database::"Teller Transactions", StrSubstNo(SendForApprovalEventDescTxt, 'Teller Transactions'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelTellerTransactionApprovalCode, Database::"Teller Transactions", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Teller Transactions'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendLienForApprovalCode, Database::Lien, StrSubstNo(SendForApprovalEventDescTxt, 'Lien'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelLienApprovalCode, Database::Lien, StrSubstNo(CancelApprovalRequestEventDescTxt, 'Lien'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendStandingOrderForApprovalCode, Database::"Standing Order", StrSubstNo(SendForApprovalEventDescTxt, 'Standing Order'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelStandingOrderApprovalCode, Database::"Standing Order", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Standing Order'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendMemberFixedDepositForApprovalCode, Database::"Member Fixed Deposits", StrSubstNo(SendForApprovalEventDescTxt, 'Fixed Deposit Register'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelMemberFixedDepositApprovalCode, Database::"Member Fixed Deposits", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Fixed Deposit Register'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendBankersChequeForApprovalCode, Database::"Bankers Cheque", StrSubstNo(SendForApprovalEventDescTxt, 'Bankers Cheque'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelBankersChequeApprovalCode, Database::"Bankers Cheque", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Bankers Cheque'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendATMApplicationForApprovalCode, Database::"ATM Application", StrSubstNo(SendForApprovalEventDescTxt, 'ATM Application'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelATMApplicationApprovalCode, Database::"ATM Application", StrSubstNo(CancelApprovalRequestEventDescTxt, 'ATM Application'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendMobileApplicationForApprovalCode, Database::"Mobile Application", StrSubstNo(SendForApprovalEventDescTxt, 'Mobile Application'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelMobileApplicationApprovalCode, Database::"Mobile Application", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Mobile Application'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendLoanBatchForApprovalCode, Database::"Loan Batch Header", StrSubstNo(SendForApprovalEventDescTxt, 'Loan Batch Header'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelLoanBatchApprovalCode, Database::"Loan Batch Header", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Loan Batch Header'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendMemberExitForApprovalCode, Database::"Member Withdrawal", StrSubstNo(SendForApprovalEventDescTxt, 'Member Exit Header'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelMemberExitApprovalCode, Database::"Member Withdrawal", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Member Exit Header'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendBenevolentFundForApprovalCode, Database::"Benevolent Fund", StrSubstNo(SendForApprovalEventDescTxt, 'Benevolent Fund'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelBenevolentFundApprovalCode, Database::"Benevolent Fund", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Benevolent Fund'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendGuarantorMgtForApprovalCode, Database::"Loan Security Mgmt", StrSubstNo(SendForApprovalEventDescTxt, 'Guarantor Header'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelGuarantorMgtApprovalCode, Database::"Loan Security Mgmt", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Guarantor Header'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendLoanRecoveryForApprovalCode, Database::"Loan Recovery Header", StrSubstNo(SendForApprovalEventDescTxt, 'Loan Recovery Header'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelLoanRecoveryApprovalCode, Database::"Loan Recovery Header", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Loan Recovery Header'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendMemberActivationForApprovalCode, Database::"Member Activations", StrSubstNo(SendForApprovalEventDescTxt, 'Member Activations'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelMemberActivationApprovalCode, Database::"Member Activations", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Member Activations'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendCheckOffForApprovalCode, Database::"Checkoff Header", StrSubstNo(SendForApprovalEventDescTxt, ' Checkoff Header'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelCheckOffApprovalCode, Database::"Checkoff Header", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Checkoff Header'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendChequeBookApplicationForApprovalCode, Database::"Cheque Book Applications", StrSubstNo(SendForApprovalEventDescTxt, 'Cheque Book Applications'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelChequeBookApplicationApprovalCode, Database::"Cheque Book Applications", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Cheque Book Applications'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendInterAccountTransferForApprovalCode, Database::"Inter Account Transfer", StrSubstNo(SendForApprovalEventDescTxt, 'Inter Account Transfer'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelInterAccountTransferApprovalCode, Database::"Inter Account Transfer", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Inter Account Transfer'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendAccountOpeningForApprovalCode, Database::"Account Opening", StrSubstNo(SendForApprovalEventDescTxt, 'Account Opening'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelAccountOpeningApprovalCode, Database::"Account Opening", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Account Opening'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendMemberAccountMgmtForApprovalCode, Database::"Member Accounts Mgmt.", StrSubstNo(SendForApprovalEventDescTxt, 'Member Account Activation/Deactivation'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelMemberAccountMgmtApprovalCode, Database::"Member Accounts Mgmt.", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Member Account Activation/Deactivation'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendDividendHeaderForApprovalCode, Database::"Dividend Header", StrSubstNo(SendForApprovalEventDescTxt, 'Dividend'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelDividendHeaderApprovalCode, Database::"Dividend Header", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Dividend'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendFOSATransactionForApprovalCode, Database::"FOSA Transactions", StrSubstNo(SendForApprovalEventDescTxt, 'FOSA Transactions'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelFOSATransactionApprovalCode, Database::"FOSA Transactions", StrSubstNo(CancelApprovalRequestEventDescTxt, 'FOSA Transactions'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendChequeDepositForApprovalCode, Database::"Cheque Deposits", StrSubstNo(SendForApprovalEventDescTxt, 'Cheque Deposit'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelChequeDepositApprovalCode, Database::"Cheque Deposits", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Cheque Deposit'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendMoneyLaundaryCheckForApprovalCode, Database::"Money Laundary Check", StrSubstNo(SendForApprovalEventDescTxt, 'Money Laundary Check'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelMoneyLaundaryCheckApprovalCode, Database::"Money Laundary Check", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Money Laundary Check'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendShareFloatingForApprovalCode, Database::"Share Floating", StrSubstNo(SendForApprovalEventDescTxt, 'Share Floating'), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelShareFloatingApprovalCode, Database::"Share Floating", StrSubstNo(CancelApprovalRequestEventDescTxt, 'Share Floating'), 0, false);
    end;
    //#endregion
    //#region AddEventPredecessor
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventPredecessorsToLibrary', '', false, false)]
    local procedure AddEventPredecessors(EventFunctionName: Code[128])
    begin
        case EventFunctionName of //****************CREDIT MODULE**************************
            RunWorkflowOnCancelLoanApplicationApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelLoanApplicationApprovalCode, RunWorkflowOnSendLoanApplicationForApprovalCode);
            RunWorkflowOnCancelProductsManagementApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelProductsManagementApprovalCode, RunWorkflowOnSendProductsManagementForApprovalCode);
            RunWorkflowOnCancelLoanDisbursementApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelLoanDisbursementApprovalCode, RunWorkflowOnSendLoanDisbursementForApprovalCode);
            RunWorkflowOnCancelLoanRestructureApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelLoanRestructureApprovalCode, RunWorkflowOnSendLoanRestructureForApprovalCode);
            RunWorkflowOnCancelCollateralApplicationApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelCollateralApplicationApprovalCode, RunWorkflowOnSendCollateralApplicationForApprovalCode);
            RunWorkflowOnCancelCollateralReleaseApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelCollateralReleaseApprovalCode, RunWorkflowOnSendCollateralReleaseForApprovalCode);
            RunWorkflowOnCancelMemberApplicationApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelMemberApplicationApprovalCode, RunWorkflowOnSendMemberApplicationForApprovalCode);
            RunWorkflowOnCancelMemberEditingApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelMemberEditingApprovalCode, RunWorkflowOnSendMemberEditingForApprovalCode);
            RunWorkflowOnCancelPaymentVoucherApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelPaymentVoucherApprovalCode, RunWorkflowOnSendPaymentVoucherForApprovalCode);
            RunWorkflowOnCancelJournalVoucherApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelJournalVoucherApprovalCode, RunWorkflowOnSendJournalVoucherForApprovalCode);
            RunWorkflowOnCancelTellerTransactionApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelTellerTransactionApprovalCode, RunWorkflowOnSendTellerTransactionForApprovalCode);
            RunWorkflowOnCancelLienApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelLienApprovalCode, RunWorkflowOnSendLienForApprovalCode);
            RunWorkflowOnCancelStandingOrderApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelStandingOrderApprovalCode, RunWorkflowOnSendStandingOrderForApprovalCode);
            RunWorkflowOnCancelMemberFixedDepositApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelMemberFixedDepositApprovalCode, RunWorkflowOnSendMemberFixedDepositForApprovalCode);
            RunWorkflowOnCancelBankersChequeApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelBankersChequeApprovalCode, RunWorkflowOnSendBankersChequeForApprovalCode);
            RunWorkflowOnCancelATMApplicationApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelATMApplicationApprovalCode, RunWorkflowOnSendATMApplicationForApprovalCode);
            RunWorkflowOnCancelMobileApplicationApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelMobileApplicationApprovalCode, RunWorkflowOnSendMobileApplicationForApprovalCode);
            RunWorkflowOnCancelLoanBatchApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelLoanBatchApprovalCode, RunWorkflowOnSendLoanBatchForApprovalCode);
            RunWorkflowOnCancelMemberExitApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelMemberExitApprovalCode, RunWorkflowOnSendMemberExitForApprovalCode);
            RunWorkflowOnCancelBenevolentFundApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelBenevolentFundApprovalCode, RunWorkflowOnSendBenevolentFundForApprovalCode);
            RunWorkflowOnCancelGuarantorMgtApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelGuarantorMgtApprovalCode, RunWorkflowOnSendGuarantorMgtForApprovalCode);
            RunWorkflowOnCancelLoanRecoveryApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelLoanRecoveryApprovalCode, RunWorkflowOnSendLoanRecoveryForApprovalCode);
            RunWorkflowOnCancelMemberActivationApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelMemberActivationApprovalCode, RunWorkflowOnSendMemberActivationForApprovalCode);
            RunWorkflowOnCancelCheckOffApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelCheckOffApprovalCode, RunWorkflowOnSendCheckOffForApprovalCode);
            RunWorkflowOnCancelChequeBookApplicationApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelChequeBookApplicationApprovalCode, RunWorkflowOnSendChequeBookApplicationForApprovalCode);
            RunWorkflowOnCancelChequeBookTransactionApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelChequeBookTransactionApprovalCode, RunWorkflowOnSendChequeBookTransactionForApprovalCode);
            RunWorkflowOnCancelInterAccountTransferApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelInterAccountTransferApprovalCode, RunWorkflowOnSendInterAccountTransferForApprovalCode);
            RunWorkflowOnCancelAccountOpeningApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelAccountOpeningApprovalCode, RunWorkflowOnSendAccountOpeningForApprovalCode);
            RunWorkflowOnCancelMemberAccountMgmtApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelMemberAccountMgmtApprovalCode, RunWorkflowOnSendMemberAccountMgmtForApprovalCode);
            RunWorkflowOnCancelDividendHeaderApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelDividendHeaderApprovalCode, RunWorkflowOnSendDividendHeaderForApprovalCode);
            RunWorkflowOnCancelReceiptApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelReceiptApprovalCode, RunWorkflowOnSendReceiptForApprovalCode);
            RunWorkflowOnCancelFOSATransactionApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelFOSATransactionApprovalCode, RunWorkflowOnSendFOSATransactionForApprovalCode);
            RunWorkflowOnCancelChequeDepositApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelChequeDepositApprovalCode, RunWorkflowOnSendChequeDepositForApprovalCode);
            RunWorkflowOnCancelMoneyLaundaryCheckApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelMoneyLaundaryCheckApprovalCode, RunWorkflowOnSendMoneyLaundaryCheckForApprovalCode);
            RunWorkflowOnCancelShareFloatingApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelShareFloatingApprovalCode, RunWorkflowOnSendShareFloatingForApprovalCode);
            WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode:
                begin
                    //****************CREDIT MODULE**************************
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendLoanApplicationForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendProductsManagementForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendLoanDisbursementForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendLoanRestructureForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendCollateralApplicationForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendCollateralReleaseForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendMemberApplicationForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendMemberEditingForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendPaymentVoucherForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendJournalVoucherForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendTellerTransactionForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendLienForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendStandingOrderForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendMemberFixedDepositForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendBankersChequeForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendATMApplicationForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendMobileApplicationForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendLoanBatchForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendMemberExitForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendBenevolentFundForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendGuarantorMgtForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendLoanRecoveryForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendMemberActivationForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendCheckOffForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendChequeBookApplicationForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendChequeBookTransactionForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendInterAccountTransferForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendAccountOpeningForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendMemberAccountMgmtForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendDividendHeaderForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendReceiptForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendFOSATransactionForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendChequeDepositForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendMoneyLaundaryCheckForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendShareFloatingForApprovalCode);
                end;
            WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode:
                begin
                    //****************CREDIT MODULE**************************
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendLoanApplicationForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendProductsManagementForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendLoanDisbursementForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendLoanRestructureForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendCollateralApplicationForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendCollateralReleaseForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendMemberApplicationForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendMemberEditingForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendPaymentVoucherForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendJournalVoucherForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendTellerTransactionForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendLienForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendStandingOrderForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendMemberFixedDepositForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendBankersChequeForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendATMApplicationForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendMobileApplicationForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendLoanBatchForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendMemberExitForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendBenevolentFundForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendGuarantorMgtForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendLoanRecoveryForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendMemberActivationForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendCheckOffForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendChequeBookApplicationForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendChequeBookTransactionForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendInterAccountTransferForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendAccountOpeningForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendMemberAccountMgmtForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendDividendHeaderForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendReceiptForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendFOSATransactionForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendChequeDepositForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendMoneyLaundaryCheckForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendShareFloatingForApprovalCode);
                end;
        end;
    end; //#endregion
}
