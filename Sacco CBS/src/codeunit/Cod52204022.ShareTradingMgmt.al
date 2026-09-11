codeunit 52204022 "Share Trading Mgmt"
{
    var
        Dim1: Code[20];
        Dim2: Code[20];
        DocumentNo: Code[20];
        PostingDate: Date;
        PostingAmount: Decimal;
        LineNo: Integer;
        JournalBatch: Code[20];
        JournalTemplate: Code[20];
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        Vendor: Record Vendor;
        JournalManagement: Codeunit "Journal Management";
        CompanyInformation: Record "Company Information";
        Member: Record Members;
        GeneralLedgerSetup: Record "General Ledger Setup";
        TextMessage: Text[250];
        TextPhone: List of [Text];
        CommunicationsMgmt: Codeunit "Communications Mgmt";
        ReasonCode: Record "Reason Code";
        DimensionValue: Record "Dimension Value";

    procedure PublishShareTradingSetup(ShareTradingSetup: Record "Share Trading Setup")
    var
        myInt: Integer;
    begin
        if CONFIRM(StrSubstNo('You are about to Publish the Share Trading %1,\\Do you wish to continue?', ShareTradingSetup."Document No.")) then begin
            if not ReasonCode.GET(ShareTradingSetup."Document No.") then begin
                ReasonCode.INIT;
                ReasonCode.Code := ShareTradingSetup."Document No.";
                ReasonCode.Description := ShareTradingSetup.Description;
                ReasonCode.INSERT;
            end;
            GeneralLedgerSetup.Get;
            GeneralLedgerSetup.TestField("Share Trading Dimension Code");
            GeneralLedgerSetup.TestField("Share Trading Dimension No.");
            if not DimensionValue.GET(GeneralLedgerSetup."Share Trading Dimension Code", ShareTradingSetup."Document No.") then begin
                DimensionValue.INIT;
                DimensionValue."Dimension Code" := GeneralLedgerSetup."Share Trading Dimension Code";
                DimensionValue.Validate(Code, ShareTradingSetup."Document No.");
                DimensionValue.Validate(Name, ShareTradingSetup.Description);
                DimensionValue."Dimension Value Type" := DimensionValue."Dimension Value Type"::Standard;
                DimensionValue."Global Dimension No." := GeneralLedgerSetup."Share Trading Dimension No.";
                DimensionValue.Insert(true);
            end;
            ShareTradingSetup.Published := true;
            ShareTradingSetup.Status := ShareTradingSetup.Status::Published;
            ShareTradingSetup.MODIFY;
        end;
    end;

    procedure TakeDownShareTradingSetup(ShareTradingSetup: Record "Share Trading Setup")
    var
        myInt: Integer;
    begin
        if CONFIRM(StrSubstNo('You are about to take down the Share Trading %1,\\Do you wish to continue?', ShareTradingSetup."Document No.")) then begin
            ShareTradingSetup.Published := false;
            ShareTradingSetup.MODIFY;
        end;
    end;

    [Scope('Cloud')]
    procedure PublishSale(ShareFloating: Record "Share Floating")
    var
        ShareTradingSetup: Record "Share Trading Setup";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        OnBeforeFloatShares(ShareFloating);
        Dim1 := '';
        Dim2 := '';
        ShareFloating.VALIDATE("Share Type");
        ShareFloating.VALIDATE("Shares to Float");
        ShareFloating.VALIDATE("Minimum Acceptable Price");
        Dim1 := ShareFloating."Global Dimension 1 Code";
        Dim2 := ShareFloating."Global Dimension 2 Code";
        ShareTradingSetup.GET(ShareFloating."Share Type");
        ShareTradingSetup.TESTFIELD("Holding Account");
        JournalBatch := 'S-TRADE';
        JournalTemplate := 'PURCHASES';
        if not GenJournalBatch.GET(JournalTemplate, JournalBatch) then begin
            GenJournalBatch.INIT;
            GenJournalBatch."Journal Template Name" := JournalTemplate;
            GenJournalBatch.Name := JournalBatch;
            GenJournalBatch.Description := 'Member Share Trading';
            GenJournalBatch.INSERT;
        end;
        GenJournalLine.RESET;
        GenJournalLine.SETRANGE("Journal Template Name", JournalTemplate);
        GenJournalLine.SETRANGE("Journal Batch Name", JournalBatch);
        if GenJournalLine.FINDFIRST then GenJournalLine.DELETEALL;
        DocumentNo := ShareFloating."Document No";
        PostingDate := TODAY;
        VendorLedgerEntry.RESET;
        VendorLedgerEntry.SETRANGE("Document No.", DocumentNo);
        VendorLedgerEntry.SETRANGE("Reason Code", DocumentNo);
        VendorLedgerEntry.SETRANGE("Vendor No.", ShareFloating."Account No.");
        VendorLedgerEntry.SETRANGE(Reversed, false);
        if VendorLedgerEntry.FINDFIRST then begin
        end
        else begin
            GenJournalLine.INIT;
            GenJournalLine."Journal Template Name" := JournalTemplate;
            GenJournalLine."Journal Batch Name" := JournalBatch;
            GenJournalLine."Line No." := LineNo;
            GenJournalLine."Posting Date" := TODAY;
            GenJournalLine."Document No." := DocumentNo;
            LineNo += 1000;
            GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
            GenJournalLine.VALIDATE("Account No.", ShareFloating."Account No.");
            If Vendor.Get(ShareFloating."Account No.") then GenJournalLine."Member No." := Vendor."Member No.";
            GenJournalLine."Debit Amount" := ABS(ShareFloating."Shares to Float" * ShareFloating."Par Value");
            GenJournalLine.VALIDATE("Debit Amount");
            GenJournalLine.VALIDATE("Shortcut Dimension 1 Code");
            GenJournalLine.VALIDATE("Shortcut Dimension 2 Code");
            GenJournalLine."Message to Recipient" := 'S: Share Sale ' + FORMAT(ShareFloating."Shares to Float") + ' at ' + FORMAT(ShareFloating."Minimum Acceptable Price") + 'Minimum';
            GenJournalLine.Description := 'S: Share Sale ' + FORMAT(ShareFloating."Shares to Float") + ' at ' + FORMAT(ShareFloating."Minimum Acceptable Price") + 'Minimum';
            GenJournalLine."Due Date" := ShareTradingSetup."End Date";
            GenJournalLine."Reason Code" := ShareFloating."Document No";
            GenJournalLine."Source Code" := 'STRADE';
            GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
            GenJournalLine.VALIDATE("Bal. Account No.", ShareTradingSetup."Holding Account");
            GenJournalLine.VALIDATE("Shortcut Dimension 1 Code", Dim1);
            GenJournalLine.VALIDATE("Shortcut Dimension 2 Code", Dim2);
            if GenJournalLine.Amount <> 0 then GenJournalLine.INSERT;
        end;
        JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
        ShareFloating."Published On" := TODAY;
        if FORMAT(ShareFloating."Share Life") <> '' then ShareFloating."Exiry Date" := CALCDATE(ShareFloating."Share Life", TODAY);
        ShareFloating.Published := true;
        ShareFloating.MODIFY;
        COMMIT;
        Member.GET(ShareFloating."Member No.");
        CompanyInformation.GET;
        GeneralLedgerSetup.GET;
        Clear(TextMessage);
        Clear(TextPhone);
        TextMessage := 'Dear ' + Member."Full Name" + ', You Have Successfully Floated ' + FORMAT(ShareFloating."Floated Value") + ' ' + GeneralLedgerSetup."LCY Code" + ' Shares with ' + CompanyInformation.Name + ' at a Minimum Price of ' + FORMAT(ShareFloating."Minimum Acceptable Price" * ShareFloating."Shares to Float") + ' ' + GeneralLedgerSetup."LCY Code";
        TextPhone.Add(Member."Mobile Phone No.");
        CommunicationsMgmt.SendSMSNotification(TextPhone, TextMessage, ShareFloating."Member No.");
    end;

    [TryFunction]
    [Scope('Cloud')]
    procedure AnalyseShareTrade(ShareFloating: Record "Share Floating")
    var
        ShareTradingLines: Record "Share Trading Lines";
    begin
        ShareTradingLines.RESET;
        ShareTradingLines.SETRANGE("Document No.", ShareFloating."Document No");
        if ShareTradingLines.FINDFIRST then begin
            repeat
                ShareTradingLines.Awarded := false;
                ShareTradingLines."Total Amount" := 0;
                ShareTradingLines.MODIFY;
            until ShareTradingLines.NEXT = 0;
        end;
        ShareFloating.CALCFIELDS("Maximum Bid Price");
        ShareTradingLines.RESET;
        ShareTradingLines.SETRANGE("Document No.", ShareFloating."Document No");
        ShareTradingLines.SETRANGE("Bid Price", ShareFloating."Maximum Bid Price");
        ShareTradingLines.SETCURRENTKEY("Bid Date");
        if ShareTradingLines.FINDFIRST then begin
            ShareTradingLines.Awarded := true;
            ShareTradingLines.VALIDATE("Bid Price");
            ShareTradingLines.MODIFY;
        end;
    end;

    [Scope('Cloud')]
    procedure NotifyAward(ShareFloating: Record "Share Floating")
    var
        ShareTradingLines: Record "Share Trading Lines";
    begin
        ShareTradingLines.RESET;
        ShareTradingLines.SETRANGE(Awarded, true);
        ShareTradingLines.SETRANGE("Document No.", ShareFloating."Document No");
        if ShareTradingLines.FINDFIRST then begin
            Member.GET(ShareTradingLines."Member No.");
            CompanyInformation.GET;
            GeneralLedgerSetup.GET;
            TextMessage := 'Dear ' + ShareTradingLines."Member Name" + ', you have won the Bid on Purchase of ' + FORMAT(ShareFloating."Floated Value") + ' ' + GeneralLedgerSetup."LCY Code" + ' Shares at ' + CompanyInformation.Name + '. Please Pay ' + FORMAT(ShareTradingLines."Total Amount") + ' ' + GeneralLedgerSetup."LCY Code" + ' using Refrence ' + ShareTradingLines."Document No.";
            TextPhone.Add(Member."Mobile Transacting No");
            CommunicationsMgmt.SendSMSNotification(TextPhone, TextMessage, ShareTradingLines."Member No.");
        end;
    end;

    [Scope('Cloud')]
    procedure PostPurchase(ShareFloating: Record "Share Floating")
    var
        ShareTradingSetup: Record "Share Trading Setup";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        ShareTradingLines: Record "Share Trading Lines";
    begin
        ShareTradingLines.RESET;
        ShareTradingLines.SETRANGE("Document No.", ShareFloating."Document No");
        ShareTradingLines.SetRange(Awarded, true);
        if not ShareTradingLines.FINDFIRST then Error('You need to award the before posting');
        ShareFloating.VALIDATE("Share Type");
        //ShareFloating.VALIDATE("Shares to Float");
        //ShareFloating.VALIDATE("Minimum Acceptable Price");
        // ShareFloating.TESTFIELD("Global Dimension 1 Code");
        // ShareFloating.TESTFIELD("Global Dimension 2 Code");
        Dim1 := ShareFloating."Global Dimension 1 Code";
        Dim2 := ShareFloating."Global Dimension 2 Code";
        ShareTradingSetup.GET(ShareFloating."Share Type");
        ShareTradingSetup.TESTFIELD("Clearing Account");
        ShareTradingLines.RESET;
        ShareTradingLines.SETRANGE(Awarded, true);
        ShareTradingLines.SETRANGE("Document No.", ShareFloating."Document No");
        if ShareTradingLines.FINDFIRST then begin
            JournalBatch := 'S-TRADE';
            JournalTemplate := 'PURCHASES';
            if not GenJournalBatch.GET(JournalTemplate, JournalBatch) then begin
                GenJournalBatch.INIT;
                GenJournalBatch."Journal Template Name" := JournalTemplate;
                GenJournalBatch.Name := JournalBatch;
                GenJournalBatch.Description := 'Member Share Trading';
                GenJournalBatch.INSERT;
            end;
            GenJournalLine.RESET;
            GenJournalLine.SETRANGE("Journal Template Name", JournalTemplate);
            GenJournalLine.SETRANGE("Journal Batch Name", JournalBatch);
            if GenJournalLine.FINDFIRST then GenJournalLine.DELETEALL;
            DocumentNo := ShareFloating."Document No";
            PostingDate := TODAY;
            CustLedgerEntry.RESET;
            CustLedgerEntry.SETRANGE("Document No.", DocumentNo);
            CustLedgerEntry.SETRANGE("Reason Code", DocumentNo);
            CustLedgerEntry.SETRANGE("Customer No.", ShareTradingSetup."Clearing Account");
            CustLedgerEntry.SETRANGE(Reversed, false);
            if CustLedgerEntry.FINDFIRST then begin
            end
            else begin
                GenJournalLine.INIT;
                GenJournalLine."Journal Template Name" := JournalTemplate;
                GenJournalLine."Journal Batch Name" := JournalBatch;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Posting Date" := TODAY;
                GenJournalLine."Document No." := DocumentNo;
                LineNo += 1000;
                GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
                GenJournalLine.VALIDATE("Account No.", ShareTradingSetup."Clearing Account");
                GenJournalLine."Debit Amount" := ABS(ShareTradingLines."Total Amount");
                GenJournalLine.VALIDATE("Debit Amount");
                GenJournalLine."Message to Recipient" := 'P: Share Purchase ' + FORMAT(ShareFloating."Shares to Float") + ' at ' + FORMAT(ShareFloating."Minimum Acceptable Price") + 'Minimum';
                GenJournalLine.Description := 'P: Share Purchase ' + FORMAT(ShareFloating."Shares to Float") + ' at ' + FORMAT(ShareFloating."Minimum Acceptable Price") + 'Minimum';
                GenJournalLine."Due Date" := ShareTradingSetup."End Date";
                GenJournalLine."Reason Code" := ShareFloating."Document No";
                GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
                GenJournalLine.VALIDATE("Bal. Account No.", ShareTradingSetup."Holding Account");
                GenJournalLine."External Document No." := ShareTradingLines."Member No.";
                GenJournalLine."Source Code" := 'STRADE';
                GenJournalLine.VALIDATE("Shortcut Dimension 1 Code", Dim1);
                if GenJournalLine.Amount <> 0 then GenJournalLine.INSERT;
            end;
            JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
            ShareTradingLines.Bought := true;
            ShareTradingLines.MODIFY;
        end;
        ShareFloating."Purchase Date" := TODAY;
        if FORMAT(ShareFloating."Tolerance Period") <> '' then ShareFloating."Payment Due Date" := CALCDATE(ShareFloating."Tolerance Period", TODAY);
        ShareFloating.Awarded := true;
        ShareFloating.MODIFY;
        COMMIT;
        ShareTradingLines.RESET;
        ShareTradingLines.SETRANGE(Awarded, true);
        ShareTradingLines.SETRANGE("Document No.", ShareFloating."Document No");
        if ShareTradingLines.FINDFIRST then begin
            Member.GET(ShareTradingLines."Member No.");
            CompanyInformation.GET;
            TextMessage := 'Dear ' + ShareTradingLines."Member Name" + ', you have won the Bid on Purchase of Shares at ' + CompanyInformation.Name + '. Please Pay ' + FORMAT(ShareTradingLines."Total Amount") + ' using Refrence ' + ShareTradingLines."Document No." + ' On or Before ' + FORMAT(ShareFloating."Payment Due Date");
            TextPhone.Add(Member."Mobile Transacting No");
            CommunicationsMgmt.SendSMSNotification(TextPhone, TextMessage, ShareTradingLines."Member No.");
        end;
    end;

    [Scope('Cloud')]
    procedure TransferShares(ShareFloating: Record "Share Floating")
    var
        ShareTradingSetup: Record "Share Trading Setup";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        ShareTradingLines: Record "Share Trading Lines";
        Proceeds: Decimal;
        TransactionChargeSetup: Record "Transaction Charges Setup";
        BaseAmount: Decimal;
        TransactionCalcScheme: Record "Transaction Calc. Scheme";
        Base1: Decimal;
        TransactionCalcScheme1: Record "Transaction Calc. Scheme";
        ShareTransferReceipt: Record "Share Transfer Receipt";
    begin
        //ShareFloating.TESTFIELD("Global Dimension 1 Code");
        //ShareFloating.TESTFIELD("Global Dimension 2 Code");
        Dim1 := ShareFloating."Global Dimension 1 Code";
        Dim2 := ShareFloating."Global Dimension 2 Code";
        ShareTradingSetup.GET(ShareFloating."Share Type");
        ShareTradingSetup.TESTFIELD("Clearing Account");
        ShareTradingLines.RESET;
        ShareTradingLines.SETRANGE(Awarded, true);
        ShareTradingLines.SETRANGE("Document No.", ShareFloating."Document No");
        if ShareTradingLines.FINDFIRST then begin
            JournalBatch := 'S-TRADE';
            JournalTemplate := 'PURCHASES';
            if not GenJournalBatch.GET(JournalTemplate, JournalBatch) then begin
                GenJournalBatch.INIT;
                GenJournalBatch."Journal Template Name" := JournalTemplate;
                GenJournalBatch.Name := JournalBatch;
                GenJournalBatch.Description := 'Member Share Trading';
                GenJournalBatch.INSERT;
            end;
            GenJournalLine.RESET;
            GenJournalLine.SETRANGE("Journal Template Name", JournalTemplate);
            GenJournalLine.SETRANGE("Journal Batch Name", JournalBatch);
            if GenJournalLine.FINDFIRST then GenJournalLine.DELETEALL;
            DocumentNo := ShareFloating."Document No";
            PostingDate := TODAY;
            //Post To Bank OR FOSA Account
            ShareTransferReceipt.RESET;
            ShareTransferReceipt.SETRANGE("Document No.", DocumentNo);
            ShareTransferReceipt.SETFILTER("Allocated Amount", '>%1', 0);
            if ShareTransferReceipt.FINDFIRST then begin
                repeat
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := JournalTemplate;
                    GenJournalLine."Journal Batch Name" := JournalBatch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine."Document No." := DocumentNo;
                    LineNo += 1000;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                    GenJournalLine.VALIDATE("Account No.", ShareTransferReceipt."Account No.");
                    if Vendor.Get(ShareTransferReceipt."Account No.") then;
                    GenJournalLine.VALIDATE("Member No.", Vendor."Member No.");
                    ShareFloating.CALCFIELDS("Payment Amount");
                    GenJournalLine."Debit Amount" := ABS(ShareTransferReceipt."Allocated Amount");
                    GenJournalLine.VALIDATE("Debit Amount");
                    GenJournalLine."Message to Recipient" := 'P: Payment For Shares Bought ' + FORMAT(ShareFloating."Shares to Float") + ' at ' + FORMAT(ShareFloating."Maximum Bid Price");
                    GenJournalLine.Description := 'P: Payment For Shares Bought ' + FORMAT(ShareFloating."Shares to Float") + ' at ' + FORMAT(ShareFloating."Maximum Bid Price");
                    GenJournalLine."Due Date" := ShareTradingSetup."End Date";
                    GenJournalLine."Reason Code" := ShareFloating."Document No";
                    GenJournalLine."External Document No." := ShareFloating."External Refrence No.";
                    GenJournalLine."Applies-to Doc. No." := ShareTransferReceipt."Refrence No.";
                    GenJournalLine.VALIDATE("Shortcut Dimension 1 Code", Dim1);
                    GenJournalLine.VALIDATE("Shortcut Dimension 2 Code", Dim2);
                    if GenJournalLine.Amount <> 0 then GenJournalLine.INSERT;
                until ShareTransferReceipt.NEXT = 0;
            end;
            //Pay Holding Account Invoice
            GenJournalLine.INIT;
            GenJournalLine."Journal Template Name" := JournalTemplate;
            GenJournalLine."Journal Batch Name" := JournalBatch;
            GenJournalLine."Line No." := LineNo;
            GenJournalLine."Posting Date" := TODAY;
            GenJournalLine."Document No." := DocumentNo;
            LineNo += 1000;
            GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
            GenJournalLine.VALIDATE("Account No.", ShareTradingSetup."Clearing Account");
            ShareFloating.CALCFIELDS("Payment Amount");
            GenJournalLine."Credit Amount" := ABS(ShareFloating."Payment Amount");
            GenJournalLine.VALIDATE("Credit Amount");
            GenJournalLine."Message to Recipient" := 'P: Payment For Shares Bought ' + FORMAT(ShareFloating."Shares to Float") + ' at ' + FORMAT(ShareFloating."Maximum Bid Price");
            GenJournalLine.Description := 'P: Payment For Shares Bought ' + FORMAT(ShareFloating."Shares to Float") + ' at ' + FORMAT(ShareFloating."Maximum Bid Price");
            GenJournalLine."Due Date" := ShareTradingSetup."End Date";
            GenJournalLine."Reason Code" := ShareFloating."Document No";
            GenJournalLine."External Document No." := ShareFloating."External Refrence No.";
            GenJournalLine.VALIDATE("Applies-to Doc. No.", DocumentNo);
            GenJournalLine.VALIDATE("Shortcut Dimension 1 Code", Dim1);
            GenJournalLine.VALIDATE("Shortcut Dimension 2 Code", Dim2);
            if GenJournalLine.Amount <> 0 then GenJournalLine.INSERT;
            //Transfer Shares to Bought Member
            GenJournalLine.INIT;
            GenJournalLine."Journal Template Name" := JournalTemplate;
            GenJournalLine."Journal Batch Name" := JournalBatch;
            GenJournalLine."Line No." := LineNo;
            GenJournalLine."Posting Date" := TODAY;
            GenJournalLine."Document No." := DocumentNo;
            LineNo += 1000;
            GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
            GenJournalLine.VALIDATE("Account No.", ShareTradingLines."Account No");
            If Vendor.Get(ShareTradingLines."Account No") then;
            GenJournalLine.VALIDATE("Member No.", Vendor."Member No.");
            ShareFloating.CALCFIELDS("Payment Amount");
            GenJournalLine."Credit Amount" := ABS(ShareFloating."Shares to Float" * ShareFloating."Par Value");
            GenJournalLine.VALIDATE("Credit Amount");
            GenJournalLine."Message to Recipient" := 'P:Shares Bought ' + FORMAT(ShareFloating."Shares to Float") + ' at ' + FORMAT(ShareFloating."Par Value");
            GenJournalLine.Description := 'P:Shares Bought ' + FORMAT(ShareFloating."Shares to Float") + ' at ' + FORMAT(ShareFloating."Par Value");
            GenJournalLine."Due Date" := ShareTradingSetup."End Date";
            GenJournalLine."Reason Code" := ShareFloating."Document No";
            GenJournalLine."External Document No." := ShareFloating."External Refrence No.";
            GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
            GenJournalLine.VALIDATE("Bal. Account No.", ShareTradingSetup."Holding Account");
            GenJournalLine."Source Code" := 'STRADE';
            GenJournalLine.VALIDATE("Shortcut Dimension 1 Code", Dim1);
            GenJournalLine.VALIDATE("Shortcut Dimension 2 Code", Dim2);
            if GenJournalLine.Amount <> 0 then GenJournalLine.INSERT;
            //Credit Variance to Member Income
            GenJournalLine.INIT;
            GenJournalLine."Journal Template Name" := JournalTemplate;
            GenJournalLine."Journal Batch Name" := JournalBatch;
            GenJournalLine."Line No." := LineNo;
            GenJournalLine."Posting Date" := TODAY;
            GenJournalLine."Document No." := DocumentNo;
            LineNo += 1000;
            GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
            GenJournalLine.VALIDATE("Account No.", ShareFloating."Proceeds Account");
            If Vendor.Get(ShareFloating."Proceeds Account") then;
            GenJournalLine.VALIDATE("Member No.", Vendor."Member No.");
            ShareFloating.CALCFIELDS("Payment Amount");
            GenJournalLine."Credit Amount" := ABS(ShareFloating."Payment Amount");
            GenJournalLine.VALIDATE("Credit Amount");
            GenJournalLine."Message to Recipient" := 'P:Shares Sold ' + FORMAT(ShareFloating."Shares to Float") + ' at ' + FORMAT(ShareFloating."Maximum Bid Price");
            GenJournalLine.Description := 'P:Shares Sold ' + FORMAT(ShareFloating."Shares to Float") + ' at ' + FORMAT(ShareFloating."Maximum Bid Price");
            GenJournalLine."Due Date" := ShareTradingSetup."End Date";
            GenJournalLine."Reason Code" := ShareFloating."Document No";
            GenJournalLine."External Document No." := ShareFloating."External Refrence No.";
            GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
            GenJournalLine.VALIDATE("Bal. Account No.", ShareTradingSetup."Holding Account");
            GenJournalLine.VALIDATE("Shortcut Dimension 1 Code", Dim1);
            GenJournalLine.VALIDATE("Shortcut Dimension 2 Code", Dim2);
            if GenJournalLine.Amount <> 0 then GenJournalLine.INSERT;
            //Add Charges
            if ShareTradingSetup.Charges <> '' then begin
                Proceeds := 0;
                ShareFloating.CALCFIELDS("Payment Amount");
                Proceeds := ShareFloating."Payment Amount" - (ShareFloating."Par Value" * ShareFloating."Shares to Float");
                LineNo := JournalManagement.AddCharges(ShareTradingSetup.Charges, ShareFloating."Proceeds Account", Proceeds, LineNo, DocumentNo, Vendor."Member No.", 'STRADE', '', '', JournalBatch, JournalTemplate, Dim1, Dim2, PostingDate, False);
            end;
            COMMIT;
            JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
            OnAfterTtransferShares(ShareFloating);
            ShareFloating.Archived := true;
            ShareFloating.Published := false;
            ShareFloating.MODIFY;
        end;
    end;

    [Scope('Cloud')]
    procedure TakeDownSale(ShareFloating: Record "Share Floating")
    var
        ShareTradingSetup: Record "Share Trading Setup";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        if ShareFloating.Published = false then begin
            ShareFloating.Archived := false;
            ShareFloating.Status := ShareFloating.Status::Open;
            ShareFloating.MODIFY;
        end
        else begin
            ShareFloating.TESTFIELD("Share Type");
            ShareFloating.TESTFIELD("Shares to Float");
            ShareFloating.TESTFIELD("Minimum Acceptable Price");
            Dim1 := ShareFloating."Global Dimension 1 Code";
            Dim2 := ShareFloating."Global Dimension 2 Code";
            ShareTradingSetup.GET(ShareFloating."Share Type");
            ShareTradingSetup.TESTFIELD("Holding Account");
            JournalBatch := 'S-TRADE';
            JournalTemplate := 'PURCHASES';
            if not GenJournalBatch.GET(JournalTemplate, JournalBatch) then begin
                GenJournalBatch.INIT;
                GenJournalBatch."Journal Template Name" := JournalTemplate;
                GenJournalBatch.Name := JournalBatch;
                GenJournalBatch.Description := 'Member Share Trading';
                GenJournalBatch.INSERT;
            end;
            GenJournalLine.RESET;
            GenJournalLine.SETRANGE("Journal Template Name", JournalTemplate);
            GenJournalLine.SETRANGE("Journal Batch Name", JournalBatch);
            if GenJournalLine.FINDFIRST then GenJournalLine.DELETEALL;
            DocumentNo := ShareFloating."Document No";
            PostingDate := TODAY;
            VendorLedgerEntry.RESET;
            VendorLedgerEntry.SETRANGE("Document No.", DocumentNo);
            VendorLedgerEntry.SETRANGE("Reason Code", DocumentNo);
            VendorLedgerEntry.SETRANGE("Vendor No.", ShareFloating."Account No.");
            VendorLedgerEntry.SETRANGE(Reversed, false);
            if VendorLedgerEntry.FINDFIRST then begin
                GenJournalLine.INIT;
                GenJournalLine."Journal Template Name" := JournalTemplate;
                GenJournalLine."Journal Batch Name" := JournalBatch;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Posting Date" := TODAY;
                GenJournalLine."Document No." := DocumentNo;
                LineNo += 1000;
                GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                GenJournalLine.VALIDATE("Account No.", ShareFloating."Account No.");
                GenJournalLine."Credit Amount" := ABS(ShareFloating."Shares to Float" * ShareFloating."Par Value");
                GenJournalLine.VALIDATE("Credit Amount");
                GenJournalLine.VALIDATE("Shortcut Dimension 1 Code");
                GenJournalLine.VALIDATE("Shortcut Dimension 2 Code");
                GenJournalLine."Message to Recipient" := 'R: Share Sale Reversal ' + FORMAT(ShareFloating."Shares to Float") + ' at ' + FORMAT(ShareFloating."Minimum Acceptable Price") + 'Minimum';
                GenJournalLine.Description := 'R: Share Sale Reversal ' + FORMAT(ShareFloating."Shares to Float") + ' at ' + FORMAT(ShareFloating."Minimum Acceptable Price") + 'Minimum';
                GenJournalLine."Due Date" := ShareTradingSetup."End Date";
                GenJournalLine."Reason Code" := ShareFloating."Document No";
                GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
                GenJournalLine.VALIDATE("Bal. Account No.", ShareTradingSetup."Holding Account");
                GenJournalLine.VALIDATE("Shortcut Dimension 1 Code", Dim1);
                GenJournalLine.VALIDATE("Shortcut Dimension 2 Code", Dim2);
                if GenJournalLine.Amount <> 0 then GenJournalLine.INSERT;
            end;
            JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
            ShareFloating."Published On" := TODAY;
            if FORMAT(ShareFloating."Share Life") <> '' then ShareFloating."Exiry Date" := CALCDATE(ShareFloating."Share Life", TODAY);
            ShareFloating.Published := false;
            ShareFloating.Archived := true;
            ShareFloating.MODIFY;
            COMMIT;
            Member.GET(ShareFloating."Member No.");
            CompanyInformation.GET;
            TextMessage := 'Dear ' + Member."Full Name" + ', You Have Successfully Cancelled ' + FORMAT(ShareFloating."Shares to Float" * ShareFloating."Reserve Price") + ' Shares Floated On ' + CompanyInformation.Name;
            TextPhone.Add(Member."Mobile Transacting No");
            CommunicationsMgmt.SendSMSNotification(TextPhone, TextMessage, ShareFloating."Member No.");
        end;
    end;

    [IntegrationEvent(false, false)]
    [Scope('Cloud')]
    procedure OnBeforeFloatShares(ShareFloating: Record "Share Floating")
    begin
    end;

    [IntegrationEvent(false, false)]
    [Scope('Cloud')]
    procedure OnAfterTtransferShares(ShareFloating: Record "Share Floating")
    begin
    end;
}
