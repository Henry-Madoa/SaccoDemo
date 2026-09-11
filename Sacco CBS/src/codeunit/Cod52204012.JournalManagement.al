codeunit 52204012 "Journal Management"
{
    var
        GlobalTransactionType: Enum "Sacco Transaction Type";
        GlobalAccountType: Enum "Gen. Journal Account Type";

    procedure PrepareJournal(JournalTemplate: Code[20]; JournalBatch: Code[20]) LineNo: Integer
    var
        Batch: Record "Gen. Journal Batch";
        JournalLine: Record "Gen. Journal Line";
        Template: Record "Gen. Journal Template";
    begin
        if not Template.Get(JournalTemplate) then begin
            Template.Init();
            Template.Name := JournalTemplate;
            Template.Description := JournalTemplate;
            Template."Copy VAT Setup to Jnl. Lines" := false;
            Template.Validate("Page ID", 39);
            Template.Insert();
        end;
        if not Batch.Get(JournalTemplate, JournalBatch) then begin
            Batch.Init();
            Batch."Journal Template Name" := JournalTemplate;
            Batch.Name := JournalBatch;
            Batch."Copy VAT Setup to Jnl. Lines" := false;
            Batch.Insert();
        end;
        DeleteJournalLines(JournalTemplate, JournalBatch);
        Commit();
        LineNo := 1000;
        exit(LineNo);
    end;

    procedure AddCharges(ChargeCode: Code[20]; DebitAccount: Code[20]; BaseAmount: Decimal; LineNo: Integer; DocumentNo: Code[20]; MemberNo: code[20]; SourceCode: Code[20]; ReasonCode: Code[20]; ExternalDocumentNo: Code[20]; JournalBatch: Code[20]; JournalTemplate: Code[20]; Dim1: Code[20]; Dim2: Code[20]; PostingDate: Date; SelfBalancing: Boolean) EntyNo: Integer
    var
        SaccoTTypes: Record "Sacco Product Categories";
        TransactionCharge: Record "Transaction Charges";
        TransactionChargesSetup: Record "Transaction Charges Setup";
        TransactionCalcScheme: array[2] of Record "Transaction Calc. Scheme";
        TempBase, PostingAmount, CoopCharge, SaccoCharge : Decimal;
        AccountNumber: code[20];
        PostingDescription: Text[100];
        JournalManagement: Codeunit "Journal Management";
    begin
        if ChargeCode = '' then begin
            LineNo += 1000;
            exit(LineNo);
        end;

        If TransactionCharge.Get(ChargeCode) then begin
            TransactionChargesSetup.Reset();
            TransactionChargesSetup.SetRange("Transaction Code", TransactionCharge.Code);
            TransactionChargesSetup.SetCurrentKey(Priority);
            TransactionChargesSetup.SetAscending(Priority, true);
            if TransactionChargesSetup.Findset THEN BEGIN
                repeat
                    TransactionChargesSetup.TestField("Post-to Account No.");
                    PostingAmount := 0;

                    IF TransactionChargesSetup."Calculation Type" = TransactionChargesSetup."Calculation Type"::"Calculation Scheme" THEN BEGIN
                        TransactionCalcScheme[1].RESET;
                        TransactionCalcScheme[1].SETFILTER("Lower Limit", '<=%1', BaseAmount);
                        TransactionCalcScheme[1].SETFILTER("Upper Limit", '>=%1', BaseAmount);
                        TransactionCalcScheme[1].SETRANGE("Source Code", TransactionChargesSetup."Transaction Code");
                        TransactionCalcScheme[1].SETRANGE("Charge Code", TransactionChargesSetup.Code);
                        IF TransactionCalcScheme[1].FINDFIRST THEN BEGIN
                            PostingAmount := TransactionCalcScheme[1].Rate;
                            if TransactionCalcScheme[1]."Rate Type" = TransactionCalcScheme[1]."Rate Type"::Percentage THEN begin
                                PostingAmount := ((TransactionCalcScheme[1].Rate) / 100) * BaseAmount;
                                if ((TransactionCalcScheme[1]."Upper Charge Limit" <> 0) and ((((TransactionCalcScheme[1].Rate) / 100) * BaseAmount) > TransactionCalcScheme[1]."Upper Charge Limit")) then
                                    PostingAmount := TransactionCalcScheme[1]."Upper Charge Limit"
                                else if ((TransactionCalcScheme[1]."Lower Charge Limit" <> 0) and ((((TransactionCalcScheme[1].Rate) / 100) * BaseAmount) < TransactionCalcScheme[1]."Lower Charge Limit")) then PostingAmount := TransactionCalcScheme[1]."Lower Charge Limit";
                            end;
                        end;
                    END

                    ELSE BEGIN
                        TransactionCalcScheme[1].RESET;
                        TransactionCalcScheme[1].SETFILTER("Lower Limit", '<=%1', BaseAmount);
                        TransactionCalcScheme[1].SETFILTER("Upper Limit", '>=%1', BaseAmount);
                        TransactionCalcScheme[1].SETRANGE("Source Code", TransactionChargesSetup."Transaction Code");
                        TransactionCalcScheme[1].SETRANGE("Charge Code", TransactionChargesSetup."Source Code");
                        IF TransactionCalcScheme[1].FINDFIRST THEN BEGIN
                            TempBase := TransactionCalcScheme[1].Rate;
                            if TransactionCalcScheme[1]."Rate Type" = TransactionCalcScheme[1]."Rate Type"::Percentage THEN begin
                                TempBase := ((TransactionCalcScheme[1].Rate) / 100) * BaseAmount;
                                if ((TransactionCalcScheme[1]."Upper Charge Limit" <> 0) and ((((TransactionCalcScheme[1].Rate) / 100) * BaseAmount) > TransactionCalcScheme[1]."Upper Charge Limit")) then
                                    TempBase := TransactionCalcScheme[1]."Upper Charge Limit"
                                else if ((TransactionCalcScheme[1]."Lower Charge Limit" <> 0) and ((((TransactionCalcScheme[1].Rate) / 100) * BaseAmount) < TransactionCalcScheme[1]."Lower Charge Limit")) then TempBase := TransactionCalcScheme[1]."Lower Charge Limit";
                            end;
                            TransactionCalcScheme[2].RESET;
                            TransactionCalcScheme[2].SETFILTER("Lower Limit", '<=%1', TempBase);
                            TransactionCalcScheme[2].SETFILTER("Upper Limit", '>=%1', TempBase);
                            TransactionCalcScheme[2].SETRANGE("Source Code", TransactionChargesSetup."Transaction Code");
                            TransactionCalcScheme[2].SETRANGE("Charge Code", TransactionChargesSetup.Code);
                            IF TransactionCalcScheme[2].FINDFIRST THEN BEGIN
                                PostingAmount := TransactionCalcScheme[2].Rate;
                                if TransactionCalcScheme[2]."Rate Type" = TransactionCalcScheme[2]."Rate Type"::Percentage THEN begin
                                    PostingAmount := ((TransactionCalcScheme[2].Rate) / 100) * TempBase;
                                    if ((TransactionCalcScheme[2]."Upper Charge Limit" <> 0) and ((((TransactionCalcScheme[2].Rate) / 100) * TempBase) > TransactionCalcScheme[2]."Upper Charge Limit")) then
                                        PostingAmount := TransactionCalcScheme[2]."Upper Charge Limit"
                                    else if ((TransactionCalcScheme[2]."Lower Charge Limit" <> 0) and ((((TransactionCalcScheme[2].Rate) / 100) * TempBase) < TransactionCalcScheme[2]."Lower Charge Limit")) then PostingAmount := TransactionCalcScheme[2]."Lower Charge Limit";
                                end;
                            end;
                        end;
                    end;
                    if TransactionCharge."Posting Transaction Type" in [TransactionCharge."Posting Transaction Type"::ATM, TransactionCharge."Posting Transaction Type"::"Bankers Cheque"] then
                        CoopCharge := TransactionChargesSetup."Coop Charge";

                    SaccoCharge := PostingAmount;
                    SaccoCharge := PostingAmount - CoopCharge;

                    if TransactionCharge."Posting Transaction Type" <> TransactionCharge."Posting Transaction Type"::"Cash Deposit" then
                        SaccoCharge := -1 * SaccoCharge;

                    AccountNumber := '';
                    AccountNumber := TransactionChargesSetup."Post-to Account No.";
                    PostingDescription := '';
                    PostingDescription := 'Chrg:' + TransactionChargesSetup.Description;

                    case TransactionChargesSetup."Post To Account Type" of
                        TransactionChargesSetup."Post To Account Type"::"G/L Account":
                            LineNo := CreateJournalLine(GlobalAccountType::"G/L Account", AccountNumber, PostingDate, PostingDescription, SaccoCharge, Dim1, Dim2, '', DocumentNo, GlobalTransactionType::Charge, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                        TransactionChargesSetup."Post To Account Type"::"Bank Account":
                            LineNo := CreateJournalLine(GlobalAccountType::"Bank Account", AccountNumber, PostingDate, PostingDescription, SaccoCharge, Dim1, Dim2, '', DocumentNo, GlobalTransactionType::Charge, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                        TransactionChargesSetup."Post To Account Type"::Vendor:
                            LineNo := CreateJournalLine(GlobalAccountType::Vendor, AccountNumber, PostingDate, PostingDescription, SaccoCharge, Dim1, Dim2, '', DocumentNo, GlobalTransactionType::Charge, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                    end;
                    if CoopCharge <> 0 then begin
                        TransactionCharge.TestField("Control Account");
                        AccountNumber := TransactionCharge."Control Account";
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"Bank Account", AccountNumber, PostingDate, PostingDescription, -1 * CoopCharge, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::Charge, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                    end;

                    if TransactionCharge."Posting Transaction Type" = TransactionCharge."Posting Transaction Type"::"Cash Deposit" then begin
                        TransactionCharge.TestField("Control Account");
                        AccountNumber := TransactionCharge."Control Account";
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"Bank Account", AccountNumber, PostingDate, PostingDescription, -1 * SaccoCharge, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::Charge, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                    end;

                    if SelfBalancing then begin
                        AccountNumber := '';
                        AccountNumber := DebitAccount;
                        LineNo := CreateJournalLine(GlobalAccountType::Vendor, AccountNumber, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::Charge, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                    end;
                until TransactionChargesSetup.Next = 0;
            end;
        end;
        LineNo += 1000;
        exit(LineNo);
    end;

    procedure GetChargesAmount(ChargeCode: Code[20]; BaseAmount: Decimal) TotalCharges: Decimal
    var
        SaccoTTypes: Record "Sacco Product Categories";
        TransactionCharge: Record "Transaction Charges";
        TransactionChargesSetup: Record "Transaction Charges Setup";
        TransactionCalcScheme: array[3] of Record "Transaction Calc. Scheme";
        TempBase, PostingAmount : Decimal;
    begin
        TotalCharges := 0;
        If TransactionCharge.Get(ChargeCode) then begin
            if TransactionCharge."Posting Transaction Type" <> TransactionCharge."Posting Transaction Type"::"Cash Deposit" then begin
                TransactionChargesSetup.Reset();
                TransactionChargesSetup.SetRange("Transaction Code", TransactionCharge.Code);
                if TransactionChargesSetup.Findset THEN BEGIN
                    repeat
                        PostingAmount := 0;
                        IF TransactionChargesSetup."Calculation Type" = TransactionChargesSetup."Calculation Type"::"Calculation Scheme" THEN BEGIN
                            TransactionCalcScheme[1].RESET;
                            TransactionCalcScheme[1].SETFILTER("Lower Limit", '<=%1', BaseAmount);
                            TransactionCalcScheme[1].SETFILTER("Upper Limit", '>=%1', BaseAmount);
                            TransactionCalcScheme[1].SETRANGE("Source Code", TransactionChargesSetup."Transaction Code");
                            TransactionCalcScheme[1].SETRANGE("Charge Code", TransactionChargesSetup.Code);
                            IF TransactionCalcScheme[1].FINDFIRST THEN BEGIN
                                PostingAmount := TransactionCalcScheme[1].Rate;
                                if TransactionCalcScheme[1]."Rate Type" = TransactionCalcScheme[1]."Rate Type"::Percentage THEN begin
                                    PostingAmount := ((TransactionCalcScheme[1].Rate) / 100) * BaseAmount;
                                    if ((TransactionCalcScheme[1]."Upper Charge Limit" <> 0) and ((((TransactionCalcScheme[1].Rate) / 100) * BaseAmount) > TransactionCalcScheme[1]."Upper Charge Limit")) then
                                        PostingAmount := TransactionCalcScheme[1]."Upper Charge Limit"
                                    else if ((TransactionCalcScheme[1]."Lower Charge Limit" <> 0) and ((((TransactionCalcScheme[1].Rate) / 100) * BaseAmount) < TransactionCalcScheme[1]."Lower Charge Limit")) then PostingAmount := TransactionCalcScheme[1]."Lower Charge Limit";
                                end;
                            end;
                        END
                        ELSE BEGIN
                            TransactionCalcScheme[1].RESET;
                            TransactionCalcScheme[1].SETFILTER("Lower Limit", '<=%1', BaseAmount);
                            TransactionCalcScheme[1].SETFILTER("Upper Limit", '>=%1', BaseAmount);
                            TransactionCalcScheme[1].SETRANGE("Source Code", TransactionChargesSetup."Transaction Code");
                            TransactionCalcScheme[1].SETRANGE("Charge Code", TransactionChargesSetup."Source Code");
                            IF TransactionCalcScheme[1].FINDFIRST THEN BEGIN
                                TempBase := TransactionCalcScheme[1].Rate;
                                if TransactionCalcScheme[1]."Rate Type" = TransactionCalcScheme[1]."Rate Type"::Percentage THEN begin
                                    TempBase := ((TransactionCalcScheme[1].Rate) / 100) * BaseAmount;
                                    if ((TransactionCalcScheme[1]."Upper Charge Limit" <> 0) and ((((TransactionCalcScheme[1].Rate) / 100) * BaseAmount) > TransactionCalcScheme[1]."Upper Charge Limit")) then
                                        TempBase := TransactionCalcScheme[1]."Upper Charge Limit"
                                    else if ((TransactionCalcScheme[1]."Lower Charge Limit" <> 0) and ((((TransactionCalcScheme[1].Rate) / 100) * BaseAmount) < TransactionCalcScheme[1]."Lower Charge Limit")) then TempBase := TransactionCalcScheme[1]."Lower Charge Limit";
                                end;
                                TransactionCalcScheme[2].RESET;
                                TransactionCalcScheme[2].SETFILTER("Lower Limit", '<=%1', TempBase);
                                TransactionCalcScheme[2].SETFILTER("Upper Limit", '>=%1', TempBase);
                                TransactionCalcScheme[2].SETRANGE("Source Code", TransactionChargesSetup."Transaction Code");
                                TransactionCalcScheme[2].SETRANGE("Charge Code", TransactionChargesSetup.Code);
                                IF TransactionCalcScheme[2].FINDFIRST THEN BEGIN
                                    PostingAmount := TransactionCalcScheme[2].Rate;
                                    if TransactionCalcScheme[2]."Rate Type" = TransactionCalcScheme[2]."Rate Type"::Percentage THEN begin
                                        PostingAmount := ((TransactionCalcScheme[2].Rate) / 100) * TempBase;
                                        if ((TransactionCalcScheme[2]."Upper Charge Limit" <> 0) and ((((TransactionCalcScheme[2].Rate) / 100) * TempBase) > TransactionCalcScheme[2]."Upper Charge Limit")) then
                                            PostingAmount := TransactionCalcScheme[2]."Upper Charge Limit"
                                        else if ((TransactionCalcScheme[2]."Lower Charge Limit" <> 0) and ((((TransactionCalcScheme[2].Rate) / 100) * TempBase) < TransactionCalcScheme[2]."Lower Charge Limit")) then PostingAmount := TransactionCalcScheme[2]."Lower Charge Limit";
                                    end;
                                end;
                            end;
                        end;
                        TotalCharges += PostingAmount;
                    until TransactionChargesSetup.Next = 0;
                end;
            end;
        end;
        exit(TotalCharges);
    end;

    procedure GetTransactionChargesAmount(TransactionCode: Code[20]; ChargeCode: Code[20]; BaseAmount: Decimal) Charge: Decimal
    var
        SaccoTTypes: Record "Sacco Product Categories";
        TransactionChargesSetup: Record "Transaction Charges Setup";
        TransactionCalcScheme: array[3] of Record "Transaction Calc. Scheme";
        TempBase, PostingAmount : Decimal;
    begin
        if TransactionChargesSetup.Get(TransactionCode, ChargeCode) then begin
            IF TransactionChargesSetup."Calculation Type" = TransactionChargesSetup."Calculation Type"::"Calculation Scheme" then begin
                TransactionCalcScheme[1].RESET;
                TransactionCalcScheme[1].SETFILTER("Lower Limit", '<=%1', BaseAmount);
                TransactionCalcScheme[1].SETFILTER("Upper Limit", '>=%1', BaseAmount);
                TransactionCalcScheme[1].SETRANGE("Source Code", TransactionChargesSetup."Transaction Code");
                TransactionCalcScheme[1].SETRANGE("Charge Code", TransactionChargesSetup.Code);
                IF TransactionCalcScheme[1].FINDFIRST THEN BEGIN
                    PostingAmount := TransactionCalcScheme[1].Rate;
                    if TransactionCalcScheme[1]."Rate Type" = TransactionCalcScheme[1]."Rate Type"::Percentage THEN begin
                        PostingAmount := ((TransactionCalcScheme[1].Rate) / 100) * BaseAmount;
                        if ((TransactionCalcScheme[1]."Upper Charge Limit" <> 0) and ((((TransactionCalcScheme[1].Rate) / 100) * BaseAmount) > TransactionCalcScheme[1]."Upper Charge Limit")) then
                            PostingAmount := TransactionCalcScheme[1]."Upper Charge Limit"
                        else if ((TransactionCalcScheme[1]."Lower Charge Limit" <> 0) and ((((TransactionCalcScheme[1].Rate) / 100) * BaseAmount) < TransactionCalcScheme[1]."Lower Charge Limit")) then PostingAmount := TransactionCalcScheme[1]."Lower Charge Limit";
                    end;
                end;
            END
            ELSE BEGIN
                TransactionCalcScheme[1].RESET;
                TransactionCalcScheme[1].SETFILTER("Lower Limit", '<=%1', BaseAmount);
                TransactionCalcScheme[1].SETFILTER("Upper Limit", '>=%1', BaseAmount);
                TransactionCalcScheme[1].SETRANGE("Source Code", TransactionChargesSetup."Transaction Code");
                TransactionCalcScheme[1].SETRANGE("Charge Code", TransactionChargesSetup."Source Code");
                IF TransactionCalcScheme[1].FINDFIRST THEN BEGIN
                    TempBase := TransactionCalcScheme[1].Rate;
                    if TransactionCalcScheme[1]."Rate Type" = TransactionCalcScheme[1]."Rate Type"::Percentage THEN begin
                        TempBase := ((TransactionCalcScheme[1].Rate) / 100) * BaseAmount;
                        if ((TransactionCalcScheme[1]."Upper Charge Limit" <> 0) and ((((TransactionCalcScheme[1].Rate) / 100) * BaseAmount) > TransactionCalcScheme[1]."Upper Charge Limit")) then
                            TempBase := TransactionCalcScheme[1]."Upper Charge Limit"
                        else if ((TransactionCalcScheme[1]."Lower Charge Limit" <> 0) and ((((TransactionCalcScheme[1].Rate) / 100) * BaseAmount) < TransactionCalcScheme[1]."Lower Charge Limit")) then TempBase := TransactionCalcScheme[1]."Lower Charge Limit";
                    end;
                    TransactionCalcScheme[2].RESET;
                    TransactionCalcScheme[2].SETFILTER("Lower Limit", '<=%1', TempBase);
                    TransactionCalcScheme[2].SETFILTER("Upper Limit", '>=%1', TempBase);
                    TransactionCalcScheme[2].SETRANGE("Source Code", TransactionChargesSetup."Transaction Code");
                    TransactionCalcScheme[2].SETRANGE("Charge Code", TransactionChargesSetup.Code);
                    IF TransactionCalcScheme[2].FINDFIRST THEN BEGIN
                        PostingAmount := TransactionCalcScheme[2].Rate;
                        if TransactionCalcScheme[2]."Rate Type" = TransactionCalcScheme[2]."Rate Type"::Percentage THEN begin
                            PostingAmount := ((TransactionCalcScheme[2].Rate) / 100) * TempBase;
                            if ((TransactionCalcScheme[2]."Upper Charge Limit" <> 0) and ((((TransactionCalcScheme[2].Rate) / 100) * TempBase) > TransactionCalcScheme[2]."Upper Charge Limit")) then
                                PostingAmount := TransactionCalcScheme[2]."Upper Charge Limit"
                            else if ((TransactionCalcScheme[2]."Lower Charge Limit" <> 0) and ((((TransactionCalcScheme[2].Rate) / 100) * TempBase) < TransactionCalcScheme[2]."Lower Charge Limit")) then PostingAmount := TransactionCalcScheme[2]."Lower Charge Limit";
                        end;
                    end;
                end;
            end;
            Charge := PostingAmount;
        end;
        exit(Charge);
    end;

    procedure CompletePosting(JournalTemplate: Code[20]; JournalBatch: Code[20])
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.RESET;
        GenJournalLine.SETRANGE("Journal Batch Name", JournalBatch);
        GenJournalLine.SETRANGE("Journal Template Name", JournalTemplate);
        IF GenJournalLine.FindSet() THEN CODEUNIT.RUN(CODEUNIT::"Gen. Jnl.-Post Ext", GenJournalLine);
    end;

    procedure CreateJournalLine(AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; PostingDate: Date; PostingDescription: Text[100]; Amount: Decimal; Dimension1: Code[20]; Dimension2: Code[20]; MemberNo: Code[20]; DocumentNo: Code[20]; TransactionType: Enum "Sacco Transaction Type"; LineNo: Integer; SourceCode: Code[20]; ReasonCode: Code[20]; ExternalDocNo: Code[20]; CurrencyCode: Code[20]; AppliestToDocType: Enum "Gen. Journal Document Type"; AppliestToDocNo: Code[20]; JournalTemplate: Code[20]; JournalBatch: Code[20]) EntryNo: Integer
    var
        GenJournalLine: Record "Gen. Journal Line";
        Vendor: Record Vendor;
        LoansMgt: Codeunit "Loans Management";
        LoanApp: Record Loans;
        UserMgmtExt: Codeunit "User Management Ext";
    begin
        GenJournalLine.INIT;
        GenJournalLine."Journal Template Name" := JournalTemplate;
        GenJournalLine."Journal Batch Name" := JournalBatch;
        GenJournalLine."Document No." := DocumentNo;
        GenJournalLine."Line No." := LineNo;
        GenJournalLine."Posting Date" := PostingDate;
        GenJournalLine."Account Type" := AccountType;
        GenJournalLine.VALIDATE("Account No.", AccountNo);
        GenJournalLine.VALIDATE(Amount, Amount);
        GenJournalLine.VALIDATE("Currency Code", CurrencyCode);
        if AppliestToDocNo <> '' then begin
            GenJournalLine.VALIDATE("Applies-to Doc. Type", AppliestToDocType);
            GenJournalLine.VALIDATE("Applies-to Doc. No.", AppliestToDocNo);
        end;
        GenJournalLine."Transaction Type" := TransactionType;
        GenJournalLine."Message to Recipient" := PostingDescription;
        GenJournalLine.Description := PostingDescription;
        GenJournalLine."Due Date" := PostingDate;
        GenJournalLine."Source Code" := copystr(SourceCode, 1, 10);
        GenJournalLine."Payment Reference" := ExternalDocNo;
        GenJournalLine."External Document No." := ExternalDocNo;
        GenJournalLine."Member No." := MemberNo;
        GenJournalLine."Loan No." := ReasonCode;
        if ((Dimension1 = '') or (Dimension2 = '')) then UserMgmtExt.GetUserDimensions(UserId, Dimension1, Dimension2);
        GenJournalLine.VALIDATE("Shortcut Dimension 1 Code", Dimension1);
        GenJournalLine.VALIDATE("Shortcut Dimension 2 Code", Dimension2);
        if AccountType = AccountType::Vendor then begin
            if Vendor.Get(AccountNo) then
                GenJournalLine."Product Posting Type" := Vendor."Product Posting Type";
        end;
        if GenJournalLine."Member No." = '' then begin
            if GenJournalLine."Loan No." <> '' then begin
                if LoanApp.Get(GenJournalLine."Loan No.") then
                    GenJournalLine."Member No." := LoanApp."Member No.";
            end;
        end;
        IF GenJournalLine.Amount <> 0 THEN GenJournalLine.INSERT;
        LineNo += 1000;
        exit(LineNo);
    end;

    procedure CreateUnallocationJournalLine(AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; PostingDate: Date; PostingDescription: Text[100]; Amount: Decimal; Dimension1: Code[20]; Dimension2: Code[20]; MemberNo: Code[20]; DocumentNo: Code[20]; TransactionType: Enum "Sacco Transaction Type"; LineNo: Integer; SourceCode: Code[20]; ReasonCode: Code[20]; ExternalDocNo: code[20]; JournalTemplate: Code[20]; JournalBatch: Code[20]) EntryNo: Integer
    var
        ProductSetup: Record "Sacco Products";
        Vendor: array[2] of Record Vendor;
        LoansMgt: Codeunit "Loans Management";
        UnallocatedAccount: Code[20];
        Member: Record Members;
    begin
        ProductSetup.Reset();
        ProductSetup.SetRange("Product Posting Type", ProductSetup."Product Posting Type"::"School Fee Account");
        if ProductSetup.FindFirst then begin
            ProductSetup.TestField(Prefix);
            ProductSetup.TestField("Posting Group");
            UnallocatedAccount := '';
            UnallocatedAccount := ProductSetup.Prefix + MemberNo + ProductSetup.Suffix;
            Vendor[1].Reset();
            Vendor[1].SetRange("Member No.", MemberNo);
            Vendor[1].SetRange("Product Posting Type", Vendor[1]."Product Posting Type"::"School Fee Account");
            if Vendor[1].FindFirst then
                UnallocatedAccount := Vendor[1]."No."
            else begin
                Member.Get(MemberNo);
                Vendor[2].Init();
                Vendor[2]."No." := UnallocatedAccount;
                Vendor[2].Name := UpperCase(ProductSetup.Description);
                Vendor[2]."Vendor Posting Group" := ProductSetup."Posting Group";
                Vendor[2]."Member No." := MemberNo;
                Vendor[2]."Member Name" := UpperCase(Member.FullName);
                Vendor[2]."Account Type" := Vendor[1]."Account Type"::Sacco;
                Vendor[2]."Product Code" := ProductSetup.Code;
                Vendor[2]."Product Posting Type" := ProductSetup."Product Posting Type";
                Vendor[2]."Business Account" := ProductSetup."Business Account";
                Vendor[2]."Cash Deposit Allowed" := ProductSetup."Cash Deposit Allowed";
                Vendor[2]."Cash Withdraw Allowed" := ProductSetup."Cash Withdraw Allowed";
                Vendor[2]."Cash Transfer Allowed" := ProductSetup."Cash Transfer Allowed";
                Vendor[2]."Cheque Book Allowed" := ProductSetup."Cheque Book Allowed";
                Vendor[2].Status := Vendor[1].Status::Active;
                Vendor[2].Insert(true);
                UnallocatedAccount := Vendor[2]."No.";
            end;
            //Credit Unallocated Account
            LineNo := CreateJournalLine(GlobalAccountType::Vendor, UnallocatedAccount, PostingDate, PostingDescription, -1 * Amount, Dimension1, Dimension2, MemberNo, DocumentNo, GlobalTransactionType::"Acc. Transfer", LineNo, SourceCode, ReasonCode, ExternalDocNo, '', 0, '', JournalTemplate, JournalBatch);
            //Debit Transfering Account
            if AccountNo <> '' then LineNo := CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, Amount, Dimension1, Dimension2, MemberNo, DocumentNo, GlobalTransactionType::"Acc. Transfer", LineNo, SourceCode, ReasonCode, ExternalDocNo, '', 0, '', JournalTemplate, JournalBatch);
            exit(LineNo);
        end
        else
            Error('There is no Unallocated Account Setup');
    end;


    procedure PostJournalVoucher(JournalVoucher: Record "Journal Voucher Header")
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        JournalTemplate: Code[20];
        JournalBatch: Code[20];
        DocumentNo: Code[20];
        LineNo: Integer;
        PostingDate: date;
        JVLines: Record "Journal Voucher Lines";
        ProductFactory: Record "Sacco Products";
        Dim1: code[20];
        Dim2: code[20];
        Loans: Record Loans;
    begin
        JournalBatch := 'JVS';
        JournalTemplate := 'PAYMENT';
        Dim1 := JournalVoucher."Global Dimension 1 Code";
        Dim2 := JournalVoucher."Global Dimension 2 Code";
        if not GenJournalBatch.Get(JournalTemplate, JournalBatch) then begin
            GenJournalBatch.Init();
            GenJournalBatch."Journal Template Name" := JournalTemplate;
            GenJournalBatch.Name := JournalBatch;
            GenJournalBatch.Insert();
        end;
        GenJournalLine.reset;
        GenJournalLine.SetRange("Journal Template Name", JournalTemplate);
        GenJournalLine.SetRange("Journal Batch Name", JournalBatch);
        if GenJournalLine.FindSet() then GenJournalLine.DeleteAll();
        PostingDate := JournalVoucher."Posting Date";
        DocumentNo := JournalVoucher."No.";
        LineNo := 1000;
        JVLines.Reset();
        JVLines.SetRange("Document No.", JournalVoucher."No.");
        if JVLines.FindSet() then begin
            repeat
                GenJournalLine.INIT;
                GenJournalLine."Journal Template Name" := JournalTemplate;
                GenJournalLine."Journal Batch Name" := JournalBatch;
                GenJournalLine."Document No." := DocumentNo;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Posting Date" := PostingDate;
                LineNo += 1000;
                case JVLines."Account Type" of
                    JVLines."Account Type"::"Customer Account":
                        GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
                    JVLines."Account Type"::"Bank Account":
                        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Bank Account";
                    JVLines."Account Type"::"Vendor Account":
                        GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                    JVLines."Account Type"::"Member Account":
                        GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                    JVLines."Account Type"::"G/L Account":
                        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    JVLines."Account Type"::"Loan Account":
                        GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                    JVLines."Account Type"::"Fixed Asset":
                        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Fixed Asset";
                end;
                GenJournalLine.VALIDATE("Account No.", JVLines."Post to Account");
                if JVLines."Credit Amount" > 0 then begin
                    GenJournalLine."Credit Amount" := JVLines."Credit Amount";
                    GenJournalLine.VALIDATE("Credit Amount");
                end
                else if JVLines."Debit Amount" > 0 then begin
                    GenJournalLine."Debit Amount" := JVLines."Debit Amount";
                    GenJournalLine.VALIDATE("Debit Amount");
                end;
                GenJournalLine."Message to Recipient" := JVLines."Posting Description";
                GenJournalLine.Description := GenJournalLine."Message to Recipient";
                GenJournalLine."Due Date" := PostingDate;
                if JVLines."Account Type" = JVLines."Account Type"::"Loan Account" then begin
                    GenJournalLine."Reason Code" := copystr(JVLines."Account No.", 1, 10);
                    Loans.Get(JVLines."Account No.");
                    GenJournalLine."Source Code" := Loans."Product Code";
                end;
                GenJournalLine."External Document No." := JournalVoucher."External Document No.";
                GenJournalLine."Member No." := JVLines."Member No.";
                GenJournalLine."Transaction Type" := JVLines."Transaction Type";
                GenJournalLine."Loan No." := GenJournalLine."Reason Code";
                if JVLines."Member No." <> '' then begin
                    if ProductFactory.Get(JVLines."Account No.") then GenJournalLine."Product Posting Type" := ProductFactory."Product Posting Type";
                end;
                if JVLines."Account Type" = JVLines."Account Type"::"Loan Account" then GenJournalLine."Product Posting Type" := GenJournalLine."Product Posting Type"::"Loan Account";
                if JVLines."Account Type" IN [JVLines."Account Type"::"Loan Account", JVLines."Account Type"::"Member Account"] = false then GenJournalLine."Member No." := '';
                if GenJournalLine."Account Type" = GenJournalLine."Account Type"::"G/L Account" then GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Purchase;
                GenJournalLine.Validate("Shortcut Dimension 1 Code", Dim1);
                GenJournalLine.Validate("Shortcut Dimension 2 Code", Dim2);
                IF GenJournalLine.Amount <> 0 THEN GenJournalLine.INSERT;
            until JVLines.Next = 0;
        end;
        GenJournalLine.RESET;
        GenJournalLine.SETFILTER("Account No.", '<>%1', '');
        GenJournalLine.SETRANGE("Journal Batch Name", JournalBatch);
        GenJournalLine.SETRANGE("Journal Template Name", JournalTemplate);
        IF GenJournalLine.FINDFIRST THEN CODEUNIT.RUN(CODEUNIT::"Gen. Jnl.-Post", GenJournalLine);
        JournalVoucher.Posted := true;
        JournalVoucher.Modify();
    end;

    local procedure DeleteJournalLines(JournalTemplate: Code[20]; JournalBatch: Code[20])
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.Reset;
        GenJournalLine.SetRange("Journal Template Name", JournalTemplate);
        GenJournalLine.SetRange("Journal Batch Name", JournalBatch);
        if GenJournalLine.FindSet then GenJournalLine.DeleteAll;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertDtldVendLedgEntry', '', True, True)]
    procedure OnBeforeInsertDtldVendLedgEntry(GenJournalLine: Record "Gen. Journal Line"; var DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry")
    var
        Vendor: Record Vendor;
    begin
        if GenJournalLine."Member No." <> '' then
            if Vendor.Get(GenJournalLine."Account No.") then
                if Vendor."Account Type" <> Vendor."Account Type"::Supplier then
                    if GenJournalLine."Product Posting Type" = GenJournalLine."Product Posting Type"::" " then
                        Error('Select the correct posting Type');

        DtldVendLedgEntry."Member No." := GenJournalLine."Member No.";
        DtldVendLedgEntry."Product Posting Type" := GenJournalLine."Product Posting Type";
        DtldVendLedgEntry."Sacco Transaction Type" := GenJournalLine."Transaction Type";
        DtldVendLedgEntry."Loan No." := GenJournalLine."Loan No.";
        DtldVendLedgEntry."Transaction Time" := Time;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertDtldCustLedgEntry', '', true, true)]
    procedure OnBeforeInsertDtldCustLedgEntry(var DtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        DtldCustLedgEntry."Member No." := GenJournalLine."Member No.";
        DtldCustLedgEntry."Product Posting Type" := GenJournalLine."Product Posting Type";
        DtldCustLedgEntry."Sacco Transaction Type" := GenJournalLine."Transaction Type";
        DtldCustLedgEntry."Loan No." := GenJournalLine."Loan No.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"G/L Entry", 'OnAfterCopyGLEntryFromGenJnlLine', '', true, true)]
    procedure OnAfterCopyGLEntryFromGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry")
    begin
        GLEntry."Member No." := GenJournalLine."Member No.";
        GLEntry."Product Posting Type" := GenJournalLine."Product Posting Type";
        GLEntry."Sacco Transaction Type" := GenJournalLine."Transaction Type";
        GLEntry."Loan No." := GenJournalLine."Loan No.";
        GLEntry."Transaction Time" := Time;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Ledger Entry", 'OnAfterCopyVendLedgerEntryFromGenJnlLine', '', true, true)]
    procedure OnAfterCopyVendLedgerEntryFromGenJnlLine(GenJournalLine: Record "Gen. Journal Line"; var VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        VendorLedgerEntry."Member No." := GenJournalLine."Member No.";
        VendorLedgerEntry."Product Posting Type" := GenJournalLine."Product Posting Type";
        VendorLedgerEntry."Sacco Transaction Type" := GenJournalLine."Transaction Type";
        VendorLedgerEntry."Loan No." := GenJournalLine."Loan No.";
        VendorLedgerEntry."Transaction Time" := Time;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnAfterCopyCustLedgerEntryFromGenJnlLine', '', true, true)]
    procedure OnAfterCopyCustLedgerEntryFromGenJnlLine(GenJournalLine: Record "Gen. Journal Line"; var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        CustLedgerEntry."Member No." := GenJournalLine."Member No.";
        CustLedgerEntry."Product Posting Type" := GenJournalLine."Product Posting Type";
        CustLedgerEntry."Sacco Transaction Type" := GenJournalLine."Transaction Type";
        CustLedgerEntry."Loan No." := GenJournalLine."Loan No.";
        CustLedgerEntry."Transaction Time" := Time;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account Ledger Entry", 'OnAfterCopyFromGenJnlLine', '', true, true)]
    procedure OnAfterCopyFromGenJnlLine(GenJournalLine: Record "Gen. Journal Line"; var BankAccountLedgerEntry: Record "Bank Account Ledger Entry")
    begin
        BankAccountLedgerEntry."Member No." := GenJournalLine."Member No.";
        BankAccountLedgerEntry."Product Posting Type" := GenJournalLine."Product Posting Type";
        BankAccountLedgerEntry."Transaction Type" := GenJournalLine."Transaction Type";
        BankAccountLedgerEntry."Loan No." := GenJournalLine."Loan No.";
        BankAccountLedgerEntry."Transaction Time" := Time;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnAfterCheckGenJnlLine', '', true, true)]
    procedure OnAfterCheckGenJnlLine(var GenJournalLine: Record "Gen. Journal Line")
    var
        Vendor: Record Vendor;
    begin
        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor then begin
            if Vendor.Get(GenJournalLine."Account No.") then begin
                if Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Loan Account" then begin
                    GenJournalLine.TestField("Loan No.");
                    GenJournalLine.TestField("Member No.");
                    GenJournalLine.TestField("Product Posting Type");
                    if (GenJournalLine."Transaction Type" in [GenJournalLine."Transaction Type"::"Penalty Due", GenJournalLine."Transaction Type"::"Penalty Paid", GenJournalLine."Transaction Type"::"Loan Disbursal", GenJournalLine."Transaction Type"::"Interest Due", GenJournalLine."Transaction Type"::"Interest Paid", GenJournalLine."Transaction Type"::"Principal Paid"]) = false then
                        Error('The Transaction type %1 doc %2 is not allowed for Loan Account!', GenJournalLine."Transaction Type", GenJournalLine."Document No.");
                end;
                if Vendor."Account Type" = Vendor."Account Type"::Sacco then begin
                    GenJournalLine.TestField("Member No.");
                end;
            end;
        end;
    end;
}
