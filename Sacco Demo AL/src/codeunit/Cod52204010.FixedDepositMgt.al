codeunit 52204010 "Fixed Deposit Mgt."
{
    var
        JournalMgmt: Codeunit "Journal Management";
        GlobalTransactionType: Enum "Sacco Transaction Type";
        GlobalAccountType: Enum "Gen. Journal Account Type";
        LineNo: Integer;
        AccountNo, ExtDocumentNo, JournalBatch, JournalTemplate, Dim1, Dim2, DocumentNo, MemberNo, ReasonCode, SourceCode : code[20];
        PostingDescription: Text[100];
        PostingDate: Date;
        PostingAmount: Decimal;
        GLEntry: Record "G/L Entry";

    procedure CreateFixedDepositSchedule(FixedDeposit: Record "Member Fixed Deposits")
    VAR
        Schedule: Record "Member Fixed Deposit Schedule";
        EntryNo: Integer;
        SDate: date;
        FPrincipal: Decimal;
        Interest: Decimal;
        FDTypes: Record "Member Fixed Deposit Types";
    begin
        if not FixedDeposit.Posted then begin
            if FixedDeposit."Source Balance" < FixedDeposit.Amount then
                Error('You Can only fix upto %1', FixedDeposit."Source Balance");
        end;

        SDate := FixedDeposit."Start Date";
        FDTypes.Get(FixedDeposit.Type);
        FPrincipal := 0;
        FPrincipal := FixedDeposit.Amount;
        FixedDeposit.TestField("End Date");

        Schedule.Reset();
        Schedule.SetRange("No.", FixedDeposit."No.");
        Schedule.SetRange(Transferred, true);
        if Schedule.FindSet() then
            Error('The FD Has transferred Entries. The Schedule Cannot be modified');
        Schedule.Reset();
        Schedule.SetRange("No.", FixedDeposit."No.");
        if Schedule.FindSet() then Schedule.DeleteAll();
        EntryNo := 1;
        Schedule.Reset();
        if Schedule.FindLast() then EntryNo := Schedule."Entry No." + 1;
        repeat
            Interest := 0;
            Interest := FixedDeposit.Rate * FPrincipal * 0.01 * (1 / 12);
            if FDTypes."Interest Calculation Type" = FDTypes."Interest Calculation Type"::"Reducing Balance" then FPrincipal += Interest;
            Schedule.Init();
            Schedule."Entry No." := EntryNo;
            EntryNo += 1;
            Schedule."No." := FixedDeposit."No.";
            Schedule.Description := 'Accrued Interest for ' + Format(SDate);
            Schedule."Posting Date" := SDate;
            Schedule.Amount := Interest;
            Schedule.Insert();
            SDate := CalcDate('1M', SDate);
        until SDate >= FixedDeposit."End Date";
    end;

    procedure CreateFDAccount(FixedDeposit: Record "Member Fixed Deposits") FDAccount: Code[20]
    var
        Vendor: Record Vendor;
        Members: Record Members;
        FDType: Record "Member Fixed Deposit Types";
        SaccoProducts: Record "Sacco Products";
        AccNo: Code[20];
    begin
        FDType.Get(FixedDeposit.Type);
        SaccoProducts.Get(FDType."Linking Account Type");
        SaccoProducts.TestField(Prefix);
        AccNo := SaccoProducts.Prefix + FixedDeposit."Member No." + SaccoProducts.Suffix;
        if not Vendor.Get(AccNo) then begin
            Members.Get(FixedDeposit."Member No.");
            Vendor.Init();
            Vendor."No." := AccNo;
            Vendor.Name := UpperCase(SaccoProducts.Description);
            Vendor."Vendor Posting Group" := SaccoProducts."Posting Group";
            Vendor."Product Posting Type" := SaccoProducts."Product Posting Type";
            Vendor."Account Type" := Vendor."Account Type"::Sacco;
            Vendor."Member No." := Members."No.";
            Vendor."Member Name" := UpperCase(Members.FullName);
            Vendor.Status := Vendor.Status::Active;
            Vendor."Product Code" := SaccoProducts.Code;
            Vendor.Insert(true);
        end;
        exit(AccNo);
    end;

    procedure ActivateFD(FixedDeposit: Record "Member Fixed Deposits")
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        JournalTemplate := 'PAYMENT';
        JournalBatch := 'FD-PST';
        LineNo := JournalMgmt.PrepareJournal(JournalTemplate, JournalBatch);
        PostingDate := FixedDeposit."Posting Date";
        DocumentNo := FixedDeposit."No.";
        MemberNo := FixedDeposit."Member No.";
        SourceCode := FixedDeposit."No.";
        PostingDescription := 'Fixed deposit activation';
        PostingAmount := FixedDeposit.Amount;
        //Credit Destination Account 
        AccountNo := '';
        AccountNo := CreateFDAccount(FixedDeposit);
        Commit;
        LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Fixed Deposit", LineNo, SourceCode, ReasonCode, ExtDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
        //Debit Source Account  
        AccountNo := '';
        AccountNo := FixedDeposit."Source Account";
        LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Fixed Deposit", LineNo, SourceCode, ReasonCode, ExtDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
        JournalMgmt.CompletePosting(JournalTemplate, JournalBatch);
        FixedDeposit.Posted := true;
        FixedDeposit."Control Account" := CreateFDAccount(FixedDeposit);
        FixedDeposit."Posted By" := UserId;
        FixedDeposit.Modify(true);
    end;

    procedure PostFDROpeningBalances()
    var
        FixedDeposit: Record "Member Fixed Deposits";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        JournalTemplate := 'PAYMENT';
        JournalBatch := 'FD-PST';
        FixedDeposit.Reset();
        FixedDeposit.SetRange(Posted, false);
        FixedDeposit.SetRange(Status, FixedDeposit.Status::Approved);
        if FixedDeposit.FindSet then begin
            repeat
                LineNo := JournalMgmt.PrepareJournal(JournalTemplate, JournalBatch);
                GeneralLedgerSetup.Get;
                GeneralLedgerSetup.TestField("Opening Balance Acc.");
                GeneralLedgerSetup.TestField("Opening Balance Posting Date");
                DocumentNo := FixedDeposit."No.";
                PostingDate := GeneralLedgerSetup."Opening Balance Posting Date";
                MemberNo := FixedDeposit."Member No.";
                PostingDescription := 'Fixed deposit activation';
                PostingAmount := FixedDeposit.Amount;
                GLEntry.Reset();
                GLEntry.SetRange("Document No.", DocumentNo);
                GLEntry.SetRange("Document Date", PostingDate);
                if not GLEntry.FindFirst() then begin
                    //Credit Destination Account 
                    AccountNo := '';
                    AccountNo := CreateFDAccount(FixedDeposit);
                    Commit;
                    LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Fixed Deposit", LineNo, SourceCode, ReasonCode, ExtDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                    //Debit Source Account  
                    AccountNo := '';
                    AccountNo := GeneralLedgerSetup."Opening Balance Acc.";
                    LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Fixed Deposit", LineNo, SourceCode, ReasonCode, ExtDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                    JournalMgmt.CompletePosting(JournalTemplate, JournalBatch);
                    FixedDeposit.Posted := true;
                    FixedDeposit."Control Account" := CreateFDAccount(FixedDeposit);
                    FixedDeposit."Posted By" := UserId;
                    FixedDeposit.Modify(true);
                end;
            until FixedDeposit.Next = 0;
        end;
    end;

    procedure PostFDAccrual(FixedDeposit: Record "Member Fixed Deposits")
    var
        NoSeries: Codeunit NoSeriesManagement;
        Schedule: array[2] of Record "Member Fixed Deposit Schedule";
        FDType: Record "Member Fixed Deposit Types";
    begin
        if FDType.Get(FixedDeposit.Type) = false then exit;
        JournalTemplate := 'PAYMENT';
        JournalBatch := 'FD-ACCR';
        LineNo := JournalMgmt.PrepareJournal(JournalTemplate, JournalBatch);
        Schedule[1].Reset();
        Schedule[1].SetRange("No.", FixedDeposit."No.");
        Schedule[1].SetRange(Transferred, false);
        Schedule[1].SetFilter("Posting Date", '..%1', WorkDate);
        if Schedule[1].FindSet() then begin
            repeat
                DocumentNo := FixedDeposit."No.";
                MemberNo := FixedDeposit."Member No.";
                PostingDescription := Schedule[1].Description;
                PostingDate := Schedule[1]."Posting Date";
                PostingAmount := Schedule[1].Amount;
                //Credit Provisioning Account
                AccountNo := '';
                AccountNo := FDType."Interest Provision Account";
                LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Fixed Deposit", LineNo, SourceCode, ReasonCode, ExtDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                //Debit  Payable Account
                AccountNo := '';
                AccountNo := FDType."Interest Payable Account";
                LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Fixed Deposit", LineNo, SourceCode, ReasonCode, ExtDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
            until Schedule[1].Next() = 0;
            JournalMgmt.CompletePosting(JournalTemplate, JournalBatch);
            Schedule[2].Reset();
            Schedule[2].SetRange("No.", FixedDeposit."No.");
            Schedule[2].SetRange(Transferred, false);
            Schedule[2].SetFilter("Posting Date", '..%1', WorkDate);
            if Schedule[2].FindSet() then begin
                repeat
                    GLEntry.Reset();
                    GLEntry.SetRange("Document No.", DocumentNo);
                    GLEntry.SetRange("Document Date", Schedule[2]."Posting Date");
                    if GLEntry.FindFirst() then begin
                        Schedule[2].Transferred := true;
                        Schedule[2].Modify(true);
                    end;
                until Schedule[2].Next() = 0;
            end;
        end;
    end;

    procedure MatureFixedDeposit(FixedDeposit: Record "Member Fixed Deposits")
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        FDType: Record "Member Fixed Deposit Types";
        FixedDepositRollOver: array[2] of Record "Member Fixed Deposits";
    begin
        if FixedDeposit."End Date" > WorkDate then Error('You Cannot Mature the fixed deposit before its due date of %1', FixedDeposit."End Date");
        if not FDType.Get(FixedDeposit.Type) then exit;
        FDType.TestField("Withholding Tax Rate");
        FDType.TestField("Withholding Tax Account");
        DocumentNo := FixedDeposit."No.";
        MemberNo := FixedDeposit."Member No.";
        SourceCode := FixedDeposit."No.";
        FixedDeposit.CalcFields("Total Interest Payable", "Running Balance", "Linked Loan Balance");
        //FixedDeposit.TestField("Total Interest Payable");
        FixedDeposit.TestField("Linked Loan Balance", 0);
        DocumentNo := FixedDeposit."No.";
        PostingDate := FixedDeposit."End Date";
        JournalTemplate := 'GENERAL';
        JournalBatch := 'FD-PST';
        LineNo := JournalMgmt.PrepareJournal(JournalTemplate, JournalBatch);
        //Pay Interest  
        PostingAmount := FixedDeposit."Total Interest Payable";
        PostingDescription := 'Interest Earned ' + FixedDeposit."No.";
        AccountNo := '';
        AccountNo := FDType."Interest Provision Account";
        LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Fixed Deposit", LineNo, SourceCode, ReasonCode, ExtDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
        AccountNo := '';
        AccountNo := FixedDeposit."Control Account";
        LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Fixed Deposit", LineNo, SourceCode, ReasonCode, ExtDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
        LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Fixed Deposit", LineNo, SourceCode, ReasonCode, ExtDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
        AccountNo := '';
        AccountNo := FixedDeposit."Source Account";
        LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Fixed Deposit", LineNo, SourceCode, ReasonCode, ExtDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
        AccountNo := '';
        PostingDescription := 'Withholding Tax on Interest ' + FixedDeposit."No.";
        AccountNo := FDType."Withholding Tax Account";
        PostingAmount := FixedDeposit."Total Interest Payable" * FDType."Withholding Tax Rate" * 0.01;
        LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Fixed Deposit", LineNo, SourceCode, ReasonCode, ExtDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
        AccountNo := '';
        AccountNo := FixedDeposit."Source Account";
        LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Fixed Deposit", LineNo, SourceCode, ReasonCode, ExtDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
        //Refund Principal
        PostingDescription := 'Fixed Deposit Maturity ' + FixedDeposit."No.";
        PostingAmount := 0;
        PostingAmount := FixedDeposit."Running Balance";
        AccountNo := '';
        AccountNo := FixedDeposit."Source Account";
        LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Fixed Deposit", LineNo, SourceCode, ReasonCode, ExtDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
        AccountNo := '';
        AccountNo := FixedDeposit."Control Account";
        LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Fixed Deposit", LineNo, SourceCode, ReasonCode, ExtDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
        if FixedDeposit."Maturity Instructions" <> FixedDeposit."Maturity Instructions"::Liquidate then begin
            if FixedDepositRollOver[1].Get(CopyFixedDeposit(FixedDeposit)) then begin
                PostingDescription := 'Fixed Deposit Roll OVer to ' + FixedDepositRollOver[1]."No.";
                if FixedDeposit."Maturity Instructions" = FixedDeposit."Maturity Instructions"::"Roll Over Principal" then
                    PostingAmount := FixedDeposit.Amount
                else
                    PostingAmount := (FixedDeposit.Amount + FixedDeposit."Total Interest Payable" - JournalMgmt.GetChargesAmount(FDType."Charge Code", FixedDeposit."Total Interest Payable"));
                // AccountNo := '';
                // AccountNo := '';
                // AccountNo := FixedDepositRollOver[1]."Source Account";
                // LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Fixed Deposit", LineNo, SourceCode, ReasonCode, ExtDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                // AccountNo := '';
                // AccountNo := FixedDepositRollOver[1]."Control Account";
                // LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Fixed Deposit", LineNo, SourceCode, ReasonCode, ExtDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                FixedDepositRollOver[1].Status := FixedDepositRollOver[1].Status::Open;
                FixedDepositRollOver[1].Posted := false;
                FixedDepositRollOver[1].Modify(true);
            end;
        end;
        LineNo := JournalMgmt.AddCharges(FDType."Charge Code", FixedDeposit."Source Account", FixedDeposit."Total Interest Payable", LineNo, DocumentNo, MemberNo, 'FD', 'FD', SourceCode, JournalBatch, JournalTemplate, Dim1, Dim2, PostingDate, True);
        JournalMgmt.CompletePosting(JournalTemplate, JournalBatch);
        GLEntry.Reset();
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("Document Date", PostingDate);
        if GLEntry.FindFirst() then begin
            if FixedDepositRollOver[2].Get(FixedDeposit."No.") then begin
                FixedDepositRollOver[2].Matured := true;
                FixedDepositRollOver[2].Modify(true);
            end;
        end;
    end;

    procedure CancelFixedDeposit(FixedDeposit: Record "Member Fixed Deposits")
    var
        NewFDNo: code[20];
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        FDType: Record "Member Fixed Deposit Types";
    begin
        if not FDType.Get(FixedDeposit.Type) then exit;
        DocumentNo := FixedDeposit."No.";
        MemberNo := FixedDeposit."Member No.";
        SourceCode := FixedDeposit."No.";
        FixedDeposit.CalcFields("Total Interest Payable", "Running Balance");
        JournalTemplate := 'PAYMENT';
        JournalBatch := 'FD-PST';
        PostingDate := WorkDate;
        PostingAmount := FixedDeposit."Total Interest Payable";
        LineNo := JournalMgmt.PrepareJournal(JournalTemplate, JournalBatch);
        PostingDescription := 'Principal Revoked ' + FixedDeposit."No.";
        PostingAmount := 0;
        PostingAmount := FixedDeposit."Running Balance";
        AccountNo := '';
        AccountNo := FixedDeposit."Source Account";
        LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Fixed Deposit", LineNo, SourceCode, ReasonCode, ExtDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
        AccountNo := '';
        AccountNo := FixedDeposit."Control Account";
        LineNo := JournalMgmt.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Fixed Deposit", LineNo, SourceCode, ReasonCode, ExtDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
        JournalMgmt.CompletePosting(JournalTemplate, JournalBatch);
        FixedDeposit.Terminated := true;
        FixedDeposit.Modify();
    end;

    local procedure CopyFixedDeposit(FixedDeposit: Record "Member Fixed Deposits") NewFDNo: code[20]
    var
        SaccoSetup: Record "General Ledger Setup";
        NoSeries: Codeunit NoSeriesManagement;
        NewFixedDeposit: Record "Member Fixed Deposits";
        FDNo: code[20];
        FDType: Record "Member Fixed Deposit Types";
    begin
        SaccoSetup.get;
        SaccoSetup.TestField("FD Nos.");
        FDNo := NoSeries.GetNextNo(SaccoSetup."FD Nos.", Today, true);
        NewFixedDeposit.Init();
        NewFixedDeposit.TransferFields(FixedDeposit, false);
        NewFixedDeposit."No." := FDNo;
        if FixedDeposit."Maturity Instructions" = NewFixedDeposit."Maturity Instructions"::"Roll Over Net" then begin
            NewFixedDeposit.Amount := (FixedDeposit.Amount + FixedDeposit."Total Interest Payable" - (FDType."Withholding Tax Rate" * FixedDeposit."Total Interest Payable" * 0.01));
        end;
        NewFixedDeposit."Start Date" := FixedDeposit."End Date";
        NewFixedDeposit.Validate("Start Date");
        NewFixedDeposit.Insert();
        CreateFixedDepositSchedule(NewFixedDeposit);
        FixedDeposit.Terminated := true;
        FixedDeposit.Modify();
        exit(FDNo);
    end;

    procedure UpdateFDMaturity()
    var
        MemberFixedDeposits: Record "Member Fixed Deposits";
    begin
        MemberFixedDeposits.Reset;
        MemberFixedDeposits.SetRange(Status, MemberFixedDeposits.Status::Approved);
        MemberFixedDeposits.SetRange(Matured, false);
        MemberFixedDeposits.SetRange(Terminated, false);
        MemberFixedDeposits.SetRange(Posted, true);
        MemberFixedDeposits.SetFilter("End Date", '<=%1', WorkDate);
        if MemberFixedDeposits.FindSet then begin
            repeat
                MemberFixedDeposits.Due := true;
                MemberFixedDeposits.Modify(true);
            until MemberFixedDeposits.Next = 0;
        end;
    end;

    procedure FDMaturityNotifications()
    var
        MemberFixedDeposits: Record "Member Fixed Deposits";
        UserSetup: Record "User Setup";
        CommunicationMgmt: Codeunit "Communications Mgmt";
        SMS: Codeunit "Notifications Management";
        SMSPhone, SMSText : Text[250];
        Recipients: List of [Text];
        Body: Text;
        Subject: Text;
        SMSSource: Code[20];
        Employee: Record Employee;
    begin
        Clear(Recipients);
        Clear(Subject);
        Clear(Body);
        Clear(SMSPhone);
        Clear(SMSText);
        SMSSource := 'FDR';
        MemberFixedDeposits.Reset;
        MemberFixedDeposits.SetRange(Status, MemberFixedDeposits.Status::Approved);
        MemberFixedDeposits.SetRange(Matured, false);
        MemberFixedDeposits.SetRange(Terminated, false);
        MemberFixedDeposits.SetRange(Posted, true);
        MemberFixedDeposits.SetRange("End Date", WorkDate, CalcDate('+2D', WorkDate));
        if MemberFixedDeposits.FindSet then begin
            repeat
                UserSetup.Reset;
                UserSetup.SetRange("Finance Admin", true);
                if UserSetup.FindSet then begin
                    repeat
                        if Employee.Get(UserSetup."Employee No.") then begin
                            SMSPhone := Employee."Phone No.";
                            if MemberFixedDeposits."End Date" - WorkDate <> 0 then
                                SMSText := StrSubstNo('Dear %1, Member Fixed Deposit %2 For %3 will mature on %4', Employee."First Name", MemberFixedDeposits."No.", MemberFixedDeposits."Member Name", MemberFixedDeposits."End Date")
                            else
                                SMSText := StrSubstNo('Dear %1, Member Fixed Deposit %2 For %3 is maturing Today', Employee."First Name", MemberFixedDeposits."No.", MemberFixedDeposits."Member Name");
                            SMS.SendSms(SMSPhone, SMSText, SMSSource);
                            Recipients.Add(Employee."Company E-Mail");
                            Subject := 'Member Fixed Deposit';
                            Body := 'Dear ' + Employee."First Name";
                            Body := '<br></br>';
                            if MemberFixedDeposits."End Date" - WorkDate <> 0 then
                                Body := StrSubstNo('Member Fixed Deposit %1 For %2 will mature on %3', MemberFixedDeposits."No.", MemberFixedDeposits."Member Name", MemberFixedDeposits."End Date")
                            else
                                Body := StrSubstNo('Member Fixed Deposit %1 For %2 is maturing Today', MemberFixedDeposits."No.", MemberFixedDeposits."Member Name");
                            CommunicationMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
                        end;
                    until UserSetup.Next = 0;
                end;
            until MemberFixedDeposits.Next = 0;
        end;
    end;


}
