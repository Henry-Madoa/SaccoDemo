codeunit 52204024 "Coop B2B Integration"
{
    var
        JournalBatch, JournalTemplate : Code[20];
        JournalMgt: Codeunit "Journal Management";
        ProductPostingType: Enum "Product Posting Type";
        GlobalTransactionType: Enum "Sacco Transaction Type";
        GlobalAccountType: Enum "Gen. Journal Account Type";
        Dim1, Dim2 : Code[20];
    procedure SendAccountPaymentAdvice(var TransactionReferenceCode: Code[50]; var TransactionDate: DateTime; var TotalAmount: Decimal; var Currency: Code[10]; var DocumentReferenceNumber: Code[30]; var BankCode: Code[30]; var BranchCode: Code[30]; var PaymentDate: DateTime; var PaymentReferenceCode: Code[30]; var PaymentCode: Code[30]; var PaymentMode: Code[30]; var PaymentAmount: Decimal; var AccountNumber: Code[30]; var AccountName: Text[200]; var InstitutionCode: Code[30]; var InstitutionName: Text[200]; var AdditionalInfo: Text[200]; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        B2BTransactions: Record "B2B Transactions";
        EntryNo: Integer;
    begin
        ClearResponses(ResponseCode, ResponseMessage);
        B2BTransactions.LockTable();
        B2BTransactions.RESET;
        if B2BTransactions.FINDLAST then
            EntryNo := B2BTransactions."Entry No" + 1
        else
            EntryNo := 1;
        B2BTransactions.RESET;
        B2BTransactions.SETRANGE("Transaction Refrence", TransactionReferenceCode);
        if B2BTransactions.ISEMPTY then begin
            B2BTransactions.INIT;
            B2BTransactions."Entry No" := EntryNo;
            B2BTransactions."Source Code" := 'COOP';
            B2BTransactions."Transaction Refrence" := TransactionReferenceCode;
            B2BTransactions."Transaction Date" := TransactionDate;
            B2BTransactions."Total Amount" := TotalAmount;
            B2BTransactions.Currency := Currency;
            B2BTransactions."Document Refrence" := DocumentReferenceNumber;
            B2BTransactions."Bank Code" := BankCode;
            B2BTransactions."Branch Code" := BranchCode;
            B2BTransactions."Payment Date" := PaymentDate;
            B2BTransactions."Payment Refrence Code" := PaymentReferenceCode;
            B2BTransactions."Payment Code" := PaymentCode;
            B2BTransactions."Payment Mode" := PaymentMode;
            B2BTransactions."Payment Amount" := PaymentAmount;
            B2BTransactions."Account Number" := AccountNumber;
            B2BTransactions."Account Name" := AccountName;
            B2BTransactions."Institution Code" := InstitutionCode;
            B2BTransactions."Institution Name" := InstitutionName;
            B2BTransactions."Additional Info" := AdditionalInfo;
            if B2BTransactions.Insert() then begin
                ResponseCode := '00';
                ResponseMessage.AddText('{"Message":"TransactionReceived Successfully"}');
            end;
        end
        else begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Transaction Could Not Be Received"}');
        end;
    end;

    procedure getAccountValidation(var TransactionReferenceCode: Code[50]; var TransactionDate: DateTime; var AccountNumber: Code[20]; var AccountName: Text; var InstitutionCode: Code[20]; var InstitutionName: Text; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        Member: Record Members;
        MemberNo: Code[20];
    begin
        MemberNo := '';
        if InstitutionCode = '' then InstitutionCode := 'BSSL';
        if InstitutionName = '' then InstitutionName := 'Kenya Police Investment COOP';
        if TransactionReferenceCode <> '' then begin
            Member.RESET;
            Member.SETRANGE("No.", TransactionReferenceCode);
            if Member.FINDFIRST then
                MemberNo := Member."No."
            else begin
                Member.RESET;
                Member.SETRANGE("Identification No.", TransactionReferenceCode);
                if Member.FINDFIRST then
                    MemberNo := Member."No."
                else begin
                    Member.RESET;
                    Member.SETRANGE("Mobile Transacting No", TransactionReferenceCode);
                    if Member.FINDFIRST then MemberNo := Member."No.";
                end;
            end;
        end;
        if MemberNo <> '' then begin
            if Member.GET(MemberNo) then begin
                AccountNumber := MemberNo;
                AccountName := Member."Full Name";
                ResponseCode := '00';
                ResponseMessage.AddText('{"AccountNo":"' + Member."No." + '","AccountName":"' + Member."Full Name" + '","IDNo":"' + Member."Identification No." + '","PhoneNo":"' + Member."Mobile Transacting No" + '"}');
            end
            else begin
                ResponseCode := '01';
                ResponseMessage.AddText('{"Error":"Member does not exist"}');
            end;
        end
        else begin
            AccountNumber := '';
            AccountName := '';
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"Member does not exist"}');
        end;
    end;

    procedure ClearResponses(var ResponseCode: Code[20]; var ResponseMessage: BigText)
    begin
        Clear(ResponseCode);
        Clear(ResponseMessage);
    end;
    //Ipn Transactions
    procedure PostIPNTransactions()
    var
        IPNNotifications: Record "CBS Event Notifications";
        PayToFosaNo, MemberNo, FOSAAccount, DebitAccount, PostToAccount, DocumentNo, SourceCode, ReasonCode, ExternalDocumentNo : Code[25];
        Members: Record Members;
        Vendor: Record Vendor;
        MemberMgt: Codeunit "Member Management";
        PostingAmount: Decimal;
        PostingDate: Date;
        PostingDescription: Text;
        BankLedger: Record "Bank Account Ledger Entry";
        BankAccount: Record "Bank Account";
        SMSSource: Code[20];
        SMSText, SMSNo : Text;
        SMSMgt: Codeunit "Notifications Management";
        LineNo: Integer;
    begin
        JournalBatch := 'COOP-IPN';
        JournalTemplate := 'PAYMENT';
        LineNo := JournalMgt.PrepareJournal(JournalTemplate, JournalBatch);
        IPNNotifications.Reset();
        IPNNotifications.SetRange(Posted, false);
        IPNNotifications.SetRange("Event Type", 'CREDIT');
        if IPNNotifications.FindSet() then begin
            repeat
                PayToFosaNo := CopyStr(IPNNotifications."Cust. Memo Line1", 1, StrPos(IPNNotifications."Cust. Memo Line1", ' '));
                FOSAAccount := CopyStr(PayToFosaNo, 5, StrLen(PayToFosaNo));
                Vendor.Reset();
                Vendor.SetRange("No.", FOSAAccount);
                if Vendor.FindFirst() then begin
                    PostToAccount := Vendor."No.";
                    MemberNo := Vendor."Member No.";
                end
                else begin
                    Members.Reset();
                    Members.SetRange("Identification No.", FOSAAccount);
                    if Members.FindFirst() then begin
                        MemberNo := Members."No.";
                        PostToAccount := MemberMgt.GetMemberAccount(MemberNo, ProductPostingType::"Withdrawable Deposit");
                    end
                    else begin
                        Members.Reset();
                        Members.SetRange("No.", FOSAAccount);
                        if Members.FindFirst() then begin
                            MemberNo := Members."No.";
                            PostToAccount := MemberMgt.GetMemberAccount(MemberNo, ProductPostingType::"Withdrawable Deposit");
                        end;
                    end;
                end;
                if Members.get(MemberNo) then begin
                    SMSNo := Members."Mobile Phone No.";
                    SMSText := 'Dear ' + Members."First Name" + ' KSHS. ' + Format(IPNNotifications.Amount) + ' has been credited to your FOSA Account No. ' + FOSAAccount + ' on ' + Format(Today) + ' at ' + Format(Time);
                    SMSSource := 'PAY_TO_FOSA';
                end;
                BankAccount.Reset();
                BankAccount.SetRange(IBAN, IPNNotifications."Account No.");
                if BankAccount.FindFirst() then DebitAccount := BankAccount."No.";
                if Vendor.get(PostToAccount) then begin
                    DocumentNo := '';
                    SourceCode := 'IPN';
                    ReasonCode := 'COOP';
                    ExternalDocumentNo := IPNNotifications."Transaction Id";
                    DocumentNo := IPNNotifications."Payment Ref.";
                    PostingAmount := 0;
                    PostingAmount := IPNNotifications.Amount;
                    PostingDate := DT2Date(IPNNotifications."Transaction Date");
                    PostingDescription := CopyStr('Pay To Fosa ' + IPNNotifications."Cust. Memo Line2", 1, 50);
                    BankLedger.Reset();
                    BankLedger.SetRange(Reversed, false);
                    BankLedger.SetRange("Document No.", DocumentNo);
                    if BankLedger.FindFirst() then begin
                        IPNNotifications.Posted := true;
                        IPNNotifications."Posted On" := CurrentDateTime;
                        IPNNotifications.Modify();
                    end
                    else begin
                        if ((PostToAccount <> '') and (DebitAccount <> '')) then begin
                            LineNo := JournalMgt.CreateJournalLine(GlobalAccountType::Vendor, PostToAccount, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Cash Deposit", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, Journalbatch);
                            LineNo := JournalMgt.CreateJournalLine(GlobalAccountType::"Bank Account", DebitAccount, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Cash Deposit", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, Journalbatch);
                            JournalMgt.CompletePosting(JournalTemplate, JournalBatch);
                            IPNNotifications.Posted := true;
                            IPNNotifications."Posted On" := CurrentDateTime;
                            IPNNotifications.Modify();
                            SMSMgt.SendSms(SMSNo, SMSText, SMSSource);
                        end;
                    end;
                end;
            until IPNNotifications.Next() = 0;
        end;
    end;

    procedure PostCoopB2BTransaction()
    var
        CoopB2BTransaction: Record "B2B Transactions";
        DRAccount, CRAccount, MemberNo, DocumentNo, SourceCode, ReasonCode, ExternalDocumentNo : Code[20];
        PostingDate: Date;
        PostingDescription: Text;
        PostingAmount: Decimal;
        Posted: Boolean;
        SMSText, SMSNo : text;
        SMSSource: Code[20];
        SMSMgt: Codeunit "Notifications Management";
        Members: Record Members;
        LineNo: Integer;
        Vendor: Record Vendor;
    begin
        JournalBatch := 'COOP-B2B';
        JournalTemplate := 'PAYMENT';
        LineNo := JournalMgt.PrepareJournal(JournalTemplate, JournalBatch);
        CoopB2BTransaction.Reset();
        CoopB2BTransaction.SetRange(Processed, false);
        CoopB2BTransaction.SetRange("Source Code", 'COOP');
        if CoopB2BTransaction.FindSet() then begin
            repeat
                DocumentNo := '';
                SourceCode := 'B2B';
                ReasonCode := 'COOP';
                if Vendor.Get(CoopB2BTransaction."Account Number") then begin
                    MemberNo := Vendor."Member No.";
                    ExternalDocumentNo := CoopB2BTransaction."Payment Refrence Code";
                    DocumentNo := CoopB2BTransaction."Document Refrence";
                    PostingAmount := 0;
                    PostingAmount := CoopB2BTransaction."Payment Amount";
                    PostingDate := DT2DATE(CoopB2BTransaction."Transaction Date");
                    PostingDescription := CoopB2BTransaction."Document Refrence" + ' B2B Deposit';
                    CRAccount := CoopB2BTransaction."Account Number";
                    GetCoopAccounts(CoopB2BTransaction."Account Number", CoopB2BTransaction."Institution Code", CoopB2BTransaction."Payment Refrence Code", MemberNo, DRAccount, CRAccount, Posted);
                    if Posted then begin
                        CoopB2BTransaction.Processed := True;
                        CoopB2BTransaction.Modify();
                    end
                    else begin
                        if ((DRAccount <> '') and (CRAccount <> '')) then begin
                            LineNo := JournalMgt.CreateJournalLine(GlobalAccountType::Vendor, CRAccount, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Cash Deposit", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, Journalbatch);
                            LineNo := JournalMgt.CreateJournalLine(GlobalAccountType::"Bank Account", DRAccount, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Cash Deposit", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, Journalbatch);
                            JournalMgt.CompletePosting(JournalTemplate, JournalBatch);
                            CoopB2BTransaction.Processed := True;
                            CoopB2BTransaction.Modify();
                            if Members.get(MemberNo) then begin
                                SMSNo := Members."Mobile Phone No.";
                                SMSText := 'Dear ' + Members."First Name" + ' KSHS. ' + Format(CoopB2BTransaction."Payment Amount") + ' has been credited to your FOSA Account No. ' + CRAccount + ' on ' + Format(Today) + ' at ' + Format(Time);
                                SMSSource := 'COOP_B2B';
                            end;
                        end;
                    end;
                end;
            until CoopB2BTransaction.Next() = 0;
        end;
    end;

    local procedure GetCoopAccounts(RefrenceCode: Code[20]; InstitutionCode: Code[20]; DocumentNo: Code[20]; var MemberNo: Code[20]; var DebitAccount: Code[20]; var CreditAccount: Code[20]; var Posted: Boolean)
    var
        Members: Record Members;
        MemberMgt: Codeunit "Member Management";
        BankAccount: Record "Bank Account";
        GLEntry: Record "G/L Entry";
        Vendor: Record Vendor;
    begin
        Posted := false;
        GLEntry.Reset();
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange(Reversed, false);
        if GLEntry.FindFirst() then Posted := true;

        Members.Reset();
        Members.SetRange("Identification No.", RefrenceCode);
        if Members.FindLast() then begin
            MemberNo := Members."No.";
            CreditAccount := MemberMgt.GetMemberAccount(MemberNo, ProductPostingType::"Withdrawable Deposit");
        end else begin
            Members.Reset();
            Members.SetRange("No.", RefrenceCode);
            if Members.FindLast() then begin
                MemberNo := Members."No.";
                CreditAccount := MemberMgt.GetMemberAccount(MemberNo, ProductPostingType::"Withdrawable Deposit");
            end else begin
                Vendor.Reset();
                Vendor.SetRange("No.", RefrenceCode);
                if Vendor.FindFirst() then begin
                    MemberNo := Vendor."Member No.";
                    CreditAccount := Vendor."No.";
                end;
            end;
        end;

        BankAccount.Reset();
        BankAccount.SetRange("Transit No.", InstitutionCode);
        if BankAccount.FindFirst() then
            DebitAccount := BankAccount."No.";
    end;
}
