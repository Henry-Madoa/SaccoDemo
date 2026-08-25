codeunit 52204025 "ATM Integration"
{
    var
        Vendor: Record Vendor;
        Member: Record Members;
        GlobalAccountType: Enum "Gen. Journal Account Type";
        GlobalTransactionType: Enum "Sacco Transaction Type";
        CompanyInformation: Record "Company Information";
        ChannelIntegrations: Codeunit "Channels Integrations";
        ProductPostingType: Enum "Product Posting Type";
        JournalManagement: Codeunit "Journal Management";
        GLEntry: Record "G/L Entry";

    local procedure GetSettlmentAccount(CardNo: code[50]) SettlementAccount: code[20]
    var
        ATMCards: Record "ATM Cards";
        ATMTypes: Record "ATM Types";
        SaccoSetup: Record "General Ledger Setup";
    begin
        ATMCards.RESET;
        ATMCards.SETRANGE("Card No.", CardNo);
        if ATMCards.FINDFIRST then begin
            if ATMTypes.GET(ATMCards."ATM Type") then begin
                ATMTypes.TestField("ATM Settlment Account");
                SettlementAccount := ATMTypes."ATM Settlment Account";
            end;
            exit(SettlementAccount);
        end;
    end;

    procedure ATMTransactionReversal(var EntryNo: Integer; var DocumentNo: Code[20])
    var
        GLEntry: Record "G/L Entry";
        ReversalEntry: Record "Reversal Entry";
        Loans: Record Loans;
        ATMTransactions: Record "ATM Transactions";
    begin
        GLEntry.RESET;
        GLEntry.SETRANGE(Reversed, true);
        GLEntry.SETRANGE("Document No.", DocumentNo);
        IF GLEntry.FINDSET THEN BEGIN
            REPEAT
                If ATMTransactions.Get(EntryNo) then begin
                    ATMTransactions."Reversed Posted" := true;
                    ATMTransactions.Modify(true);
                end;
            UNTIL GLEntry.NEXT = 0;
        end;
        GLEntry.RESET;
        GLEntry.SETRANGE(Reversed, FALSE);
        GLEntry.SETRANGE("Document No.", DocumentNo);
        IF GLEntry.FINDSET THEN BEGIN
            repeat
                ReversalEntry.SetHideDialog(TRUE);
                ReversalEntry.SetHideWarningDialogs;
                ReversalEntry.ReverseTransaction(GLEntry."Transaction No.");
                If ATMTransactions.Get(EntryNo) then begin
                    ATMTransactions."Reversed Posted" := true;
                    ATMTransactions.Modify(true);
                end;
            until GLEntry.Next = 0;
        end;
    end;

    procedure BalanceInquiry(var CardNo: code[20]; var DocumentNo: Code[20]; var ReferenceNo: Code[20]; var RequestType: Code[20]; var responseCode: Code[20]; var ResponseMessage: BigText)
    var
        MemberNo: Code[20];
        Member: Record Members;
        TempResponse: BigText;
        Vendor: Record Vendor;
        BookBalance, AvailableBalance : Decimal;
        Charges, BalanceBefore : Decimal;
        SaccoProduct: Record "Sacco Products";
    begin
        Clear(TempResponse);
        clear(responseCode);
        clear(ResponseMessage);
        Vendor.RESET;
        Vendor.SETRANGE("Card No", CardNo);
        Vendor.SETRANGE(Blocked, Vendor.Blocked::" ");
        IF Vendor.FindFirst THEN BEGIN
            BookBalance := 0;
            AvailableBalance := 0;
            responseCode := '00';
            Vendor.CALCFIELDS(Balance, "Uncleared Funds");
            if (BalanceBefore - Charges) < 0 then begin
                ResponseCode := '01';
                ResponseMessage.AddText('{"Error":"Insufficient Funds"}');
                exit;
            end;
            BookBalance := Vendor.Balance;
            SaccoProduct.Get(Vendor."Product Code");
            AvailableBalance := BookBalance - Vendor."Uncleared Funds" - SaccoProduct."Minimum Balance" - ChannelIntegrations.GetPendingChannelsTransactions(Vendor."Member No.");
            if AvailableBalance < 0 then AvailableBalance := 0;
            ResponseMessage.AddText('{"AccountNo":"' + Vendor."No." + '","AccountBalance":"' + Format(BookBalance) + '","ActualBalance":"' + Format(AvailableBalance) + '"}');
        end
        else begin
            responseCode := '01';
            ResponseMessage.AddText('{"Error":"The Account Does Not Exist"}');
            exit;
        end;
    end;

    procedure MiniStatement(var CardNo: code[20]; var noOfTransactions: Integer; var DocumentNo: Code[20]; var ReferenceNo: Code[20]; var RequestType: Code[20]; var responseCode: Code[20]; var ResponseMessage: BigText)
    var
        MemberNo, DrCr : Code[20];
        Member: Record Members;
        TempResponse: BigText;
        Vendor: Record Vendor;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        i: integer;
        OpeningBalance, RunningBalance : Decimal;
        DetailedLedger: Record "Detailed Vendor Ledg. Entry";
        LastDate: Date;
    begin
        Clear(TempResponse);
        clear(responseCode);
        clear(ResponseMessage);
        Vendor.RESET;
        Vendor.SETRANGE("Card No", CardNo);
        Vendor.SETRANGE(Blocked, Vendor.Blocked::" ");
        IF Vendor.FindFirst THEN BEGIN
            Vendor.CALCFIELDS(Balance);
            LastDate := 0D;
            VendorLedgerEntry.RESET;
            VendorLedgerEntry.SETRANGE(Reversed, FALSE);
            VendorLedgerEntry.SETRANGE("Vendor No.", Vendor."No.");
            VendorLedgerEntry.SetCurrentKey("Posting Date", "Transaction Time");
            VendorLedgerEntry.SetAscending("Posting Date", false);
            VendorLedgerEntry.SetAscending("Transaction Time", false);
            IF VendorLedgerEntry.FINDSET THEN BEGIN
                REPEAT
                    LastDate := VendorLedgerEntry."Posting Date";
                UNTIL (VendorLedgerEntry.NEXT = 0) OR (i = noOfTransactions);
            end;
            if LastDate <> 0D then begin
                LastDate := CalcDate('-1D', LastDate);
                DetailedLedger.Reset();
                DetailedLedger.SetFilter("Posting Date", '..%1', LastDate);
                DetailedLedger.SetRange("Vendor No.", Vendor."No.");
                if DetailedLedger.FindSet() then begin
                    DetailedLedger.CalcSums(Amount);
                    OpeningBalance := DetailedLedger.Amount;
                end;
            end
            else
                OpeningBalance := 0;
            RunningBalance := 0;
            RunningBalance := OpeningBalance;
            responseCode := '00';
            ResponseMessage.ADDTEXT('{"AccountName":"' + Vendor.Name + '", "Balance":"' + Format(Vendor.Balance) + '", "Transactions":[');
            VendorLedgerEntry.RESET;
            VendorLedgerEntry.SETRANGE(Reversed, FALSE);
            VendorLedgerEntry.SETRANGE("Vendor No.", Vendor."No.");
            VendorLedgerEntry.SetCurrentKey("Posting Date", "Transaction Time");
            VendorLedgerEntry.SetAscending("Posting Date", false);
            VendorLedgerEntry.SetAscending("Transaction Time", false);
            IF VendorLedgerEntry.FINDSET THEN BEGIN
                i := 1;
                REPEAT
                    DrCr := '';
                    VendorLedgerEntry.CALCFIELDS(Amount);
                    if VendorLedgerEntry.Amount > 0 then
                        DrCr := 'DR'
                    else
                        DrCr := 'CR';
                    RunningBalance += VendorLedgerEntry.Amount;
                    TempResponse.ADDTEXT('{"transactionID":"' + FORMAT(VendorLedgerEntry."Document No.") + '",');
                    TempResponse.ADDTEXT('"DrCr":"' + DrCr + '",');
                    TempResponse.ADDTEXT('"Description":"' + VendorLedgerEntry.Description + '",');
                    TempResponse.ADDTEXT('"postingDate":"' + FORMAT(VendorLedgerEntry."Posting Date", 0, '<Year4>-<Month,2>-<Day,2>') + '",');
                    TempResponse.ADDTEXT('"postingTime":"' + FORMAT(VendorLedgerEntry."Transaction Time", 0, '<Hours24,2>:<Minutes,2>:<Seconds,2>') + '",');
                    TempResponse.ADDTEXT('"amount":"' + FORMAT(ABS(VendorLedgerEntry.Amount), 0, 1) + '",');
                    TempResponse.ADDTEXT('"RunningBalance":"' + FORMAT((RunningBalance), 0, 1) + '"}');
                    TempResponse.ADDTEXT(',');
                    i += 1;
                UNTIL (VendorLedgerEntry.NEXT = 0) OR (i = noOfTransactions);
                IF STRLEN(FORMAT(TempResponse)) > 1 THEN ResponseMessage.ADDTEXT(COPYSTR(FORMAT(TempResponse), 1, STRLEN(FORMAT(TempResponse)) - 1));
            end;
            ResponseMessage.ADDTEXT(']}');
        END
        ELSE BEGIN
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Account Does Not Exist"}');
            Exit;
        end;
    end;

    procedure ChannelTransactions(var CardNo: Code[250]; var DocumentNo: code[20]; var ReferenceNo: code[250]; var TransactionAmount: Decimal; var TransactionTypeCode: Code[20]; var Location: Text[1000]; var DeviceType: Text[250]; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        EntryNo: integer;
        Vendor: Record Vendor;
        ATMTransactions: Record "ATM Transactions";
        ATMPostedTransactions: Record "ATM Posted Transactions";
        GLEntry: Record "G/L Entry";
        MemberNo, AccountNo : Code[20];
        BalanceBefore, BalanceAfter, Charges : decimal;
        ChannelTransactionTypes: Record "Channel Transaction Setup";
        JournalMgt: Codeunit "Journal Management";
        Loans: Record Loans;
        MemberManagement: Codeunit "Member Management";
        SaccoProduct: Record "Sacco Products";
    begin
        BalanceBefore := 0;
        BalanceAfter := 0;
        Charges := 0;
        if not ChannelTransactionTypes.Get(TransactionTypeCode) then begin
            ResponseCode := '01';
            ResponseMessage.AddText('{"Error":"The Transaction Type Code do not exist ' + TransactionTypeCode + '"}');
            ChannelIntegrations.LogTransactionResponse(TransactionTypeCode, DocumentNo, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
            exit;
        end
        else begin
            if ChannelTransactionTypes."Posting Type" <> ChannelTransactionTypes."Posting Type"::Reversal then begin
                ATMTransactions.Reset();
                ATMTransactions.SetRange("Document No.", DocumentNo);
                if ATMTransactions.FindFirst() then begin
                    ResponseCode := '01';
                    ResponseMessage.AddText('{"Error":"The Transaction already exists ' + DocumentNo + '"}');
                    ChannelIntegrations.LogTransactionResponse(TransactionTypeCode, DocumentNo, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
                    exit;
                end;
                ATMPostedTransactions.Reset();
                ATMPostedTransactions.SetRange("Document No.", DocumentNo);
                if ATMPostedTransactions.FindFirst() then begin
                    ResponseCode := '01';
                    ResponseMessage.AddText('{"Error":"The Transaction already exists ' + DocumentNo + '"}');
                    ChannelIntegrations.LogTransactionResponse(TransactionTypeCode, DocumentNo, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
                    exit;
                end;
            end;
            Charges := JournalMgt.GetChargesAmount(ChannelTransactionTypes."Charge Code", TransactionAmount);
            if ChannelTransactionTypes."Posting Type" = ChannelTransactionTypes."Posting Type"::Credit then begin
                Vendor.RESET;
                Vendor.SETRANGE("Card No", CardNo);
                Vendor.SETRANGE(Blocked, Vendor.Blocked::" ");
                if Vendor.FindFirst then begin
                    if (Vendor."Cash Deposit Allowed" and (Vendor."Product Posting Type" <> Vendor."Product Posting Type"::"Loan Account")) then begin
                        Vendor.CalcFields(Balance);
                        BalanceBefore := Vendor.Balance;
                        MemberNo := Vendor."Member No.";
                        AccountNo := Vendor."No.";
                    end;
                    if Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Loan Account" then begin
                        Loans.Reset();
                        Loans.SetRange("Member No.", Vendor."Member No.");
                        Loans.SetRange("Loan Account", Vendor."No.");
                        if Loans.FindFirst then begin
                            Loans.CalcFields("Loan Balance");
                            BalanceBefore := Loans."Loan Balance";
                            MemberNo := Loans."Member No.";
                            AccountNo := Vendor."No.";
                            BalanceAfter := BalanceBefore + Charges - TransactionAmount;
                        end;
                    end;
                end;
            end
            else if ChannelTransactionTypes."Posting Type" = ChannelTransactionTypes."Posting Type"::Debit then begin
                Vendor.Reset();
                Vendor.SetRange("Card No", CardNo);
                if Vendor.FindFirst then begin
                    if Vendor.Blocked <> Vendor.Blocked::" " then begin
                        ResponseCode := '01';
                        ResponseMessage.AddText('{"Error":"The Account is Blocked!"}');
                        ChannelIntegrations.LogTransactionResponse(TransactionTypeCode, DocumentNo, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
                        exit;
                    end
                    else if not Vendor."Cash Withdraw Allowed" then begin
                        ResponseCode := '01';
                        ResponseMessage.AddText('{"Error":"The Account Does Not Allow Cash Withdrawals!"}');
                        ChannelIntegrations.LogTransactionResponse(TransactionTypeCode, DocumentNo, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
                        exit;
                    end
                    else begin
                        SaccoProduct.Get(Vendor."Product Code");
                        MemberNo := Vendor."Member No.";
                        AccountNo := Vendor."No.";
                        Vendor.CalcFields(Balance, "Uncleared Funds");
                        BalanceBefore := Vendor.Balance - Vendor."Uncleared Funds" - SaccoProduct."Minimum Balance" - ChannelIntegrations.GetPendingChannelsTransactions(MemberNo);
                        BalanceAfter := BalanceBefore - Charges - TransactionAmount;
                        if BalanceAfter < 0 then begin
                            ResponseCode := '01';
                            ResponseMessage.AddText('{"Error":"Insufficient Funds"}');
                            ChannelIntegrations.LogTransactionResponse(TransactionTypeCode, DocumentNo, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
                            exit;
                        end;
                        if ChannelIntegrations.HasPendingTransaction(MemberNo, TransactionTypeCode, ResponseCode, ResponseMessage) then begin
                            ChannelIntegrations.LogTransactionResponse(TransactionTypeCode, DocumentNo, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
                            exit;
                        end;
                    end;
                end
                else begin
                    ResponseCode := '01';
                    ResponseMessage.AddText('{"Error":"The Debit Account Does Not Exist"}');
                    ChannelIntegrations.LogTransactionResponse(TransactionTypeCode, DocumentNo, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
                    exit;
                end;
            end;
            if TransactionAmount <= 0 then begin
                ResponseCode := '01';
                ResponseMessage.AddText('{"Error":"Please Provide Transaction Amount"}');
                ChannelIntegrations.LogTransactionResponse(TransactionTypeCode, DocumentNo, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
                exit;
            end;
            if ChannelIntegrations.CheckBelowMaximumAmount(TransactionTypeCode, TransactionAmount, ResponseCode, ResponseMessage) = false then begin
                ChannelIntegrations.LogTransactionResponse(TransactionTypeCode, DocumentNo, ResponseCode, CopyStr(Format(ResponseMessage), 1, 400));
                exit;
            end;
            ATMTransactions.Reset();
            if ATMTransactions.FindLast() then
                EntryNo := ATMTransactions."Entry No." + 1
            else
                EntryNo := 1;
            ATMTransactions.INIT;
            ATMTransactions."Entry No." := EntryNo;
            ATMTransactions."Document No." := DocumentNo;
            ATMTransactions."Reference No" := ReferenceNo;
            ATMTransactions."Account No" := AccountNo;
            ATMTransactions.Validate("Member No", MemberNo);
            ATMTransactions."Card No" := CardNo;
            ATMTransactions.Amount := TransactionAmount;
            ATMTransactions.Location := Location;
            ATMTransactions."Device Type" := DeviceType;
            ATMTransactions."Transaction Type" := ChannelTransactionTypes.Code;
            ATMTransactions."Posting Type" := ChannelTransactionTypes."Posting Type";
            If ChannelTransactionTypes."Posting Type" = ChannelTransactionTypes."Posting Type"::Reversal then
                ATMTransactions.Reversal := true;
            ATMTransactions."Transaction Time" := TIME;
            ATMTransactions."Transaction Date" := TODAY;
            ATMTransactions."Posting Date" := TODAY;
            ATMTransactions.INSERT;
            ResponseCode := '00';
            ResponseMessage.AddText('{"Message":"Transaction Received","EntryNo":"' + Format(EntryNo) + '","BeginningBalance":"' + Format(BalanceBefore) + '","Charges":"' + Format(Charges) + '","BalanceAfter":"' + Format(BalanceAfter) + '"}');
        end;
    end;

    internal procedure PostATMTransactions()
    var
        ATMPostedTransactions: Record "ATM Posted Transactions";
        ATMTransactions: Record "ATM Transactions";
        ChannelTransactionsSetup: Record "Channel Transaction Setup";
        PostingDescription: Text[100];
        LoanNo, Dim1, Dim2, JournalBatch, JournalTemplate, DocumentNo, ExternalDocumentNo, PostingAccount : Code[20];
        LineNo: Integer;
        PostingDate: Date;
        InterestBalance, PrincipalBalance, BaseAmount, InterestPaid, PrincipalPaid, UnAllocatedAmount : Decimal;
        Loans: Record Loans;
        MembersMgt: Codeunit "Member Management";
        JobExecEntries: Record "Job Execution Entries";
        All: Integer;
        SaccoSetup: Record "General Ledger Setup";
        SMSManagement: Codeunit "Notifications Management";
        SMSSource: Code[20];
        SMSPhoneNo: Text;
        SMSText: Text;
        Vendor_Check: Record Vendor;
    begin
        SaccoSetup.Get();
        ATMTransactions.Reset();
        ATMTransactions.SetRange(Posted, false);
        ATMTransactions.SetRange(Reversal, false);
        ATMTransactions.SetFilter(Amount, '<>%1', 0);
        ATMTransactions.SetFilter("Member No", '<>%1', '');
        ATMTransactions.SetFilter("Account No", '<>%1', '');
        ATMTransactions.SetCurrentKey("Transaction Type");
        ATMTransactions.SetCurrentKey("Entry No.", "Transaction Type");
        ATMTransactions.SetAscending("Transaction Type", true);
        if ATMTransactions.FindSet() then begin
            All := ATMTransactions.Count;
            repeat
                if ChannelTransactionsSetup.Get(ATMTransactions."Transaction Type") then begin
                    SMSSource := 'ATM_POST';
                    JournalTemplate := 'PAYMENT';
                    JournalBatch := 'ATM';
                    PostingAccount := '';
                    LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
                    DocumentNo := ATMTransactions."Document No.";
                    PostingDate := ATMTransactions."Posting Date";
                    ExternalDocumentNo := ATMTransactions."Card No";
                    if ((ChannelIntegrations.CheckPostOk(DocumentNo)) and (DocumentNo <> '')) then begin
                        if ChannelTransactionsSetup."Posting Type" = ChannelTransactionsSetup."Posting Type"::Credit then begin
                            if Vendor.Get(ATMTransactions."Account No") then begin
                                if Vendor."Product Posting Type" <> Vendor."Product Posting Type"::"Loan Account" then begin
                                    if Vendor.Blocked = Vendor.Blocked::" " then begin
                                        PostingAccount := ChannelTransactionsSetup."Balancing Account No";
                                        If PostingAccount = '' then
                                            PostingAccount := GetSettlmentAccount(ATMTransactions."Card No");
                                        PostingDescription := StrSubstNo('%1 : %2 %3', ATMTransactions."Member Name", ChannelTransactionsSetup.Description, DocumentNo);
                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"Bank Account", PostingAccount, PostingDate, PostingDescription, ATMTransactions.Amount, Dim1, Dim2, ATMTransactions."Member No", DocumentNo, GlobalTransactionType::"Cash Deposit", LineNo, 'ATM', 'ATM', ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                        PostingDescription := StrSubstNo('%1 %2', ChannelTransactionsSetup.Description, DocumentNo);
                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, ATMTransactions."Account No", PostingDate, PostingDescription, -1 * ATMTransactions.Amount, Dim1, Dim2, ATMTransactions."Member No", DocumentNo, GlobalTransactionType::"Cash Deposit", LineNo, 'ATM', 'ATM', ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                        If ChannelTransactionsSetup."Charge Code" <> '' then begin
                                            PostingDescription := 'Charges';
                                            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, ATMTransactions."Account No", PostingDate, PostingDescription, JournalManagement.GetChargesAmount(ChannelTransactionsSetup."Charge Code", ATMTransactions.Amount), Dim1, Dim2, ATMTransactions."Member No", DocumentNo, GlobalTransactionType::Charge, LineNo, 'ATM', 'ATM', ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                            LineNo := JournalManagement.AddCharges(ChannelTransactionsSetup."Charge Code", '', ATMTransactions.Amount, LineNo, DocumentNo, ATMTransactions."Member No", 'ATM', 'ATM', ExternalDocumentNo, JournalBatch, JournalTemplate, Dim1, Dim2, PostingDate, false);
                                        end;
                                    end;
                                end
                                else if Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Loan Account" then begin
                                    LoanNo := '';
                                    LoanNo := ChannelIntegrations.GetLoanNo(ATMTransactions."Account No");
                                    if Loans.Get(LoanNo) then begin
                                        Loans.CalcFields("Principal Balance", "Interest Balance");
                                        BaseAmount := 0;
                                        InterestPaid := 0;
                                        PrincipalPaid := 0;
                                        InterestBalance := 0;
                                        UnAllocatedAmount := 0;
                                        BaseAmount := ATMTransactions.Amount;
                                        InterestBalance := Loans."Interest Balance";
                                        PrincipalBalance := Loans."Principal Balance";
                                        if InterestBalance < 0 then InterestBalance := 0;
                                        if PrincipalBalance < 0 then PrincipalBalance := 0;
                                        if InterestBalance < BaseAmount then begin
                                            InterestPaid := InterestBalance;
                                            BaseAmount -= InterestPaid;
                                        end
                                        else begin
                                            InterestPaid := BaseAmount;
                                            BaseAmount := 0;
                                        end;
                                        if PrincipalBalance > BaseAmount then begin
                                            PrincipalPaid := BaseAmount;
                                            BaseAmount := 0;
                                        end
                                        else begin
                                            PrincipalPaid := PrincipalBalance;
                                            BaseAmount -= PrincipalPaid;
                                        end;
                                        if BaseAmount <> 0 then UnAllocatedAmount := BaseAmount;
                                        PostingDescription := 'Interest Paid';
                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, Loans."Loan Account", PostingDate, PostingDescription, -1 * InterestPaid, Dim1, Dim2, Loans."Member No.", DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, Loans."Product Code", Loans."No.", ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                        PostingDescription := 'Principal Paid';
                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, Loans."Loan Account", PostingDate, PostingDescription, -1 * PrincipalPaid, Dim1, Dim2, Loans."Member No.", DocumentNo, GlobalTransactionType::"Principal Paid", LineNo, Loans."Product Code", Loans."No.", ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                        PostingDescription := ChannelTransactionsSetup.Description;
                                        if UnallocatedAmount <> 0 then begin
                                            //Post Unallocated Amount
                                            PostingDescription := 'School Fee Transfer';
                                            LineNo := JournalManagement.CreateUnallocationJournalLine(GlobalAccountType::Vendor, '', PostingDate, PostingDescription, UnAllocatedAmount, Dim1, Dim2, Loans."Member No.", DocumentNo, GlobalTransactionType::"Acc. Transfer", LineNo, Loans."Product Code", Loans."No.", ExternalDocumentNo, JournalTemplate, JournalBatch);
                                        end;
                                        PostingAccount := ChannelTransactionsSetup."Balancing Account No";
                                        If PostingAccount = '' then
                                            PostingAccount := GetSettlmentAccount(ATMTransactions."Card No");
                                        PostingDescription := StrSubstNo('%1 : %2 %3', ATMTransactions."Member Name", ChannelTransactionsSetup.Description, DocumentNo);
                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"Bank Account", PostingAccount, PostingDate, PostingDescription, ATMTransactions.Amount, Dim1, Dim2, ATMTransactions."Member No", DocumentNo, GlobalTransactionType::"Cash Deposit", LineNo, 'ATM', 'ATM', ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                    end;
                                end;
                            end;
                        end
                        else if ChannelTransactionsSetup."Posting Type" = ChannelTransactionsSetup."Posting Type"::Debit then begin
                            //Debit Balancing Account  
                            PostingAccount := ChannelTransactionsSetup."Balancing Account No";
                            If PostingAccount = '' then
                                PostingAccount := GetSettlmentAccount(ATMTransactions."Card No");
                            PostingDescription := StrSubstNo('%1 : %2 %3', ATMTransactions."Member Name", ChannelTransactionsSetup.Description, DocumentNo);
                            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"Bank Account", PostingAccount, PostingDate, PostingDescription, -1 * ATMTransactions.Amount, Dim1, Dim2, '', DocumentNo, GlobalTransactionType::"Cash Withdrawal", LineNo, 'ATM', 'ATM', ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                            PostingDescription := StrSubstNo('%1 %2', ChannelTransactionsSetup.Description, DocumentNo);
                            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, ATMTransactions."Account No", PostingDate, PostingDescription, ATMTransactions.Amount, Dim1, Dim2, ATMTransactions."Member No", DocumentNo, GlobalTransactionType::"Cash Withdrawal", LineNo, 'ATM', 'ATM', ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                            If ChannelTransactionsSetup."Charge Code" <> '' then begin
                                PostingDescription := 'Charges';
                                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, ATMTransactions."Account No", PostingDate, PostingDescription, JournalManagement.GetChargesAmount(ChannelTransactionsSetup."Charge Code", ATMTransactions.Amount), Dim1, Dim2, ATMTransactions."Member No", DocumentNo, GlobalTransactionType::Charge, LineNo, 'ATM', 'ATM', ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                LineNo := JournalManagement.AddCharges(ChannelTransactionsSetup."Charge Code", '', ATMTransactions.Amount, LineNo, DocumentNo, ATMTransactions."Member No", 'ATM', 'ATM', ATMTransactions."Member No", JournalBatch, JournalTemplate, Dim1, Dim2, PostingDate, false);
                            end;
                        end;
                        // if isBalancing(JournalTemplate, JournalBatch) then begin
                        JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
                        GLEntry.Reset();
                        GLEntry.SetRange("Document No.", DocumentNo);
                        GLEntry.SetRange("Document Date", PostingDate);
                        if GLEntry.FindFirst() then begin
                            SMSSource := 'CHANNELS';
                            If ChannelTransactionsSetup."Posting Type" = ChannelTransactionsSetup."Posting Type"::Debit then begin
                                If Member.Get(ATMTransactions."Member No") then begin
                                    SMSPhoneNo := Member."Mobile Phone No.";
                                    SMSText := StrSubstNo('Your ATM withdrawal of KES %1 on %2 was successful', Format(ATMTransactions.Amount), Format(CurrentDateTime, 0, '<Day,2>/<Month,2>/<Year4> <Hours24,2>:<Minutes,2>'));
                                    SMSManagement.SendSms(SMSPhoneNo, SMSText, SMSSource);
                                end;
                            end
                            else If ChannelTransactionsSetup."Posting Type" = ChannelTransactionsSetup."Posting Type"::Credit then begin
                                If Member.Get(ATMTransactions."Member No") then begin
                                    SMSPhoneNo := Member."Mobile Phone No.";
                                    If Vendor_Check.Get(ATMTransactions."Account No") then begin
                                        if Vendor_Check."Product Posting Type" <> Vendor_Check."Product Posting Type"::"Loan Account" then
                                            SMSText := StrSubstNo('Dear %1, Your Account have deposited KES %2 to %3 on %4. Ref No.: %5', Member."First Name", Format(ATMTransactions.Amount), ATMTransactions."Account No", Format(CurrentDateTime, 0, '<Day,2>/<Month,2>/<Year4> <Hours24,2>:<Minutes,2>'), Format(ATMTransactions."Reference No"))
                                        else
                                            SMSText := StrSubstNo('Dear %1, Your Loan repayment of KES %2 on %3 has been Successful. Ref No.: %4', Member."First Name", Format(ATMTransactions.Amount), Format(CurrentDateTime, 0, '<Day,2>/<Month,2>/<Year4> <Hours24,2>:<Minutes,2>'), Format(ATMTransactions."Reference No"));
                                    end;
                                    SMSManagement.SendSms(SMSPhoneNo, SMSText, SMSSource);
                                end;
                            end;
                            ATMTransactions.Posted := true;
                            ATMTransactions."Posting Time" := CurrentDateTime;
                            ATMTransactions.Modify();
                        end;
                    end;
                end;
            until ATMTransactions.Next() = 0;
        end;
        JobExecEntries.LockTable();
        JobExecEntries.Reset();
        if JobExecEntries.FindLast() then
            LineNo := JobExecEntries."Entry No" + 1
        else
            LineNo := 1;
        JobExecEntries.Init();
        JobExecEntries."Document No" := Format(Today);
        JobExecEntries."Entry No" := LineNo;
        JobExecEntries."Member No" := Loans."Member No.";
        JobExecEntries."Task Type" := JobExecEntries."Task Type"::"ATM Post";
        JobExecEntries."Run Date" := CurrentDateTime;
        JobExecEntries."Transactions Count" := All;
        JobExecEntries.Insert();
    end;

    internal procedure PostATMReversals()
    var
        ATMTransactions: Record "ATM Transactions";
    begin
        ATMTransactions.Reset();
        ATMTransactions.SetRange("Reversed Posted", false);
        ATMTransactions.SetRange(Reversal, true);
        if ATMTransactions.FindSet() then begin
            repeat
                ATMTransactionReversal(ATMTransactions."Entry No.", ATMTransactions."Document No.");
            until ATMTransactions.Next = 0;
        end;
    end;
}
