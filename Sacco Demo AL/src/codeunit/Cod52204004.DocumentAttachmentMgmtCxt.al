codeunit 52204004 "Document Attachment Mgmt Cxt"
{
    var
        RelatedAttachmentsFilterTxt: Label '%1|%2', Comment = '%1 = Source Table ID, %2 = Related Table ID', Locked = true;

    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Factbox", 'OnBeforeDrillDown', '', false, false)]
    local procedure DocumentAttachmentOnBeforeDrillDown(DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        //**********Credit**********
        Loans: Record Loans;
        ProductsManagement: Record "Products Management";
        LoanDisbursement: Record "Loan Disbursement";
        ChannelLoanApplication: Record "Channel Loan Application";
        CollateralApplication: Record "Collateral Application";
        CollateralRelease: Record "Collateral Release";
        Member: Record Members;
        MemberApplication: Record "Member Application";
        MemberUpdate: Record "Member Editing";
        JournalVoucher: Record "Journal Voucher Header";
        TellerTransaction: Record "Teller Transactions";
        Lien: Record Lien;
        StandingOrder: Record "Standing Order";
        FixedDepositRegister: Record "Member Fixed Deposits";
        BankersCheque: Record "Bankers Cheque";
        ATMApplication: Record "ATM Application";
        LoanBatch: Record "Loan Batch Header";
        MemberExit: Record "Member Withdrawal";
        BenevolentFund: Record "Benevolent Fund";
        GuarantorMgt: Record "Loan Security Mgmt";
        LoanRecovery: Record "Loan Recovery Header";
        MemberActivation: Record "Member Activations";
        CheckOff: Record "Checkoff Header";
        ChequeBookApplication: Record "Cheque Book Applications";
        InterAccountTransfer: Record "Inter Account Transfer";
        AccountOpening: Record "Account Opening";
        MemberAccMgmt: Record "Member Accounts Mgmt.";
        DividendHeader: Record "Dividend Header";
        MoneyLaundaryCheck: Record "Money Laundary Check";
        ShareFloating: Record "Share Floating";
        CustodialHeader: Record "Custodial Header";
    begin
        case DocumentAttachment."Table ID" of //**********Credit**********
            DATABASE::Loans:
                begin
                    RecRef.Open(DATABASE::Loans);
                    if Loans.Get(DocumentAttachment."No.") then RecRef.GetTable(Loans);
                end;
            DATABASE::"Products Management":
                begin
                    RecRef.Open(DATABASE::"Products Management");
                    if ProductsManagement.Get(DocumentAttachment."No.") then RecRef.GetTable(ProductsManagement);
                end;
            DATABASE::"Loan Disbursement":
                begin
                    RecRef.Open(DATABASE::"Loan Disbursement");
                    if LoanDisbursement.Get(DocumentAttachment."No.") then RecRef.GetTable(LoanDisbursement);
                end;
            DATABASE::"Channel Loan Application":
                begin
                    RecRef.Open(DATABASE::"Channel Loan Application");
                    if ChannelLoanApplication.Get(DocumentAttachment."No.") then RecRef.GetTable(ChannelLoanApplication);
                end;
            DATABASE::"Collateral Application":
                begin
                    RecRef.Open(DATABASE::"Collateral Application");
                    if CollateralApplication.Get(DocumentAttachment."No.") then RecRef.GetTable(CollateralApplication);
                end;
            DATABASE::"Collateral Release":
                begin
                    RecRef.Open(DATABASE::"Collateral Release");
                    if CollateralRelease.Get(DocumentAttachment."No.") then RecRef.GetTable(CollateralRelease);
                end;
            DATABASE::Members:
                begin
                    RecRef.Open(DATABASE::Members);
                    if Member.Get(DocumentAttachment."No.") then RecRef.GetTable(Member);
                end;
            DATABASE::"Member Application":
                begin
                    RecRef.Open(DATABASE::"Member Application");
                    if MemberApplication.Get(DocumentAttachment."No.") then RecRef.GetTable(MemberApplication);
                end;
            DATABASE::"Journal Voucher Header":
                begin
                    RecRef.Open(DATABASE::"Journal Voucher Header");
                    if JournalVoucher.Get(DocumentAttachment."No.") then RecRef.GetTable(JournalVoucher);
                end;
            DATABASE::"Teller Transactions":
                begin
                    RecRef.Open(DATABASE::"Teller Transactions");
                    if TellerTransaction.Get(DocumentAttachment."No.") then RecRef.GetTable(TellerTransaction);
                end;
            DATABASE::Lien:
                begin
                    RecRef.Open(DATABASE::Lien);
                    if Lien.Get(DocumentAttachment."No.") then RecRef.GetTable(Lien);
                end;
            DATABASE::"Standing Order":
                begin
                    RecRef.Open(DATABASE::"Standing Order");
                    if StandingOrder.Get(DocumentAttachment."No.") then RecRef.GetTable(StandingOrder);
                end;
            DATABASE::"Member Fixed Deposits":
                begin
                    RecRef.Open(DATABASE::"Member Fixed Deposits");
                    if FixedDepositRegister.Get(DocumentAttachment."No.") then RecRef.GetTable(FixedDepositRegister);
                end;
            DATABASE::"Bankers Cheque":
                begin
                    RecRef.Open(DATABASE::"Bankers Cheque");
                    if BankersCheque.Get(DocumentAttachment."No.") then RecRef.GetTable(BankersCheque);
                end;
            DATABASE::"ATM Application":
                begin
                    RecRef.Open(DATABASE::"ATM Application");
                    if ATMApplication.Get(DocumentAttachment."No.") then RecRef.GetTable(ATMApplication);
                end;
            DATABASE::"Loan Batch Header":
                begin
                    RecRef.Open(DATABASE::"Loan Batch Header");
                    if LoanBatch.Get(DocumentAttachment."No.") then RecRef.GetTable(LoanBatch);
                end;
            DATABASE::"Member Withdrawal":
                begin
                    RecRef.Open(DATABASE::"Member Withdrawal");
                    if MemberExit.Get(DocumentAttachment."No.") then RecRef.GetTable(MemberExit);
                end;
            DATABASE::"Benevolent Fund":
                begin
                    RecRef.Open(DATABASE::"Benevolent Fund");
                    if BenevolentFund.Get(DocumentAttachment."No.") then RecRef.GetTable(BenevolentFund);
                end;
            DATABASE::"Loan Security Mgmt":
                begin
                    RecRef.Open(DATABASE::"Loan Security Mgmt");
                    if GuarantorMgt.Get(DocumentAttachment."No.") then RecRef.GetTable(GuarantorMgt);
                end;
            DATABASE::"Loan Recovery Header":
                begin
                    RecRef.Open(DATABASE::"Loan Recovery Header");
                    if LoanRecovery.Get(DocumentAttachment."No.") then RecRef.GetTable(LoanRecovery);
                end;
            DATABASE::"Member Activations":
                begin
                    RecRef.Open(DATABASE::"Member Activations");
                    if MemberActivation.Get(DocumentAttachment."No.") then RecRef.GetTable(MemberActivation);
                end;
            DATABASE::"Checkoff Header":
                begin
                    RecRef.Open(DATABASE::"Checkoff Header");
                    if CheckOff.Get(DocumentAttachment."No.") then RecRef.GetTable(CheckOff);
                end;
            DATABASE::"Cheque Book Applications":
                begin
                    RecRef.Open(DATABASE::"Cheque Book Applications");
                    if ChequeBookApplication.Get(DocumentAttachment."No.") then RecRef.GetTable(ChequeBookApplication);
                end;
            DATABASE::"Inter Account Transfer":
                begin
                    RecRef.Open(DATABASE::"Inter Account Transfer");
                    if InterAccountTransfer.Get(DocumentAttachment."No.") then RecRef.GetTable(InterAccountTransfer);
                end;
            DATABASE::"Account Opening":
                begin
                    RecRef.Open(DATABASE::"Account Opening");
                    if AccountOpening.Get(DocumentAttachment."No.") then RecRef.GetTable(AccountOpening);
                end;
            DATABASE::"Member Accounts Mgmt.":
                begin
                    RecRef.Open(DATABASE::"Member Accounts Mgmt.");
                    if MemberAccMgmt.Get(DocumentAttachment."No.") then RecRef.GetTable(MemberAccMgmt);
                end;
            DATABASE::"Dividend Header":
                begin
                    RecRef.Open(DATABASE::"Dividend Header");
                    if DividendHeader.Get(DocumentAttachment."No.") then RecRef.GetTable(DividendHeader);
                end;
            DATABASE::"Money Laundary Check":
                begin
                    RecRef.Open(DATABASE::"Money Laundary Check");
                    if MoneyLaundaryCheck.Get(DocumentAttachment."No.") then RecRef.GetTable(MoneyLaundaryCheck);
                end;
            DATABASE::"Share Floating":
                begin
                    RecRef.Open(DATABASE::"Share Floating");
                    if ShareFloating.Get(DocumentAttachment."No.") then RecRef.GetTable(ShareFloating);
                end;
            DATABASE::"Custodial Header":
                begin
                    RecRef.Open(DATABASE::"Custodial Header");
                    if CustodialHeader.Get(DocumentAttachment."No.") then RecRef.GetTable(CustodialHeader);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Details", 'OnAfterOpenForRecRef', '', false, false)]
    local procedure DocumentAtachmentOnAfterOpenForRecRef(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        FieldRef: FieldRef;
        RecNo: Code[20];
        LineNo: Integer;
    begin
        case RecRef.Number of //**********Credit**********
            Database::Loans, Database::"Products Management", Database::"Loan Disbursement", Database::"Channel Loan Application", Database::"Collateral Application", Database::"Collateral Release", Database::Members, Database::"Member Application", Database::"Member Editing", Database::"Journal Voucher Header", Database::"Teller Transactions", Database::Lien, Database::"Standing Order", Database::"Member Fixed Deposits", Database::"Bankers Cheque", Database::"ATM Application", Database::"Loan Batch Header", Database::"Member Withdrawal", Database::"Benevolent Fund", Database::"Loan Security Mgmt", Database::"Loan Recovery Header", Database::"Member Activations", Database::"Checkoff Header", Database::"Cheque Book Applications", Database::"Inter Account Transfer", Database::"Account Opening", Database::"Member Accounts Mgmt.", Database::"Dividend Header", Database::"Money Laundary Check", Database::"Share Floating", Database::"Custodial Header":
                begin
                    FieldRef := RecRef.Field(1);
                    RecNo := FieldRef.Value;
                    DocumentAttachment.SetRange("No.", RecNo);
                end;
        end;
        case RecRef.Number of
            DATABASE::"Bank Acc. Reconciliation":
                begin
                    FieldRef := RecRef.Field(489);
                    RecNo := FieldRef.Value;
                    DocumentAttachment.SetRange("No.", RecNo);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Document Attachment", 'OnAfterInitFieldsFromRecRef', '', false, false)]
    local procedure DocAttachmentOnAfterInitFieldsFromRecRef(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        FieldRef: FieldRef;
        RecNo: Code[20];
        LineNo: Integer;
    begin
        DocumentAttachment.Validate("Table ID", RecRef.Number);
        case RecRef.Number of //**********Credit**********
            Database::Loans, Database::"Products Management", Database::"Loan Disbursement", Database::"Channel Loan Application", Database::"Collateral Application", Database::"Collateral Release", Database::Members, Database::"Member Application", Database::"Member Editing", Database::"Journal Voucher Header", Database::"Teller Transactions", Database::Lien, Database::"Standing Order", Database::"Member Fixed Deposits", Database::"Bankers Cheque", Database::"ATM Application", Database::"Loan Batch Header", Database::"Member Withdrawal", Database::"Benevolent Fund", Database::"Loan Security Mgmt", Database::"Loan Recovery Header", Database::"Member Activations", Database::"Checkoff Header", Database::"Cheque Book Applications", Database::"Inter Account Transfer", Database::"Account Opening", Database::"Member Accounts Mgmt.", Database::"Dividend Header", Database::"Money Laundary Check", Database::"Share Floating", Database::"Custodial Header":
                begin
                    FieldRef := RecRef.Field(1);
                    RecNo := FieldRef.Value;
                    DocumentAttachment.Validate("No.", RecNo);
                end;
        end;
    end;

    procedure PortalDocumentAttchment(RecordID: RecordID; Base64: Text; FileName: Text)
    var
        DocAttachment: Record "Document Attachment";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        RecNo: Code[20];
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        varInstream: InStream;
        varOutstream: OutStream;
    begin
        RecRef := RecordID.GetRecord;
        case RecRef.Number of //**********Credit**********
            Database::Loans, Database::"Products Management", Database::"Loan Disbursement", Database::"Channel Loan Application", Database::"Collateral Application", Database::"Collateral Release", Database::Members, Database::"Member Application", Database::"Member Editing", Database::"Journal Voucher Header", Database::"Teller Transactions", Database::Lien, Database::"Standing Order", Database::"Member Fixed Deposits", Database::"Bankers Cheque", Database::"ATM Application", Database::"Loan Batch Header", Database::"Member Withdrawal", Database::"Benevolent Fund", Database::"Loan Security Mgmt", Database::"Loan Recovery Header", Database::"Member Activations", Database::"Checkoff Header", Database::"Cheque Book Applications", Database::"Inter Account Transfer", Database::"Account Opening", Database::"Member Accounts Mgmt.", Database::"Dividend Header", Database::"Money Laundary Check", Database::"Share Floating", Database::"Custodial Header":
                begin
                    FieldRef := RecRef.Field(1);
                    RecNo := FieldRef.Value;
                end;
        end;
        TempBlob.CreateOutStream(varOutstream);
        TempBlob.CreateInStream(varInstream);
        Base64Convert.FromBase64(Base64, VarOutStream);
        DocAttachment.InitFieldsFromRecRef(RecRef);
        DocAttachment."Document Flow Sales" := RecRef.Number() = Database::"Sales Header";
        DocAttachment."Document Flow Purchase" := RecRef.Number() = Database::"Purchase Header";
        DocAttachment.SaveAttachmentFromStream(varInstream, RecRef, StrSubstNo('%1.pdf', FileName));
    end;


    procedure UploadToSharepoint(FromRecRef: RecordRef; Base64: Text; FileName: Text)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        PayLoad: Text;
        HttpClient: HttpClient;
        RequestHeaders: HttpHeaders;
        ResponseCode: Text;
        ResponseDocumentURL: Text;
        RequestContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        JObject: JsonObject;
        JToken: JsonToken;
        RequestUrl: Text;
        RecRef: RecordRef;
        FieldRef: FieldRef;
        RecNo: Code[20];
    begin
        RecRef := FromRecRef;

        case RecRef.Number of //**********Credit**********
            Database::Loans, Database::"Products Management", Database::"Loan Disbursement", Database::"Channel Loan Application", Database::"Collateral Application", Database::"Collateral Release", Database::Members, Database::"Member Application", Database::"Member Editing", Database::"Journal Voucher Header", Database::"Teller Transactions", Database::Lien, Database::"Standing Order", Database::"Member Fixed Deposits", Database::"Bankers Cheque", Database::"ATM Application", Database::"Loan Batch Header", Database::"Member Withdrawal", Database::"Benevolent Fund", Database::"Loan Security Mgmt", Database::"Loan Recovery Header", Database::"Member Activations", Database::"Checkoff Header", Database::"Cheque Book Applications", Database::"Inter Account Transfer", Database::"Account Opening", Database::"Member Accounts Mgmt.", Database::"Dividend Header", Database::"Money Laundary Check", Database::"Share Floating", Database::"Custodial Header":
                begin
                    FieldRef := RecRef.Field(1);
                    RecNo := FieldRef.Value;
                end;
        end;

        GeneralLedgerSetup.Get;
        GeneralLedgerSetup.TestField("EDMS Url");

        PayLoad := '{' + '"module":"' + Format(4) + '"' + ',' + '"recordId":"' + RecNo + '"' + ',' + '"documentName":"' + FileName + '"' + ',' + '"document":"' + Base64 + '"' + '}';
        RequestUrl := GeneralLedgerSetup."EDMS Url";

        RequestHeaders := HttpClient.DefaultRequestHeaders();
        RequestContent.WriteFrom(PayLoad);
        RequestContent.GetHeaders(RequestHeaders);

        RequestHeaders.Clear();
        RequestHeaders.Add('Content-Type', 'application/json');

        HttpClient.Post(RequestURL, RequestContent, ResponseMessage);

        ResponseMessage.Content().ReadAs(ResponseCode);
        JObject.ReadFrom(ResponseCode);

        if JObject.Get('code', JToken) then
            ResponseCode := JToken.AsValue().AsText();

        if ResponseCode = '200' then begin
            if JObject.Get('documentUrl', JToken) then begin
                ResponseDocumentURL := JToken.AsValue().AsText();
                if ResponseDocumentURL <> '' then
                    SharepointDocumentAttchment(FromRecRef, FileName, ResponseDocumentURL);
            end;
        end;
    end;

    procedure SharepointDocumentAttchment(RecRef: RecordRef; FileName: Text; SharepointLink: Text)
    var
        DocAttachment: Record "Document Attachment";
        FileExtension: Text;
        FileMgt: Codeunit "File Management";
    begin
        FileExtension := FileMgt.GetExtension(FileName);
        DocAttachment.InitFieldsFromRecRef(RecRef);
        DocAttachment."Document Flow Sales" := RecRef.Number() = Database::"Sales Header";
        DocAttachment."Document Flow Purchase" := RecRef.Number() = Database::"Purchase Header";
        DocAttachment."File Name" := FileName;
        DocAttachment.Validate("File Extension", FileExtension);
        DocAttachment."Sharepoint Link" := SharepointLink;
        DocAttachment."Attached Date" := CurrentDateTime;
        DocAttachment."Attached By" := UserSecurityId;
        DocAttachment.Insert;
    end;


    [EventSubscriber(ObjectType::Table, Database::"Document Attachment", 'OnBeforeSaveAttachmentFromStream', '', false, false)]

    local procedure OnBeforeSaveAttachmentFromStream(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef; var FileName: Text; var DocStream: InStream)
    begin
        Error('Kindly Upload to Sharepoint');
    end;
}
