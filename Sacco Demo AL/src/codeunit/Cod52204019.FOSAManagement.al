codeunit 52204019 "FOSA Management"
{
    var
        GlobalTransactionType: Enum "Sacco Transaction Type";
        GlobalAccountType: Enum "Gen. Journal Account Type";
        JournalManagement: Codeunit "Journal Management";
        SaccoSetup: Record "General Ledger Setup";
        TellerSetup: Record "Teller Setup";
        GLEntry: Record "G/L Entry";
        JournalBatch, JournalTemplate, Dim1, Dim2, ExternalDocNo, ReasonCode, SourceCode, MemberNo, AccountNo : code[20];
        LineNo: Integer;
        PostingDescription: Text[100];
        PostingDate: Date;
        InterAccountTransfer: Record "Inter Account Transfer";
        MemberCharging: Record "Member Charging";
        Vendor: array[2] of Record Vendor;
        TransactionDenomination: Record "Transaction Denomination";
        DenominationSetup: Record "Denominations Setup";
        ChequeInstructions: Record "Cheque Instructions";
        Loans: Record Loans;
        ProratedInterest, BaseAmount, PostingAmount : Decimal;
        LoansMgt: Codeunit "Loans Management";
        SaccoProducts: Record "Sacco Products";
        ChequeTypes: Record "Cheque Types";

    procedure PostInterAccountTransfer(DocumentNo: code[20])
    begin
        SaccoSetup.Get;
        SaccoSetup.TestField("Inter Acc. Transfer Template");
        SaccoSetup.TestField("Inter Acc. Transfer Batch");
        InterAccountTransfer.Get(DocumentNo);
        InterAccountTransfer.OnBeforeSendForApproval;
        JournalBatch := SaccoSetup."Inter Acc. Transfer Batch";
        JournalTemplate := SaccoSetup."Inter Acc. Transfer Template";
        LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
        PostingDate := WorkDate;
        if InterAccountTransfer."Member No" = InterAccountTransfer."Destination Member" then begin
            Vendor[1].Get(InterAccountTransfer."Destination Account");
            PostingDescription := StrSubstNo('Inter Account Transfer To: %1', Vendor[1].Name);
        end
        else
            PostingDescription := StrSubstNo('Inter Account Transfer To: %1', InterAccountTransfer."Destination Name");
        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, InterAccountTransfer."Transfer From", PostingDate, PostingDescription, InterAccountTransfer.Amount, Dim1, Dim2, InterAccountTransfer."Member No", InterAccountTransfer."No.", GlobalTransactionType::"Acc. Transfer", LineNo, '', 'TRNS', DocumentNo, '', 0, '', JournalTemplate, JournalBatch);
        if InterAccountTransfer."Member No" = InterAccountTransfer."Destination Member" then begin
            Vendor[2].Get(InterAccountTransfer."Transfer From");
            PostingDescription := StrSubstNo('Inter Account Transfer From: %1', Vendor[2].Name);
        end
        else
            PostingDescription := StrSubstNo('Inter Account Transfer From: %1', InterAccountTransfer."Source Name");
        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, InterAccountTransfer."Destination Account", PostingDate, PostingDescription, -1 * InterAccountTransfer.Amount, Dim1, Dim2, InterAccountTransfer."Destination Member", InterAccountTransfer."No.", GlobalTransactionType::"Acc. Transfer", LineNo, '', 'TRNS', DocumentNo, '', 0, '', JournalTemplate, JournalBatch);
        JournalManagement.AddCharges(InterAccountTransfer."Charge Code", InterAccountTransfer."Transfer From", InterAccountTransfer.Amount, LineNo, DocumentNo, InterAccountTransfer."Member No", 'FOSA', 'TRNS', DocumentNo, JournalBatch, JournalTemplate, Dim1, Dim2, PostingDate, True);
        JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
        GLEntry.Reset();
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("Document Date", PostingDate);
        if GLEntry.FindFirst() then begin
            InterAccountTransfer.Status := InterAccountTransfer.Status::Approved;
            InterAccountTransfer.Posted := true;
            InterAccountTransfer."Posted By" := UserId;
            InterAccountTransfer."Posted Date" := WorkDate;
            InterAccountTransfer.Modify();
            OnAfterPostInterAccountTransfer(InterAccountTransfer);
        end;
    end;

    procedure PostMemberCharges(DocumentNo: Code[20])
    begin
        MemberCharging.Get(DocumentNo);
        MemberCharging.OnBeforePosting;
        JournalTemplate := 'GENERAL';
        JournalBatch := 'M_CHARGE';
        LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
        DocumentNo := MemberCharging."No.";
        PostingDate := WorkDate;
        PostingDescription := MemberCharging.Description;
        MemberNo := MemberCharging."Member No.";
        AccountNo := '';
        AccountNo := MemberCharging."Source Account";
        PostingAmount := MemberCharging."Amount Charged";
        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::Charge, LineNo, SourceCode, ReasonCode, ExternalDocNo, '', 0, '', JournalTemplate, JournalBatch);
        JournalManagement.AddCharges(MemberCharging."Charge Code", AccountNo, MemberCharging."No Of Pages", LineNo, DocumentNo, MemberNo, SourceCode, ReasonCode, DocumentNo, JournalBatch, JournalTemplate, Dim1, Dim2, PostingDate, false);
        JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
        GLEntry.Reset();
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("Document Date", PostingDate);
        if GLEntry.FindFirst() then begin
            MemberCharging.Posted := true;
            MemberCharging."Posted By" := UserId;
            MemberCharging."Posted On" := CurrentDateTime;
            MemberCharging.Modify();
        end;
    end;

    procedure PrecheckTellerTransasction(TellerTransaction: Record "Teller Transactions")
    begin
        TellerTransaction.TestField("Account No");
        TellerTransaction.TestField(Amount);
        TellerTransaction.CalcFields(Denominations);
        If TellerTransaction."Transaction Type" = TellerTransaction."Transaction Type"::"Cash Deposit" then TellerTransaction.TestField(Description);
        SaccoSetup.Get;
        if SaccoSetup."Validate Cash Denomination" and (TellerTransaction.Denominations <> TellerTransaction.Amount) then Error('The Denominations breakdown is not equal to the Total Amount');
        if TellerTransaction."Transaction Type" <> TellerTransaction."Transaction Type"::"Cash Deposit" then begin
            if (TellerTransaction."Available Balance" - TellerTransaction.Amount) < 0 then begin
                Error('You cannot overdraw a members account');
            end;
        end;
    end;

    procedure PostFOSATransaction(FosaTransaction: Record "FOSA Transactions")
    begin
        if CheckFOSATransaction(FosaTransaction) then begin
            JournalTemplate := 'GENERAL';
            JournalBatch := 'FOSA';
            LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
            case FosaTransaction."Document Type" of
                FosaTransaction."Document Type"::"Send to Bank":
                    begin
                        PostingDescription := 'Return to Bank ' + FosaTransaction."No.";
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"Bank Account", FosaTransaction."Source No", WorkDate, PostingDescription, -1 * FosaTransaction.Amount, Dim1, Dim2, '', FosaTransaction."No.", GlobalTransactionType::"Teller-Treasury", LineNo, 'FOSA', '', '', '', 0, '', JournalTemplate, JournalBatch);
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"Bank Account", FosaTransaction."Destination No", WorkDate, PostingDescription, FosaTransaction.Amount, Dim1, Dim2, '', FosaTransaction."No.", GlobalTransactionType::"Teller-Treasury", LineNo, 'FOSA', '', '', '', 0, '', JournalTemplate, JournalBatch);
                    end;
                FosaTransaction."Document Type"::"Inter Teller Transfer":
                    begin
                        FosaTransaction.TestField("Created By", UserId);
                        PostingDescription := 'Inter Teller Transfer ' + FosaTransaction."Destination No";
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"Bank Account", FosaTransaction."Source No", WorkDate, PostingDescription, -1 * FosaTransaction.Amount, Dim1, Dim2, '', FosaTransaction."No.", GlobalTransactionType::"Teller-Treasury", LineNo, 'FOSA', '', '', '', 0, '', JournalTemplate, JournalBatch);
                        PostingDescription := 'Inter Teller Receipt ' + FosaTransaction."Source No";
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"Bank Account", FosaTransaction."Destination No", WorkDate, PostingDescription, FosaTransaction.Amount, Dim1, Dim2, '', FosaTransaction."No.", GlobalTransactionType::"Teller-Treasury", LineNo, 'FOSA', '', '', '', 0, '', JournalTemplate, JournalBatch);
                    end;
                FosaTransaction."Document Type"::"Receive From Bank":
                    begin
                        PostingDescription := 'Receive from Bank ' + FosaTransaction."No.";
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"Bank Account", FosaTransaction."Source No", WorkDate, PostingDescription, -1 * FosaTransaction.Amount, Dim1, Dim2, '', FosaTransaction."No.", GlobalTransactionType::"Teller-Treasury", LineNo, 'FOSA', '', '', '', 0, '', JournalTemplate, JournalBatch);
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"Bank Account", FosaTransaction."Destination No", WorkDate, PostingDescription, FosaTransaction.Amount, Dim1, Dim2, '', FosaTransaction."No.", GlobalTransactionType::"Teller-Treasury", LineNo, 'FOSA', '', '', '', 0, '', JournalTemplate, JournalBatch);
                    end;
                FosaTransaction."Document Type"::"Treasury Return":
                    begin
                        TellerSetup.Reset();
                        TellerSetup.SetRange("Setup Type", TellerSetup."Setup Type"::Treasury);
                        if not TellerSetup.FindFirst then Error('Only Treasury User can Post Treasury Return Request');
                        PostingDescription := 'Return to Treasury ' + FosaTransaction."No.";
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"Bank Account", FosaTransaction."Source No", WorkDate, PostingDescription, -1 * FosaTransaction.Amount, Dim1, Dim2, '', FosaTransaction."No.", GlobalTransactionType::"Teller-Treasury", LineNo, 'FOSA', '', '', '', 0, '', JournalTemplate, JournalBatch);
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"Bank Account", FosaTransaction."Destination No", WorkDate, PostingDescription, FosaTransaction.Amount, Dim1, Dim2, '', FosaTransaction."No.", GlobalTransactionType::"Teller-Treasury", LineNo, 'FOSA', '', '', '', 0, '', JournalTemplate, JournalBatch);
                    end;
                FosaTransaction."Document Type"::"Treasury Request":
                    begin
                        FosaTransaction.TestField("Created By", UserId);
                        PostingDescription := 'Receive From Treasury ' + FosaTransaction."No.";
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"Bank Account", FosaTransaction."Source No", WorkDate, PostingDescription, -1 * FosaTransaction.Amount, Dim1, Dim2, '', FosaTransaction."No.", GlobalTransactionType::"Teller-Treasury", LineNo, 'FOSA', '', '', '', 0, '', JournalTemplate, JournalBatch);
                        PostingDescription := 'Issue to Teller ' + FosaTransaction."No.";
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"Bank Account", FosaTransaction."Destination No", WorkDate, PostingDescription, FosaTransaction.Amount, Dim1, Dim2, '', FosaTransaction."No.", GlobalTransactionType::"Teller-Treasury", LineNo, 'FOSA', '', '', '', 0, '', JournalTemplate, JournalBatch);
                    end;
            end;
            JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
            GLEntry.Reset;
            GLEntry.SetRange("Document No.", FosaTransaction."No.");
            GLEntry.SetRange("Document Date", WorkDate);
            if GLEntry.FindFirst then begin
                FosaTransaction.Validate(Posted, true);
                FosaTransaction.Validate("Posting Date", WorkDate);
                FosaTransaction.Validate("Posted By", UserId);
                FosaTransaction.Modify();
            end;
        end;
    end;

    procedure ValidateTransactionDenominations(DocNo: Code[20]; DocType: Enum "FOSA Transaction Types")
    begin
        TransactionDenomination.Reset();
        TransactionDenomination.SetRange("Document Type", DocType);
        TransactionDenomination.SetRange("No.", DocNo);
        if TransactionDenomination.FindSet() then TransactionDenomination.DeleteAll();
        DenominationSetup.Reset();
        if DenominationSetup.FindSet() then begin
            repeat
                TransactionDenomination.Init();
                TransactionDenomination."Document Type" := DocType;
                TransactionDenomination."No." := DocNo;
                TransactionDenomination.Code := DenominationSetup.Code;
                TransactionDenomination.Description := DenominationSetup.Description;
                TransactionDenomination.Value := DenominationSetup.Value;
                TransactionDenomination.Insert();
            until DenominationSetup.Next() = 0;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostTellerTransaction(TellerTransaction: Record "Teller Transactions")
    begin
    end;

    procedure PostTellerTransaction(TellerTransaction: Record "Teller Transactions")
    var
        Member: Record Members;
    begin
        JournalBatch := 'TEL-TRANS';
        JournalTemplate := 'GENERAL';
        PostingDate := WorkDate;
        GLentry.Reset();
        GLentry.SetRange("Document No.", TellerTransaction."No.");
        if GLentry.IsEmpty then begin
            LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
            if TellerTransaction."Transaction Type" = TellerTransaction."Transaction Type"::"Cash Deposit" then begin
                PostingDescription := StrSubstNo('Cash Deposit (OTC) %1 %2 (Source: %3)', TellerTransaction."Transacted By Name", TellerTransaction."Transacted By ID No", TellerTransaction.Description);
                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"Bank Account", TellerTransaction.Till, PostingDate, PostingDescription, TellerTransaction.Amount, Dim1, Dim2, TellerTransaction."Member No.", TellerTransaction."No.", GlobalTransactionType::"Cash Deposit", LineNo, 'TELLER', TellerTransaction."Member No.", TellerTransaction."Transacted By ID No", '', 0, '', JournalTemplate, JournalBatch);
                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, TellerTransaction."Account No", PostingDate, PostingDescription, -1 * TellerTransaction.Amount, Dim1, Dim2, TellerTransaction."Member No.", TellerTransaction."No.", GlobalTransactionType::"Cash Deposit", LineNo, 'TELLER', TellerTransaction."Member No.", TellerTransaction."Transacted By ID No", '', 0, '', JournalTemplate, JournalBatch);
            end
            else begin
                Member.Get(TellerTransaction."Member No.");
                PostingDescription := 'Cash Withdrawal (OTC) ' + Member."First Name" + ' ' + Member."Identification No.";
                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"Bank Account", TellerTransaction.Till, PostingDate, PostingDescription, -1 * TellerTransaction.Amount, Dim1, Dim2, TellerTransaction."Member No.", TellerTransaction."No.", GlobalTransactionType::"Cash Deposit", LineNo, 'TELLER', TellerTransaction."Member No.", TellerTransaction."Transacted By ID No", '', 0, '', JournalTemplate, JournalBatch);
                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, TellerTransaction."Account No", PostingDate, PostingDescription, TellerTransaction.Amount, Dim1, Dim2, TellerTransaction."Member No.", TellerTransaction."No.", GlobalTransactionType::"Cash Deposit", LineNo, 'TELLER', TellerTransaction."Member No.", TellerTransaction."Transacted By ID No", '', 0, '', JournalTemplate, JournalBatch);
            end;
            if TellerTransaction."Charge Code" <> '' then JournalManagement.AddCharges(TellerTransaction."Charge Code", TellerTransaction."Account No", TellerTransaction.Amount, LineNo, TellerTransaction."No.", TellerTransaction."Member No.", 'TELL', 'TELL', TellerTransaction."Transacted By ID No", JournalBatch, JournalTemplate, Dim1, Dim2, PostingDate, True);
            JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
            GLEntry.Reset();
            GLEntry.SetRange("Document No.", TellerTransaction."No.");
            GLEntry.SetRange("Document Date", PostingDate);
            if GLEntry.FindFirst() then begin
                TellerTransaction.Posted := true;
                TellerTransaction."Posted By" := UserId;
                TellerTransaction."Posted On" := CurrentDateTime;
                TellerTransaction.Validate(Status, TellerTransaction.Status::Approved);
                TellerTransaction.Modify();
                OnAfterPostTellerTransaction(TellerTransaction);
            end;
        end
        else begin
            TellerTransaction.Posted := true;
            TellerTransaction."Posted By" := UserId;
            TellerTransaction."Posted On" := CurrentDateTime;
            TellerTransaction.Validate(Status, TellerTransaction.Status::Approved);
            TellerTransaction.Modify();
        end;
    end;

    procedure IssueChequeBook(ChequeBookApp: Record "Cheque Book Applications")
    begin
        ChequeBookApp.TestField("Collected At");
        ChequeBookApp.TestField("Collected By ID No");
        ChequeBookApp.TestField("Collected By Name");
        ChequeBookApp.TestField("Collected By Phone No");
        ChequeBookApp.TestField("Collected On");
        ChequeBookApp.TestField("Serial No");
        JournalBatch := 'CHQIssue';
        JournalTemplate := 'GENERAL';
        LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
        PostingDate := WorkDate;
        LineNo := JournalManagement.AddCharges(ChequeBookApp."Leaf Charge", ChequeBookApp."Account No", ChequeBookApp."No. of Leafs", LineNo, ChequeBookApp."No.", ChequeBookApp."Member No", 'BCQ', 'BCQ', ChequeBookApp."Member No", JournalBatch, JournalTemplate, Dim1, Dim2, PostingDate, True);
        JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
        GLEntry.Reset();
        GLEntry.SetRange("Document No.", ChequeBookApp."No.");
        GLEntry.SetRange("Document Date", PostingDate);
        if GLEntry.FindFirst() then begin
            if ChequeBookCreation(ChequeBookApp) then begin
                ChequeBookApp.Processed := true;
                ChequeBookApp."Processed On" := WorkDate;
                ChequeBookApp.Modify();
            end;
        end;
    end;

    local procedure ChequeBookCreation(ChequeBookApp: Record "Cheque Book Applications"): Boolean
    var
        ChequeBook: array[2] of Record "Cheque Books";
    begin
        ChequeBook[1].Reset();
        ChequeBook[1].Setrange("Member No", ChequeBookApp."Member No");
        ChequeBook[1].Setrange("Account No", ChequeBookApp."Account No");
        ChequeBook[1].Setrange(Active, true);
        if ChequeBook[1].FindFirst() then begin
            ChequeBook[1].Active := false;
            ChequeBook[1].Modify(true);
        end;
        ChequeBook[2].Init();
        ChequeBook[2]."Serial No" := ChequeBookApp."Serial No";
        ChequeBook[2]."Application No." := ChequeBookApp."No.";
        ChequeBook[2]."Member No" := ChequeBookApp."Member No";
        ChequeBook[2]."Member Name" := ChequeBookApp."Member Name";
        ChequeBook[2]."Account No" := ChequeBookApp."Account No";
        ChequeBook[2]."Account Name" := ChequeBookApp."Account Name";
        ChequeBook[2]."No of Leafs" := ChequeBookApp."No. of Leafs";
        ChequeBook[2].Active := true;
        ChequeBook[2]."Applied On" := ChequeBookApp."Created On";
        ChequeBook[2]."Collected On" := CurrentDateTime;
        if ChequeBook[2].Insert(true) then exit(true);
    end;

    procedure PostCheque(ChequeDeposit: Record "Cheque Deposits"; PostingType: Option Clear,Express,Bounce,Reopen,Archive)
    begin
        PostingDate := WorkDate;
        SaccoSetup.GET;
        JournalBatch := 'CTS';
        JournalTemplate := 'GENERAL';
        LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
        if ChequeDeposit."Document Type" = ChequeDeposit."Document Type"::Deposit then
            ChequeTypes.Get(ChequeDeposit."Cheque Type", ChequeTypes.Type::"External Cheque")
        else if ChequeDeposit."Document Type" = ChequeDeposit."Document Type"::Clearance then ChequeTypes.Get(ChequeDeposit."Cheque Type", ChequeTypes.Type::"Internal Cheque");
        case PostingType of
            PostingType::Archive:
                ChequeDeposit.Status := ChequeDeposit.Status::Archived;
            PostingType::Reopen:
                ChequeDeposit.Status := ChequeDeposit.Status::Open;
            PostingType::Clear, PostingType::Express:
                begin
                    if ChequeDeposit."Document Type" = ChequeDeposit."Document Type"::Deposit then begin
                        //Debit Clearing Account                    
                        PostingDescription := 'Cheque Deposit ' + ChequeDeposit."Cheque No";
                        LineNo := JournalManagement.CreateJournalLine(ChequeTypes."Clearing Account Type", ChequeTypes."Clearing Account", PostingDate, PostingDescription, ChequeDeposit.Amount, Dim1, Dim2, ChequeDeposit."Member No", ChequeDeposit."No.", GlobalTransactionType::"Cheque Deposit", LineNo, 'CTS', ChequeDeposit."Member No", ChequeDeposit."Member No", '', 0, '', JournalTemplate, JournalBatch);
                        //Credit Target Account
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, ChequeDeposit."Account No.", PostingDate, PostingDescription, -1 * ChequeDeposit.Amount, Dim1, Dim2, ChequeDeposit."Member No", ChequeDeposit."No.", GlobalTransactionType::"Cheque Deposit", LineNo, 'CTS', ChequeDeposit."Member No", ChequeDeposit."Member No", '', 0, '', JournalTemplate, JournalBatch);
                        //Post Instructions
                        ChequeInstructions.Reset();
                        ChequeInstructions.SetRange("Document No", ChequeDeposit."No.");
                        if ChequeInstructions.FindSet() then begin
                            repeat
                                PostingDescription := '';
                                PostingDescription := 'Transfer to ' + ChequeInstructions."Account Name";
                                BaseAmount := 0;
                                BaseAmount := ChequeInstructions.Amount;
                                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, ChequeDeposit."Account No.", PostingDate, PostingDescription, ChequeInstructions.Amount, Dim1, Dim2, ChequeDeposit."Member No", ChequeDeposit."No.", GlobalTransactionType::"Cheque Deposit", LineNo, 'CTS', ChequeDeposit."Member No", ChequeDeposit."Member No", '', 0, '', JournalTemplate, JournalBatch);
                                if ChequeInstructions."Account Type" = ChequeInstructions."Account Type"::Account then begin
                                    PostingDescription := 'Transfer from ' + ChequeDeposit."Account Name" + '-' + ChequeDeposit."Cheque No";
                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, ChequeInstructions."Account No", PostingDate, PostingDescription, -1 * ChequeInstructions.Amount, Dim1, Dim2, ChequeDeposit."Member No", ChequeDeposit."No.", GlobalTransactionType::"Cheque Deposit", LineNo, 'CTS', ChequeDeposit."Member No", ChequeDeposit."Member No", '', 0, '', JournalTemplate, JournalBatch);
                                end
                                else begin
                                    Loans.Get(ChequeInstructions."Account No");
                                    SaccoProducts.Get(Loans."Product Code");
                                    ReasonCode := Loans."No.";
                                    SourceCode := Loans."Product Code";
                                    ProratedInterest := LoansMgt.GetProratedInterest(ReasonCode, PostingDate);
                                    Loans.CalcFields("Interest Balance", "Penalty Balance", "Principal Balance");
                                    postingAmount := 0;
                                    Loans."Interest Balance" += ProratedInterest;
                                    if Loans."Interest Balance" < 0 then Loans."Interest Balance" := 0;
                                    if Loans."Penalty Balance" < 0 then Loans."Penalty Balance" := 0;
                                    if Loans."Principal Balance" < 0 then Loans."Principal Balance" := 0;
                                    //Pay Penalty
                                    PostingAmount := 0;
                                    if Loans."Penalty Balance" > BaseAmount then begin
                                        postingAmount := BaseAmount;
                                        BaseAmount := 0;
                                    end
                                    else begin
                                        postingAmount := Loans."Penalty Balance";
                                        BaseAmount -= postingAmount;
                                    end;
                                    PostingDescription := 'Penalty Paid';
                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, Loans."Loan Account", PostingDate, PostingDescription, -1 * postingAmount, Dim1, Dim2, ChequeDeposit."Member No", ChequeDeposit."No.", GlobalTransactionType::"Penalty Paid", LineNo, SourceCode, ReasonCode, ChequeDeposit."Member No", '', 0, '', JournalTemplate, JournalBatch);
                                    if SaccoSetup."Interest Accrual Type" = SaccoSetup."Interest Accrual Type"::"Cash Basis" then begin
                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, SaccoProducts."Penalty Due Account", PostingDate, PostingDescription, postingAmount, Dim1, Dim2, ChequeDeposit."Member No", ChequeDeposit."No.", GlobalTransactionType::"Penalty Paid", LineNo, SourceCode, ReasonCode, ChequeDeposit."Member No", '', 0, '', JournalTemplate, JournalBatch);
                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, SaccoProducts."Penalty Paid Account", PostingDate, PostingDescription, -1 * postingAmount, Dim1, Dim2, ChequeDeposit."Member No", ChequeDeposit."No.", GlobalTransactionType::"Penalty Paid", LineNo, SourceCode, ReasonCode, ChequeDeposit."Member No", '', 0, '', JournalTemplate, JournalBatch);
                                    end;
                                    //PayInterest
                                    postingAmount := 0;
                                    if Loans."Interest Balance" > BaseAmount then begin
                                        postingAmount := BaseAmount; //0728129414
                                        BaseAmount := 0;
                                    end
                                    else begin
                                        postingAmount := Loans."Interest Balance";
                                        BaseAmount -= postingAmount;
                                    end;
                                    PostingDescription := 'Interest Due';
                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, Loans."Loan Account", PostingDate, PostingDescription, ProratedInterest, Dim1, Dim2, ChequeDeposit."Member No", ChequeDeposit."No.", GlobalTransactionType::"Interest Due", LineNo, SourceCode, ReasonCode, ChequeDeposit."Member No", '', 0, '', JournalTemplate, JournalBatch);
                                    PostingDescription := 'Interest Paid';
                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, Loans."Loan Account", PostingDate, PostingDescription, -1 * postingAmount, Dim1, Dim2, ChequeDeposit."Member No", ChequeDeposit."No.", GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ChequeDeposit."Member No", '', 0, '', JournalTemplate, JournalBatch);
                                    if SaccoSetup."Interest Accrual Type" = SaccoSetup."Interest Accrual Type"::"Cash Basis" then begin
                                        //Debit Interest Due
                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", SaccoProducts."Interest Due Account", PostingDate, PostingDescription, postingAmount, Dim1, Dim2, ChequeDeposit."Member No", ChequeDeposit."No.", GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ChequeDeposit."Member No", '', 0, '', JournalTemplate, JournalBatch);
                                        //Credit Interest Paid
                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", SaccoProducts."Interest Paid Account", PostingDate, PostingDescription, -1 * postingAmount, Dim1, Dim2, ChequeDeposit."Member No", ChequeDeposit."No.", GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ChequeDeposit."Member No", '', 0, '', JournalTemplate, JournalBatch);
                                        //Post Prorated Interest
                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", SaccoProducts."Interest Due Account", PostingDate, PostingDescription, -1 * ProratedInterest, Dim1, Dim2, ChequeDeposit."Member No", ChequeDeposit."No.", GlobalTransactionType::"Penalty Paid", LineNo, SourceCode, ReasonCode, ChequeDeposit."Member No", '', 0, '', JournalTemplate, JournalBatch);
                                    end
                                    else begin
                                        //Post Prorated Interest
                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", SaccoProducts."Interest Paid Account", PostingDate, PostingDescription, -1 * ProratedInterest, Dim1, Dim2, ChequeDeposit."Member No", ChequeDeposit."No.", GlobalTransactionType::"Penalty Paid", LineNo, SourceCode, ReasonCode, ChequeDeposit."Member No", '', 0, '', JournalTemplate, JournalBatch);
                                    end;
                                    //Pay Principal
                                    postingAmount := 0;
                                    if BaseAmount > Loans."Principal Balance" then begin
                                        postingAmount := Loans."Principal Balance";
                                        BaseAmount -= postingAmount;
                                    end
                                    else begin
                                        postingAmount := BaseAmount;
                                        BaseAmount := 0;
                                    end;
                                    PostingDescription := 'Principal Paid';
                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, Loans."Loan Account", PostingDate, PostingDescription, -1 * postingAmount, Dim1, Dim2, ChequeDeposit."Member No", ChequeDeposit."No.", GlobalTransactionType::"Principal Paid", LineNo, SourceCode, ReasonCode, ChequeDeposit."Member No", '', 0, '', JournalTemplate, JournalBatch);
                                    //Refund Any Amount excess
                                    PostingDescription := 'Excess Loan Repayment Refund';
                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, ChequeDeposit."Account No.", PostingDate, PostingDescription, -1 * BaseAmount, Dim1, Dim2, ChequeDeposit."Member No", ChequeDeposit."No.", GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ChequeDeposit."Member No", '', 0, '', JournalTemplate, JournalBatch);
                                end;
                            until ChequeInstructions.Next() = 0;
                        end;
                        //Add Charges
                        if PostingType = PostingType::Clear then
                            LineNo := JournalManagement.AddCharges(ChequeDeposit."Clearing Charge", ChequeDeposit."Account No.", ChequeDeposit.Amount, LineNo, ChequeDeposit."No.", ChequeDeposit."Member No", 'CTS', 'CTS', ChequeDeposit."Member No", JournalBatch, JournalTemplate, Dim1, Dim2, PostingDate, True)
                        else begin
                            JournalManagement.AddCharges(ChequeDeposit."Express Clearing Charge", ChequeDeposit."Account No.", ChequeDeposit."Express Amount", LineNo, ChequeDeposit."No.", ChequeDeposit."Member No", 'CTS', 'CTS', ChequeDeposit."Member No", JournalBatch, JournalTemplate, Dim1, Dim2, PostingDate, True);
                            CreateCheckDepositLien(ChequeDeposit."No.");
                        end;
                    end;
                    ChequeDeposit.Status := ChequeDeposit.Status::Cleared;
                    ChequeDeposit."Cleared By" := UserId;
                    ChequeDeposit."Clearance Date" := WorkDate;
                    ChequeDeposit.Processed := true;
                    ChequeDeposit."Processed Date" := WorkDate;
                end;
            PostingType::Bounce:
                begin
                    JournalManagement.AddCharges(ChequeDeposit."Bouncing Charge", ChequeDeposit."Account No.", ChequeDeposit.Amount, LineNo, ChequeDeposit."No.", ChequeDeposit."Member No", 'CTS', 'CTS', ChequeDeposit."Member No", JournalBatch, JournalTemplate, Dim1, Dim2, PostingDate, True);
                    ChequeDeposit.Status := ChequeDeposit.Status::Bounced;
                end;
        end;
        JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
        GLEntry.Reset();
        GLEntry.SetRange("Document No.", ChequeDeposit."No.");
        GLEntry.SetRange("Document Date", PostingDate);
        if GLEntry.FindFirst() then begin
            ChequeDeposit.Modify();
        end;
    end;

    procedure PostBankersCheque(BankersCheque: Record "Bankers Cheque")
    var
        BankersChequeType: Record "Cheque Types";
        Vendor: Record Vendor;
        AvailableBal: Decimal;
        SaccoProduct: Record "Sacco Products";
        ChannelsIntegrations: Codeunit "Channels Integrations";
    begin
        JournalBatch := 'BNKCHQ';
        JournalTemplate := 'GENERAL';
        Vendor.Get(BankersCheque."Account Type");
        Vendor.CalcFields(Balance, "Uncleared Funds");
        SaccoProduct.Get(Vendor."Product Code");

        if Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Withdrawable Deposit" then
            AvailableBal := Vendor.Balance - Vendor."Uncleared Funds" - SaccoProduct."Minimum Balance" - ChannelsIntegrations.GetPendingChannelsTransactions(Vendor."Member No.")
        else
            AvailableBal := Vendor.Balance - Vendor."Uncleared Funds" - SaccoProduct."Minimum Balance";

        if BankersCheque."Net Amount" > AvailableBal then
            Error(StrSubstNo('You cannot overdraw Account, The Available Balance is %1', Format(AvailableBal)));

        LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
        BankersCheque.TestField("Payee Details");
        BankersChequeType.Get(BankersCheque."Cheque Type", BankersChequeType.Type::"Bankers Cheque");
        BankersChequeType.TestField("Clearing Account");
        PostingDate := WorkDate;
        PostingDescription := BankersCheque."Payee Details";
        ExternalDocNo := BankersCheque."Cheque No.";

        LineNo := JournalManagement.CreateJournalLine(BankersChequeType."Clearing Account Type", BankersChequeType."Clearing Account", PostingDate, PostingDescription, -1 * BankersCheque.Amount, Dim1, Dim2, BankersCheque."Member No.", BankersCheque."No.", GlobalTransactionType::"Bankers Cheque", LineNo, 'BCQ', 'BCQ', ExternalDocNo, '', 0, '', JournalTemplate, JournalBatch);
        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, BankersCheque."Account Type", PostingDate, PostingDescription, BankersCheque.Amount, Dim1, Dim2, BankersCheque."Member No.", BankersCheque."No.", GlobalTransactionType::"Bankers Cheque", LineNo, 'BCQ', 'BCQ', ExternalDocNo, '', 0, '', JournalTemplate, JournalBatch);
        if BankersChequeType."Clearing Charge" <> '' then LineNo := JournalManagement.AddCharges(BankersChequeType."Clearing Charge", BankersCheque."Account Type", BankersCheque.Amount, LineNo, BankersCheque."No.", BankersCheque."Member No.", 'BCQ', 'BCQ', BankersCheque."Member No.", JournalBatch, JournalTemplate, Dim1, Dim2, PostingDate, True);
        JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
        GLEntry.Reset();
        GLEntry.SetRange("Document No.", BankersCheque."No.");
        GLEntry.SetRange("Document Date", PostingDate);
        if GLEntry.FindFirst() then begin
            BankersCheque.Posted := true;
            BankersCheque.Modify();
        end;
    end;

    local procedure CheckFOSATransaction(FOSATransaction: Record "FOSA Transactions") PostOk: Boolean
    var
        BankLedgerEntry: Record "Bank Account Ledger Entry";
        BankAccount: Record "Bank Account";
    begin
        BankLedgerEntry.Reset();
        BankLedgerEntry.SetRange("Document No.", FOSATransaction."No.");
        if BankLedgerEntry.FindSet() then begin
            FOSATransaction.Posted := true;
            FOSATransaction.Modify();
            PostOk := false;
            exit(PostOk);
        end;
        PostOk := true;
        case FOSATransaction."Document Type" of
            FOSATransaction."Document Type"::"Receive From Bank", FOSATransaction."Document Type"::"Send to Bank":
                begin
                    TellerSetup.Get(UserId, TellerSetup."Setup Type"::Treasury);
                    BankAccount.Get(TellerSetup."Account Code");
                    BankAccount.CalcFields(Balance);
                    if FOSATransaction."Document Type" = FOSATransaction."Document Type"::"Receive From Bank" then begin
                        if (BankAccount.Balance + FOSATransaction.Amount) > TellerSetup."Maximum Capacity" then Error('The Transaction cannot be completed. It will take the vault balance above the limit');
                    end;
                    if FOSATransaction."Document Type" = FOSATransaction."Document Type"::"Send to Bank" then begin
                        if (BankAccount.Balance - FOSATransaction.Amount) < TellerSetup."Minimum Capacity" then Error('The Transaction cannot be completed. It will take the vault balance above the limit');
                    end;
                end;
            FOSATransaction."Document Type"::"Treasury Request":
                begin
                    if TellerSetup.Get(UserId, TellerSetup."Setup Type"::Teller) then begin
                        BankAccount.Get(TellerSetup."Account Code");
                        BankAccount.CalcFields(Balance);
                        if (BankAccount.Balance + FOSATransaction.Amount) > TellerSetup."Maximum Capacity" then Error('The Transaction cannot be completed. It will take the Till balance above the limit');
                    end;
                    if TellerSetup.Get(UserId, TellerSetup."Setup Type"::Treasury) then begin
                        BankAccount.Get(TellerSetup."Account Code");
                        BankAccount.CalcFields(Balance);
                        if (BankAccount.Balance - FOSATransaction.Amount) < TellerSetup."Minimum Capacity" then Error('The Transaction cannot be completed. It will take the vault balance below the limit');
                    end;
                end;
            FOSATransaction."Document Type"::"Inter Teller Transfer":
                begin
                    if TellerSetup.Get(UserId, TellerSetup."Setup Type"::Teller) then begin
                        //TellerSetup.TestField("Account Code", FOSATransaction."Source No");
                        BankAccount.Get(FOSATransaction."Source No");
                        BankAccount.CalcFields(Balance);
                        if (BankAccount.Balance - FOSATransaction.Amount) < TellerSetup."Minimum Capacity" then Error('The Transaction cannot be completed. It will take the Till balance below the limit');
                    end;
                    if TellerSetup.Get(UserId, TellerSetup."Setup Type"::Teller) then begin
                        //TellerSetup.TestField("Account Code", FOSATransaction."Destination No");
                        BankAccount.Get(TellerSetup."Account Code");
                        BankAccount.CalcFields(Balance);
                        if (BankAccount.Balance + FOSATransaction.Amount) > TellerSetup."Maximum Capacity" then Error('The Transaction cannot be completed. It will take the Till balance above the limit');
                    end;
                end;
        end;
        exit(PostOk);
    end;

    procedure RunStandingOrder(STONo: Code[20]; RunDate: Date)
    var
        StandingOrder: Record "Standing Order";
        DetailedLedger: Record "Detailed Vendor Ledg. Entry";
        ChannelsIntegrations: Codeunit "Channels Integrations";
        AvailableAmount, RunAmount, TargetAmount, InterestPaid, PrincipalBalance, PrincipalPaid, BaseAmount, InterestBalance, ChargeAmount, UnallocatedAmount : Decimal;
        DocumentNo, AccountNo : Code[20];
        MemberNo, ExtDocNo, ReasonCode, SourceCode : Code[20];
        DateFilter: Text[50];
        StartDate, STORequiredDate : Date;
        Day, Month, Year : Integer;
    begin
        if StandingOrder.Get(STONo) then begin
            if StandingOrder.Terminated = false then begin
                Day := Date2DMY(RunDate, 1);
                Month := Date2DMY(RunDate, 2);
                Year := Date2DMY(RunDate, 3);
                STORequiredDate := DMY2Date(Day, Month, Year);

                StartDate := RunDate;
                MemberNo := StandingOrder."Member No";
                DocumentNo := STONo;
                if ((Vendor[1].Get(StandingOrder."Account No")) and (RunDate >= StandingOrder."Start Date")) then begin
                    DateFilter := Format(RunDate);
                    JournalBatch := 'STO';
                    JournalTemplate := 'GENERAL';
                    LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);

                    PostingDate := StartDate;
                    DetailedLedger.Reset();
                    DetailedLedger.SetFilter("Posting Date", DateFilter);
                    DetailedLedger.SetRange("Document No.", STONo);
                    DetailedLedger.SetRange("Vendor No.", Vendor[1]."No.");
                    if DetailedLedger.FindSet() then begin
                        DetailedLedger.CalcSums("Debit Amount");
                        RunAmount := DetailedLedger."Debit Amount";
                    end;

                    Vendor[1].CalcFields(Balance, "Uncleared Funds");
                    SaccoProducts.Get(Vendor[1]."Product Code");
                    AvailableAmount := Vendor[1].Balance - Vendor[1]."Uncleared Funds" - SaccoProducts."Minimum Balance" - ChannelsIntegrations.GetPendingChannelsTransactions(Vendor[1]."Member No.");
                    if StandingOrder."Amount Type" = StandingOrder."Amount Type"::Fixed then begin
                        TargetAmount := StandingOrder.Amount;
                        PostingAmount := TargetAmount - RunAmount;
                        if PostingAmount > AvailableAmount then
                            PostingAmount := AvailableAmount;

                        if TargetAmount = RunAmount then
                            StandingOrder."Next Run Date" := CalcDate('1M', STORequiredDate)
                        else
                            StandingOrder."Next Run Date" := CalcDate('1D', STORequiredDate);
                    end;
                    if StandingOrder."Amount Type" = StandingOrder."Amount Type"::Sweep then begin
                        TargetAmount := AvailableAmount;
                        PostingAmount := TargetAmount;
                    end;
                    if StandingOrder."Amount Type" = StandingOrder."Amount Type"::"Amount Based" then begin
                        if AvailableAmount >= StandingOrder."Amount Limit" then begin
                            TargetAmount := AvailableAmount;
                            PostingAmount := TargetAmount;
                        end;
                    end;
                    if PostingAmount < 0 then PostingAmount := 0;
                    if PostingAmount > AvailableAmount then PostingAmount := 0;
                    if PostingAmount > 0 then begin
                        BaseAmount := PostingAmount;
                        PostingDescription := StrSubstNo('STO: %1', StandingOrder."Posting Description");
                        DocumentNo := STONo;
                        AccountNo := '';
                        AccountNo := Vendor[1]."No.";
                        ReasonCode := StandingOrder."No.";
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Standing Order", LineNo, SourceCode, ReasonCode, ExtDocNo, '', 0, '', JournalTemplate, JournalBatch);
                        LineNo := JournalManagement.AddCharges(StandingOrder."Charge Code", AccountNo, PostingAmount, LineNo, DocumentNo, MemberNo, SourceCode, ReasonCode, DocumentNo, JournalBatch, JournalTemplate, Dim1, Dim2, PostingDate, true);
                        AccountNo := StandingOrder."Destination Account";
                        case StandingOrder."Standing Order Class" of
                            StandingOrder."Standing Order Class"::Internal:
                                begin
                                    PostingDescription := StrSubstNo('STO: %1', StandingOrder."Member Name");
                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Standing Order", LineNo, SourceCode, ReasonCode, ExtDocNo, '', 0, '', JournalTemplate, JournalBatch);
                                end;
                            StandingOrder."Standing Order Class"::External:
                                begin
                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"Bank Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Standing Order", LineNo, SourceCode, ReasonCode, ExtDocNo, '', 0, '', JournalTemplate, JournalBatch);
                                end;
                            StandingOrder."Standing Order Class"::"Loan-Principal":
                                begin
                                    Loans.Get(StandingOrder."Destination Account");
                                    PostingAmount := StandingOrder.Amount;
                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Principal Paid", LineNo, SourceCode, ReasonCode, ExtDocNo, '', 0, '', JournalTemplate, JournalBatch);
                                end;
                            StandingOrder."Standing Order Class"::"Loan-Interest":
                                begin
                                    Loans.Get(StandingOrder."Destination Account");
                                    PostingAmount := StandingOrder.Amount;
                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ExtDocNo, '', 0, '', JournalTemplate, JournalBatch);
                                end;
                            StandingOrder."Standing Order Class"::"Loan Principal+Interest":
                                begin
                                    if Loans.Get(StandingOrder."Destination Account") then begin
                                        Loans.CalcFields("Principal Balance", "Interest Balance");
                                        InterestPaid := 0;
                                        PrincipalPaid := 0;
                                        InterestBalance := 0;
                                        UnAllocatedAmount := 0;
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
                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, Loans."Loan Account", PostingDate, PostingDescription, -1 * InterestPaid, Dim1, Dim2, Loans."Member No.", DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, Loans."Product Code", Loans."No.", Loans."Member No.", '', 0, '', JournalTemplate, JournalBatch);
                                        PostingDescription := 'Principal Paid';
                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, Loans."Loan Account", PostingDate, PostingDescription, -1 * PrincipalPaid, Dim1, Dim2, Loans."Member No.", DocumentNo, GlobalTransactionType::"Principal Paid", LineNo, Loans."Product Code", Loans."No.", Loans."Member No.", '', 0, '', JournalTemplate, JournalBatch);
                                        if UnallocatedAmount <> 0 then begin
                                            //Post Unallocated Amount
                                            PostingDescription := 'School Fee Transfer';
                                            LineNo := JournalManagement.CreateUnallocationJournalLine(GlobalAccountType::Vendor, '', PostingDate, PostingDescription, UnAllocatedAmount, Dim1, Dim2, Loans."Member No.", DocumentNo, GlobalTransactionType::"Acc. Transfer", LineNo, Loans."Product Code", Loans."No.", Loans."Member No.", JournalTemplate, JournalBatch);
                                        end;
                                    end;
                                end;
                        end;
                        JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
                    end;
                end;
            end;
        end;
    end;

    procedure STOFreezeMgmt(STONo: Code[20]; FreezeOption: Option Freeze,UnFreeze; FreezeDate: Date)
    var
        StandingOrder: Record "Standing Order";
    begin
        if StandingOrder.Get(STONo) then begin
            if FreezeOption = FreezeOption::Freeze then begin
                StandingOrder."Freeze End Date" := FreezeDate;
                StandingOrder.Freezed := true;
            end
            else if FreezeOption = FreezeOption::UnFreeze then begin
                StandingOrder."Freeze End Date" := 0D;
                StandingOrder.Freezed := false;
            end;
            StandingOrder.Modify(true);
        end;
    end;

    local procedure CreateCheckDepositLien(DocNo: Code[20])
    var
        UnclearedEffect: Record "Uncleared Funds";
        ChequeDeposit: Record "Cheque Deposits";
    begin
        if ChequeDeposit.Get(DocNo) then begin
            if ChequeDeposit."Express Cheque" then begin
                UnclearedEffect.Init();
                UnclearedEffect."Entry No" := UnclearedEffect.GetLastEntryNo + 1;
                UnclearedEffect.Validate("Member No", ChequeDeposit."Member No");
                UnclearedEffect."Document No" := DocNo;
                UnclearedEffect.Amount := (ChequeDeposit.Amount - ChequeDeposit."Express Amount");
                UnclearedEffect."Account No" := ChequeDeposit."Account No.";
                UnclearedEffect."Created By" := UserId;
                UnclearedEffect."Created On" := CurrentDateTime;
                UnclearedEffect.Insert(true);
            end;
        end;
    end;

    procedure UpdateSTO(STONo: Code[20]; AsAtDate: Date)
    var
        StandingOrder: Record "Standing Order";
    begin
        SaccoSetup.Get;
        StandingOrder.Reset();
        if STONo <> '' then
            StandingOrder.SetRange("No.", STONo);
        StandingOrder.SetRange(Terminated, false);
        StandingOrder.SetRange(Running, true);
        if StandingOrder.FindSet() then begin
            repeat
                if ((StandingOrder.Freezed) and (StandingOrder."Freeze End Date" < AsAtDate)) then begin
                    StandingOrder.Freezed := false;
                    StandingOrder.Modify(true);
                end;

                if Loans.Get(StandingOrder."Destination Account") then begin
                    if SaccoSetup."Daily Interest Accrual" then
                        LoansMgt.PostLoanInterest(AsAtDate, '', 0, Loans."Member No.", Loans."No.");
                    Loans.CalcFields("Loan Balance");
                    if Loans."Loan Balance" <= 0 then begin
                        StandingOrder.Terminated := true;
                        StandingOrder.Running := false;
                        StandingOrder.Modify(true);
                    end;
                end;

                if StandingOrder."End Date" < WorkDate then begin
                    StandingOrder.Terminated := true;
                    StandingOrder.Running := false;
                    StandingOrder.Modify(true)
                end;
            until StandingOrder.Next = 0;
        end;
    end;

    procedure UpdateCheque()
    var
        ChequeDeposits: Record "Cheque Deposits";
    begin
        ChequeDeposits.Reset();
        ChequeDeposits.SetRange(Status, ChequeDeposits.Status::Approved);
        if ChequeDeposits.FindSet then begin
            if ChequeDeposits."Maturity Date" >= WorkDate then begin
                ChequeDeposits.Due := true;
                ChequeDeposits.Modify(true);
            end;
        end;
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterPostInterAccountTransfer(var InterAccountTransfer: Record "Inter Account Transfer")
    begin
    end;
}
