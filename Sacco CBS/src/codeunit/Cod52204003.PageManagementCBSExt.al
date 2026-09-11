codeunit 52204003 "Page Management CBS Ext"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Management", 'OnAfterGetPageID', '', true, true)]
    local Procedure OnAfterGetPageID(RecordRef: RecordRef; var PageId: Integer)
    begin
        if PageId = 0 then PageId := GetConditionalCardPageID(RecordRef);
    end;

    local procedure GetConditionalCardPageID(RecordRef: RecordRef): Integer
    begin
        case RecordRef.Number of //***********************CREDIT MODULE***************************
            Database::Loans:
                exit(Page::Loan);
            DATABASE::"Products Management":
                exit(GetProductsManagementPageID(RecordRef));
            Database::"Loan Disbursement":
                exit(Page::"Loan Disbursement");
            Database::"Loan Moratorium":
                exit(Page::"Loan Moratorium");
            Database::"Collateral Application":
                exit(Page::"Collateral Application");
            Database::"Collateral Release":
                exit(Page::"Collateral Release");
            Database::"Member Application":
                exit(Page::"Member Application");
            Database::"Member Editing":
                exit(Page::"Member Editing");
            Database::"Journal Voucher Header":
                exit(Page::"Journal Voucher");
            Database::"Teller Transactions":
                exit(Page::"Teller Transaction");
            Database::Lien:
                exit(Page::Lien);
            Database::"Standing Order":
                exit(Page::"Standing Order");
            Database::"Member Fixed Deposits":
                exit(Page::"Member Fixed Deposit");
            Database::"Bankers Cheque":
                exit(Page::"Bankers Cheque");
            Database::"ATM Application":
                exit(Page::"ATM Application");
            Database::"Mobile Application":
                exit(Page::"Mobile Application");
            Database::"Loan Batch Header":
                exit(Page::"Loan Batch");
            Database::"Member Withdrawal":
                exit(GetMemberRefundWithdrawalPageID(RecordRef));
            Database::"Benevolent Fund":
                exit(Page::"Benevolent Fund");
            Database::"Loan Security Mgmt":
                exit(Page::"Loan Security Mgmt.");
            Database::"Loan Recovery Header":
                exit(Page::"Loan Recovery");
            Database::"Member Activations":
                exit(Page::"Member Activation");
            Database::"Checkoff Header":
                exit(GetCheckOffPageID(RecordRef));
            Database::"Cheque Book Applications":
                exit(Page::"Cheque Book Application");
            Database::"Inter Account Transfer":
                exit(Page::"Inter Account Transfer");
            Database::"Account Opening":
                exit(Page::"Account Opening");
            DATABASE::"Member Accounts Mgmt.":
                exit(GetMemberAccountMgmtPageID(RecordRef));
            DATABASE::"Dividend Header":
                exit(GetDividendPageID(RecordRef));
            DATABASE::"Sacco Products":
                exit(PAGE::"Sacco Product");
            DATABASE::"FOSA Transactions":
                exit(GetFOSATransactionPageID(RecordRef));
            DATABASE::"Cheque Deposits":
                exit(GetChequeDepositPageID(RecordRef));
            DATABASE::"Money Laundary Check":
                exit(Page::"Money Laundary Check");
            DATABASE::"Share Floating":
                exit(Page::"Floated Share");
        //
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Management", 'OnAfterGetPageID', '', true, true)]
    local procedure OnAfterGetListPageID(RecordRef: RecordRef; var PageId: Integer)
    begin
        if PageId = 0 then PageId := GetConditionalListPageID(RecordRef);
    end;

    local procedure GetConditionalListPageID(RecRef: RecordRef): Integer
    begin
        case RecRef.Number of
        end;
    end;

    local procedure GetFOSATransactionPageID(RecRef: RecordRef): Integer
    var
        FOSATRansaction: Record "FOSA Transactions";
    begin
        RecRef.SetTable(FOSATRansaction);
        case FOSATRansaction."Document Type" of
            FOSATRansaction."Document Type"::"Inter Teller Transfer":
                exit(PAGE::"Inter Teller Transfer");
            FOSATRansaction."Document Type"::"Receive From Bank":
                exit(PAGE::"Receive From Bank");
            FOSATRansaction."Document Type"::"Treasury Request":
                exit(Page::"Treasury Request");
            FOSATRansaction."Document Type"::"Treasury Return":
                exit(Page::"Treasury Return");
            FOSATRansaction."Document Type"::"Send to Bank":
                exit(Page::"Send To Bank");
        end;
    end;

    local procedure GetChequeDepositPageID(RecRef: RecordRef): Integer
    var
        ChequeDeposit: Record "Cheque Deposits";
    begin
        RecRef.SetTable(ChequeDeposit);
        case ChequeDeposit."Document Type" of
            ChequeDeposit."Document Type"::Deposit:
                exit(PAGE::"Cheque Deposit");
            ChequeDeposit."Document Type"::Clearance:
                exit(PAGE::"Cheque Clearance");
        end;
    end;

    local procedure GetMemberAccountMgmtPageID(RecRef: RecordRef): Integer
    var
        MemberAccountMgmt: Record "Member Accounts Mgmt.";
    begin
        RecRef.SetTable(MemberAccountMgmt);
        case MemberAccountMgmt."Document Type" of
            MemberAccountMgmt."Document Type"::Deactivation:
                exit(PAGE::"Member Account Deactivation");
            MemberAccountMgmt."Document Type"::Activation:
                exit(PAGE::"Member Account Activation");
        end;
    end;

    local procedure GetDividendPageID(RecRef: RecordRef): Integer
    var
        DividendHeader: Record "Dividend Header";
    begin
        RecRef.SetTable(DividendHeader);
        case DividendHeader."Document Type" of
            DividendHeader."Document Type"::BOSA:
                exit(PAGE::"BOSA Dividend");
            DividendHeader."Document Type"::FOSA:
                exit(PAGE::"FOSA Dividend");
        end;
    end;

    local procedure GetCheckOffPageID(RecRef: RecordRef): Integer
    var
        CheckoffHeader: Record "Checkoff Header";
    begin
        RecRef.SetTable(CheckoffHeader);
        case CheckoffHeader."Upload Type" of
            CheckoffHeader."Upload Type"::Checkoff:
                exit(PAGE::Checkoff);
            CheckoffHeader."Upload Type"::Salary:
                exit(PAGE::Salary);
        end;
    end;

    local procedure GetProductsManagementPageID(RecRef: RecordRef): Integer
    var
        ProductsManagement: Record "Products Management";
    begin
        RecRef.SetTable(ProductsManagement);
        case ProductsManagement."Document Type" of
            ProductsManagement."Document Type"::Application:
                exit(PAGE::"Product Appplication");
            ProductsManagement."Document Type"::Update:
                exit(PAGE::"Product Editing");
        end;
    end;

    local procedure GetMemberRefundWithdrawalPageID(RecRef: RecordRef): Integer
    var
        MemberWithdrawal: Record "Member Withdrawal";
    begin
        RecRef.SetTable(MemberWithdrawal);
        case MemberWithdrawal."Document Type" of
            MemberWithdrawal."Document Type"::Refund:
                exit(PAGE::"Member Refund");
            MemberWithdrawal."Document Type"::Withdrawal:
                exit(PAGE::"Member Exit");
        end;
    end;
}
