codeunit 52204000 "Approval Mgmt. CBS Ext"
{
    var
        ApprovalMgmt: Codeunit "Approvals Mgmt.";
        ApprovalEntry: Record "Approval Entry";
        UserSetup: Record "User Setup";
        NoWFUserGroupMembersErr: Label 'A Workflow User Group with at least one member must be set up.';
    //#region Approval Methods
    local procedure "*****************CREDIT MODULE*********************"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendLoanApplicationForApproval(var Loans: Record Loans)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendProductsManagementForApproval(var ProductsManagement: Record "Products Management")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendLoanDisbursementForApproval(var LoanDisbursement: Record "Loan Disbursement")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendLoanRestructureForApproval(var LoanRestructure: Record "Loan Moratorium")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendCollateralApplicationForApproval(var CollateralApplication: Record "Collateral Application")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendCollateralReleaseForApproval(var CollateralRelease: Record "Collateral Release")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendMemberApplicationForApproval(var MemberApplication: Record "Member Application")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendMemberEditingForApproval(var MemberEditing: Record "Member Editing")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendJournalVoucherForApproval(var JournalVoucher: Record "Journal Voucher Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendTellerTransactionForApproval(var TellerTransaction: Record "Teller Transactions")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendLienForApproval(var Lien: Record Lien)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendStandingOrderForApproval(var StandingOrder: Record "Standing Order")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendMemberFixedDepositForApproval(var FixedDeposit: Record "Member Fixed Deposits")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendBankersChequeForApproval(var BankersCheque: Record "Bankers Cheque")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendATMApplicationForApproval(var ATMApplication: Record "ATM Application")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendMobileApplicationForApproval(var MobileApplication: Record "Mobile Application")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendLoanBatchForApproval(var LoanBatch: Record "Loan Batch Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendMemberExitForApproval(var MemberExit: Record "Member Withdrawal")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendBenevolentFundForApproval(var BenevolentFund: Record "Benevolent Fund")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendGuarantorMgtForApproval(var GuarantorMgt: Record "Loan Security Mgmt")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendLoanRecoveryForApproval(var LoanRecovery: Record "Loan Recovery Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendMemberActivationForApproval(var MemberActivation: Record "Member Activations")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendCheckoffForApproval(var Checkoff: Record "Checkoff Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendChequeBookApplicationForApproval(var ChequeBookApplication: Record "Cheque Book Applications")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendInterAccountTransferForApproval(var InterAccountTransfer: Record "Inter Account Transfer")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendAccountOpeningForApproval(var AccountOpening: Record "Account Opening")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendMemberAccountMgmtForApproval(var MemberAccountMgmt: Record "Member Accounts Mgmt.")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendDividendHeaderForApproval(var DividendHeader: Record "Dividend Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendFOSATRansactionForApproval(var FOSATRansaction: Record "FOSA Transactions")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendChequeDepositForApproval(var ChequeDeposit: Record "Cheque Deposits")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendMoneyLaundaryCheckForApproval(var MoneyLaundaryCheck: Record "Money Laundary Check")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendShareFloatingForApproval(var ShareFloating: Record "Share Floating")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelLoanApplicationForApproval(var Loans: Record Loans)
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelProductsManagementForApproval(var ProductsManagement: Record "Products Management")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelLoanDisbursementForApproval(var LoanDisbursement: Record "Loan Disbursement")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelLoanRestructureForApproval(var LoanRestructure: Record "Loan Moratorium")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelCollateralApplicationForApproval(var CollateralApplication: Record "Collateral Application")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelCollateralReleaseForApproval(var CollateralRelease: Record "Collateral Release")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelMemberApplicationForApproval(var MemberApplication: Record "Member Application")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelMemberEditingForApproval(var MemberEditing: Record "Member Editing")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelJournalVoucherForApproval(var JournalVoucher: Record "Journal Voucher Header")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelTellerTransactionForApproval(var TellerTransaction: Record "Teller Transactions")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelLienForApproval(var Lien: Record Lien)
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelStandingOrderForApproval(var StandingOrder: Record "Standing Order")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelMemberFixedDepositForApproval(var FixedDeposit: Record "Member Fixed Deposits")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelBankersChequeForApproval(var BankersCheque: Record "Bankers Cheque")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelATMApplicationForApproval(var ATMApplication: Record "ATM Application")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelMobileApplicationForApproval(var MobileApplication: Record "Mobile Application")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelLoanBatchForApproval(var LoanBatch: Record "Loan Batch Header")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelMemberExitForApproval(var MemberExit: Record "Member Withdrawal")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelBenevolentFundForApproval(var BenevolentFund: Record "Benevolent Fund")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelGuarantorMgtForApproval(var GuarantorMgt: Record "Loan Security Mgmt")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelLoanRecoveryForApproval(var LoanRecovery: Record "Loan Recovery Header")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelMemberActivationForApproval(var MemberActivation: Record "Member Activations")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelCheckoffForApproval(var Checkoff: Record "Checkoff Header")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelChequeBookApplicationForApproval(var ChequeBookApplication: Record "Cheque Book Applications")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelInterAccountTransferForApproval(var InterAccountTransfer: Record "Inter Account Transfer")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelAccountOpeningForApproval(var AccountOpening: Record "Account Opening")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelMemberAccountMgmtForApproval(var MemberAccountMgmt: Record "Member Accounts Mgmt.")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelDividendHeaderForApproval(var DividendHeader: Record "Dividend Header")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelFOSATRansactionForApproval(var FOSATRansaction: Record "FOSA Transactions")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelChequeDepositForApproval(var ChequeDeposit: Record "Cheque Deposits")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelMoneyLaundaryCheckForApproval(var MoneyLaundaryCheck: Record "Money Laundary Check")
    begin
    end;

    [IntegrationEvent(False, false)]
    procedure OnCancelShareFloatingForApproval(var ShareFloating: Record "Share Floating")
    begin
    end;
    //#endregion
    //#region SetStatusToPending
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', true, true)]
    local procedure SetStatusToPendingApproval(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    var
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
        FixedDeposit: Record "Member Fixed Deposits";
        BankersCheque: Record "Bankers Cheque";
        MemberMgt: Codeunit "Member Management";
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
        FOSATRansaction: Record "FOSA Transactions";
        ChequeDeposit: Record "Cheque Deposits";
        MoneyLaundaryCheck: Record "Money Laundary Check";
        ShareFloating: Record "Share Floating";
    begin
        case RecRef.Number of //***********************CREDIT MODULE***************************
            Database::"Collateral Application":
                begin
                    RecRef.SetTable(CollateralApplication);
                    CollateralApplication.Validate(Status, CollateralApplication.Status::"Pending Approval");
                    CollateralApplication.Modify(true);
                    IsHandled := true;
                end;
            Database::"Collateral Release":
                begin
                    RecRef.SetTable(CollateralRelease);
                    CollateralRelease.Validate(Status, CollateralRelease.Status::"Pending Approval");
                    CollateralRelease.Modify(true);
                    IsHandled := true;
                end;
            Database::Loans:
                begin
                    RecRef.SetTable(Loans);
                    Loans.Validate(Status, Loans.Status::"Pending Approval");
                    Loans."Appraisal Commited" := true;
                    Loans.Modify(true);
                    IsHandled := true;
                end;
            Database::"Products Management":
                begin
                    RecRef.SetTable(ProductsManagement);
                    ProductsManagement.Validate(Status, ProductsManagement.Status::"Pending Approval");
                    ProductsManagement.Modify(true);
                    IsHandled := true;
                end;
            Database::"Loan Disbursement":
                begin
                    RecRef.SetTable(LoanDisbursement);
                    LoanDisbursement.Validate(Status, LoanDisbursement.Status::"Pending Approval");
                    LoanDisbursement.Modify(true);
                    IsHandled := true;
                end;
            Database::"Loan Moratorium":
                begin
                    RecRef.SetTable(LoanRestructure);
                    LoanRestructure.Validate(Status, LoanRestructure.Status::"Pending Approval");
                    LoanRestructure.Modify(true);
                    IsHandled := true;
                end;
            Database::"Member Application":
                begin
                    RecRef.SetTable(MemberApplication);
                    MemberApplication.Validate(Status, MemberApplication.Status::"Pending Approval");
                    MemberApplication.Modify(true);
                    IsHandled := true;
                end;
            Database::"Member Editing":
                begin
                    RecRef.SetTable(MemberEditing);
                    MemberEditing.Validate(Status, MemberEditing.Status::"Pending Approval");
                    MemberEditing.Modify(true);
                    IsHandled := true;
                end;
            Database::"Journal Voucher Header":
                begin
                    RecRef.SetTable(JournalVoucher);
                    JournalVoucher.Validate(Status, JournalVoucher.Status::"Pending Approval");
                    JournalVoucher.Modify(true);
                    IsHandled := true;
                end;
            Database::"Teller Transactions":
                begin
                    RecRef.SetTable(TellerTransaction);
                    TellerTransaction.Validate(Status, TellerTransaction.Status::"Pending Approval");
                    TellerTransaction.Modify(true);
                    IsHandled := true;
                end;
            Database::Lien:
                begin
                    RecRef.SetTable(Lien);
                    Lien.Validate(Status, Lien.Status::"Pending Approval");
                    Lien.Modify(true);
                    IsHandled := true;
                end;
            Database::"Standing Order":
                begin
                    RecRef.SetTable(StandingOrder);
                    StandingOrder.Validate(Status, StandingOrder.Status::"Pending Approval");
                    StandingOrder.Modify(true);
                    IsHandled := true;
                end;
            Database::"Member Fixed Deposits":
                begin
                    RecRef.SetTable(FixedDeposit);
                    FixedDeposit.Validate(Status, FixedDeposit.Status::"Pending Approval");
                    FixedDeposit.Modify(true);
                    IsHandled := true;
                end;
            Database::"Bankers Cheque":
                begin
                    RecRef.SetTable(BankersCheque);
                    BankersCheque.Validate(Status, BankersCheque.Status::"Pending Approval");
                    BankersCheque.Modify(true);
                    IsHandled := true;
                end;
            Database::"ATM Application":
                begin
                    RecRef.SetTable(ATMApplication);
                    ATMApplication.Validate(Status, ATMApplication.Status::"Pending Approval");
                    MemberMgt.CreateAtmLien(ATMApplication."No.");
                    ATMApplication.Modify(true);
                    IsHandled := true;
                end;
            Database::"Mobile Application":
                begin
                    RecRef.SetTable(MobileApplication);
                    MobileApplication.Validate(Status, MobileApplication.Status::"Pending Approval");
                    MobileApplication.Modify(true);
                    IsHandled := true;
                end;
            Database::"Loan Batch Header":
                begin
                    RecRef.SetTable(LoanBatch);
                    LoanBatch.Validate(Status, LoanBatch.Status::"Pending Approval");
                    LoanBatch.Modify(true);
                    IsHandled := true;
                end;
            Database::"Member Withdrawal":
                begin
                    RecRef.SetTable(MemberExit);
                    MemberExit.Validate(Status, MemberExit.Status::"Pending Approval");
                    MemberExit.Modify(true);
                    IsHandled := true;
                end;
            Database::"Benevolent Fund":
                begin
                    RecRef.SetTable(BenevolentFund);
                    BenevolentFund.Validate(Status, BenevolentFund.Status::"Pending Approval");
                    BenevolentFund.Modify(true);
                    IsHandled := true;
                end;
            Database::"Loan Security Mgmt":
                begin
                    RecRef.SetTable(GuarantorMgt);
                    GuarantorMgt.Validate(Status, GuarantorMgt.Status::"Pending Approval");
                    GuarantorMgt.Modify(true);
                    IsHandled := true;
                end;
            Database::"Loan Recovery Header":
                begin
                    RecRef.SetTable(LoanRecovery);
                    LoanRecovery.Validate(Status, LoanRecovery.Status::"Pending Approval");
                    LoanRecovery.Modify(true);
                    IsHandled := true;
                end;
            Database::"Member Activations":
                begin
                    RecRef.SetTable(MemberActivation);
                    MemberActivation.Validate(Status, MemberActivation.Status::"Pending Approval");
                    MemberActivation.Modify(true);
                    IsHandled := true;
                end;
            Database::"Checkoff Header":
                begin
                    RecRef.SetTable(Checkoff);
                    Checkoff.Validate(Status, Checkoff.Status::"Pending Approval");
                    Checkoff.Modify(true);
                    IsHandled := true;
                end;
            Database::"Cheque Book Applications":
                begin
                    RecRef.SetTable(ChequeBookApplication);
                    ChequeBookApplication.Validate(Status, ChequeBookApplication.Status::"Pending Approval");
                    ChequeBookApplication.Modify(true);
                    IsHandled := true;
                end;
            Database::"Inter Account Transfer":
                begin
                    RecRef.SetTable(InterAccountTransfer);
                    InterAccountTransfer.Validate(Status, InterAccountTransfer.Status::"Pending Approval");
                    InterAccountTransfer.Modify(true);
                    IsHandled := true;
                end;
            Database::"Account Opening":
                begin
                    RecRef.SetTable(AccountOpening);
                    AccountOpening.Validate(Status, AccountOpening.Status::"Pending Approval");
                    AccountOpening.Modify(true);
                    IsHandled := true;
                end;
            Database::"Member Accounts Mgmt.":
                begin
                    RecRef.SetTable(MemberAccountMgmt);
                    MemberAccountMgmt.Validate(Status, MemberAccountMgmt.Status::"Pending Approval");
                    MemberAccountMgmt.Modify(true);
                    IsHandled := true;
                end;
            Database::"Dividend Header":
                begin
                    RecRef.SetTable(DividendHeader);
                    DividendHeader.Validate(Status, DividendHeader.Status::"Pending Approval");
                    DividendHeader.Modify(true);
                    IsHandled := true;
                end;
            Database::"FOSA Transactions":
                begin
                    RecRef.SetTable(FOSATRansaction);
                    FOSATRansaction.Validate(Status, FOSATRansaction.Status::"Pending Approval");
                    FOSATRansaction.Modify(true);
                    IsHandled := true;
                end;
            Database::"Cheque Deposits":
                begin
                    RecRef.SetTable(ChequeDeposit);
                    ChequeDeposit.Validate(Status, ChequeDeposit.Status::"Pending Approval");
                    ChequeDeposit.Modify(true);
                    IsHandled := true;
                end;
            Database::"Money Laundary Check":
                begin
                    RecRef.SetTable(MoneyLaundaryCheck);
                    MoneyLaundaryCheck.Validate(Status, MoneyLaundaryCheck.Status::"Pending Approval");
                    MoneyLaundaryCheck.Modify(true);
                    IsHandled := true;
                end;
            Database::"Share Floating":
                begin
                    RecRef.SetTable(ShareFloating);
                    ShareFloating.Validate(Status, ShareFloating.Status::"Pending Approval");
                    ShareFloating.Modify(true);
                    IsHandled := true;
                end;
        end;
    end;
    //#endregion
    //#region PopulateApprovalEntryArgument
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', true, true)]
    local procedure PopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry")
    var
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
        FixedDeposit: Record "Member Fixed Deposits";
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
        FOSATRansaction: Record "FOSA Transactions";
        ChequeDeposit: Record "Cheque Deposits";
        MoneyLaundaryCheck: Record "Money Laundary Check";
        ShareFloating: Record "Share Floating";
    begin
        case RecRef.Number of //***********************CREDIT MODULE***************************
            Database::Loans:
                begin
                    RecRef.SetTable(Loans);
                    ApprovalEntryArgument."Document No." := Loans."No.";
                    ApprovalEntryArgument.Amount := Loans."Approved Amount";
                    ApprovalEntryArgument."Amount (LCY)" := Loans."Approved Amount";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            Database::"Products Management":
                begin
                    RecRef.SetTable(ProductsManagement);
                    ApprovalEntryArgument."Document No." := ProductsManagement."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            Database::"Loan Disbursement":
                begin
                    RecRef.SetTable(LoanDisbursement);
                    ApprovalEntryArgument."Document No." := LoanDisbursement."No.";
                    ApprovalEntryArgument.Amount := LoanDisbursement.Amount;
                    ApprovalEntryArgument."Amount (LCY)" := LoanDisbursement.Amount;
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            Database::"Loan Moratorium":
                begin
                    RecRef.SetTable(LoanRestructure);
                    ApprovalEntryArgument."Document No." := LoanRestructure."No.";
                    ApprovalEntryArgument.Amount := LoanRestructure."Current Principal Balance";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            Database::"Collateral Application":
                begin
                    RecRef.SetTable(CollateralApplication);
                    ApprovalEntryArgument.Amount := CollateralApplication."Collateral Value";
                    ApprovalEntryArgument."Document No." := CollateralApplication."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            Database::"Collateral Release":
                begin
                    RecRef.SetTable(CollateralRelease);
                    ApprovalEntryArgument."Document No." := CollateralRelease."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            Database::"Member Application":
                begin
                    RecRef.SetTable(MemberApplication);
                    ApprovalEntryArgument."Document No." := MemberApplication."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            Database::"Member Editing":
                begin
                    RecRef.SetTable(MemberEditing);
                    ApprovalEntryArgument."Document No." := MemberEditing."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            Database::"Journal Voucher Header":
                begin
                    RecRef.SetTable(JournalVoucher);
                    JournalVoucher.CalcFields("Total Debit");
                    ApprovalEntryArgument."Document No." := JournalVoucher."No.";
                    ApprovalEntryArgument.Amount := JournalVoucher."Total Debit";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            Database::"Teller Transactions":
                begin
                    RecRef.SetTable(TellerTransaction);
                    ApprovalEntryArgument."Document No." := TellerTransaction."No.";
                    ApprovalEntryArgument.Amount := TellerTransaction.Amount;
                    ApprovalEntryArgument."Amount (LCY)" := TellerTransaction.Amount;
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            Database::Lien:
                begin
                    RecRef.SetTable(Lien);
                    ApprovalEntryArgument."Document No." := Lien."No.";
                    ApprovalEntryArgument.Amount := Lien.Amount;
                    ApprovalEntryArgument."Amount (LCY)" := Lien.Amount;
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            Database::"Standing Order":
                begin
                    RecRef.SetTable(StandingOrder);
                    ApprovalEntryArgument."Document No." := StandingOrder."No.";
                    ApprovalEntryArgument.Amount := StandingOrder.Amount;
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            Database::"Member Fixed Deposits":
                begin
                    RecRef.SetTable(FixedDeposit);
                    ApprovalEntryArgument."Document No." := FixedDeposit."No.";
                    ApprovalEntryArgument.Amount := FixedDeposit.Amount;
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            Database::"Bankers Cheque":
                begin
                    RecRef.SetTable(BankersCheque);
                    ApprovalEntryArgument."Document No." := BankersCheque."No.";
                    ApprovalEntryArgument.Amount := BankersCheque.Amount;
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            Database::"ATM Application":
                begin
                    RecRef.SetTable(ATMApplication);
                    ApprovalEntryArgument."Document No." := ATMApplication."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            Database::"Mobile Application":
                begin
                    RecRef.SetTable(MobileApplication);
                    ApprovalEntryArgument."Document No." := MobileApplication."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            Database::"Loan Batch Header":
                begin
                    RecRef.SetTable(LoanBatch);
                    ApprovalEntryArgument."Document No." := LoanBatch."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            Database::"Member Withdrawal":
                begin
                    RecRef.SetTable(MemberExit);
                    ApprovalEntryArgument."Document No." := MemberExit."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            Database::"Benevolent Fund":
                begin
                    RecRef.SetTable(BenevolentFund);
                    ApprovalEntryArgument."Document No." := BenevolentFund."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            Database::"Loan Security Mgmt":
                begin
                    RecRef.SetTable(GuarantorMgt);
                    ApprovalEntryArgument."Document No." := GuarantorMgt."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            Database::"Loan Recovery Header":
                begin
                    RecRef.SetTable(LoanRecovery);
                    ApprovalEntryArgument."Document No." := LoanRecovery."No.";
                    ApprovalEntryArgument.Amount := LoanRecovery."Total Recoverable";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            Database::"Member Activations":
                begin
                    RecRef.SetTable(MemberActivation);
                    ApprovalEntryArgument."Document No." := MemberActivation."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            Database::"Checkoff Header":
                begin
                    RecRef.SetTable(CheckOff);
                    CheckOff.CalcFields("Calculated Amount");
                    ApprovalEntryArgument."Document No." := CheckOff."No.";
                    ApprovalEntryArgument.Amount := CheckOff."Calculated Amount";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            Database::"Cheque Book Applications":
                begin
                    RecRef.SetTable(ChequeBookApplication);
                    ApprovalEntryArgument."Document No." := ChequeBookApplication."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            Database::"Inter Account Transfer":
                begin
                    RecRef.SetTable(InterAccountTransfer);
                    ApprovalEntryArgument."Document No." := InterAccountTransfer."No.";
                    ApprovalEntryArgument.Amount := InterAccountTransfer.Amount;
                    ApprovalEntryArgument."Amount (LCY)" := InterAccountTransfer.Amount;
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            Database::"Account Opening":
                begin
                    RecRef.SetTable(AccountOpening);
                    ApprovalEntryArgument."Document No." := AccountOpening."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            Database::"Member Accounts Mgmt.":
                begin
                    RecRef.SetTable(MemberAccountMgmt);
                    ApprovalEntryArgument."Document No." := MemberAccountMgmt."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            Database::"Dividend Header":
                begin
                    RecRef.SetTable(DividendHeader);
                    ApprovalEntryArgument."Document No." := DividendHeader."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                end;
            Database::"FOSA Transactions":
                begin
                    RecRef.SetTable(FOSATRansaction);
                    ApprovalEntryArgument."Document No." := FOSATRansaction."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                    ApprovalEntryArgument.Amount := FOSATRansaction.Amount;
                    ApprovalEntryArgument."Amount (LCY)" := FOSATRansaction.Amount;
                end;
            Database::"Cheque Deposits":
                begin
                    RecRef.SetTable(ChequeDeposit);
                    ApprovalEntryArgument."Document No." := ChequeDeposit."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                    ApprovalEntryArgument.Amount := ChequeDeposit.Amount;
                    ApprovalEntryArgument."Amount (LCY)" := ChequeDeposit.Amount;
                end;
            Database::"Money Laundary Check":
                begin
                    RecRef.SetTable(MoneyLaundaryCheck);
                    ApprovalEntryArgument."Document No." := MoneyLaundaryCheck."No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                    ApprovalEntryArgument.Amount := MoneyLaundaryCheck."Applied Amount";
                    ApprovalEntryArgument."Amount (LCY)" := MoneyLaundaryCheck."Applied Amount";
                end;
            Database::"Share Floating":
                begin
                    RecRef.SetTable(ShareFloating);
                    ApprovalEntryArgument."Document No." := ShareFloating."Document No";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::Quote;
                    ApprovalEntryArgument.Amount := Round(ShareFloating."Par Value" * ShareFloating."Shares to Float");
                    ApprovalEntryArgument."Amount (LCY)" := Round(ShareFloating."Par Value" * ShareFloating."Shares to Float");
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
    procedure CheckCommentBeforeRejecting(RecordID: RecordID; DocNo: Code[20])
    begin
        ApprovalEntry.Reset;
        ApprovalEntry.SetRange("Table ID", RecordID.TableNo);
        ApprovalEntry.SetRange("Document No.", DocNo);
        ApprovalEntry.SetRange("Approver ID", UserId);
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        ApprovalEntry.SetRange(Comment, false);
        if ApprovalEntry.FindFirst then
            Error('Please comment first before rejecting');
    end;

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
        case TableId of
            Database::"Collateral Application":
                begin
                    CollateralApplication.Get(DocNo);
                    CollateralApplication.Status := CollateralApplication.Status::Approved;
                    CollateralApplication.Modify;
                end;
            Database::"Collateral Release":
                begin
                    CollateralRelease.Get(DocNo);
                    CollateralRelease.Status := CollateralRelease.Status::Approved;
                    CollateralRelease.Modify;
                end;
            Database::Loans:
                begin
                    Loans.Get(DocNo);
                    Loans.Status := Loans.Status::Approved;
                    Loans."Appraisal Commited" := true;
                    Loans.Modify;
                end;
            Database::"Products Management":
                begin
                    ProductsManagement.Get(DocNo);
                    ProductsManagement.Status := ProductsManagement.Status::Approved;
                    ProductsManagement.Modify;
                end;
            Database::"Loan Disbursement":
                begin
                    LoanDisbursement.Get(DocNo);
                    LoanDisbursement.Status := LoanDisbursement.Status::Approved;
                    LoanDisbursement.Modify;
                end;
            Database::"Loan Moratorium":
                begin
                    LoanRestructure.Get(DocNo);
                    LoanRestructure.Status := LoanRestructure.Status::Approved;
                    LoanRestructure.Modify;
                end;
            Database::"Member Application":
                begin
                    MemberApplication.Get(DocNo);
                    MemberApplication.Status := MemberApplication.Status::Approved;
                    MemberApplication.Modify;
                end;
            Database::"Member Editing":
                begin
                    MemberEditing.Get(DocNo);
                    MemberEditing.Status := MemberEditing.Status::Approved;
                    MemberEditing.Modify;
                end;
            Database::"Journal Voucher Header":
                begin
                    JournalVoucher.Get(DocNo);
                    JournalVoucher.Status := JournalVoucher.Status::Approved;
                    JournalVoucher.Modify;
                end;
            Database::"Teller Transactions":
                begin
                    TellerTransaction.Get(DocNo);
                    TellerTransaction.Status := TellerTransaction.Status::Approved;
                    TellerTransaction.Modify;
                end;
            Database::Lien:
                begin
                    Lien.Get(DocNo);
                    Lien.Status := Lien.Status::Approved;
                    Lien.Modify;
                end;
            Database::"Standing Order":
                begin
                    StandingOrder.Get(DocNo);
                    StandingOrder.Status := StandingOrder.Status::Approved;
                    StandingOrder.Running := true;
                    StandingOrder.Modify;
                end;
            Database::"Member Fixed Deposits":
                begin
                    FixedDepositRegister.Get(DocNo);
                    FixedDepositRegister.Status := FixedDepositRegister.Status::Approved;
                    FDManagement.ActivateFD(FixedDepositRegister);
                end;
            Database::"Bankers Cheque":
                begin
                    BankersCheque.Get(DocNo);
                    BankersCheque.Status := BankersCheque.Status::Approved;
                    BankersCheque.Modify;
                end;
            Database::"ATM Application":
                begin
                    ATMApplication.Get(DocNo);
                    ATMApplication.Status := ATMApplication.Status::Approved;
                    ATMApplication.Modify;
                end;
            Database::"Mobile Application":
                begin
                    MobileApplication.Get(DocNo);
                    MobileApplication.Status := MobileApplication.Status::Approved;
                    MobileApplication.Modify;
                end;
            Database::"Loan Batch Header":
                begin
                    LoanBatch.Get(DocNo);
                    LoanBatch.Status := LoanBatch.Status::Approved;
                    LoanBatch.Modify;
                end;
            Database::"Member Withdrawal":
                begin
                    MemberExit.Get(DocNo);
                    MemberExit.Status := MemberExit.Status::Approved;
                    MemberMgt.OnMemberExitApproval(MemberExit);
                    MemberExit.Modify;
                end;
            Database::"Benevolent Fund":
                begin
                    BenevolentFund.Get(DocNo);
                    BenevolentFund.Status := BenevolentFund.Status::Approved;
                    BenevolentFund.Modify;
                end;
            Database::"Loan Security Mgmt":
                begin
                    GuarantorMgt.Get(DocNo);
                    GuarantorMgt.Status := GuarantorMgt.Status::Approved;
                    GuarantorMgt.Modify;
                end;
            Database::"Loan Recovery Header":
                begin
                    LoanRecovery.Get(DocNo);
                    LoanRecovery.Status := LoanRecovery.Status::Approved;
                    LoanRecovery.Modify;
                end;
            Database::"Member Activations":
                begin
                    MemberActivation.Get(DocNo);
                    MemberActivation.Status := MemberActivation.Status::Approved;
                    MemberActivation.Modify;
                end;
            Database::"Checkoff Header":
                begin
                    Checkoff.Get(DocNo);
                    Checkoff.Status := Checkoff.Status::Approved;
                    Checkoff.Modify;
                end;
            Database::"Cheque Book Applications":
                begin
                    ChequeBookApplication.Get(DocNo);
                    ChequeBookApplication.Status := ChequeBookApplication.Status::Approved;
                    ChequeBookApplication.Modify;
                end;
            Database::"Inter Account Transfer":
                begin
                    InterAccountTransfer.Get(DocNo);
                    InterAccountTransfer.Status := InterAccountTransfer.Status::Approved;
                    InterAccountTransfer.Modify;
                end;
            Database::"Account Opening":
                begin
                    AccountOpening.Get(DocNo);
                    AccountOpening.Status := AccountOpening.Status::Approved;
                    AccountOpening.Processed := true;
                    AccountOpening.Modify;
                    AccountOpening."Account No." := MemberMgt.OpenAccounts(AccountOpening."No.");
                end;
            Database::"Member Accounts Mgmt.":
                begin
                    MemberAccountMgmt.Get(DocNo);
                    MemberAccountMgmt.Validate(Status, MemberAccountMgmt.Status::Approved);
                    MemberAccountMgmt.Modify;
                end;
            Database::"Dividend Header":
                begin
                    DividendHeader.Get(DocNo);
                    DividendHeader.Validate(Status, DividendHeader.Status::Approved);
                    DividendHeader.Modify;
                end;
            Database::"FOSA Transactions":
                begin
                    FOSATransaction.Reset();
                    FOSATransaction.SetRange("No.", DocNo);
                    if FOSATransaction.FindFirst() then begin
                        FOSATransaction.Validate(Status, FOSATransaction.Status::Approved);
                        FOSATransaction.CalcFields("Source Balance");
                        if FOSATransaction."Source Balance" < FOSATransaction.Amount then Error('You cannot Overdraw the Source Account');
                        FOSATransaction.Modify;
                    end;
                end;
            Database::"Cheque Deposits":
                begin
                    ChequeDeposit.Get(DocNo);
                    ChequeDeposit.Validate(Status, ChequeDeposit.Status::Approved);
                    ChequeDeposit.Modify;
                end;
            Database::"Money Laundary Check":
                begin
                    MoneyLaundaryCheck.Get(DocNo);
                    MoneyLaundaryCheck.Validate(Status, MoneyLaundaryCheck.Status::Approved);
                    MoneyLaundaryCheck.Modify;
                end;
            Database::"Share Floating":
                begin
                    ShareFloating.Get(DocNo);
                    ShareFloating.Validate(Status, ShareFloating.Status::Approved);
                    ShareFloating.Modify;
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
        case TableId of
            Database::"Collateral Application":
                begin
                    CollateralApplication.Get(DocNo);
                    CollateralApplication.Status := CollateralApplication.Status::Open;
                    CollateralApplication.Modify;
                end;
            Database::"Collateral Release":
                begin
                    CollateralRelease.Get(DocNo);
                    CollateralRelease.Status := CollateralRelease.Status::Open;
                    CollateralRelease.Modify;
                end;
            Database::Loans:
                begin
                    Loans.Get(DocNo);
                    Loans.Status := Loans.Status::Open;
                    Loans.Modify;
                end;
            Database::"Products Management":
                begin
                    ProductsManagement.Get(DocNo);
                    ProductsManagement.Status := ProductsManagement.Status::Open;
                    ProductsManagement.Modify;
                end;
            Database::"Loan Disbursement":
                begin
                    LoanDisbursement.Get(DocNo);
                    LoanDisbursement.Status := LoanDisbursement.Status::Open;
                    LoanDisbursement.Modify;
                end;
            Database::"Loan Moratorium":
                begin
                    LoanRestructure.Get(DocNo);
                    LoanRestructure.Status := LoanRestructure.Status::Open;
                    LoanRestructure.Modify;
                end;
            Database::"Member Application":
                begin
                    MemberApplication.Get(DocNo);
                    MemberApplication.Status := MemberApplication.Status::Open;
                    MemberApplication.Modify;
                end;
            Database::"Member Editing":
                begin
                    MemberEditing.Get(DocNo);
                    MemberEditing.Status := MemberEditing.Status::Open;
                    MemberEditing.Modify;
                end;
            Database::"Journal Voucher Header":
                begin
                    JournalVoucher.Get(DocNo);
                    JournalVoucher.Status := JournalVoucher.Status::Open;
                    JournalVoucher.Modify;
                end;
            Database::"Teller Transactions":
                begin
                    TellerTransaction.Get(DocNo);
                    TellerTransaction.Status := TellerTransaction.Status::Open;
                    TellerTransaction.Modify;
                end;
            Database::Lien:
                begin
                    Lien.Get(DocNo);
                    Lien.Status := Lien.Status::Open;
                    Lien.Modify;
                end;
            Database::"Standing Order":
                begin
                    StandingOrder.Get(DocNo);
                    StandingOrder.Status := StandingOrder.Status::Open;
                    StandingOrder.Modify;
                end;
            Database::"Member Fixed Deposits":
                begin
                    FixedDepositRegister.Get(DocNo);
                    FixedDepositRegister.Status := FixedDepositRegister.Status::Open;
                    FixedDepositRegister.Modify;
                end;
            Database::"Bankers Cheque":
                begin
                    BankersCheque.Get(DocNo);
                    BankersCheque.Status := BankersCheque.Status::Open;
                    BankersCheque.Modify;
                end;
            Database::"ATM Application":
                begin
                    ATMApplication.Get(DocNo);
                    ATMApplication.Status := ATMApplication.Status::Open;
                    MemberMgt.ReverseAtmLien(ATMApplication."No.");
                    ATMApplication.Modify;
                end;
            Database::"Mobile Application":
                begin
                    MobileApplication.Get(DocNo);
                    MobileApplication.Status := MobileApplication.Status::Open;
                    MemberMgt.ReverseAtmLien(MobileApplication."No.");
                    MobileApplication.Modify;
                end;
            Database::"Loan Batch Header":
                begin
                    LoanBatch.Get(DocNo);
                    LoanBatch.Status := LoanBatch.Status::Open;
                    LoanBatch.Modify;
                end;
            Database::"Member Withdrawal":
                begin
                    MemberExit.Get(DocNo);
                    MemberExit.Status := MemberExit.Status::Open;
                    MemberExit.Modify;
                end;
            Database::"Benevolent Fund":
                begin
                    BenevolentFund.Get(DocNo);
                    BenevolentFund.Status := BenevolentFund.Status::Open;
                    BenevolentFund.Modify;
                end;
            Database::"Loan Security Mgmt":
                begin
                    GuarantorMgt.Get(DocNo);
                    GuarantorMgt.Status := GuarantorMgt.Status::Open;
                    GuarantorMgt.Modify;
                end;
            Database::"Loan Recovery Header":
                begin
                    LoanRecovery.Get(DocNo);
                    LoanRecovery.Status := LoanRecovery.Status::Open;
                    LoanRecovery.Modify;
                end;
            Database::"Member Activations":
                begin
                    MemberActivation.Get(DocNo);
                    MemberActivation.Status := MemberActivation.Status::Open;
                    MemberActivation.Modify;
                end;
            Database::"Checkoff Header":
                begin
                    CheckOff.Get(DocNo);
                    CheckOff.Status := CheckOff.Status::Open;
                    CheckOff.Modify;
                end;
            Database::"Cheque Book Applications":
                begin
                    ChequeBookApplication.Get(DocNo);
                    ChequeBookApplication.Status := ChequeBookApplication.Status::Open;
                    ChequeBookApplication.Modify;
                end;
            Database::"Inter Account Transfer":
                begin
                    InterAccountTransfer.Get(DocNo);
                    InterAccountTransfer.Status := InterAccountTransfer.Status::Open;
                    InterAccountTransfer.Modify;
                end;
            Database::"Account Opening":
                begin
                    AccountOpening.Get(DocNo);
                    AccountOpening.Status := AccountOpening.Status::Open;
                    AccountOpening.Modify;
                end;
            Database::"Member Accounts Mgmt.":
                begin
                    MemberAccountMgmt.Get(DocNo);
                    MemberAccountMgmt.Validate(Status, MemberAccountMgmt.Status::Open);
                    MemberAccountMgmt.Modify;
                end;
            Database::"Dividend Header":
                begin
                    DividendHeader.Get(DocNo);
                    DividendHeader.Validate(Status, DividendHeader.Status::Open);
                    DividendHeader.Modify;
                end;
            Database::"FOSA Transactions":
                begin
                    FOSATransaction.Reset();
                    FOSATransaction.SetRange("No.", DocNo);
                    if FOSATransaction.FindFirst() then begin
                        FOSATransaction.Status := FOSATransaction.Status::Open;
                        FOSATransaction.Modify;
                    end;
                end;
            Database::"Cheque Deposits":
                begin
                    ChequeDeposit.Get(DocNo);
                    ChequeDeposit.Status := ChequeDeposit.Status::Open;
                    ChequeDeposit.Modify;
                end;
            Database::"Money Laundary Check":
                begin
                    MoneyLaundaryCheck.Get(DocNo);
                    MoneyLaundaryCheck.Status := MoneyLaundaryCheck.Status::Open;
                    MoneyLaundaryCheck.Modify;
                end;
            Database::"Share Floating":
                begin
                    ShareFloating.Get(DocNo);
                    ShareFloating.Status := ShareFloating.Status::Open;
                    ShareFloating.Modify;
                end;
        end;
    end;
    // procedure ShowApprovalNotification(DocumentNo: Code[20])
    // var
    //     MyNotification: Notification;
    // begin
    //     MyNotification.Message := StrSubstNo('Document %1 is waiting for your approval.', DocumentNo);
    //     MyNotification.Scope := NotificationScope::LocalScope;
    //     MyNotification.AddAction('Open Approvals', Codeunit::"Approvals Mgmt.", 'OpenApprovalEntriesPage');
    //     MyNotification.Send();
    // end;
}
