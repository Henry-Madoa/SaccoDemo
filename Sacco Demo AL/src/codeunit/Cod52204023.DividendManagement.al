codeunit 52204023 "Dividend Management"
{
    var
        Window: Dialog;
        All: Integer;
        Current: Integer;
        Dim1: Code[20];
        Dim2: Code[20];
        RecoveryCode: Code[20];
        LoanNo: Code[20];
        PostingDescription: Text[100];
        PostingAmount: Decimal;
        EntryType: Enum "Dividend Recovery Types";
        ProductPostingType: Enum "Product Posting Type";
        JournalMgmt: Codeunit "Journal Management";
        LoansMgmt: Codeunit "Loans Management";
        MemberMgmt: Codeunit "Member Management";
        Member: Record Members;
        Vendor: Record Vendor;
        DividendLines: Record "Dividend Lines";
        DividendDetEntries: Record "Dividend Det. Entries";
        DividendDetRunningEntries: Record "Dividend Det. Running Entries";
        DividendMemberList: Record "Dividend Member List";
        DividendRecoveries: array[7] of Record "Dividend Recoveries";
        SaccoProduct: Record "Sacco Products";
        DividendWithdrawnMembers: Record "Dividend Withdrawn Members";
        TransactionTypeRecoveries: Record "Transaction Recoveries";
        Loans: Record Loans;

    [Scope('Cloud')]
    procedure CalculateDividend(DividendHeader: Record "Dividend Header")
    begin
        PrepareDividendCalculation(DividendHeader);
        PopulateDivindedMembers(DividendHeader);
        PopulateWithdrawnMembers(DividendHeader);
        PopulateMemberList(DividendHeader);
        PopulatePreviousAccounts(DividendHeader);
        CalculateDividendCharges(DividendHeader);
        LoanRecoveries(DividendHeader);
        ComputeDividendBoosts(DividendHeader);
        ComputePreferentialBoost(DividendHeader);
        CalculateNetAmount(DividendHeader);
    end;

    [Scope('Cloud')]
    procedure PostDividend(DividendHeader: Record "Dividend Header"; Queued: Boolean)
    var
        DividendLines: Record "Dividend Lines";
        JournalTemplate, JournalBatch, DocumentNo, AccountNo, MemberNo, ExternalDocumentNo, SourceCode, ReasonCode : Code[20];
        GlobalAccountType: Enum "Gen. Journal Account Type";
        GlobalTransactionType: Enum "Sacco Transaction Type";
        GLEntry: Record "G/L Entry";
        PostingAmount: Decimal;
        PostingDate: Date;
        JournalMgmt: Codeunit "Journal Management";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        LineNo: Integer;
        DividendDetEntries: Record "Dividend Det. Entries";
        TotalDebit: Decimal;
        TransactionChargesSetup: Record "Transaction Charges Setup";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        DeductedAmount: Decimal;
        RecoveredAmount: Decimal;
        GenJnlLine: Record "Gen. Journal Line";
        Prefix: Code[20];
    begin
        InitializePosting(DividendHeader);
        if DividendHeader."Posting Type" = DividendHeader."Posting Type"::Provisioning then begin
            JournalTemplate := 'PAYMENT';
            JournalBatch := 'DIV-PROV';
            LineNo := JournalMgmt.PrepareJournal(JournalTemplate, JournalBatch);
            Prefix := '';
            case DATE2DMY(DividendHeader."Posting Date", 2) of
                1:
                    Prefix := 'JAN-';
                2:
                    Prefix := 'FEB-';
                3:
                    Prefix := 'MAR-';
                4:
                    Prefix := 'APR-';
                5:
                    Prefix := 'MAY-';
                6:
                    Prefix := 'JUN-';
                7:
                    Prefix := 'JUL-';
                8:
                    Prefix := 'AUG-';
                9:
                    Prefix := 'SEP-';
                10:
                    Prefix := 'OCT-';
                11:
                    Prefix := 'NOV-';
                12:
                    Prefix := 'DEC-';
            end;
            Prefix += FORMAT(DATE2DMY(DividendHeader."Posting Date", 3));
            TotalDebit := 0;
            DividendLines.Reset;
            if DividendHeader."Progression Computation Type" = DividendHeader."Progression Computation Type"::Automatic then
                DividendLines.SETFILTER("Automatic Amount Earned", '<>%1', 0)
            else
                DividendLines.SETFILTER("Manual Amount Earned", '<>%1', 0);
            DividendLines.SetRange("Dividend Code", DividendHeader."No.");
            DividendLines.SetRange(Posted, false);
            if DividendLines.FindFirst then begin
                All := DividendLines.Count;
                Current := 0;
                Window.Open('Counting Dividends Provisioning #1### #2### #3###');
                repeat
                    Current += 1;
                    if GUIALLOWED then begin
                        Window.Update(1, DividendLines."Member Name");
                        Window.Update(2, StrSubstNo('%1%', Round((Current / All) * 100, 0.01)));
                        Window.Update(3, FORMAT(Current) + ' of ' + FORMAT(All));
                    end;
                    Dim1 := '';
                    Dim2 := '';
                    if Member.GET(DividendLines."Member No.") then begin
                        Dim1 := Member."Global Dimension 1 Code";
                        Dim2 := Member."Global Dimension 2 Code";
                    end;
                    ReasonCode := DividendLines."Member No.";
                    SourceCode := 'PROVISION';
                    ExternalDocumentNo := Prefix;
                    DocumentNo := DividendHeader."No.";
                    PostingDate := DividendHeader."Posting Date";
                    PostingAmount := 0;
                    DividendLines.CALCFIELDS("Automatic Amount Earned", "Manual Amount Earned");
                    PostingAmount := DividendLines."Automatic Amount Earned" + DividendLines."Manual Amount Earned";
                    PostingDescription := COPYSTR(DividendLines."Member Name" + ' Provisioning ' + DividendLines."Member No.", 1, 100);
                    GlobalTransactionType := GlobalTransactionType::General;
                    AccountNo := '';
                    AccountNo := DividendHeader."Expense Account No.";
                    LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::General, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                    AccountNo := '';
                    AccountNo := DividendHeader."Payable Account No.";
                    LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::General, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                until DividendLines.NEXT = 0;
                Window.Close;
            end;
        end
        else if DividendHeader."Posting Type" = DividendHeader."Posting Type"::Payout then begin
            JournalTemplate := 'PAYMENT';
            JournalBatch := 'DIVIDEND';
            LineNo := JournalMgmt.PrepareJournal(JournalTemplate, JournalBatch);
            DividendLines.Reset;
            DividendLines.SetRange("Dividend Code", DividendHeader."No.");
            DividendLines.SetRange(Posted, false);
            if DividendHeader."Progression Computation Type" = DividendHeader."Progression Computation Type"::Automatic then
                DividendLines.SETFILTER("Automatic Amount Earned", '>%1', 0)
            else
                DividendLines.SETFILTER("Manual Amount Earned", '>%1', 0);
            DividendLines.SETCURRENTKEY("Member No.");
            if DividendLines.FindSet then begin
                repeat
                    if Member.GET(DividendLines."Member No.") then begin
                        Dim1 := Member."Global Dimension 1 Code";
                        Dim2 := Member."Global Dimension 2 Code";
                    end;
                    DocumentNo := DividendHeader."No.";
                    PostingDate := DividendHeader."Posting Date";
                    ExternalDocumentNo := DividendLines."Member No.";
                    ReasonCode := DividendLines."Member No.";
                    SourceCode := 'DIVIDEND';
                    MemberNo := Member."No.";
                    //Credit Member With Full Amount
                    DividendLines.CALCFIELDS("Automatic Amount Earned", "Manual Amount Earned");
                    PostingAmount := 0;
                    PostingAmount := DividendLines."Automatic Amount Earned" + DividendLines."Manual Amount Earned";
                    PostingDescription := DividendHeader."Posting Description";
                    AccountNo := '';
                    AccountNo := DividendLines."Savings Account";
                    GlobalTransactionType := GlobalTransactionType::"Divinded Processing";

                    LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                    AccountNo := '';
                    AccountNo := DividendHeader."Payable Account No.";
                    LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);

                    //Post Charges
                    DividendRecoveries[1].Reset;
                    DividendRecoveries[1].SETFILTER("Recovery Code", '<>%1', '');
                    DividendRecoveries[1].SetRange("Entry Type", DividendRecoveries[1]."Entry Type"::Charges);
                    DividendRecoveries[1].SetRange("Dividend Code", DividendHeader."No.");
                    DividendRecoveries[1].SetRange("Member No", DividendLines."Member No.");
                    DividendRecoveries[1].SetRange("Account No.", DividendLines."Account No");
                    DividendRecoveries[1].SetCurrentKey(Priority);
                    DividendRecoveries[1].SetAscending(Priority, true);
                    if DividendRecoveries[1].FindFirst then begin
                        All := DividendRecoveries[1].Count;
                        Current := 0;
                        Window.Open('Posting Charges #1### #2### #3###');
                        repeat
                            Current += 1;
                            if GUIALLOWED then begin
                                Window.Update(1, DividendLines."Member Name");
                                Window.Update(2, StrSubstNo('%1%', Round((Current / All) * 100, 0.01)));
                                Window.Update(3, FORMAT(Current) + ' of ' + FORMAT(All));
                            end;
                            if TransactionChargesSetup.GET(DividendHeader."Transaction Code", DividendRecoveries[1]."Recovery Code") then begin
                                //Credit Account
                                PostingAmount := 0;
                                PostingAmount := Abs(DividendRecoveries[1].Amount);
                                PostingDescription := TransactionChargesSetup.Description;
                                AccountNo := '';
                                AccountNo := TransactionChargesSetup."Post-to Account No.";
                                LineNo := JournalMgmt.CreateJournalLine(TransactionChargesSetup."Post to Account Type", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                AccountNo := '';
                                AccountNo := DividendLines."Savings Account";
                                LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                Commit;
                            end;
                        until DividendRecoveries[1].NEXT = 0;
                        Window.Close;
                    end;
                    Commit;
                    //Boost
                    DividendRecoveries[2].Reset;
                    DividendRecoveries[2].SetFilter("Entry Type", '%1|%2', DividendRecoveries[2]."Entry Type"::Boost, DividendRecoveries[2]."Entry Type"::"Preferential Boost");
                    DividendRecoveries[2].SetRange("Dividend Code", DividendHeader."No.");
                    DividendRecoveries[2].SetRange("Member No", DividendLines."Member No.");
                    DividendRecoveries[2].SetRange("Account No.", DividendLines."Account No");
                    if DividendRecoveries[2].FindFirst then begin
                        All := DividendRecoveries[2].Count;
                        Current := 0;
                        Window.Open('Posting Boosting #1### #2### #3###');
                        repeat
                            Current += 1;
                            if GUIALLOWED then begin
                                Window.Update(1, DividendLines."Member Name");
                                Window.Update(2, StrSubstNo('%1%', Round((Current / All) * 100, 0.01)));
                                Window.Update(3, FORMAT(Current) + ' of ' + FORMAT(All));
                            end;
                            PostingAmount := 0;
                            PostingAmount := Abs(DividendRecoveries[2].Amount);
                            PostingDescription := 'Boost ' + DividendRecoveries[2]."Account No.";
                            AccountNo := '';
                            AccountNo := MemberMgmt.GetMemberAccount(DividendLines."Member No.", ProductPostingType::"Share Capital Account");
                            LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                            AccountNo := '';
                            AccountNo := LoansMgmt.GetFOSAAccount(DividendLines."Member No.");
                            LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                            Commit;
                        until DividendRecoveries[2].NEXT = 0;
                        Window.Close;
                    end;
                    Commit;
                    //Post Loan Interest To FOSA
                    DividendRecoveries[3].Reset;
                    DividendRecoveries[3].SetRange("Entry Type", DividendRecoveries[3]."Entry Type"::"Interest Paid");
                    DividendRecoveries[3].SetRange("Dividend Code", DividendHeader."No.");
                    DividendRecoveries[3].SetRange("Member No", DividendLines."Member No.");
                    DividendRecoveries[3].SetRange("Account No.", DividendLines."Account No");
                    if DividendRecoveries[3].FindSet then begin
                        DividendRecoveries[3].CalcSums(Amount);
                        PostingAmount := 0;
                        PostingAmount := Abs(DividendRecoveries[3].Amount);
                        PostingDescription := 'Interest Recovered on Dividend Advance';
                        AccountNo := '';
                        AccountNo := LoansMgmt.GetFOSAAccount(DividendLines."Member No.");
                        LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                    end;
                    Commit;
                    //Post Loan Principal To FOSA
                    DividendRecoveries[4].Reset;
                    DividendRecoveries[4].SetRange("Entry Type", DividendRecoveries[4]."Entry Type"::"Principal Paid");
                    DividendRecoveries[4].SetRange("Dividend Code", DividendHeader."No.");
                    DividendRecoveries[4].SetRange("Member No", DividendLines."Member No.");
                    DividendRecoveries[4].SetRange("Account No.", DividendLines."Account No");
                    if DividendRecoveries[4].FindSet then begin
                        DividendRecoveries[4].CalcSums(Amount);
                        PostingAmount := 0;
                        PostingAmount := Abs(DividendRecoveries[4].Amount);
                        PostingDescription := 'Principal Recovered on Dividend Advance';
                        AccountNo := '';
                        AccountNo := LoansMgmt.GetFOSAAccount(DividendLines."Member No.");
                        LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                    end;
                    Commit;
                    //Post Loans Interest Arrears To FOSA
                    DividendRecoveries[5].Reset;
                    DividendRecoveries[5].SetRange("Entry Type", DividendRecoveries[5]."Entry Type"::"Interest Arrears");
                    DividendRecoveries[5].SetRange("Dividend Code", DividendHeader."No.");
                    DividendRecoveries[5].SetRange("Member No", DividendLines."Member No.");
                    DividendRecoveries[5].SetRange("Account No.", DividendLines."Account No");
                    if DividendRecoveries[5].FindSet then begin
                        DividendRecoveries[5].CalcSums(Amount);
                        PostingAmount := 0;
                        PostingAmount := Abs(DividendRecoveries[5].Amount);
                        PostingDescription := 'Interest Arrears Recovery';
                        AccountNo := '';
                        AccountNo := LoansMgmt.GetFOSAAccount(DividendLines."Member No.");
                        LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                    end;
                    Commit;
                    //Post Loans Principal Arrears To FOSA
                    DividendRecoveries[6].Reset;
                    DividendRecoveries[6].SetRange("Entry Type", DividendRecoveries[6]."Entry Type"::"Principal Arrears");
                    DividendRecoveries[6].SetRange("Dividend Code", DividendHeader."No.");
                    DividendRecoveries[6].SetRange("Member No", DividendLines."Member No.");
                    DividendRecoveries[6].SetRange("Account No.", DividendLines."Account No");
                    if DividendRecoveries[6].FindSet then begin
                        DividendRecoveries[6].CalcSums(Amount);
                        PostingAmount := 0;
                        PostingAmount := Abs(DividendRecoveries[6].Amount);
                        PostingDescription := 'Principal Arrears Recovery';
                        AccountNo := '';
                        AccountNo := LoansMgmt.GetFOSAAccount(DividendLines."Member No.");
                        LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                    end;
                    Commit;
                    //Post Loans
                    DividendRecoveries[7].Reset;
                    DividendRecoveries[7].SETFILTER("Entry Type", '%1|%2|%3|%4', DividendRecoveries[7]."Entry Type"::"Interest Arrears", DividendRecoveries[7]."Entry Type"::"Interest Paid", DividendRecoveries[7]."Entry Type"::"Principal Arrears", DividendRecoveries[7]."Entry Type"::"Principal Paid");
                    DividendRecoveries[7].SetRange("Dividend Code", DividendHeader."No.");
                    DividendRecoveries[7].SetRange("Member No", DividendLines."Member No.");
                    DividendRecoveries[7].SetRange("Account No.", DividendLines."Account No");
                    DividendRecoveries[7].SetCurrentKey("Loan No");
                    DividendRecoveries[7].SetAscending("Loan No", true);
                    if DividendRecoveries[7].FindFirst then begin
                        All := DividendRecoveries[7].Count;
                        Current := 0;
                        Window.Open('Posting Loans Recoveries #1### #2### #3###');
                        repeat
                            Current += 1;
                            if GUIALLOWED then begin
                                Window.Update(1, DividendLines."Member Name");
                                Window.Update(2, StrSubstNo('%1%', Round((Current / All) * 100, 0.01)));
                                Window.Update(3, FORMAT(Current) + ' of ' + FORMAT(All));
                            end;
                            Loans.GET(DividendRecoveries[7]."Recovery Code");
                            ReasonCode := Loans."No.";
                            SourceCode := Loans."Product Code";
                            SaccoProduct.GET(Loans."Product Code");
                            if DividendRecoveries[7]."Entry Type" in [DividendRecoveries[7]."Entry Type"::"Interest Arrears", DividendRecoveries[7]."Entry Type"::"Interest Paid"] then begin
                                PostingAmount := 0;
                                PostingAmount := Abs(DividendRecoveries[7].Amount);
                                PostingDescription := DividendRecoveries[7].Description;
                                GlobalTransactionType := GlobalTransactionType::"Interest Paid";
                                AccountNo := '';
                                AccountNo := Loans."Loan Account";
                                LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                Commit;
                            end
                            else if DividendRecoveries[7]."Entry Type" in [DividendRecoveries[7]."Entry Type"::"Principal Arrears", DividendRecoveries[7]."Entry Type"::"Principal Paid"] then begin
                                PostingAmount := 0;
                                PostingAmount := Abs(DividendRecoveries[7].Amount);
                                PostingDescription := DividendRecoveries[7].Description;
                                GlobalTransactionType := GlobalTransactionType::"Principal Paid";
                                AccountNo := '';
                                AccountNo := Loans."Loan Account";
                                LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                Commit;
                            end;
                        until DividendRecoveries[7].NEXT = 0;
                        Window.Close;
                    end;
                until DividendLines.NEXT = 0;
            end;
        end;
        JournalMgmt.CompletePosting(JournalTemplate, JournalBatch);
        OnAfterPostDividend(DividendHeader);
        Commit;
        GLEntry.Reset;
        GLEntry.SetRange(GLEntry."Document No.", DividendHeader."No.");
        GLEntry.SetRange(GLEntry.Reversed, false);
        if GLEntry.FindFirst then begin
            if Queued then begin
                if DividendHeader.GET(DividendHeader."No.") then begin
                    DividendHeader."Next Run Date" := CALCDATE('1M', TODAY);
                    DividendHeader.MODIFY;
                end;
            end
            else begin
                if DividendHeader.GET(DividendHeader."No.") then begin
                    DividendHeader.Posted := true;
                    DividendHeader."Posted By" := USERID;
                    DividendHeader."Posted On" := TODAY;
                    DividendHeader.MODIFY;
                    DividendLines.Reset();
                    DividendLines.SetRange("Dividend Code", DividendHeader."No.");
                    if DividendLines.FindSet then begin
                        repeat
                            if DividendLines."Blocked Account" then begin
                                if Vendor.Get(DividendLines."Savings Account") then begin
                                    Vendor.Blocked := Vendor.Blocked::All;
                                    Vendor.Modify(true);
                                end;
                            end;
                            DividendLines.Posted := true;
                            DividendLines.Modify(true);
                        until DividendLines.Next = 0;
                    end;
                end;
            end;
        end;
    end;

    [Scope('Cloud')]
    procedure InitializePosting(DividendHeader: Record "Dividend Header")
    var
        DividendLines: Record "Dividend Lines";
        ODAmount: Decimal;
    begin
        DividendLines.Reset;
        DividendLines.SetRange("Dividend Code", DividendHeader."No.");
        DividendLines.SetRange(Posted, false);
        if DividendLines.FindFirst then begin
            All := DividendLines.Count;
            Window.Open('Preparing to Post #1### #2### #3###');
            Current := 0;
            repeat
                Current += 1;
                if GUIALLOWED then begin
                    Window.Update(1, DividendLines."Member Name");
                    Window.Update(2, StrSubstNo('%1%', Round((Current / All) * 100, 0.01)));
                    Window.Update(3, FORMAT(Current) + ' of ' + FORMAT(All));
                end;
                if DividendLines."Savings Account" = '' then begin
                    DividendLines."Savings Account" := LoansMgmt.GetFOSAAccount(DividendLines."Member No.");
                    DividendLines.MODIFY;
                    Commit;
                end;
                if Vendor.GET(DividendLines."Savings Account") then begin
                    if Vendor.Blocked <> Vendor.Blocked::" " then begin
                        Vendor.Blocked := Vendor.Blocked::" ";
                        Vendor.MODIFY;
                        DividendLines."Blocked Account" := true;
                        DividendLines.Modify(true);
                    end;
                end;
            until DividendLines.NEXT = 0;
            Window.Close;
        end;
    end;

    [Scope('Cloud')]
    procedure GetPrincipalApplicationNo(MemberNo: Code[20]; LoanProduct: Code[20]; AmountToApply: Decimal) DocNumber: Code[20]
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        DocNumber := '';
        /*VendorLedgerEntry.Reset;
                VendorLedgerEntry.SETFILTER("Transaction Type",'<>%1',VendorLedgerEntry."Transaction Type"::"Interest Due");
                VendorLedgerEntry.SetRange(Positive,TRUE);
                VendorLedgerEntry.SetRange(Reversed,FALSE);
                VendorLedgerEntry.SetRange("Vendor No.",LoanProduct+'-'+MemberNo);
                IF VendorLedgerEntry.FindFirst then begin
                  REPEAT
                    VendorLedgerEntry.CALCFIELDS("Remaining Amount");
                    IF VendorLedgerEntry."Remaining Amount">=AmountToApply THEN
                      DocNumber:=VendorLedgerEntry."Document No.";
                  UNTIL VendorLedgerEntry.NEXT = 0;
                  end;
                EXIT(DocNumber);*/
    end;

    [Scope('Cloud')]
    procedure GetDisbursalApplicationNo(MemberNo: Code[20]; AmountToApply: Decimal) DocNumber: Code[20]
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VLedger: Record "Vendor Ledger Entry";
    begin
        DocNumber := ''; /*
        VendorLedgerEntry.Reset;
        VendorLedgerEntry.SetRange(Positive,FALSE);
        VendorLedgerEntry.SetRange(Reversed,FALSE);
        VendorLedgerEntry.SetRange("Vendor No.",LoansManagement.GetFOSAAccount(MemberNo));
        IF VendorLedgerEntry.FindFirst then begin
          REPEAT
            VLedger.Reset;
            VLedger.SetRange("Document No.",VendorLedgerEntry."Document No.");
            VLedger.SetRange("Vendor No.",VendorLedgerEntry."Vendor No.");
            IF VLedger.FindFirst then begin
              IF VLedger.Count=1 THEN BEGIN
                VendorLedgerEntry.CALCFIELDS("Remaining Amount");
                IF Abs(VendorLedgerEntry."Remaining Amount")>=AmountToApply THEN
                  DocNumber:=VendorLedgerEntry."Document No.";
                end;
              end;
          UNTIL VendorLedgerEntry.NEXT = 0;
          end;*/
        exit(DocNumber);
    end;

    [Scope('Cloud')]
    procedure SendSMSNotifications(DividendHeader: Record "Dividend Header")
    var
        DividendLines: Record "Dividend Lines";
        SMSNo: Text[250];
        SMSText: Text[500];
        TransactionsType: Option Deposit,Withdrawal;
        CompanyInformation: Record "Company Information";
        NotificationsManagement: Codeunit "Notifications Management";
        Customer: Record Customer;
        JournalBatch: Code[20];
        JournalTemplate: Code[20];
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        CompanyInformation.GET;
        DividendLines.Reset;
        if DividendHeader."Progression Computation Type" = DividendHeader."Progression Computation Type"::Automatic then
            DividendLines.SETFILTER("Automatic Amount Earned", '<>%1', 0)
        else
            DividendLines.SETFILTER("Manual Amount Earned", '<>%1', 0);
        DividendLines.SetRange("Dividend Code", DividendHeader."No.");
        DividendLines.SetRange(Posted, true);
        DividendLines.SetRange(Notified, false);
        DividendLines.SETFILTER("Phone No.", '<>%1', '');
        if DividendLines.FindFirst then begin
            All := DividendLines.Count;
            Current := 0;
            Window.Open('Sending SMS Notifications #1### #2### #3###');
            repeat
                CompanyInformation.GET;
                DividendLines.CALCFIELDS("Manual Amount Earned", "Automatic Amount Earned", "Charges Amount", "Loans Recoveries", "Loan Arrears");
                Current += 1;
                Window.Update(1, DividendLines."Member No." + '-' + DividendLines."Member Name");
                Window.Update(2, StrSubstNo('%1%', Round((Current / All) * 100, 0.01)));
                Window.Update(3, FORMAT(All - Current));
                Member.GET(DividendLines."Member No.");
                SMSNo := DividendLines."Phone No.";
                if StrLen(SMSNo) <= 15 then begin
                    SMSText := '';
                    if DividendLines."Loans Recoveries" = 0 then
                        SMSText := StrSubstNo('Dear %1, %2 of Kes. %3, Less W/Tax of Kes. %4. The Net Amount Credited to your FOSA Account is Kes. %5. Save more for better returns.', Member."First Name", DividendHeader.Description, Round(DividendLines."Automatic Amount Earned" + DividendLines."Manual Amount Earned"), Abs(Round(DividendLines."Charges Amount")), Round(DividendLines."Net Amount"))
                    else
                        SMSText := StrSubstNo('Dear %1, %2 of Kes. %3, Less W/Tax of Kes. %4, Dividend Advance Recoveries of Kes. %5, Loan Arrear of Kes %6. The Net Amount Credited to your FOSA Account is Kes. %7. Save more for better returns.', Member."First Name", DividendHeader.Description, Round(DividendLines."Automatic Amount Earned" + DividendLines."Manual Amount Earned"), Abs(Round(DividendLines."Charges Amount")), Abs(Round(DividendLines."Loans Recoveries" - DividendLines."Loan Arrears")), Abs(Round(DividendLines."Loan Arrears")), Round(DividendLines."Net Amount"));
                    NotificationsManagement.SendSms(SMSNo, SMSText, Member."No.");
                    DividendLines.Posted := true;
                    DividendLines.Notified := true;
                    DividendLines.MODIFY;
                end;
                Commit;
            until DividendLines.NEXT = 0;
            Window.Close;
        end;
    end;

    local procedure PopulateDivindedMembers(DividendHeader: Record "Dividend Header")
    var
        DividendMembers: Record "Dividend Member List";
        DividendEarnedEntries: Record "Dividend Earned Entries";
        Current: Integer;
        All: Integer;
    begin
        Member.Reset();
        Member.SetRange("Dividend Exempt", false);
        if Member.FindSet then begin
            Window.Open('Updating Member #1### #2### #3###');
            All := Member.Count;
            Current := 0;
            repeat
                Current += 1;
                Window.Update(1, Member.FullName);
                Window.Update(2, StrSubstNo('%1%', Round((Current / All) * 100, 0.01)));
                Window.Update(3, FORMAT(Current) + ' of ' + FORMAT(All));

                DividendMembers.Init();
                DividendMembers."Dividend Code" := DividendHeader."No.";
                DividendMembers."Member No." := Member."No.";
                DividendMembers."Member Name" := Member.FullName;
                if DividendHeader."Progression Computation Type" = DividendHeader."Progression Computation Type"::"Manual Upload" then begin
                    DividendEarnedEntries.Reset();
                    DividendEarnedEntries.SetRange("Dividend Code", DividendHeader."No.");
                    DividendEarnedEntries.SetRange("Member No.", Member."No.");
                    if DividendEarnedEntries.FindFirst then
                        DividendMembers.Insert(true);
                end else
                    DividendMembers.Insert(true);
            until Member.Next = 0;
            Window.Close;
        end;
    end;

    local procedure PrepareDividendCalculation(DividendHeader: Record "Dividend Header")
    begin
        DividendLines.Reset;
        DividendLines.SetRange("Dividend Code", DividendHeader."No.");
        if DividendLines.FINDFIRST then
            DividendLines.DELETEALL;

        DividendMemberList.Reset;
        DividendMemberList.SetRange("Dividend Code", DividendHeader."No.");
        if DividendMemberList.FindSet then
            DividendMemberList.DELETEALL;

        DividendRecoveries[1].Reset;
        DividendRecoveries[1].SetRange("Dividend Code", DividendHeader."No.");
        if DividendRecoveries[1].FINDFIRST then
            DividendRecoveries[1].DELETEALL;

        DividendDetEntries.Reset;
        DividendDetEntries.SetRange("Dividend Code", DividendHeader."No.");
        DividendDetEntries.SetRange("System Entry", true);
        if DividendDetEntries.FINDFIRST then
            DividendDetEntries.DELETEALL;

        DividendDetRunningEntries.Reset;
        DividendDetRunningEntries.SetRange("Dividend Code", DividendHeader."No.");
        if DividendDetRunningEntries.FINDFIRST then
            DividendDetRunningEntries.DELETEALL;
    end;

    local procedure PopulateWithdrawnMembers(DividendHeader: Record "Dividend Header")
    var
        AccountClosureHeader: Record "Member Withdrawal";
    begin
        //Check Withdrawals
        AccountClosureHeader.Reset;
        AccountClosureHeader.SETFILTER("Maturity Date", '%1..%2', DMY2DATE(1, 1, DATE2DMY(DividendHeader."End Date", 3)), DMY2DATE(31, 12, DATE2DMY(DividendHeader."End Date", 3)));
        AccountClosureHeader.SetRange(Posted, true);
        if AccountClosureHeader.FindSet then begin
            All := AccountClosureHeader.Count;
            Current := 0;
            Window.Open('Checking Processed Account Closures \#1## \#2##\#3##');
            repeat
                Current += 1;
                if GUIALLOWED then begin
                    Window.Update(1, AccountClosureHeader."Member Name");
                    Window.Update(2, StrSubstNo('%1%', Round((Current / All) * 100, 0.01)));
                    Window.Update(3, FORMAT(Current) + ' of ' + FORMAT(All));
                end;
                if DividendWithdrawnMembers.GET(DividendHeader."No.", AccountClosureHeader."Member No") = false then begin
                    DividendWithdrawnMembers.INIT;
                    DividendWithdrawnMembers."Dividend Header" := DividendHeader."No.";
                    DividendWithdrawnMembers."Member No" := AccountClosureHeader."Member No";
                    DividendWithdrawnMembers."Member Name" := AccountClosureHeader."Member Name";
                    DividendWithdrawnMembers.INSERT;
                end;
            until AccountClosureHeader.NEXT = 0;
            Window.Close;
        end;
    end;

    local procedure PopulateMemberList(DividendHeader: Record "Dividend Header")
    var
        DividendMemberList: Record "Dividend Member List";
        Customer: Record Customer;
        DividendCalculationParams: Record "Dividend Calculation Params";
        Vendor: Record Vendor;
        DividendLines: Record "Dividend Lines";
    begin
        DividendMemberList.Reset;
        DividendMemberList.SetRange("Dividend Code", DividendHeader."No.");
        if DividendMemberList.FindSet then begin
            Window.Open('Updating Divinded Lines #1### #2### #3###');
            All := DividendMemberList.Count;
            Current := 0;
            repeat
                Current += 1;
                if Member.GET(DividendMemberList."Member No.") then begin
                    Window.Update(1, Member.FullName);
                    Window.Update(2, StrSubstNo('%1%', Round((Current / All) * 100, 0.01)));
                    Window.Update(3, FORMAT(Current) + ' of ' + FORMAT(All));
                    DividendCalculationParams.Reset;
                    DividendCalculationParams.SetRange("Dividend Code", DividendHeader."No.");
                    if DividendCalculationParams.FindFirst then begin
                        repeat
                            Vendor.Reset();
                            Vendor.SetRange("Product Code", DividendCalculationParams.Type);
                            Vendor.SetRange("Member No.", Member."No.");
                            if Vendor.Findset then begin
                                repeat
                                    Vendor.CALCFIELDS(Balance);
                                    DividendLines.INIT;
                                    DividendLines."Dividend Code" := DividendHeader."No.";
                                    DividendLines."Member No." := Member."No.";
                                    DividendLines."Member Name" := Member."Full Name";
                                    DividendLines.Deceased := Member.Status = Member.Status::Deceased;
                                    DividendLines."Account Type" := DividendCalculationParams.Type;
                                    DividendLines."Account No" := Vendor."No.";
                                    DividendLines."Savings Account" := LoansMgmt.GetFOSAAccount(DividendMemberList."Member No.");
                                    DividendLines.VALIDATE("Prefrential Boost");
                                    DividendLines."Phone No." := Member."Mobile Transacting No";
                                    DividendLines."Prefrential Boost" := Member."Prefrential Boost";
                                    DividendLines."Preferential Boost %" := Member."Preferential Boost %";
                                    DividendLines."Account Balance" := Vendor.Balance;
                                    DividendLines."Posting Description" := DividendCalculationParams."Posting Description";
                                    DividendLines.INSERT;
                                until Vendor.Next = 0;
                            end;
                        until DividendCalculationParams.NEXT = 0;
                    end;
                end;
            until DividendMemberList.NEXT = 0;
            Window.Close;
        end;
    end;

    local procedure GetPrefixCode(Pdate: Date) PCode: Code[10]
    begin
        PCode := '';
        case DATE2DMY(Pdate, 2) of
            1:
                PCode := 'JAN-';
            2:
                PCode := 'FEB-';
            3:
                PCode := 'MAR-';
            4:
                PCode := 'APR-';
            5:
                PCode := 'MAY-';
            6:
                PCode := 'JUN-';
            7:
                PCode := 'JUL-';
            8:
                PCode := 'AUG-';
            9:
                PCode := 'SEP-';
            10:
                PCode := 'OCT-';
            11:
                PCode := 'NOV-';
            12:
                PCode := 'DEC-';
        end;
        PCode += FORMAT(DATE2DMY(Pdate, 3));
        exit(PCode);
    end;

    local procedure PopulatePreviousAccounts(DividendHeader: Record "Dividend Header")
    var
        PrevMnthCode: Code[10];
        CurrMnthCode: Code[10];
        Vendor: Record Vendor;
        DividendDetEntries: Record "Dividend Det. Entries";
        DividendCalculationParams: Record "Dividend Calculation Params";
        EntryNo: Integer;
        SDate: Date;
    begin
        if DividendHeader."Progression Computation Type" = DividendHeader."Progression Computation Type"::Automatic then begin
            DividendDetEntries.Reset;
            DividendDetEntries.SetRange("Dividend Code", DividendHeader."No.");
            if DividendDetEntries.FINDSET then
                DividendDetEntries.DELETEALL;

            EntryNo := 1;
            PrevMnthCode := '';
            CurrMnthCode := '';
            DividendCalculationParams.Reset;
            DividendCalculationParams.SetRange("Dividend Code", DividendHeader."No.");
            DividendCalculationParams.SetRange("Rate Type", DividendCalculationParams."Rate Type"::"Pro Rated");
            if DividendCalculationParams.FindSet then begin
                Window.Open('Calculating #1### #2### #3## #4###');
                repeat
                    DividendCalculationParams.TestField("Posting Description");
                    DividendLines.Reset;
                    DividendLines.SetRange("Dividend Code", DividendHeader."No.");
                    DividendLines.SetRange("Account Type", DividendCalculationParams.Type);
                    if DividendLines.FindSet then begin
                        All := DividendLines.Count;
                        Current := 0;
                        repeat
                            SDate := 0D;
                            Current += 1;
                            SDate := DividendHeader."Start Date";
                            Window.Update(1, DividendCalculationParams.Type + ' ' + DividendCalculationParams.Description);
                            Window.Update(2, DividendLines."Member Name");
                            Window.Update(3, StrSubstNo('%1%', Round((Current / All) * 100, 0.01)));
                            Window.Update(4, FORMAT(Current) + ' of ' + FORMAT(All));
                            repeat
                                if DATE2DMY(SDate, 2) > 1 then
                                    PrevMnthCode := GetPrefixCode(DMY2DATE(1, DATE2DMY(SDate, 2) - 1, DATE2DMY(SDate, 3)))
                                else
                                    PrevMnthCode := 'JAN-' + FORMAT(DATE2DMY(SDate, 3) - 1);
                                CurrMnthCode := GetPrefixCode(DMY2DATE(1, DATE2DMY(SDate, 2), DATE2DMY(SDate, 3)));
                                Vendor.Reset;
                                Vendor.SetRange("No.", DividendLines."Account No");
                                Vendor.SetRange("Member No.", DividendLines."Member No.");
                                Vendor.SetRange("Product Code", DividendCalculationParams.Type);
                                if Vendor.FindFirst then begin
                                    DividendDetEntries.INIT;
                                    DividendDetEntries."Dividend Code" := DividendHeader."No.";
                                    DividendDetEntries."Member No." := Vendor."Member No.";
                                    DividendDetEntries."Entry Type" := DividendDetEntries."Entry Type"::"Int. Earned";
                                    DividendDetEntries.Code := Vendor."No.";
                                    DividendDetEntries."Month Code" := CurrMnthCode;
                                    DividendDetEntries."Min. Balance" := DividendCalculationParams."Minimum Balance";
                                    DividendDetEntries."Entry No" := EntryNo;
                                    EntryNo += 1;
                                    DividendDetEntries.Description := DividendCalculationParams."Posting Description" + ' ' + CurrMnthCode;
                                    DividendDetEntries.Amount := 0;
                                    DividendDetEntries."Account Type" := DividendCalculationParams.Type;
                                    DividendDetEntries."Account Balance" := 0;
                                    DividendDetEntries."Month No." := DATE2DMY(SDate, 2);
                                    DividendDetEntries."Destination Account" := Vendor."No.";
                                    DividendDetEntries."Boosting Amount" := 0;
                                    DividendDetEntries."Net Amount" := 0;
                                    DividendDetEntries."System Entry" := true;
                                    DividendDetEntries."Pre Calculated" := false;
                                    DividendDetEntries."Posting Type" := DividendDetEntries."Posting Type"::"Pro Rated";
                                    DividendDetEntries.Rate := DividendCalculationParams.Rate;
                                    DividendDetEntries."Previous Month" := PrevMnthCode;
                                    DividendDetEntries."Previous Month Balance" := 0;
                                    DividendDetEntries."Current Month" := CurrMnthCode;
                                    DividendDetEntries."Current Month Balance" := 0;
                                    DividendDetEntries."Net Change" := 0;
                                    DividendDetEntries.Year := DATE2DMY(SDate, 3);
                                    DividendDetEntries.VALIDATE(Ratio);
                                    DividendDetEntries.VALIDATE("Previous Month Balance");
                                    DividendDetEntries.VALIDATE("Current Month Balance");
                                    DividendDetEntries.VALIDATE("Net Change");
                                    DividendDetEntries.VALIDATE(Amount);
                                    // if DividendDetEntries."Current Month Balance" > 0 then
                                    //     DividendDetEntries."Account Balance" := DividendDetEntries."Current Month Balance"
                                    // else
                                    //     DividendDetEntries."Account Balance" := 0;
                                    DividendDetEntries."Account Balance" := DividendDetEntries."Current Month Balance";
                                    DividendDetEntries.Insert(true);
                                    Commit;
                                end;
                                SDate := CALCDATE('1M', SDate);
                            until SDate >= DividendHeader."End Date";
                        until DividendLines.NEXT = 0;
                    end;
                until DividendCalculationParams.NEXT = 0;
                Window.Close;
            end;
            //Straight Line
            DividendCalculationParams.Reset;
            DividendCalculationParams.SetRange("Dividend Code", DividendHeader."No.");
            DividendCalculationParams.SetRange("Rate Type", DividendCalculationParams."Rate Type"::"Straight Line");
            if DividendCalculationParams.FindFirst then begin
                Window.Open('Calculating #1### #2### #3### #4###');
                repeat
                    DividendCalculationParams.TestField("Posting Description");
                    DividendLines.Reset;
                    DividendLines.SetRange("Dividend Code", DividendHeader."No.");
                    DividendLines.SetRange("Account Type", DividendCalculationParams.Type);
                    if DividendLines.FindFirst then begin
                        All := DividendLines.Count;
                        Current := 0;
                        repeat
                            SDate := 0D;
                            Current += 1;
                            SDate := DividendHeader."End Date";
                            Window.Update(1, DividendCalculationParams.Type + ' ' + DividendCalculationParams.Description);
                            Window.Update(2, DividendLines."Member Name");
                            Window.Update(3, StrSubstNo('%1%', Round((Current / All) * 100, 0.01)));
                            Window.Update(4, FORMAT(Current) + ' of ' + FORMAT(All));
                            repeat
                                if DATE2DMY(SDate, 2) > 1 then
                                    PrevMnthCode := GetPrefixCode(DMY2DATE(1, DATE2DMY(SDate, 2) - 1, DATE2DMY(SDate, 3)))
                                else
                                    PrevMnthCode := 'JAN-' + FORMAT(DATE2DMY(SDate, 3) - 1);
                                CurrMnthCode := GetPrefixCode(DMY2DATE(1, DATE2DMY(SDate, 2), DATE2DMY(SDate, 3)));
                                Vendor.Reset;
                                Vendor.SetRange("Member No.", DividendLines."Member No.");
                                Vendor.SetRange("Product Code", DividendCalculationParams.Type);
                                if Vendor.FindFirst then begin
                                    DividendDetEntries.INIT;
                                    DividendDetEntries."Dividend Code" := DividendHeader."No.";
                                    DividendDetEntries."Member No." := Vendor."Member No.";
                                    DividendDetEntries."Entry Type" := DividendDetEntries."Entry Type"::"Int. Earned";
                                    DividendDetEntries.Code := Vendor."No.";
                                    DividendDetEntries."Month Code" := CurrMnthCode;
                                    DividendDetEntries."Entry No" := EntryNo;
                                    EntryNo += 1;
                                    DividendDetEntries.Description := DividendCalculationParams."Posting Description" + ' ' + CurrMnthCode;
                                    DividendDetEntries.Amount := 0;
                                    DividendDetEntries."Account Type" := DividendCalculationParams.Type;
                                    DividendDetEntries."Account Balance" := 0;
                                    DividendDetEntries."Month No." := DATE2DMY(SDate, 2);
                                    DividendDetEntries."Destination Account" := Vendor."No.";
                                    DividendDetEntries."Boosting Amount" := 0;
                                    DividendDetEntries."Net Amount" := 0;
                                    DividendDetEntries."System Entry" := true;
                                    DividendDetEntries."Pre Calculated" := false;
                                    DividendDetEntries."Posting Type" := DividendDetEntries."Posting Type"::"Flat Rate";
                                    DividendDetEntries.Rate := DividendCalculationParams.Rate;
                                    DividendDetEntries."Previous Month" := PrevMnthCode;
                                    DividendDetEntries."Previous Month Balance" := 0;
                                    DividendDetEntries."Current Month" := CurrMnthCode;
                                    DividendDetEntries."Current Month Balance" := 0;
                                    DividendDetEntries."Net Change" := 0;
                                    DividendDetEntries.Year := DATE2DMY(SDate, 3);
                                    DividendDetEntries.VALIDATE(Ratio);
                                    DividendDetEntries.VALIDATE("Previous Month Balance");
                                    DividendDetEntries.VALIDATE("Current Month Balance");
                                    DividendDetEntries.VALIDATE("Net Change");
                                    DividendDetEntries.VALIDATE(Amount);
                                    // if DividendDetEntries."Current Month Balance" > 0 then
                                    //     DividendDetEntries."Account Balance" := DividendDetEntries."Current Month Balance"
                                    // else
                                    //     DividendDetEntries."Account Balance" := 0;
                                    DividendDetEntries."Account Balance" := DividendDetEntries."Current Month Balance";
                                    DividendDetEntries.INSERT;
                                    Commit;
                                end;
                                SDate := CALCDATE('1M', SDate);
                            until SDate >= DividendHeader."End Date";
                        until DividendLines.NEXT = 0;
                    end;
                until DividendCalculationParams.NEXT = 0;
                Window.CLOSE;
            end;
        end;
    end;

    local procedure CalculateDividendCharges(DividendHeader: Record "Dividend Header")
    var
        TransactionCharges: Record "Transaction Charges";
        TransactionChargeSetup: Record "Transaction Charges Setup";
        TransactionCalcScheme: Record "Transaction Calc. Scheme";
        TempBase, PostingAmount : Decimal;
        BaseAmount: Decimal;
        ChargeAmount: Decimal;
        JournalMgt: Codeunit "Journal Management";
    begin
        if DividendHeader."Transaction Code" <> '' then begin
            //Create Charges
            DividendLines.Reset;
            DividendLines.SetRange("Dividend Code", DividendHeader."No.");
            DividendLines.SETCURRENTKEY("Member No.");
            if DividendLines.FindSet then begin
                Window.Open('Checking Charges #1### #2### #3###');
                All := DividendLines.Count;
                Current := 0;
                repeat
                    DividendLines.CalcFields("Automatic Amount Earned", "Manual Amount Earned", "Total Recoveries");
                    Current += 1;
                    Window.Update(1, DividendLines."Member Name");
                    Window.Update(2, StrSubstNo('%1%', Round((Current / All) * 100, 0.01)));
                    Window.Update(3, FORMAT(Current) + ' of ' + FORMAT(All));
                    //BaseAmount := DividendLines."Automatic Amount Earned" + DividendLines."Manual Amount Earned" + DividendLines."Total Recoveries";
                    BaseAmount := DividendLines."Automatic Amount Earned" + DividendLines."Manual Amount Earned";

                    TransactionChargeSetup.Reset;
                    TransactionChargeSetup.SetRange("Transaction Code", DividendHeader."Transaction Code");
                    TransactionChargeSetup.SETCURRENTKEY(Priority);
                    TransactionChargeSetup.SETASCENDING(Priority, true);
                    if TransactionChargeSetup.FindFirst then begin
                        repeat
                            ChargeAmount := 0;
                            ChargeAmount := JournalMgt.GetTransactionChargesAmount(TransactionChargeSetup."Transaction Code", TransactionChargeSetup.Code, BaseAmount);

                            if BaseAmount < ChargeAmount then begin
                                ChargeAmount := BaseAmount;
                                BaseAmount := 0;
                            end
                            else
                                BaseAmount -= ChargeAmount;

                            ProductPostingType := ProductPostingType::" ";
                            RecoveryCode := TransactionChargeSetup.Code;
                            PostingDescription := TransactionChargeSetup.Description;
                            PostingAmount := -1 * ChargeAmount;
                            CreateDivindedRecoveries(DividendHeader."No.", EntryType::Charges, DividendLines."Member No.", LoanNo, RecoveryCode, PostingDescription, DividendLines."Account No", ProductPostingType, PostingAmount, TransactionChargeSetup.Priority);
                        until TransactionChargeSetup.NEXT = 0;
                    end;

                until DividendLines.NEXT = 0;
                Window.Close;
            end;
        end;
    end;

    local procedure ComputeDividendBoosts(DividendHeader: Record "Dividend Header")
    var
        ShareCapitalBal, MinBalance, AvailableBase, AvailableBal, BoostAmount, BoostingAmount, BoostingAportionMent, BoostingTarget : Decimal;
    begin
        if DividendHeader."Boost to Minimum" then begin
            DividendLines.Reset;
            DividendLines.SetRange("Dividend Code", DividendHeader."No.");
            DividendLines.SETCURRENTKEY("Account No");
            if DividendLines.FindSet then begin
                All := DividendLines.Count;
                Current := 0;
                Window.Open('Checking Boost Allocations #1### #2### #3###');
                repeat
                    BoostingTarget := 0;
                    BoostAmount := 0;
                    DividendLines.CALCFIELDS("Has Advance");
                    BoostingAportionMent := 0;
                    SaccoProduct.Reset();
                    SaccoProduct.SetRange("Product Posting Type", SaccoProduct."Product Posting Type"::"Share Capital Account");
                    if SaccoProduct.FindFirst then MinBalance := SaccoProduct."Minimum Balance";
                    DividendLines.CALCFIELDS("Automatic Amount Earned", "Manual Amount Earned", "Total Recoveries", "Share Capital Boost Amount");
                    AvailableBal := DividendLines."Automatic Amount Earned" + DividendLines."Manual Amount Earned" + DividendLines."Total Recoveries";
                    ShareCapitalBal := MemberMgmt.GetShareCapitalBal(DividendLines."Member No.");
                    BoostAmount := MinBalance - ShareCapitalBal - DividendLines."Share Capital Boost Amount";
                    if BoostAmount > AvailableBal then
                        BoostAmount := AvailableBal
                    else if ((BoostAmount < 0) or (BoostAmount > AvailableBal)) then BoostAmount := 0;
                    if (BoostAmount > 0) then begin
                        Current += 1;
                        Window.Update(1, DividendLines."Member Name");
                        Window.Update(2, StrSubstNo('%1%', Round((Current / All) * 100, 0.01)));
                        Window.Update(3, FORMAT(Current) + ' of ' + FORMAT(All));
                        if DividendHeader."Maximum Boost Amount" <> 0 then begin
                            if BoostAmount > DividendHeader."Maximum Boost Amount" then BoostAmount := DividendHeader."Maximum Boost Amount";
                        end;
                        ProductPostingType := ProductPostingType::" ";
                        RecoveryCode := MemberMgmt.GetMemberAccount(DividendLines."Member No.", ProductPostingType::"Share Capital Account");
                        PostingDescription := 'Boost Share Capital';
                        PostingAmount := -1 * BoostAmount;
                        CreateDivindedRecoveries(DividendHeader."No.", EntryType::Boost, DividendLines."Member No.", LoanNo, RecoveryCode, PostingDescription, DividendLines."Account No", ProductPostingType, PostingAmount, 0);
                    end;
                until DividendLines.NEXT = 0;
                Window.Close;
            end;
        end;
    end;

    local procedure ComputePreferentialBoost(DividendHeader: Record "Dividend Header")
    var
        BoostAmount, BoostingTarget, BoostingAportionMent : Decimal;
    begin
        if DividendHeader."Preferential Boost" then begin
            DividendLines.Reset;
            DividendLines.SetRange("Dividend Code", DividendHeader."No.");
            DividendLines.SetRange("Prefrential Boost", true);
            DividendLines.SETCURRENTKEY("Account No");
            if DividendLines.FindSet then begin
                All := DividendLines.Count;
                Current := 0;
                Window.Open('Checking Preferential Boost Allocations #1### #2### #3###');
                repeat
                    BoostingTarget := 0;
                    BoostAmount := 0;
                    DividendLines.CALCFIELDS("Has Advance");
                    BoostingAportionMent := 0;
                    Vendor.GET(DividendLines."Account No");
                    if Vendor."Product Posting Type" <> Vendor."Product Posting Type"::"Share Capital Account" then begin
                        Current += 1;
                        if GUIALLOWED then begin
                            Window.Update(1, DividendLines."Member Name");
                            Window.Update(2, StrSubstNo('%1%', Round((Current / All) * 100, 0.01)));
                            Window.Update(3, FORMAT(Current) + ' of ' + FORMAT(All));
                        end;
                        DividendLines.CALCFIELDS("Automatic Amount Earned", "Manual Amount Earned", "Total Recoveries");
                        BoostAmount := DividendLines."Preferential Boost %" * (DividendLines."Automatic Amount Earned" + DividendLines."Manual Amount Earned" + DividendLines."Total Recoveries") * 0.01;
                        ProductPostingType := ProductPostingType::" ";
                        RecoveryCode := Vendor."No.";
                        PostingDescription := Vendor.Name + ' Preferential Boost';
                        PostingAmount := -1 * BoostAmount;
                        CreateDivindedRecoveries(DividendHeader."No.", EntryType::"Preferential Boost", DividendLines."Member No.", LoanNo, RecoveryCode, PostingDescription, DividendLines."Account No", ProductPostingType, PostingAmount, 0);
                    end;
                until DividendLines.NEXT = 0;
                Window.Close;
            end;
        end;
    end;

    local procedure LoanRecoveries(DividendHeader: Record "Dividend Header")
    var
        BaseAmount, IntDue : Decimal;
    begin
        if DividendHeader."Recover Loans" then begin
            Window.Open('Recovering Loans  #1### #2### #3###');
            DividendLines.Reset;
            DividendLines.SetRange("Dividend Code", DividendHeader."No.");
            DividendLines.SetRange(Deceased, false);
            if DividendLines.FindSet then begin
                All := DividendLines.Count;
                Current := 0;
                repeat
                    DividendLines.CalcFields("Automatic Amount Earned", "Manual Amount Earned", "Total Recoveries");
                    Current += 1;
                    Window.Update(1, DividendLines."Member Name");
                    Window.Update(2, StrSubstNo('%1%', Round((Current / All) * 100, 0.01)));
                    Window.Update(3, FORMAT(Current) + ' of ' + FORMAT(All));
                    BaseAmount := DividendLines."Automatic Amount Earned" + DividendLines."Manual Amount Earned" + DividendLines."Total Recoveries";
                    //>>>>>>
                    TransactionTypeRecoveries.Reset;
                    TransactionTypeRecoveries.SetRange(Code, DividendHeader."Transaction Code");
                    TransactionTypeRecoveries.SETCURRENTKEY(Prioirity);
                    if TransactionTypeRecoveries.FindFirst then begin
                        repeat
                            case TransactionTypeRecoveries."Recovery Type" of
                                TransactionTypeRecoveries."Recovery Type"::Loan:
                                    begin
                                        SaccoProduct.GET(TransactionTypeRecoveries."Recovery Code");
                                        Loans.Reset;
                                        Loans.SetRange(Posted, true);
                                        Loans.SetRange("Product Code", TransactionTypeRecoveries."Recovery Code");
                                        Loans.SetRange("Member No.", DividendLines."Member No.");
                                        if Loans.FindSet then begin
                                            repeat
                                                Loans.CalcFields("Loan Balance");
                                                if Loans."Loan Balance" <> 0 then begin
                                                    Loans.CALCFIELDS("Principal Balance", "Interest Balance");
                                                    if TransactionTypeRecoveries."Deduction Type" = TransactionTypeRecoveries."Deduction Type"::"Arrears Amount" then begin
                                                        If Loans."Loan Classification" in [Loans."Loan Classification"::Substandard, Loans."Loan Classification"::Doubtfull, Loans."Loan Classification"::Loss] then begin
                                                            IntDue := 0;
                                                            IntDue := Abs(Loans."Interest Arrears");
                                                            if IntDue > BaseAmount then
                                                                IntDue := BaseAmount;
                                                            ProductPostingType := ProductPostingType::" ";
                                                            RecoveryCode := Loans."No.";
                                                            LoanNo := Loans."No.";
                                                            PostingDescription := 'Interest Arrears ' + Loans."Product Description";
                                                            PostingAmount := -1 * IntDue;
                                                            ProductPostingType := SaccoProduct."Product Posting Type";
                                                            CreateDivindedRecoveries(DividendHeader."No.", EntryType::"Interest Arrears", DividendLines."Member No.", LoanNo, RecoveryCode, PostingDescription, DividendLines."Account No", ProductPostingType, PostingAmount, 0);
                                                            BaseAmount -= IntDue;
                                                            IntDue := 0;
                                                            IntDue := Abs(Loans."Principal Arrears");
                                                            if IntDue > BaseAmount then IntDue := BaseAmount;
                                                            ProductPostingType := ProductPostingType::" ";
                                                            RecoveryCode := Loans."No.";
                                                            LoanNo := Loans."No.";
                                                            PostingDescription := 'Principal Arrears ' + Loans."Product Description";
                                                            PostingAmount := -1 * IntDue;
                                                            ProductPostingType := SaccoProduct."Product Posting Type";
                                                            CreateDivindedRecoveries(DividendHeader."No.", EntryType::"Principal Arrears", DividendLines."Member No.", LoanNo, RecoveryCode, PostingDescription, DividendLines."Account No", ProductPostingType, PostingAmount, 0);
                                                            BaseAmount -= IntDue;
                                                        end;
                                                    end
                                                    else
                                                        if TransactionTypeRecoveries."Deduction Type" = TransactionTypeRecoveries."Deduction Type"::"Loan Balance" then begin
                                                            IntDue := 0;
                                                            IntDue := Abs(Loans."Interest Balance");
                                                            if IntDue > BaseAmount then
                                                                IntDue := BaseAmount;

                                                            ProductPostingType := ProductPostingType::" ";
                                                            RecoveryCode := Loans."No.";
                                                            LoanNo := Loans."No.";
                                                            PostingDescription := 'Interest ' + Loans."Product Description";
                                                            PostingAmount := -1 * IntDue;
                                                            ProductPostingType := SaccoProduct."Product Posting Type";
                                                            CreateDivindedRecoveries(DividendHeader."No.", EntryType::"Interest Paid", DividendLines."Member No.", LoanNo, RecoveryCode, PostingDescription, DividendLines."Account No", ProductPostingType, PostingAmount, 0);
                                                            BaseAmount -= IntDue;
                                                            IntDue := 0;
                                                            IntDue := Abs(Loans."Principal Balance");
                                                            if IntDue > BaseAmount then IntDue := BaseAmount;
                                                            ProductPostingType := ProductPostingType::" ";
                                                            RecoveryCode := Loans."No.";
                                                            LoanNo := Loans."No.";
                                                            PostingDescription := 'Principal ' + Loans."Product Description";
                                                            PostingAmount := -1 * IntDue;
                                                            ProductPostingType := SaccoProduct."Product Posting Type";
                                                            CreateDivindedRecoveries(DividendHeader."No.", EntryType::"Principal Paid", DividendLines."Member No.", LoanNo, RecoveryCode, PostingDescription, DividendLines."Account No", ProductPostingType, PostingAmount, 0);
                                                            BaseAmount -= IntDue;
                                                        end;
                                                end;
                                            until Loans.Next = 0;
                                        end;
                                    end;
                            end;
                        until TransactionTypeRecoveries.NEXT = 0;
                    end;
                until DividendLines.NEXT = 0;
            end;
            Window.Close;
        end;
    end;

    local procedure CalculateNetAmount(DividendHeader: Record "Dividend Header")
    begin
        DividendLines.Reset;
        DividendLines.SetRange("Dividend Code", DividendHeader."No.");
        if DividendLines.FindSet then begin
            Window.Open('Finalizing #1###');
            All := 0;
            Current := 0;
            All := DividendLines.Count;
            repeat
                Current += 1;
                Window.Update(1, StrSubstNo('%1%', Round((Current / All) * 100, 0.01)));
                DividendLines.CALCFIELDS("Automatic Amount Earned", "Manual Amount Earned", "Total Recoveries");
                DividendLines."Net Amount" := DividendLines."Automatic Amount Earned" + DividendLines."Manual Amount Earned" + DividendLines."Total Recoveries";
                DividendLines.MODIFY;
                Commit;
            until DividendLines.NEXT = 0;
            Window.Close;
        end;
    end;

    local procedure CreateDivindedRecoveries(DividendCode: Code[20]; EntryType: Enum "Dividend Recovery Types"; MemberNo: Code[20];
                                                                                    LoanNo: Code[20];
                                                                                    Code: Code[20];
                                                                                    Description: Text[100];
                                                                                    AccountNo: Code[20];
                                                                                    ProductPostingType: Enum "Product Posting Type";
                                                                                    Amount: Decimal; Priority: Integer)
    begin
        DividendRecoveries[1].Init;
        DividendRecoveries[1]."Dividend Code" := DividendCode;
        DividendRecoveries[1]."Entry Type" := EntryType;
        DividendRecoveries[1].Validate("Member No", MemberNo);
        DividendRecoveries[1]."Loan No" := LoanNo;
        DividendRecoveries[1]."Recovery Code" := Code;
        DividendRecoveries[1].Description := Description;
        DividendRecoveries[1]."Account No." := AccountNo;
        DividendRecoveries[1]."Product Posting Type" := ProductPostingType;
        DividendRecoveries[1].Amount := Amount;
        DividendRecoveries[1].Priority := Priority;
        if DividendRecoveries[1].Amount <> 0 then
            DividendRecoveries[1].Insert;
    end;

    procedure GetNetDividend(DividendCode: Code[20]; MemberNo: Code[20]; AccountType: code[20]; var DefaultedAmounts: Decimal; var NetDiv: Decimal; var AmountOwed: Decimal; var DefaultTransfer: Decimal)
    var
        DividendLines: Record "Dividend Lines";
    begin
        NetDiv := 0;
        DividendLines.Reset();
        DividendLines.SetRange("Dividend Code", DividendCode);
        DividendLines.SetRange("Member No.", MemberNo);
        DividendLines.SetRange("Account Type", AccountType);
        if DividendLines.FindFirst() then begin
            NetDiv := DividendLines."Net Amount";
        end;
    end;

    [IntegrationEvent(false, false)]
    [Scope('Cloud')]
    procedure OnAfterPostDividend(DividendHeader: Record "Dividend Header")
    begin
    end;
}
