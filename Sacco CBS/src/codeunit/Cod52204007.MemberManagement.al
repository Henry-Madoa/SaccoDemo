codeunit 52204007 "Member Management"
{
    var
        SaccoSetup: Record "General Ledger Setup";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        Vendor: array[3] of Record Vendor;
        GLEntry: Record "G/L Entry";
        JournalManagement: Codeunit "Journal Management";
        UserMgmtExt: Codeunit "User Management Ext";
        JournalBatch, JournalTemplate : code[20];
        LineNo: Integer;
        ProductPostingType: Enum "Product Posting Type";
        ProductSetup: Record "Sacco Products";
        ConfirmationMessage: Text[100];
        Member: Record Members;
        Window: Dialog;
        All, Current : Decimal;
    procedure GetAccountBalance(PAccountNo: Code[20]; AsAtDate: Date; var BookBalance: Decimal; var Uncleared: Decimal; var ActualBalance: Decimal)
    var
        Vendor: Record Vendor;
        SpotcashTransactions: Record "Channel Transactions";
        ATMTransactions: Record "ATM Transactions";
        Datefilter: Text;
        ProductFactory: Record "Sacco Products";
        FOSAAccount: Code[20];
    begin
        BookBalance := 0;
        Uncleared := 0;
        ActualBalance := 0;
        Datefilter := '..' + Format(AsAtDate);
        Vendor.Reset();
        Vendor.SetFilter("Date Filter", Datefilter);
        Vendor.SetRange("No.", PAccountNo);
        if Vendor.FindSet() then begin
            // SpotcashTransactions.Reset();
            // SpotcashTransactions.SetRange("Account Number", PAccountNo);
            // SpotcashTransactions.SetRange(Posted, false);
            // if SpotcashTransactions.FindSet() then begin
            //     SpotcashTransactions.CalcSums(Amount);
            //     Uncleared += SpotcashTransactions.Amount;
            // end;
            Vendor.CalcFields("Net Change", "Uncleared Funds");
            if Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Loan Account" then begin
                BookBalance := -1 * Vendor."Net Change";
                ActualBalance := BookBalance;
            end
            else begin
                BookBalance := Vendor."Net Change";
                ActualBalance := BookBalance;
                Uncleared := Vendor."Uncleared Funds";
                if ProductFactory.Get(Vendor."Product Code") then ActualBalance -= ProductFactory."Minimum Balance";
                if ProductFactory."Product Posting Type" = ProductFactory."Product Posting Type"::"Share Capital Account" then ActualBalance += ProductFactory."Minimum Balance";
                if ActualBalance < 0 then ActualBalance := 0;
            end;
        end;
    end;

    procedure PostAmountHolding(DocumentNo: Code[20])
    var
        UnclearedEffect: array[3] of Record "Uncleared Funds";
        EntryNo: Integer;
        Lien: Record Lien;
    begin
        Lien.Get(DocumentNo);
        Lien.CalcFields("Member Name");
        EntryNo := 1;
        UnclearedEffect[1].Reset;
        if UnclearedEffect[1].FindLast() then
            EntryNo := UnclearedEffect[1]."Entry No" + 1;

        UnclearedEffect[2].Init();
        UnclearedEffect[2]."Entry No" := EntryNo;
        UnclearedEffect[2]."Document No" := DocumentNo;
        UnclearedEffect[2]."Member Name" := Lien."Member Name";
        if Lien."Transaction Type" = Lien."Transaction Type"::Unholding then
            UnclearedEffect[2].Amount := -1 * Lien.Amount
        else
            UnclearedEffect[2].Amount := Lien.Amount;
        UnclearedEffect[2]."Member No" := Lien."Member No.";
        UnclearedEffect[2]."Account No" := Lien."Account No";
        UnclearedEffect[2]."Created By" := UserId;
        UnclearedEffect[2]."Created On" := CurrentDateTime;
        UnclearedEffect[2].Remarks := Lien.Narration;

        UnclearedEffect[3].Reset();
        UnclearedEffect[3].SetRange("Document No", DocumentNo);
        UnclearedEffect[3].SetRange(Amount, UnclearedEffect[2].Amount);
        UnclearedEffect[3].SetRange("Member No", Lien."Member No.");
        UnclearedEffect[3].SetRange("Account No", Lien."Account No");
        if not UnclearedEffect[3].FindFirst then
            UnclearedEffect[2].Insert();

        Lien.Processed := true;
        Lien."Processed By" := UserId;
        Lien."Processed On" := CurrentDateTime;
        Lien.Modify();
    end;

    procedure ValidateIdentificationNo(IdentificationType: Enum "Identity Type"; IdentificationNo: Code[20])
    var
        Regex: Codeunit "Regex";
        Member: Record Members;
        IsValidPassport: Boolean;
        FirstChar: Text;
        DigitsPart: Text;
        i: Integer;
    begin
        if IdentificationType = IdentificationType::"National ID" then begin
            if StrLen(IdentificationNo) > 9 then
                Error('Kenyan National ID must be at most 9 digits long.');
            for i := 1 to StrLen(IdentificationNo) do begin
                if not (IdentificationNo[i] in ['0' .. '9']) then
                    Error('Kenyan National ID must only contain digits.');
            end;
        end;
        if IdentificationType = IdentificationType::Passport then begin
            if not (Regex.IsMatch(IdentificationNo, '^[A-Z]{2}[0-9]{7}$')) then
                Error('Kindly provide a valid Passport No.');
        end;
    end;

    procedure NationalIDValidation(NationalId: Text[100])
    var
        RegEx: Codeunit Regex;
        Pattern: Text;
        MatchRec: Record Matches;
    begin
        if NationalId <> '' then begin
            Pattern := '^\d{6,}';
            RegEx.Match(NationalId, Pattern, MatchRec);
            if not MatchRec.Success then Error('Kindly provide a valid Identification No.');
        end;
    end;
    // procedure KRAPinValidation(Pin: Text[100])
    // var
    //     RegEx: Codeunit Regex;
    //     Pattern: Text;
    //     MatchRec: Record Matches;
    // begin
    //     if Pin <> '' then begin
    //         Pattern:='([a-zA-Z]{1})([0-9]{9})([a-zA-Z]{1,})';
    //         RegEx.Match(Pin, Pattern, MatchRec);
    //         if not MatchRec.Success then Error('Kindly provide a valid KRA Pin');
    //         if MatchRec.Length <> 11 then Error('KRA Pin must have 11 Digits');
    //       end;
    // end;
    procedure ValidateKRAPinFormat(KRAPin: Code[20])
    var
        FirstChar: Char;
        LastChar: Char;
        MiddlePart: Text;
        i: Integer;
    begin
        if StrLen(KRAPin) <> 11 then Error('Invalid KRA PIN format. It must be 11 characters: 1 letter, 9 digits, 1 letter (e.g., A123456789B).');
        FirstChar := CopyStr(KRAPin, 1, 1) [1];
        MiddlePart := CopyStr(KRAPin, 2, 9);
        LastChar := CopyStr(KRAPin, 11, 1) [1];
        if not (FirstChar in ['A' .. 'Z']) then Error('Invalid KRA PIN: The first character must be an uppercase letter.');
        if not (LastChar in ['A' .. 'Z']) then Error('Invalid KRA PIN: The last character must be an uppercase letter.');
        for i := 1 to StrLen(MiddlePart) do begin
            if not (MiddlePart[i] in ['0' .. '9']) then Error('Invalid KRA PIN: Characters 2 to 10 must be digits.');
        end;
    end;
    // Existing KRAPinValidation procedure (if any)
    procedure KRAPinValidation(KRAPin: Code[20])
    begin
        // You can still include extra validations here if needed
        ValidateKRAPinFormat(KRAPin);
    end;

    procedure PhoneNumberValidation(PhoneNo: Text[100]; DomicileCode: Code[20]): Text
    var
        RegEx: Codeunit Regex;
        Pattern: Text;
        MatchRec: Record Matches;
        CounryCodeLength: Integer;
        GenSetup: Record "General Ledger Setup";
        CountryRegion: Record "Country/Region";
        StrimedPhoneNo: Text;
        ConcancatedPhoneNo: Text;
        CountryCode: Code[20];
    begin
        GenSetup.Get;
        CountryCode := DomicileCode;
        if CountryCode = '' then begin
            GenSetup.TestField("Country Code");
            CountryCode := GenSetup."Country Code";
        end;
        if PhoneNo <> '' then begin
            If CountryRegion.Get(CountryCode) then begin
                CountryRegion.TestField("Country Code");
                // if CopyStr(PhoneNo, 1, 1) = '0' then begin
                //     StrimedPhoneNo := DelStr(PhoneNo, 1, 1);
                //     ConcancatedPhoneNo := CountryRegion."Country Code" + StrimedPhoneNo;
                //     PhoneNo := ConcancatedPhoneNo;
                // end;
                CounryCodeLength := Text.StrLen(CountryRegion."Country Code");
                Pattern := StrSubstNo('([%1]{%2})', CountryRegion."Country Code", CounryCodeLength);
                RegEx.Match(PhoneNo, Pattern, MatchRec);
                // if not MatchRec.Success then
                //     Error('Kindly provide a valid Phone Number');
                // if CountryRegion."Country Code" = '+254' then
                //     if Text.StrLen(PhoneNo) <> 13 then
                //         Error('Phone Number must have 12 Digits');
                exit(PhoneNo);
            end;
        end;
    end;

    procedure GetBcrqSetup(UserCode: Code[100]; var GlobalEditor: Boolean; var PartialEditor: Boolean; var CanRejoin: Boolean; var MPOAEditor: Boolean)
    var
        BCRQSetup: Record "BCRQ Setup";
    begin
        BCRQSetup.Get(UserCode);
        GlobalEditor := BCRQSetup."Global Editor";
        PartialEditor := BCRQSetup."Partial Member Update";
        CanRejoin := BCRQSetup."Can Rejoin Member";
        MPOAEditor := BCRQSetup."MPOA Update";
    end;

    internal procedure DrillDownPage(MemberNo: Code[20]; AsAtDate: Date)
    var
        VendorLedger: Page "Vendor Ledger Entries";
        VendorLedgerRec: Record "Vendor Ledger Entry";
        DateFilter: Text;
    begin
        if AsAtDate <> 0D then begin
            DateFilter := format(DMY2Date(01, 01, Date2DMY(AsAtDate, 3))) + '..' + format(AsAtDate);
            VendorLedgerRec.Reset();
            VendorLedgerRec.SetRange("Member No.", MemberNo);
            VendorLedgerRec.SetFilter("Posting Date", DateFilter);
            VendorLedgerRec.SetRange("Product Posting Type", VendorLedgerRec."Product Posting Type"::"Non Withdrawable Deposit");
            if VendorLedgerRec.FindSet() then begin
                Clear(VendorLedger);
                VendorLedger.SetTableView(VendorLedgerRec);
                VendorLedger.Run();
            end
            else
                Message('No Deposit Contribution');
        end
        else
            Message('No Deposit Contribution');
    end;

    internal procedure GetDepositsCurrYear(MemberNo: Code[20]; AsAtDate: Date; var Deposits: Decimal; var RMF: Decimal)
    var
        DetailedLedger: Record "Detailed Vendor Ledg. Entry";
        DateFilter: Text;
    begin
        Deposits := 0;
        RMF := 0;
        if AsAtDate <> 0D then begin
            DateFilter := format(DMY2Date(01, 01, Date2DMY(AsAtDate, 3))) + '..' + format(AsAtDate);
            DetailedLedger.Reset();
            DetailedLedger.SetRange("Member No.", MemberNo);
            DetailedLedger.SetRange("Product Posting Type", DetailedLedger."Product Posting Type"::"Non Withdrawable Deposit");
            DetailedLedger.SetFilter("Posting Date", DateFilter);
            if DetailedLedger.FindSet() then begin
                DetailedLedger.CalcSums(Amount);
                Deposits := -1 * DetailedLedger.Amount;
                // end;
                // DetailedLedger.Reset();
                // DetailedLedger.SetRange("Member No.", MemberNo);
                // // DetailedLedger.SetRange("Product Posting Type", DetailedLedger."Product Posting Type"::Insurance);
                // DetailedLedger.SetFilter("Posting Date", DateFilter);
                // if DetailedLedger.FindSet() then begin
                //     DetailedLedger.CalcSums(Amount);
                //     RMF := -1 * DetailedLedger.Amount;
            end;
        end;
    end;

    procedure MaskCardNo(CardNo: Code[20]) MaskedCardNo: Code[50]
    var
        MiddlePart, StartPart, LastPart : Code[20];
        UserSetup: Record "User Setup";
    begin
        if StrLen(CardNo) > 4 then begin
            StartPart := CopyStr(CardNo, 1, 4);
            LastPart := CopyStr(CardNo, StrLen(CardNo) - 3, 4);
            MaskedCardNo := StartPart + '-XXXX-XXXX-XXXX-' + LastPart;
        end
        else
            MaskedCardNo := '';
        if UserSetup.Get(UserId) then begin
            if UserSetup."View Protected Account" then
                MaskedCardNo := CardNo;
        end;
        exit(MaskedCardNo);
    end;

    internal procedure UpdateMemberAccounts(ProductCode: Code[20])
    var
        ProductSetup: Record "Sacco Products";
        Loans: Record Loans;
        Window: Dialog;
    begin
        ProductSetup.Get(ProductCode);
        Vendor[1].Reset();
        Vendor[1].SetRange("Product Code", ProductCode);
        if Vendor[1].FindSet() then begin
            Window.Open('Updating \#1##');
            repeat
                Window.Update(1, Vendor[1]."No.");
                Vendor[1].Name := ProductSetup.Description;
                Vendor[1]."Product Posting Type" := ProductSetup."Product Posting Type";
                Vendor[1]."Business Account" := ProductSetup."Business Account";
                Vendor[1]."Cash Deposit Allowed" := ProductSetup."Cash Deposit Allowed";
                Vendor[1]."Cash Withdraw Allowed" := ProductSetup."Cash Withdraw Allowed";
                Vendor[1]."Cash Transfer Allowed" := ProductSetup."Cash Transfer Allowed";
                Vendor[1]."ATM Use Allowed" := ProductSetup."ATM Use Allowed";
                Vendor[1]."Loan Recovery Priority" := ProductSetup."Loan Recovery Priority";
                Vendor[1]."Print Sequence" := ProductSetup."Print Sequence";
                Vendor[1]."Salary Based" := ProductSetup."Salary Based";
                Vendor[1]."Divinded Based" := ProductSetup."Dividend Based";
                Vendor[1]."Mobile Loan" := ProductSetup."Mobile Loan";
                Vendor[1].Modify();
                if Vendor[1]."Product Posting Type" = Vendor[1]."Product Posting Type"::"Loan Account" then begin
                    Loans.Reset();
                    Loans.SetRange("Loan Account", Vendor[1]."No.");
                    if Loans.FindSet then begin
                        repeat
                            Loans."Salary Based" := Vendor[1]."Salary Based";
                            Loans."Mobile Loan" := Vendor[1]."Mobile Loan";
                            Loans."Dividend Based" := Vendor[1]."Divinded Based";
                            Loans.Modify(true);
                        until Loans.Next = 0;
                    end;
                end;
            until Vendor[1].Next() = 0;
            Window.Close;
        end;
    end;

    procedure Update_Salary_Based()
    var
        ProductSetup: Record "Sacco Products";
        Loans: Record Loans;
        Window: Dialog;
    begin
        ProductSetup.Reset();
        ProductSetup.SetRange("Salary Based", true);
        if ProductSetup.FindSet then begin
            repeat
                Loans.Reset();
                Loans.SetRange("Product Code", ProductSetup.Code);
                if Loans.FindSet() then begin
                    Window.Open('Updating \#1##');
                    repeat
                        Window.Update(1, Loans."No.");
                        Loans."Salary Based" := ProductSetup."Salary Based";
                        Loans.Modify();
                    until Loans.Next() = 0;
                    Window.Close;
                end;
            until ProductSetup.Next = 0;
        end;
    end;

    procedure CreateAtmLien(DocumentNo: Code[20])
    var
        UnclearedEffect: Record "Uncleared Funds";
        EntryNo: Integer;
        ATMApplication: Record "ATM Application";
        JournalMgt: Codeunit "Journal Management";
        Charges: Decimal;
    begin
        ATMApplication.Get(DocumentNo);
        Charges := 0;
        Charges := JournalMgt.GetChargesAmount(ATMApplication."Transaction Code", 1);
        EntryNo := 1;
        UnclearedEffect.Reset;
        if UnclearedEffect.FindLast() then EntryNo := UnclearedEffect."Entry No" + 1;
        UnclearedEffect.Init();
        UnclearedEffect."Entry No" := EntryNo;
        UnclearedEffect."Document No" := DocumentNo;
        UnclearedEffect.Amount := Charges;
        UnclearedEffect.Validate("Member No", ATMApplication."Member No");
        UnclearedEffect."Account No" := ATMApplication."Account No.";
        UnclearedEffect."Created By" := UserId;
        UnclearedEffect."Created On" := CurrentDateTime;
        UnclearedEffect.Insert();
        ATMApplication."Uncleared Effect No." := EntryNo;
        ATMApplication.Modify(true);
    end;

    procedure ReverseAtmLien(DocumentNo: Code[20])
    var
        UnclearedEffect: Record "Uncleared Funds";
        EntryNo: Integer;
        ATMApplication: Record "ATM Application";
        JournalMgt: Codeunit "Journal Management";
        Charges: Decimal;
    begin
        ATMApplication.Get(DocumentNo);
        Charges := 0;
        Charges := JournalMgt.GetChargesAmount(ATMApplication."Transaction Code", 1);
        EntryNo := 1;
        UnclearedEffect.Reset;
        if UnclearedEffect.FindLast() then EntryNo := UnclearedEffect."Entry No" + 1;
        UnclearedEffect.Init();
        UnclearedEffect."Entry No" := EntryNo;
        UnclearedEffect."Document No" := DocumentNo;
        UnclearedEffect.Amount := -1 * Charges;
        UnclearedEffect.Validate("Member No", ATMApplication."Member No");
        UnclearedEffect."Account No" := ATMApplication."Account No.";
        UnclearedEffect."Created By" := UserId;
        UnclearedEffect."Created On" := CurrentDateTime;
        UnclearedEffect.Insert();
    end;

    internal procedure PostATMLinking(DocumentNo: Code[20])
    var
        ATMApplication: Record "ATM Application";
        ATMCards: Record "ATM Cards";
        JournalMgt: Codeunit "Journal Management";
        PostingAmount, AvailableBalance, Charges : Decimal;
        JournalBatch, JournalTemplate, Dim1, Dim2, Dim3, Dim4, Dim5, Dim6, Dim7, MemberNo, SourceCode, Dim8, ReasonCode, ExternalDocumentNo, AccountNo : Code[20];
        PostingDate: Date;
        LineNo: Integer;
        JournalManagement: Codeunit "Journal Management";
        LoansMgt: Codeunit "Loans Management";
        PostingDescription: Text[100];
        SaccoProduct: Record "Sacco Products";
        ChannelsIntegrations: Codeunit "Channels Integrations";
    begin
        ATMApplication.Get(DocumentNo);
        ATMApplication.Validate("Member No");
        ATMApplication.TestField("Card No.");
        Vendor[1].Get(ATMApplication."Account No.");
        Vendor[1].CalcFields(Balance, "Uncleared Funds");
        SaccoProduct.Get(Vendor[1]."Product Code");

        AvailableBalance := Vendor[1].Balance - Vendor[1]."Uncleared Funds" - SaccoProduct."Minimum Balance" - ChannelsIntegrations.GetPendingChannelsTransactions(Vendor[1]."Member No.");
        if AvailableBalance < 0 then
            AvailableBalance := 0;

        Charges := JournalMgt.GetChargesAmount(ATMApplication."Transaction Code", 1);

        if Charges > AvailableBalance then
            Error('The Account does not have sufficient funds');

        if not ATMCards.Get(ATMApplication."Card No.", ATMApplication."ATM Type") then begin
            ATMCards.Init();
            ATMCards."ATM Type" := ATMApplication."ATM Type";
            ATMCards."Card No." := ATMApplication."Card No.";
            ATMCards.Validate("ATM Type");
            ATMCards."Account No" := ATMApplication."Account No.";
            ATMCards."Assigned By" := UserId;
            ATMCards."Assigned On" := CurrentDateTime;
            ATMCards.Status := ATMCards.Status::Transacting;
            ATMCards."Assigned to Account No" := ATMApplication."Account No.";
            ATMCards."Assigned To Member No." := ATMApplication."Member No";
            ATMCards.Insert();
        end
        else begin
            ATMCards.Validate("ATM Type");
            ATMCards."Account No" := ATMApplication."Account No.";
            ATMCards."Assigned By" := UserId;
            ATMCards."Assigned On" := CurrentDateTime;
            ATMCards.Status := ATMCards.Status::Transacting;
            ATMCards."Assigned to Account No" := ATMApplication."Account No.";
            ATMCards."Assigned To Member No." := ATMApplication."Member No";
            ATMCards.Modify();
        end;
        Vendor[1].Reset();
        Vendor[1].SetRange("No.", ATMApplication."Account No.");
        if Vendor[1].FindFirst() then begin
            Vendor[1]."Card No" := ATMApplication."Card No.";
            Vendor[1].Modify();
        end;

        if ATMApplication."Application Type" = ATMApplication."Application Type"::New then
            ReverseAtmLien(ATMApplication."No.");

        JournalBatch := 'GENERAL';
        JournalTemplate := 'GENERAL';
        AccountNo := '';
        MemberNo := ATMApplication."Member No";
        PostingDate := WorkDate;
        LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
        AccountNo := LoansMgt.GetFOSAAccount(MemberNo);
        PostingDescription := 'ATM Activation';
        LineNo := JournalManagement.AddCharges(ATMApplication."Transaction Code", AccountNo, PostingAmount, LineNo, DocumentNo, MemberNo, SourceCode, ReasonCode, ExternalDocumentNo, JournalBatch, JournalTemplate, Dim1, Dim2, PostingDate, true);
        JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
        GLEntry.Reset();
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("Document Date", PostingDate);
        if GLEntry.FindFirst() then begin
            ATMApplication.Processed := true;
            ATMApplication."Processed At" := time;
            ATMApplication."Processed By" := UserId;
            ATMApplication."Processed On" := WorkDate;
            ATMApplication.Modify();
            OnAfterPostATMLinking(ATMApplication);
        end;
    end;

    internal procedure PostATMCollection(DocumentNo: Code[20])
    var
        ATMApplication: Record "ATM Application";
    begin
        ATMApplication.Get(DocumentNo);
        ATMApplication.TestField("ATM Collected By");
        ATMApplication.TestField("ATM Collected By ID No.");
        ATMApplication.Collected := true;
        ATMApplication.Modify();
    end;

    procedure UpdateATMCards()
    var
        ATMCards: Record "ATM Cards";
    begin
        ATMCards.Reset();
        ATMCards.Setfilter("Assigned To Member No.", '<>%1', '');
        if ATMCards.FindSet then begin
            Window.Open('Updating ATM Cards. \#1##\#2##\#3##\#4##');
            All := 0;
            Current := 0;
            All := ATMCards.Count;
            repeat
                Current += 1;
                Window.Update(1, StrSubstNo('No. %1', ATMCards."Card No."));
                Window.Update(2, StrSubstNo('Name: %1', ATMCards."Member Name"));
                Window.UPDATE(3, StrSubstNo('%1%', Round((Current / All) * 100, 1)));
                Window.UPDATE(4, FORMAT(Current) + ' of ' + FORMAT(All));
                Vendor[1].Reset();
                Vendor[1].SetRange("Member No.", ATMCards."Assigned To Member No.");
                Vendor[1].SetRange("Product Posting Type", Vendor[1]."Product Posting Type"::"Withdrawable Deposit");
                if Vendor[1].FindFirst() then begin
                    Vendor[1]."Card No" := ATMCards."Card No.";
                    Vendor[1].Modify();
                end;
                ATMCards."Assigned By" := UserId;
                ATMCards."Assigned On" := CurrentDateTime;
                ATMCards.Status := ATMCards.Status::Transacting;
                ATMCards.Modify(true);
            until ATMCards.Next = 0;
            Window.Close;
        end;
    end;

    procedure PopulateIPRSData(RecId: RecordId; IDNo: Code[20])
    var
        RecRef: RecordRef;
        MemberApplication: array[2] of Record "Member Application";
        Nominees: array[2] of Record "Member Nominee/Kin";
        Signatories: array[2] of Record "Signatories & Directors";
        Name: array[3] of Text;
        JLinesToken: JsonToken;
        ResultToken: JsonToken;
        JObject: JsonObject;
        NewJObject: JsonObject;
        PayLoad: Text;
        MpesaIntegrations: Codeunit "Integrations Mgmt";
        BigText: Text;
    begin
        RecRef := RecId.GetRecord;
        SaccoSetup.Get;
        SaccoSetup.TestField("Device Id");
        SaccoSetup.TestField("IPRS Url");
        SaccoSetup.TestField("IPRS Phone No.");
        PayLoad := '{' + '"phoneNumber":"' + SaccoSetup."IPRS Phone No." + '"' + ',' + '"idType":"GetDataByIdCard"' + ',' + '"idNumber":"' + IDNo + '"' + ',' + '"deviceId":"' + SaccoSetup."Device Id" + '"' + '}';
        JObject.ReadFrom(MpesaIntegrations.CallService('IPRS', SaccoSetup."IPRS Url", 2, PayLoad, '', ''));
        case RecRef.Number of
            Database::"Member Application":
                begin
                    RecRef.SetTable(MemberApplication[1]);
                    MemberApplication[2].Get(MemberApplication[1]."No.");
                    if JObject.Get('data', JLinesToken) then begin
                        NewJObject := JLinesToken.AsObject();
                        Clear(ResultToken);
                        ResultToken := MpesaIntegrations.GetJsonToken(NewJObject, 'First_Name');
                        MemberApplication[2]."First Name" := ResultToken.AsValue().AsText();
                        Clear(ResultToken);
                        ResultToken := MpesaIntegrations.GetJsonToken(NewJObject, 'Other_Name');
                        MemberApplication[2]."Middle Name" := ResultToken.AsValue().AsCode();
                        Clear(ResultToken);
                        ResultToken := MpesaIntegrations.GetJsonToken(NewJObject, 'Surname');
                        MemberApplication[2]."Last Name" := ResultToken.AsValue().AsCode();
                        Clear(ResultToken);
                        ResultToken := MpesaIntegrations.GetJsonToken(NewJObject, 'Date_of_Birth');
                        MemberApplication[2]."Date of Birth" := ParseDate(ResultToken);
                        Clear(ResultToken);
                        ResultToken := MpesaIntegrations.GetJsonToken(NewJObject, 'Gender');
                        if ResultToken.AsValue().AsCode() = 'M' then
                            MemberApplication[2].Gender := MemberApplication[2].Gender::Male
                        else
                            MemberApplication[2].Gender := MemberApplication[2].Gender::Female;
                        MemberApplication[2].Validate("Full Name");
                        MemberApplication[2]."IPRS Uneditability" := true;
                        MemberApplication[2].Modify();
                    end;
                end;
            Database::"Member Nominee/Kin":
                begin
                    RecRef.SetTable(Nominees[1]);
                    Nominees[2].Get(Nominees[1]."Source Code", Nominees[1]."Relative Code", Nominees[1]."Identification No.", Nominees[1]."Document Type");
                    if JObject.Get('data', JLinesToken) then begin
                        NewJObject := JLinesToken.AsObject();
                        Clear(ResultToken);
                        ResultToken := MpesaIntegrations.GetJsonToken(NewJObject, 'First_Name');
                        Name[1] := ResultToken.AsValue().AsText();
                        Clear(ResultToken);
                        ResultToken := MpesaIntegrations.GetJsonToken(NewJObject, 'Other_Name');
                        Name[2] := ResultToken.AsValue().AsCode();
                        Clear(ResultToken);
                        ResultToken := MpesaIntegrations.GetJsonToken(NewJObject, 'Surname');
                        Name[3] := ResultToken.AsValue().AsCode();
                        Nominees[2].Name := StrSubstNo('%1 %2 %3', Name[1], Name[2], Name[3]);
                        Clear(ResultToken);
                        ResultToken := MpesaIntegrations.GetJsonToken(NewJObject, 'Date_of_Birth');
                        Nominees[2]."Date of Birth" := ParseDate(ResultToken);
                        Nominees[2]."IPRS Uneditability" := true;
                        Nominees[2].Modify;
                    end;
                end;
            Database::"Signatories & Directors":
                begin
                    RecRef.SetTable(Signatories[1]);
                    Signatories[2].Get(Signatories[1]."Source Code", Signatories[1]."Entry No.", Signatories[1].Type);
                    if JObject.Get('data', JLinesToken) then begin
                        NewJObject := JLinesToken.AsObject();
                        Clear(ResultToken);
                        ResultToken := MpesaIntegrations.GetJsonToken(NewJObject, 'First_Name');
                        Name[1] := ResultToken.AsValue().AsText();
                        Clear(ResultToken);
                        ResultToken := MpesaIntegrations.GetJsonToken(NewJObject, 'Other_Name');
                        Name[2] := ResultToken.AsValue().AsCode();
                        Clear(ResultToken);
                        ResultToken := MpesaIntegrations.GetJsonToken(NewJObject, 'Surname');
                        Name[3] := ResultToken.AsValue().AsCode();
                        Signatories[2].Name := StrSubstNo('%1 %2 %3', Name[1], Name[2], Name[3]);
                        Clear(ResultToken);
                        ResultToken := MpesaIntegrations.GetJsonToken(NewJObject, 'Date_of_Birth');
                        Signatories[2]."Date of Birth" := ParseDate(ResultToken);
                        Signatories[2]."IPRS Uneditability" := true;
                        Signatories[2].Modify;
                    end;
                end;
        end;
    end;

    local procedure ParseDate(Token: JsonToken): Date
    var
        DateParts: List of [Text];
        Year: Integer;
        Month: Integer;
        Day: Integer;
    begin
        // Error handling omitted from example
        DateParts := Token.AsValue().AsText().Split('/');
        Evaluate(Day, DateParts.Get(2));
        Evaluate(Month, DateParts.Get(1));
        Evaluate(Year, CopyStr(DateParts.Get(3), 1, 4));
        exit(DMY2Date(Day, Month, Year));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Member Management", 'OnAfterCreateMember', '', true, true)]
    local procedure CreateAdvice(Member: Record Members)
    var
        CheckOffAdvice: Record "Checkoff Advice";
        EntryNo: Integer;
        SubScriptions: Record "Member Subscriptions";
    begin
        CheckOffAdvice.Reset();
        if CheckOffAdvice.FindLast() then
            EntryNo := CheckOffAdvice."Entry No" + 1
        else
            EntryNo := 1;
        SubScriptions.Reset();
        SubScriptions.SetRange("Source Code", Member."No.");
        SubScriptions.SetFilter(Amount, '>0');
        if SubScriptions.FindSet() then begin
            repeat
                CheckOffAdvice.Init();
                CheckOffAdvice."Entry No" := EntryNo;
                EntryNo += 1;
                CheckOffAdvice."Member No" := Member."No.";
                CheckOffAdvice."Amount Off" := 0;
                CheckOffAdvice."Amount On" := SubScriptions.Amount;
                CheckOffAdvice."Current Balance" := 0;
                CheckOffAdvice."Product Code" := SubScriptions."Account Type";
                CheckOffAdvice."Product Name" := SubScriptions."Account Name";
                CheckOffAdvice."Advice Type" := CheckOffAdvice."Advice Type"::"New Member";
                CheckOffAdvice."Advice Date" := SubScriptions."Start Date";
                CheckOffAdvice."Posting Date" := WorkDate;
                CheckOffAdvice.Insert();
            until SubScriptions.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FOSA Management", 'OnAfterPostTellerTransaction', '', true, true)]
    local procedure OnAfterPostTellerTransaction(TellerTransaction: Record "Teller Transactions")
    var
        CheckOffAdvice: Record "Checkoff Advice";
        EntryNo: Integer;
        ProductFactory: Record "Sacco Products";
        SubScriptions: Record "Member Subscriptions";
        StartDate, EndDate : Date;
    begin
        EndDate := TellerTransaction."Posting Date";
        StartDate := DMY2Date(Date2DMY(EndDate, 1), Date2DMY(EndDate, 2), Date2DMY(EndDate, 3));
        CheckOffAdvice.Reset();
        if CheckOffAdvice.FindLast() then
            EntryNo := CheckOffAdvice."Entry No" + 1
        else
            EntryNo := 1;
        if Vendor[1].Get(TellerTransaction."Account No") then begin
            if Vendor[1]."Product Posting Type" = Vendor[1]."Product Posting Type"::"Non Withdrawable Deposit" then begin
                Vendor[1].CalcFields(Balance);
                CheckOffAdvice.Reset();
                CheckOffAdvice.SetRange("Member No", Vendor[1]."Member No.");
                CheckOffAdvice.SetRange("Product Code", Vendor[1]."Product Code");
                CheckOffAdvice.SetRange("Advice Date", StartDate, EndDate);
                if CheckOffAdvice.findset then CheckOffAdvice.Deleteall;
                CheckOffAdvice.Init();
                CheckOffAdvice."Entry No" := EntryNo;
                EntryNo += 1;
                CheckOffAdvice."Member No" := Vendor[1]."Member No.";
                CheckOffAdvice."Amount Off" := 0;
                CheckOffAdvice."Amount On" := SubScriptions.Amount;
                CheckOffAdvice."Current Balance" := 0;
                CheckOffAdvice."Product Code" := Vendor[1]."Product Code";
                CheckOffAdvice."Product Name" := Vendor[1].Name;
                CheckOffAdvice."Advice Type" := CheckOffAdvice."Advice Type"::Adjustment;
                CheckOffAdvice."Advice Date" := EndDate;
                CheckOffAdvice."Posting Date" := WorkDate;
                CheckOffAdvice."Current Balance" := Vendor[1].Balance;
                CheckOffAdvice.Insert();
            end;
        end;
    end;

    procedure SendBulkSMS(DocumentNo: code[20])
    var
        BulkSMSLines: Record "Bulk SMS Lines";
        BulkSMSHeader: Record "Bulk SMS Header";
        Window: dialog;
        SMS: Codeunit "Notifications Management";
        SMSSource: Code[20];
    begin
        SMSSource := 'BULKSMS';
        BulkSMSHeader.Get(DocumentNo);
        BulkSMSLines.SetRange(Sent, false);
        BulkSMSLines.SetRange("No.", DocumentNo);
        if BulkSMSLines.FindSet() then begin
            Window.Open('Sending \#1##');
            repeat
                Window.Update(1, BulkSMSLines."Full Name");
                SMS.SendSms(BulkSMSLines."Phone No", BulkSMSHeader.Message, SMSSource);
                BulkSMSLines.Sent := true;
                BulkSMSLines.Modify();
                Commit();
            until BulkSMSLines.Next() = 0;
            Window.Close;
        end
        else
            Error('You need to Populate Members details');
        BulkSMSHeader.Sent := true;
        BulkSMSHeader.Modify();
    end;

    procedure PopulateBulkSMSMemberList(DocumentNo: Code[20])
    var
        BulkSMSLines: Record "Bulk SMS Lines";
        BulkSMSHeader: Record "Bulk SMS Header";
        Window: dialog;
        SMS: Codeunit "Notifications Management";
        LineNo: Integer;
    begin
        BulkSMSHeader.Get(DocumentNo);
        BulkSMSLines.Reset();
        BulkSMSLines.SetRange("No.", DocumentNo);
        if BulkSMSLines.FindSet() then BulkSMSLines.DeleteAll();
        Member.Reset();
        Member.SetRange(Status, Member.Status::Active);
        if Member.FindSet() then begin
            Window.Open('Populating details of \#1##');
            repeat
                Window.Update(1, Member."Full Name");
                LineNo := LineNo + 1;
                BulkSMSLines.Init;
                BulkSMSLines."No." := DocumentNo;
                BulkSMSLines."Line No" := LineNo;
                BulkSMSLines."Full Name" := Member."Full Name";
                BulkSMSLines."Phone No" := Member."Mobile Phone No.";
                BulkSMSLines.Insert(true);
            until Member.Next() = 0;
            Window.Close;
        end;
    end;

    procedure OpenAccounts(DocumentNo: Code[20]) AccNo: Code[20]
    var
        AccountOpening: Record "Account Opening";
        AccountNo, prefix, MemberNo : code[20];
        ProductSetup: Record "Sacco Products";
        NoSeries: Codeunit NoSeriesManagement;
    begin
        AccountOpening.Get(DocumentNo);
        MemberNo := AccountOpening."Member No.";
        AccountOpening.calcfields("Passport Size Photo", "Signature Card");
        if Member.Get(MemberNo) then begin
            Member."Passport Size Photo" := AccountOpening."Passport Size Photo";
            Member.Signature := AccountOpening."Signature Card";
            Member.Modify;
        end;
        if ProductSetup.Get(AccountOpening."Product Type") then begin
            ProductSetup.TestField(Prefix);
            AccountNo := '';
            Vendor[2].Reset;
            Vendor[2].SetRange("Product Code", ProductSetup.Code);
            Vendor[2].SetRange("Member No.", AccountOpening."Member No.");
            Vendor[2].SetRange("Product Posting Type", ProductSetup."Product Posting Type");
            Vendor[2].SetAscending("No.", false);
            if Vendor[2].FindFirst then
                AccountNo := IncStr(Vendor[2]."No.")
            else
                AccountNo := ProductSetup.Prefix + MemberNo + ProductSetup.Suffix;

            if not Vendor[1].Get(AccountNo) then begin
                Vendor[1].Init();
                Vendor[1]."No." := AccountNo;
                Vendor[1]."Vendor Posting Group" := ProductSetup."Posting Group";
                Vendor[1]."Product Posting Type" := ProductSetup."Product Posting Type";
                Vendor[1]."Account Type" := Vendor[1]."Account Type"::Sacco;
                Vendor[1]."Member No." := MemberNo;
                Vendor[1]."Business Account" := AccountOpening."Business Account";
                Vendor[1]."Cash Deposit Allowed" := ProductSetup."Cash Deposit Allowed";
                Vendor[1]."Cash Withdraw Allowed" := ProductSetup."Cash Withdraw Allowed";
                Vendor[1]."Cash Transfer Allowed" := ProductSetup."Cash Transfer Allowed";
                Vendor[1]."ATM Use Allowed" := ProductSetup."ATM Use Allowed";
                Vendor[1]."Loan Recovery Priority" := ProductSetup."Loan Recovery Priority";
                Vendor[1]."Print Sequence" := ProductSetup."Print Sequence";
                Vendor[1]."Salary Based" := ProductSetup."Salary Based";
                Vendor[1]."Divinded Based" := ProductSetup."Dividend Based";
                Vendor[1]."Mobile Loan" := ProductSetup."Mobile Loan";
                Vendor[1]."Business Location" := AccountOpening."Business Location";
                Vendor[1]."Paybill Business Account No." := AccountOpening."Paybill Business Till No.";
                Vendor[1]."Phone No." := AccountOpening."Business Phone No.";
                Vendor[1]."Date Of Birth" := AccountOpening."Date of Birth";
                if ((AccountOpening."Product Posting Type" = AccountOpening."Product Posting Type"::"Junior Account") or (AccountOpening."Business Account")) then begin
                    Vendor[1]."Member Name" := UpperCase(AccountOpening."Full Name");
                    Vendor[1].Name := StrSubstNo('%1 : %2', UpperCase(ProductSetup.Description), UpperCase(AccountOpening."Full Name"));
                end
                else begin
                    Vendor[1]."Member Name" := UpperCase(Member.FullName);
                    Vendor[1].Name := UpperCase(ProductSetup.Description);
                end;

                Vendor[1].Status := Vendor[1].Status::Active;
                Vendor[1]."Product Code" := ProductSetup.Code;
                Vendor[1].Insert();
            end;
        end;
        AccountOpening.Processed := true;
        AccountOpening.Modify(true);
        exit(AccountNo);
    end;

    procedure ViewProtectedAccounts(UserCode: code[100]) CanView: Boolean
    var
        UserSetup: Record "User Setup";
    begin
        UserSetup.Get(UserCode);
        exit(UserSetup."View Protected Account");
    end;

    procedure ActivateMember(DocumentNo: code[20])
    var
        MemberActivation: Record "Member Activations";
        LineNo: Integer;
        JournalManagement: Codeunit "Journal Management";
        PostingDate: Date;
        PostingDescription: Text[100];
        PostingAmount: Decimal;
        LoansMgt: Codeunit "Loans Management";
        JournalTemplate, JournalBatch, Dim1, Dim2, ExternalDocumentNo, ReasonCode, SourceCode, MemberNo, AccountNo : code[20];
    begin
        MemberActivation.Get(DocumentNo);
        Member.Get(MemberActivation."Member No.");
        Member.Status := Member.Status::Active;
        Member.Modify(true);
        Vendor[1].Reset();
        Vendor[1].SetRange("Member No.", Member."No.");
        if Vendor[1].FindSet() then begin
            repeat
                Vendor[1].Blocked := Vendor[1].Blocked::" ";
                Vendor[1].Status := Vendor[1].Status::Active;
                Vendor[1].Modify(true);
            until Vendor[1].Next() = 0;
        end;
        JournalBatch := 'MACT';
        JournalTemplate := 'GENERAL';
        AccountNo := '';
        MemberNo := MemberActivation."Member No.";
        PostingDate := MemberActivation."Posting Date";
        ExternalDocumentNo := MemberActivation."Payment Refrence";
        SourceCode := 'MXT';
        ReasonCode := 'MXT';
        LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
        AccountNo := LoansMgt.GetFOSAAccount(MemberNo);
        if MemberActivation."Pay From Account Type" = MemberActivation."Pay From Account Type"::"Cash Book" then begin
            PostingDescription := 'Activation Fee Paid';
            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
            AccountNo := '';
            AccountNo := MemberActivation."Pay From Account";
            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"Bank Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
        end;
        PostingAmount := 9999999;
        LineNo := JournalManagement.AddCharges(MemberActivation."Reactivation Fee", LoansMgt.GetFOSAAccount(MemberNo), PostingAmount, LineNo, DocumentNo, MemberNo, SourceCode, ReasonCode, ExternalDocumentNo, JournalBatch, JournalTemplate, Dim1, Dim2, PostingDate, False);
        JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
        // GLEntry.Reset();
        // GLEntry.SetRange("Document No.", DocumentNo);
        // GLEntry.SetRange("Document Date", PostingDate);
        // if GLEntry.FindFirst() then begin
        MemberActivation.Posted := true;
        MemberActivation."Posted By" := UserId;
        MemberActivation."Posted On" := CurrentDateTime;
        MemberActivation.Modify();
        //end;
    end;

    procedure GetMemberAccount(MemberNo: Code[20]; ProductPostingType: Enum "Product Posting Type") MemberAccount: Code[20]
    var
        SaccoProducts: Record "Sacco Products";
    begin
        SaccoProducts.Reset();
        SaccoProducts.SetRange("Product Posting Type", ProductPostingType);
        SaccoProducts.SetRange("Business Account", false);
        if SaccoProducts.FindFirst() then begin
            Vendor[1].Reset();
            Vendor[1].SetRange("Member No.", MemberNo);
            Vendor[1].SetRange("Product Posting Type", ProductPostingType);
            Vendor[1].SetRange("Business Account", false);
            Vendor[1].SetRange(Blocked, Vendor[1].Blocked::" ");
            if Vendor[1].FindFirst() then
                MemberAccount := Vendor[1]."No."
            else begin
                MemberAccount := CreateMemberAccount(MemberNo, SaccoProducts.Code);
            end;
        end;
        exit(MemberAccount);
    end;

    procedure GetMemberAccountByProductCode(MemberNo: Code[20]; ProductCode: Code[20]) MemberAccount: Code[20]
    begin
        Vendor[1].Reset();
        Vendor[1].SetRange("Member No.", MemberNo);
        Vendor[1].SetRange("Product Code", ProductCode);
        Vendor[1].SetRange(Blocked, Vendor[1].Blocked::" ");
        if Vendor[1].FindFirst() then
            MemberAccount := Vendor[1]."No."
        else
            MemberAccount := CreateMemberAccount(MemberNo, ProductCode);
        exit(MemberAccount);
    end;

    local procedure CreateMemberAccount(MemberNo: Code[20]; ProductCode: Code[20]): Code[20]
    var
        AccountNo: Code[20];
    begin
        Member.Get(MemberNo);
        ProductSetup.Get(ProductCode);
        ProductSetup.TestField(Prefix);
        ProductSetup.TestField("Posting Group");
        AccountNo := '';
        AccountNo := ProductSetup.Prefix + MemberNo + ProductSetup.Suffix;
        if not Vendor[1].Get(AccountNo) then begin
            Vendor[1].Init();
            Vendor[1]."No." := AccountNo;
            Vendor[1].Name := UpperCase(ProductSetup.Description);
            Vendor[1]."Vendor Posting Group" := ProductSetup."Posting Group";
            Vendor[1]."Member No." := MemberNo;
            Vendor[1]."Member Name" := UpperCase(Member.FullName);
            Vendor[1]."Account Type" := Vendor[1]."Account Type"::Sacco;
            Vendor[1]."Product Code" := ProductSetup.Code;
            Vendor[1]."Product Posting Type" := ProductSetup."Product Posting Type";
            Vendor[1]."Business Account" := ProductSetup."Business Account";
            Vendor[1]."Cash Deposit Allowed" := ProductSetup."Cash Deposit Allowed";
            Vendor[1]."Cash Withdraw Allowed" := ProductSetup."Cash Withdraw Allowed";
            Vendor[1]."Cash Transfer Allowed" := ProductSetup."Cash Transfer Allowed";
            Vendor[1]."Cheque Book Allowed" := ProductSetup."Cheque Book Allowed";
            Vendor[1]."ATM Use Allowed" := ProductSetup."ATM Use Allowed";
            Vendor[1]."Loan Recovery Priority" := ProductSetup."Loan Recovery Priority";
            Vendor[1]."Print Sequence" := ProductSetup."Print Sequence";
            Vendor[1]."Salary Based" := ProductSetup."Salary Based";
            Vendor[1]."Divinded Based" := ProductSetup."Dividend Based";
            Vendor[1]."Mobile Loan" := ProductSetup."Mobile Loan";
            Vendor[1].Status := Vendor[1].Status::Active;
            Vendor[1].Insert(true);
        end;
        exit(AccountNo);
    end;

    procedure GetShareCapitalBal(MemberNo: Code[20]): Decimal
    var
        Vendor: Record Vendor;
    begin
        Vendor.Reset();
        Vendor.SetRange("Member No.", MemberNo);
        Vendor.SetRange("Product Posting Type", Vendor."Product Posting Type"::"Share Capital Account");
        if Vendor.FindFirst() then begin
            Vendor.CalcFields(Balance);
            exit(Vendor.Balance);
        end;
    end;

    procedure GetOutstandingGuarantee(LoanNo: Code[20]; MemberNo: Code[20]) OutstandingGuarantee: Decimal
    var
        Loans: Record Loans;
        LoanGuarantee: Record "Loan Guarantees";
        ApprovedAmount, LoanBalance, TotalGuarantee, Ratio : Decimal;
    begin
        if Loans.Get(LoanNo) then begin
            Loans.CalcFields("Loan Balance");
            if Loans."Loan Balance" <= 0 then
                OutstandingGuarantee := 0
            else begin
                Loans.CalcFields("Loan Balance", "Total Guarantees");
                LoanBalance := Loans."Loan Balance";
                ApprovedAmount := Loans."Approved Amount";
                TotalGuarantee := Loans."Total Guarantees";
                LoanGuarantee.Reset();
                LoanGuarantee.SetRange("Loan No", LoanNo);
                LoanGuarantee.SetRange("Member No.", MemberNo);
                if LoanGuarantee.FindFirst() then begin
                    if LoanGuarantee.Substituted then
                        Ratio := 0
                    else begin
                        if ApprovedAmount <> 0 then Ratio := LoanGuarantee."Guaranteed Amount" / ApprovedAmount;
                    end;
                end;
                OutstandingGuarantee := LoanBalance * Ratio;
                if OutstandingGuarantee > TotalGuarantee then OutstandingGuarantee := TotalGuarantee;
            end;
        end
        else
            OutstandingGuarantee := 0;
        exit(OutstandingGuarantee);
    end;

    procedure GetOutstandingCollateralGuarantee(LoanNo: Code[20]; SecurityCode: Code[20]) OutstandingGuarantee: Decimal
    var
        Loans: Record Loans;
        LoanSecurities: Record "Loan Securities";
        ApprovedAmount, LoanBalance, TotalGuarantee, Ratio : Decimal;
    begin
        if Loans.Get(LoanNo) then begin
            Loans.CalcFields("Loan Balance");
            if Loans."Loan Balance" <= 0 then
                OutstandingGuarantee := 0
            else begin
                Loans.CalcFields("Loan Balance", "Total Guarantees");
                LoanBalance := Loans."Loan Balance";
                ApprovedAmount := Loans."Approved Amount";
                TotalGuarantee := Loans."Total Guarantees";

                LoanSecurities.Reset();
                LoanSecurities.SetRange("Loan No", LoanNo);
                LoanSecurities.SetRange("Security Code", SecurityCode);
                if LoanSecurities.FindFirst() then begin
                    if LoanSecurities.Substituted then
                        Ratio := 0
                    else begin
                        if ApprovedAmount <> 0 then
                            Ratio := LoanSecurities.Guarantee / ApprovedAmount;
                    end;
                end;
                OutstandingGuarantee := LoanBalance * Ratio;
                if OutstandingGuarantee > TotalGuarantee then
                    OutstandingGuarantee := TotalGuarantee;
            end;
        end
        else
            OutstandingGuarantee := 0;
        exit(OutstandingGuarantee);
    end;

    procedure PopulateMemberAssetsLiabilities(DocumentNo: Code[20])
    var
        MemberExitHeader: Record "Member Withdrawal";
        MemberExitLines: Record "Member Withdrawal Lines";
        DateFilter: Text[100];
        Window: Dialog;
        Loans: Record Loans;
        EntryNo: Integer;
        LoanGuarantors: Record "Loan Guarantees";
        LoansMgt: Codeunit "Loans Management";
        ok: Boolean;
    begin
        Window.Open('Copying \Assets #1## \Libilities #2##');
        MemberExitHeader.Get(DocumentNo);
        Member.Get(MemberExitHeader."Member No");
        DateFilter := '..' + Format(MemberExitHeader.Date);
        EntryNo := 1;
        MemberExitLines.Reset();
        MemberExitLines.SetRange("No.", DocumentNo);
        if MemberExitLines.FindSet() then MemberExitLines.DeleteAll();
        Vendor[1].Reset();
        Vendor[1].SetRange("Member No.", Member."No.");
        Vendor[1].SetRange("Account Type", Vendor[1]."Account Type"::Sacco);
        Vendor[1].SetFilter("Product Posting Type", '<>%1&<>%2', Vendor[1]."Product Posting Type"::"Withdrawable Deposit", Vendor[1]."Product Posting Type"::"Benevolent Account");
        if Vendor[1].FindSet() then begin
            repeat
                Window.Update(1, Vendor[1].Name);
                Vendor[1].CalcFields(Balance);
                if Vendor[1].Balance <> 0 then begin
                    Window.Update(1, Vendor[1].Name);
                    MemberExitLines.Init();
                    MemberExitLines."No." := DocumentNo;
                    MemberExitLines."Entry Type" := MemberExitLines."Entry Type"::Asset;
                    MemberExitLines."Entry No" := EntryNo;
                    EntryNo += 1;
                    MemberExitLines."Account No" := Vendor[1]."No.";
                    MemberExitLines."Account Name" := Vendor[1].Name;
                    MemberExitLines.Balance := Vendor[1].Balance;
                    MemberExitLines."Amount (Base)" := Vendor[1].Balance;
                    if Vendor[1]."Product Posting Type" = Vendor[1]."Product Posting Type"::"Share Capital Account" then MemberExitLines."Share Capital" := true;
                    Ok := MemberExitLines.Insert();
                end;
            until Vendor[1].Next() = 0;
        end;
        if MemberExitHeader."Withdrawal Type" <> MemberExitHeader."Withdrawal Type"::Desceased then begin
            Loans.Reset();
            Loans.SetFilter("Loan Balance", '<>0');
            Loans.SetRange("Member No.", MemberExitHeader."Member No");
            Loans.SetFilter("Date Filter", DateFilter);
            if Loans.FindSet() then begin
                repeat
                    Window.Update(2, Loans."Member Name");
                    Loans.CalcFields("Loan Balance");
                    MemberExitLines.Init();
                    MemberExitLines."No." := DocumentNo;
                    MemberExitLines."Entry Type" := MemberExitLines."Entry Type"::Liability;
                    MemberExitLines."Entry No" := EntryNo;
                    EntryNo += 1;
                    MemberExitLines."Account No" := Loans."No.";
                    MemberExitLines."Account Name" := Loans."Product Code" + ' ' + Loans."Product Description";
                    MemberExitLines.Balance := Loans."Loan Balance";
                    MemberExitLines."Amount (Base)" := -1 * Loans."Loan Balance";
                    MemberExitLines."Accrued Interest" := LoansMgt.GetAccruedInterest(Loans."No.", MemberExitHeader.Date);
                    Ok := MemberExitLines.Insert();
                until Loans.Next() = 0;
            end;
            LoanGuarantors.Reset;
            LoanGuarantors.SetRange("Member No.", MemberExitHeader."Member No");
            if LoanGuarantors.FindSet() then begin
                repeat
                    Window.Update(2, Loans."Member Name");
                    MemberExitLines.Init();
                    MemberExitLines."No." := DocumentNo;
                    MemberExitLines."Entry Type" := MemberExitLines."Entry Type"::Guarantee;
                    MemberExitLines."Entry No" := EntryNo;
                    EntryNo += 1;
                    MemberExitLines."Account No" := LoanGuarantors."Loan No";
                    Loans.Reset();
                    Loans.SetFilter("Date Filter", DateFilter);
                    Loans.SetRange("No.", LoanGuarantors."Loan No");
                    if Loans.FindSet() then begin
                        Loans.CalcFields("Loan Balance");
                        MemberExitLines."Account Name" := Loans."Member Name";
                        MemberExitLines.Balance := GetOutstandingGuarantee(Loans."No.", LoanGuarantors."Member No.");
                        MemberExitLines."Amount (Base)" := -1 * GetOutstandingGuarantee(Loans."No.", LoanGuarantors."Member No.");
                        if Loans."Loan Balance" <> 0 then Ok := MemberExitLines.Insert();
                    end;
                until LoanGuarantors.Next() = 0;
            end;
        end;
        MemberExitHeader.CalcFields("Accrued Interest", Liabilities, "Total Assets");
        MemberExitHeader."Net Amount" := MemberExitHeader."Total Assets" + MemberExitHeader.Liabilities - MemberExitHeader."Accrued Interest";
        MemberExitHeader.Modify();
        Window.Close;
    end;

    procedure OnMemberExitApproval(MemberExit: Record "Member Withdrawal")
    var
        CompanyInformation: Record "Company Information";
        GeneralSetup: Record "General Ledger Setup";
        CommunicationMgmt: Codeunit "Communications Mgmt";
        Body: Text;
        Subject: Text[100];
        Recipients: List of [Text];
        TempBlob: Codeunit "Temp Blob";
        outStreamReport: OutStream;
        inStreamReport: InStream;
        Recordr: RecordRef;
    begin
        if GeneralSetup."Marketing Department Email" <> '' then begin
            Recipients.Add(GeneralSetup."Marketing Department Email");
            Subject := 'Member Resignation -' + MemberExit."No.";
            Body += '<p style="font-family:Times New Roman">';
            Body += 'This to bring to your notice that Member : <b>%1, %2</b> have applied for resignation';
            Body += '<br> </br>';
            Body += 'Please find attached attached resignation form.';
            Body += '<br>This is a system generated email.';
            Body += '<br></br>Thanks & Regards.<br></br>';
            Body += '<br></br>.******************.<br></br>';
            Body += '<br></br>For any complains/compliments call.<br></br>';
            Body += '<br>' + CompanyInformation."Phone No." + CompanyInformation."E-Mail" + '<br>,<br>';
            Body += '<br>';
            Body += CompanyInformation.Name;
            Recordr.GetTable(MemberExit);
            TempBlob.CreateOutStream(outStreamReport);
            TempBlob.CreateInStream(inStreamReport);
            Report.SaveAs(Report::"Member Withdrawal", MemberExit."No.", ReportFormat::Pdf, outStreamReport, Recordr);
            CommunicationMgmt.SendEmailWithAttachement(Recipients, Subject, Body, 'Member Resignation', 0, inStreamReport);
        end;
    end;

    procedure PostMemberWithdrawal(DocumentNo: Code[20])
    var
        MemberExitLines: Record "Member Withdrawal Lines";
        AccountNo, ExtDocNo, JournalBatch, JournalTemplate, Dim1, Dim2, MemberNo, ReasonCode, SourceCode : Code[20];
        LineNo: Integer;
        PostingDate: Date;
        PostingDescription: Text[100];
        PostingAmount: Decimal;
        MemberWithdrawal: Record "Member Withdrawal";
        Loans: Record Loans;
        GLEntry: Record "G/L Entry";
        LoansMgt: Codeunit "Loans Management";
        Mobile: Codeunit "Channels Integrations";
        SaccoProduct: Record "Sacco Products";
    begin
        JournalBatch := 'MEXIT';
        JournalTemplate := 'GENERAL';
        MemberWithdrawal.Get(DocumentNo);
        If (WorkDate < MemberWithdrawal."Maturity Date") then Error(StrSubstNo('You cannnot post before then %1, Which is the maturity Date', MemberWithdrawal."Maturity Date"));
        GLEntry.Reset();
        GLEntry.SetRange("External Document No.", JournalBatch);
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("Journal Batch Name", JournalBatch);
        GLEntry.SetRange("Member No.", MemberWithdrawal."Member No");
        GLEntry.SetRange(Reversed, false);
        if not GLEntry.IsEmpty then begin
            MemberWithdrawal.Posted := true;
            MemberWithdrawal."Posted By" := UserId;
            MemberWithdrawal."Posted On" := WorkDate;
            MemberWithdrawal.Modify(true);
        end
        else begin
            LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
            AccountNo := '';
            MemberNo := MemberWithdrawal."Member No";
            MemberWithdrawal.CalcFields("Total Assets", Liabilities, "Accrued Interest");
            PostingDate := WorkDate;
            ExtDocNo := JournalBatch;
            SourceCode := 'MXT';
            ReasonCode := 'MXT';
            SaccoSetup.Get();
            if MemberWithdrawal."Document Type" = MemberWithdrawal."Document Type"::Withdrawal then begin
                AccountNo := GetMemberAccount(MemberNo, ProductPostingType::"Withdrawable Deposit");
                PostingAmount := MemberWithdrawal.Liabilities - MemberWithdrawal."Accrued Interest";
                PostingDescription := 'Member Withdrawal -> ' + MemberNo;
                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::General, LineNo, SourceCode, ReasonCode, ExtDocNo, '', 0, '', JournalTemplate, JournalBatch);
                MemberExitLines.Reset();
                MemberExitLines.SetRange("No.", DocumentNo);
                MemberExitLines.SetRange("Share Capital", false);
                if MemberExitLines.FindSet() then begin
                    repeat
                        case MemberExitLines."Entry Type" of
                            MemberExitLines."Entry Type"::Asset:
                                begin
                                    Vendor[1].Get(MemberExitLines."Account No");
                                    SaccoProduct.Get(Vendor[1]."Product Code");
                                    PostingDescription := CopyStr('Member Withdrawal Refund ' + Vendor[1].Name, 1, 50);
                                    PostingAmount := 0;
                                    PostingAmount := MemberExitLines.Balance;
                                    AccountNo := '';
                                    AccountNo := MemberExitLines."Account No";
                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Acc. Transfer", LineNo, SourceCode, ReasonCode, ExtDocNo, '', 0, '', JournalTemplate, JournalBatch);
                                    AccountNo := GetMemberAccount(MemberNo, ProductPostingType::"Withdrawable Deposit");
                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Acc. Transfer", LineNo, SourceCode, ReasonCode, ExtDocNo, '', 0, '', JournalTemplate, JournalBatch);
                                end;
                            MemberExitLines."Entry Type"::Liability:
                                begin
                                    if Loans.Get(MemberExitLines."Account No") then begin
                                        PostingAmount := 0;
                                        PostingAmount := MemberExitLines.Balance;
                                        AccountNo := '';
                                        AccountNo := Loans."Loan Account";
                                        Loans.CalcFields("Interest Balance", "Principal Balance");
                                        ReasonCode := Loans."No.";
                                        SourceCode := Loans."Product Code";
                                        PostingAmount := Loans."Interest Balance";
                                        if PostingAmount < 0 then
                                            PostingAmount := 0;
                                        PostingDescription := 'Interest Paid';
                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ExtDocNo, '', 0, '', JournalTemplate, JournalBatch);
                                        SaccoProduct.Get(Loans."Product Code");
                                        if SaccoSetup."Interest Accrual Type" = SaccoSetup."Interest Accrual Type"::"Cash Basis" then begin
                                            AccountNo := '';
                                            SaccoProduct.TestField("Interest Paid Account");
                                            SaccoProduct.TestField("Interest Due Account");
                                            AccountNo := SaccoProduct."Interest Paid Account";
                                            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ExtDocNo, '', 0, '', JournalTemplate, JournalBatch);
                                            AccountNo := '';
                                            AccountNo := SaccoProduct."Interest Due Account";
                                            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ExtDocNo, '', 0, '', JournalTemplate, JournalBatch);
                                        end;
                                        SaccoProduct.TestField("Interest Paid Account");
                                        AccountNo := SaccoProduct."Interest Paid Account";
                                        PostingDescription := 'Interest Paid';
                                        PostingAmount := MemberExitLines."Accrued Interest";
                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ExtDocNo, '', 0, '', JournalTemplate, JournalBatch);
                                        PostingDescription := 'Principal Paid';
                                        PostingAmount := 0;
                                        PostingAmount := Loans."Principal Balance";
                                        AccountNo := '';
                                        AccountNo := Loans."Loan Account";
                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Principal Paid", LineNo, SourceCode, ReasonCode, ExtDocNo, '', 0, '', JournalTemplate, JournalBatch);
                                    end;
                                end;
                        end;
                    until MemberExitLines.Next() = 0;
                end;
            end
            else if MemberWithdrawal."Document Type" = MemberWithdrawal."Document Type"::Refund then begin
                AccountNo := GetMemberAccount(MemberNo, ProductPostingType::"Withdrawable Deposit");
                PostingAmount := MemberWithdrawal."Requested Amount";
                PostingDescription := 'Member Refund -> ' + MemberNo;
                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::General, LineNo, SourceCode, ReasonCode, ExtDocNo, '', 0, '', JournalTemplate, JournalBatch);
                AccountNo := GetMemberAccount(MemberNo, ProductPostingType::"Non Withdrawable Deposit");
                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::General, LineNo, SourceCode, ReasonCode, ExtDocNo, '', 0, '', JournalTemplate, JournalBatch);
            end;
            LineNo := JournalManagement.AddCharges(MemberWithdrawal."Charge Code", GetMemberAccount(MemberNo, ProductPostingType::"Withdrawable Deposit"), MemberWithdrawal."Total Assets" + MemberWithdrawal.Liabilities, LineNo, DocumentNo, MemberNo, SourceCode, ReasonCode, ExtDocNo, JournalBatch, JournalTemplate, Dim1, Dim2, PostingDate, true);
            JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
            GLEntry.Reset();
            GLEntry.SetRange("Document No.", DocumentNo);
            GLEntry.SetRange("Document Date", PostingDate);
            if GLEntry.FindFirst() then begin
                if MemberWithdrawal."Document Type" = MemberWithdrawal."Document Type"::Withdrawal then begin
                    Vendor[1].Reset();
                    Vendor[1].SetRange("Member No.", MemberWithdrawal."Member No");
                    Vendor[1].SetFilter("Product Posting Type", '<>%1&<>%2&<>%3', Vendor[1]."Product Posting Type"::"Withdrawable Deposit", Vendor[1]."Product Posting Type"::"Share Capital Account", Vendor[1]."Product Posting Type"::"Benevolent Account");
                    if Vendor[1].FindSet() then begin
                        repeat
                            Vendor[1].Blocked := Vendor[1].Blocked::All;
                            Vendor[1].Validate(Status, Vendor[1].Status::Closed);
                            Vendor[1].Modify();
                        until Vendor[1].Next() = 0;
                    end;
                    if Member.Get(MemberNo) then begin
                        Member.Status := Member.Status::Withdrawn;
                        Member.Modify();
                    end;
                end;
                MemberWithdrawal.Posted := true;
                MemberWithdrawal."Posted By" := UserId;
                MemberWithdrawal."Posted On" := WorkDate;
                MemberWithdrawal.Modify(true);
            end;
        end;
    end;

    procedure Check18(ParseDate: Date)
    begin
        if CalcDate('-18Y', Today) > ParseDate then Error('You Must be at least 18 years');
    end;

    procedure CreateMember(var MemberApplication: Record "Member Application") MNo: Code[20]
    var
        DefaultAccounts: Record "Member Default Accounts";
        Customer: Record Customer;
        Subscriptions: array[2] of Record "Member Subscriptions";
        Kins: array[2] of Record "Member Nominee/Kin";
        AccountInstructions: array[2] of Record "Member Account Instructions";
        Signatories: array[2] of Record "Signatories & Directors";
        SaccoSetup: Record "General Ledger Setup";
        NoSeries: Codeunit NoSeriesManagement;
        MemberNo: Code[20];
        NoSeriesCode: Code[20];
        AccountNo: Code[20];
        MemberCategories: Record "Member Categories";
    begin
        OnBeforeCreateMember(MemberApplication);
        MemberNo := '';
        MemberNo := MemberApplication."Member No.";
        SaccoSetup.Get;
        MemberCategories.Get(MemberApplication.Category);
        if MemberCategories."No. Series" = '' then begin
            SaccoSetup.TestField("Member Nos.");
            NoSeriesCode := SaccoSetup."Member Nos.";
        end
        else
            NoSeriesCode := MemberCategories."No. Series";
        if MemberNo = '' then MemberNo := NoSeries.GetNextNo(NoSeriesCode, Today, true);
        Member.Init;
        Member."No." := MemberNo;
        Member.Validate("First Name", MemberApplication."First Name");
        Member.Validate("Middle Name", MemberApplication."Middle Name");
        Member.Validate("Last Name", MemberApplication."Last Name");
        Member.Gender := MemberApplication.Gender;
        Member.Validate(Category, MemberApplication.Category);
        Member."Micro Finance Account" := MemberApplication."Micro Finance Account";
        Member."Recruited By" := MemberApplication."Recruited By";
        Member."Recruiter Code" := MemberApplication."Recruiter Code";
        Member.Validate("Relationship Officer", MemberApplication."Relationship Officer");
        Member."Global Dimension 1 Code" := MemberApplication."Global Dimension 1 Code";
        Member."Global Dimension 2 Code" := MemberApplication."Global Dimension 2 Code";
        Member.Nationality := MemberApplication.Nationality;
        Member.Validate(Domicile, MemberApplication.Domicile);
        Member."Identification Type" := MemberApplication."Identification Type";
        Member."Identification No." := MemberApplication."Identification No.";
        Member."Passport No." := MemberApplication."Passport No.";
        Member."Date of Issue" := MemberApplication."Date of Issue";
        Member."Date of Expiry" := MemberApplication."Date of Expiry";
        Member."Date of Birth" := MemberApplication."Date of Birth";
        Member."Date of Registration" := WorkDate;
        Member."Created By" := UserId;
        Member."Created On" := CurrentDateTime;
        Member."Payroll No." := MemberApplication."Payroll No.";
        Member."Employer Code" := MemberApplication."Employer Code";
        Member."Mobile Phone No." := MemberApplication."Mobile Phone No.";
        Member."Mobile Transacting No" := MemberApplication."Mobile Transacting No";
        Member."Alt. Phone No" := MemberApplication."Alt. Phone No";
        Member.Address := MemberApplication.Address;
        Member."Address 2" := MemberApplication."Address 2";
        Member.City := MemberApplication.City;
        Member.County := MemberApplication.County;
        Member."Sub County" := MemberApplication."Sub County";
        Member."E-Mail" := MemberApplication."E-Mail";
        MemberApplication.CalcFields("Front ID Photo", "Back ID Photo", "Passport Size Photo", Signature);
        Member."Back ID Photo" := MemberApplication."Back ID Photo";
        Member."Front ID Photo" := MemberApplication."Front ID Photo";
        Member."Passport Size Photo" := MemberApplication."Passport Size Photo";
        Member.Signature := MemberApplication.Signature;
        Member."Marital Status" := MemberApplication."Marital Status";
        Member."KRA PIN" := MemberApplication."KRA PIN";
        Member."Type of Residence" := MemberApplication."Type of Residence";
        Member."Emplyoment Type" := MemberApplication."Emplyoment Type";
        Member.Occupation := MemberApplication.Occupation;
        Member."Occupation Description" := MemberApplication."Occupation Description";
        Member."Estate of Residence" := MemberApplication."Estate of Residence";
        Member."Employer Code" := MemberApplication."Employer Code";
        Member."Station Code" := MemberApplication."Station Code";
        Member."Department Code" := MemberApplication."Department Code";
        Member.Designation := MemberApplication.Designation;
        Member."Payroll No." := MemberApplication."Payroll No.";
        Member."Payroll No." := MemberApplication."Payroll No.";
        Member."Town of Residence" := MemberApplication."Town of Residence";
        Member."Estate of Residence" := MemberApplication."Estate of Residence";
        Member.Validate("Group/Corporate Name", MemberApplication."Group/Corporate Name");
        Member."Group/Corporate No" := MemberApplication."Group/Corporate No.";
        Member."Permit Expiry" := MemberApplication."Permit Expiry";
        Member."Certificate of Incoop" := MemberApplication."Certificate of Incoop";
        Member."Protected Account" := MemberApplication."Protected Account";
        Member."Account Owner" := MemberApplication."Account Owner";
        Member.ATM := MemberApplication.ATM;
        Member.Mobile := MemberApplication.Mobile;
        Member."Marketing Texts" := MemberApplication."Marketing Texts";
        Member."E-Statement" := MemberApplication."E-Statement";
        Member."E-Statement Period" := MemberApplication."E-Statement Period";
        Member.Goals := MemberApplication.Goals;
        Member.Insert(true);
        DefaultAccounts.Reset();
        DefaultAccounts.SetRange("Category Code", MemberApplication.Category);
        if DefaultAccounts.FindSet then begin
            repeat
                if ProductSetup.Get(DefaultAccounts."Product Code") then begin
                    ProductSetup.TestField(Prefix);
                    ProductSetup.TestField("Posting Group");
                    AccountNo := '';
                    AccountNo := ProductSetup.Prefix + MemberNo + ProductSetup.Suffix;
                    if not Vendor[1].Get(AccountNo) then begin
                        CreateMemberAccount(MemberNo, ProductSetup.Code);
                    end;
                end
                else begin
                end;
            until DefaultAccounts.Next = 0;
        end;
        Kins[1].Reset();
        Kins[1].SetRange("Source Code", MemberApplication."No.");
        if Kins[1].FindSet() then begin
            repeat
                if not Kins[2].Get(MemberNo, Kins[1]."Relative Code", Kins[1]."Identification No.", Kins[1]."Document Type") then begin
                    Kins[2].Init();
                    Kins[2].TransferFields(Kins[1], false);
                    Kins[2]."Source Code" := MemberNo;
                    Kins[2]."Relative Code" := Kins[1]."Relative Code";
                    Kins[2]."Identification Type" := Kins[1]."Identification Type";
                    Kins[2]."Identification No." := Kins[1]."Identification No.";
                    Kins[2]."Document Type" := Kins[1]."Document Type";
                    Kins[2].Insert(true);
                end;
            until Kins[1].Next() = 0;
        end;
        AccountInstructions[1].Reset();
        AccountInstructions[1].SetRange("Source Code", MemberApplication."No.");
        if AccountInstructions[1].FindSet() then begin
            repeat
                if not AccountInstructions[2].Get(MemberNo, AccountInstructions[1]."Line No") then begin
                    AccountInstructions[2].Init();
                    AccountInstructions[2].TransferFields(AccountInstructions[1], false);
                    AccountInstructions[2]."Source Code" := MemberNo;
                    AccountInstructions[2]."Line No" := AccountInstructions[1]."Line No";
                    AccountInstructions[2].Type := AccountInstructions[1].Type;
                    AccountInstructions[2].Instruction := AccountInstructions[1].Instruction;
                    AccountInstructions[2].Insert(true);
                end;
            until AccountInstructions[1].Next() = 0;
        end;
        Subscriptions[1].Reset();
        Subscriptions[1].SetRange("Source Code", MemberApplication."No.");
        if Subscriptions[1].FindSet() then begin
            repeat
                if not Subscriptions[2].Get(MemberNo, Subscriptions[1]."Account Type") then begin
                    Subscriptions[2].Init();
                    Subscriptions[2].TransferFields(Subscriptions[1], false);
                    Subscriptions[2]."Source Code" := MemberNo;
                    Subscriptions[2]."Account Type" := Subscriptions[1]."Account Type";
                    Subscriptions[2]."Start Date" := Subscriptions[1]."Start Date";
                    Subscriptions[2].Insert();
                end;
            until Subscriptions[1].Next() = 0;
        end;
        Signatories[1].Reset();
        Signatories[1].SetRange("Source Code", MemberApplication."No.");
        if Signatories[1].FindSet() then begin
            repeat
                Signatories[1].CalcFields("Passport Image", "Signature Card");
                Signatories[2].Init();
                Signatories[2].TransferFields(Signatories[1], false);
                Signatories[2]."Source Code" := MemberNo;
                Signatories[2].Type := Signatories[1].Type;
                Signatories[2]."Entry No." := Signatories[1]."Entry No.";
                Signatories[2].Insert();
            until Signatories[1].Next() = 0;
        end;
        MemberApplication.Processed := true;
        MemberApplication."Member No." := MemberNo;
        MemberApplication.Modify();
        CopyMemberApplicationAttchments(MemberApplication."No.", MemberNo);
        OnAfterCreateMember(MemberApplication, Member);
        exit(MemberNo);
    end;

    procedure CopyMemberApplicationAttchments(ApplicationNo: Code[20]; MemberNo: Code[20])
    var
        DocumentAttachment: array[2] of Record "Document Attachment";
    begin
        DocumentAttachment[1].Reset();
        DocumentAttachment[1].SetRange("Table ID", Database::"Member Application");
        DocumentAttachment[1].SetRange("No.", ApplicationNo);
        if DocumentAttachment[1].FindSet() then begin
            repeat
                DocumentAttachment[2].Init();
                DocumentAttachment[2].TransferFields(DocumentAttachment[1], true);
                DocumentAttachment[2]."Table ID" := Database::Members;
                DocumentAttachment[2]."No." := MemberNo;
                DocumentAttachment[2].Validate("Attached Date", CurrentDateTime);
                DocumentAttachment[2].Insert;
            until DocumentAttachment[1].Next() = 0;
        end;
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeSendMemberApplicationForApproval(MemberApplication: Record "Member Application")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"Member Management", 'OnBeforeSendMemberApplicationForApproval', '', true, true)]
    local procedure CheckMemberMandatoryFields(MemberApplication: Record "Member Application")
    var
        FormartedID: Integer;
        MemberKins: array[2] of Record "Member Nominee/Kin";
        AccountInstructions: Record "Member Account Instructions";
        ApplicationDocs: Record "Doc. Attachments Checklist";
        Employer: Record Employers;
        Signatories: Record "Signatories & Directors";
        DefaultAccounts: Record "Member Default Accounts";
        SaccoProduct: Record "Sacco Products";
        ATMTypes: Record "ATM Types";
    begin
        if (CurrentClientType <> ClientType::Web) then
            MemberApplication.TestField("Payment Ref Code");

        MemberApplication.TestField(Category);
        MemberApplication.TestField("E-Mail");
        MemberApplication.TestField("Full Name");
        MemberApplication.TestField("Mobile Phone No.");
        MemberApplication.TestField(County);
        if MemberApplication.ATM then begin
            ATMTypes.Reset();
            ATMTypes.SetRange(Type, ATMTypes.Type::Debit);
            if ATMTypes.FindFirst then
                ATMTypes.TestField("Application Charge")
            else
                Error('There is no Debit ATM Types in the setups.');
        end;
        if Employer.Get(MemberApplication."Employer Code") then begin
            if Employer."Payroll No. Mandatory" then
                MemberApplication.TestField("Payroll No.");
        end;

        if MemberApplication."E-Statement" then MemberApplication.TestField("E-Statement Period");
        if MemberApplication."Category Type" = MemberApplication."Category Type"::"Group Member" then MemberApplication.TestField("Micro Finance Account");
        if MemberApplication."Category Type" in [MemberApplication."Category Type"::"Joint Account", MemberApplication."Category Type"::Group, MemberApplication."Category Type"::"Micro Finance", MemberApplication."Category Type"::Institution] = false then begin
            if MemberApplication.Nationality = MemberApplication.Nationality::Kenyan then MemberApplication.TestField("KRA PIN");
            MemberApplication.TestField("Date of Birth");
            MemberApplication.TestField("Identification No.");
        end;
        if MemberApplication."Is Group/Corporate" = false then begin
            MemberApplication.TestField("Mobile Transacting No");
            MemberApplication.TestField("Emplyoment Type");
            If MemberApplication."Emplyoment Type" = MemberApplication."Emplyoment Type"::"Employed (Checkoff)" then begin
                MemberApplication.TestField("Employer Code");
                MemberApplication.TestField("Payroll No.");
                Member.Reset();
                Member.SetRange("Payroll No.", MemberApplication."Payroll No.");
                Member.SetRange("Employer Code", MemberApplication."Employer Code");
                if Member.FindFirst() then Error('The Payroll No is already linked to ' + Member."Full Name");
            end
            else If MemberApplication."Emplyoment Type" = MemberApplication."Emplyoment Type"::"Employed (Non-Checkoff)" then
                MemberApplication.TestField("Occupation Description")
            else
                If MemberApplication."Emplyoment Type" = MemberApplication."Emplyoment Type"::"Self Employed" then
                    MemberApplication.TestField(Occupation);
            MemberKins[1].Reset();
            MemberKins[1].SetRange("Source Code", MemberApplication."No.");
            MemberKins[1].SetRange("Document Type", MemberKins[1]."Document Type"::Nominee);
            if MemberKins[1].FindSet() then begin
                MemberKins[1].CalcSums(Allocation);
                if MemberKins[1].Allocation <> 100 then Error('The Nominee Allocation must be 100%');
            end
            else
                Error('Kindly provide Nominee information');
            MemberKins[2].Reset();
            MemberKins[2].SetRange("Source Code", MemberApplication."No.");
            MemberKins[2].SetRange("Document Type", MemberKins[2]."Document Type"::"Next of Kin");
            if not MemberKins[2].FindSet then Error('Kindly provide Next of Kin information');
        end
        else begin
            MemberApplication.TestField("Group/Corporate Name");
            //MemberApplication.TestField("Group/Corporate No.");
            Signatories.Reset();
            Signatories.SetRange("Source Code", MemberApplication."No.");
            if Signatories.IsEmpty then Error('Please Provide the group signatories');
        end;
        SaccoProduct.Reset();
        SaccoProduct.SetRange("Product Posting Type", SaccoProduct."Product Posting Type"::"Withdrawable Deposit");
        if SaccoProduct.FindFirst then begin
            DefaultAccounts.Reset;
            DefaultAccounts.SetRange("Category Code", MemberApplication.Category);
            DefaultAccounts.SetRange("Product Code", SaccoProduct.Code);
            if DefaultAccounts.FindFirst then begin
                AccountInstructions.Reset();
                AccountInstructions.SetRange("Source Code", MemberApplication."No.");
                if not AccountInstructions.FindSet then Error('Kindly provide Account Instrctions');
            end;
        end;
        ApplicationDocs.Reset();
        ApplicationDocs.SetRange("Source Code", MemberApplication."No.");
        ApplicationDocs.SetRange(Mandatory, true);
        ApplicationDocs.SetRange(Provided, false);
        if ApplicationDocs.FindSet then Error('All Mandatory Documents must be provided first');
    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"Member Management", 'OnBeforeSendMemberApplicationForApproval', '', true, true)]
    local procedure CheckMemberDuplication(MemberApplication: Record "Member Application")
    begin
        if MemberApplication."Identification No." <> '' then begin
            Member.Reset();
            Member.SetRange("Identification No.", MemberApplication."Identification No.");
            Member.SetRange(Category, MemberApplication.Category);
            if Member.FindFirst() then Error('The Identification %1 is already Linked to member %2', MemberApplication."Identification No.", Member."Full Name");
        end;
        if MemberApplication."Mobile Phone No." <> '' then begin
            Member.Reset();
            Member.SetRange("Mobile Phone No.", MemberApplication."Mobile Phone No.");
            if Member.FindFirst() then Error('The Mobile Phone %1 is already Linked to member %2', MemberApplication."Mobile Phone No.", Member."Full Name");
        end;
        if MemberApplication."KRA PIN" <> '' then begin
            Member.Reset();
            Member.SetRange("KRA PIN", MemberApplication."KRA PIN");
            if Member.FindFirst() then Error('The KRA PIN  %1 is already Linked to member %2', MemberApplication."KRA PIN", Member."Full Name");
        end;
    end;

    procedure ValidateDateOfIssue(IssueDate: Date)
    begin
        if IssueDate > TODAY then Error('The Date of Issue cannot be a future date.');
    end;

    procedure ValidateDateOfExpiry(ExpiryDate: Date)
    begin
        if ExpiryDate <= TODAY then Error('The Date of Expiry must be a future date.');
    end;

    procedure ProcessMemberEditing(MemberEditing: Record "Member Editing")
    var
        MemberVersions: array[2] of Record "Member Versions";
        MemberKins: array[3] of Record "Member Nominee/Kin";
        Signatories: array[3] of Record "Signatories & Directors";
        AccountInstructions: array[3] of Record "Member Account Instructions";
        MemberSubscriptions: array[3] of Record "Member Subscriptions";
        Vendors: Record Vendor;
    begin
        MemberEditing.CalcFields("Passport Size Photo", Signature, "Front ID Photo", "Back ID Photo");
        if Member.Get(MemberEditing."Member No.") then begin
            MemberVersions[1].Init();
            MemberVersions[1]."Document No." := MemberEditing."No.";
            MemberVersions[1]."First Name" := Member."First Name";
            MemberVersions[1]."Middle Name" := Member."Middle Name";
            MemberVersions[1]."Full Name" := MemberEditing."Full Name";
            MemberVersions[1]."Last Name" := Member."Last Name";
            MemberVersions[1]."Mobile Phone No." := Member."Mobile Phone No.";
            MemberVersions[1]."Alt. Phone No" := Member."Alt. Phone No";
            MemberVersions[1].Validate("Relationship Officer", Member."Relationship Officer");
            MemberVersions[1].Channels := Member.Mobile;
            MemberVersions[1].Nationality := Member.Nationality;
            MemberVersions[1].Validate(Domicile, Member.Domicile);
            MemberVersions[1]."Identification Type" := Member."Identification Type";
            MemberVersions[1]."Identification No." := Member."Identification No.";
            MemberVersions[1]."Address 2" := Member."Address 2";
            MemberVersions[1]."Department Code" := Member."Department Code";
            MemberVersions[1]."Date of Issue" := Member."Date of Issue";
            MemberVersions[1]."Date of Expiry" := Member."Date of Expiry";
            MemberVersions[1]."Emplyoment Type" := Member."Emplyoment Type";
            MemberVersions[1]."Employer Code" := Member."Employer Code";
            MemberVersions[1]."Station Code" := Member."Station Code";
            MemberVersions[1].Designation := Member.Designation;
            MemberVersions[1]."Payroll No." := Member."Payroll No.";
            MemberVersions[1].Occupation := Member.Occupation;
            MemberVersions[1]."Occupation Description" := Member."Occupation Description";
            MemberVersions[1].Address := Member.Address;
            MemberVersions[1].City := Member.City;
            MemberVersions[1].County := Member.County;
            MemberVersions[1]."Sub County" := Member."Sub County";
            MemberVersions[1]."Marital Status" := Member."Marital Status";
            MemberVersions[1]."Type of Residence" := Member."Type of Residence";
            MemberVersions[1]."Member Image" := Member."Passport Size Photo";
            MemberVersions[1]."Signature Card" := MemberEditing.Signature;
            MemberVersions[1]."Front ID Image" := Member."Front ID Photo";
            MemberVersions[1]."Back ID Image" := Member."Back ID Photo";
            MemberVersions[1]."Marital Status" := Member."Marital Status";
            MemberVersions[1]."Member No." := MemberEditing."Member No.";
            MemberVersions[1]."Type of Residence" := MemberEditing."Type of Residence";
            MemberVersions[1]."Estate of Residence" := MemberEditing."Estate of Residence";
            MemberVersions[1]."Mobile Transacting No" := MemberEditing."Mobile Transacting No";
            MemberVersions[1]."ATM Limit" := MemberEditing."ATM Limit";
            MemberVersions[1]."Mobi Loan Limit" := MemberEditing."Mobi Loan Limit";
            MemberVersions[1]."Prior Year Dividend" := MemberEditing."Prior Year Dividend";
            MemberVersions[1]."Date of Issue" := Member."Date of Issue";
            MemberVersions[1]."Marketing Texts" := MemberEditing."Marketing Texts";
            MemberVersions[1]."E-Statement" := MemberEditing."E-Statement";
            MemberVersions[1]."E-Statement Period" := MemberEditing."E-Statement Period";
            if not MemberVersions[2].Get(MemberEditing."No.") then
                MemberVersions[1].Insert
            else
                MemberVersions[1].Modify;
            Member."First Name" := MemberEditing."First Name";
            Member."Middle Name" := MemberEditing."Middle Name";
            Member."Last Name" := MemberEditing."Last Name";
            Member."Full Name" := MemberEditing."Full Name";
            Member."Mobile Phone No." := MemberEditing."Mobile Phone No.";
            Member."Alt. Phone No" := MemberEditing."Alt. Phone No";
            Member.Validate("Relationship Officer", MemberEditing."Relationship Officer");
            Member.Nationality := MemberEditing.Nationality;
            Member.Validate(Domicile, MemberEditing.Domicile);
            Member."Identification Type" := MemberEditing."Identification Type";
            Member."Identification No." := MemberEditing."Identification No.";
            Member."Passport No." := MemberEditing."Passport No.";
            Member."Address 2" := MemberEditing."Address 2";
            Member."Department Code" := MemberEditing."Department Code";
            Member."Payroll No." := MemberEditing."Payroll No.";
            Member.Address := MemberEditing.Address;
            Member.City := MemberEditing.City;
            Member.County := MemberEditing.County;
            Member."Sub County" := MemberEditing."Sub County";
            Member."Marital Status" := MemberEditing."Marital Status";
            Member."Emplyoment Type" := MemberEditing."Emplyoment Type";
            Member.Salaried := MemberEditing.Salaried;
            Member."Employer Code" := MemberEditing."Employer Code";
            Member."Station Code" := MemberEditing."Station Code";
            Member.Designation := MemberEditing.Designation;
            Member."Payroll No." := MemberEditing."Payroll No.";
            Member.Occupation := MemberEditing.Occupation;
            Member."Occupation Description" := MemberEditing."Occupation Description";
            Member."Type of Residence" := MemberEditing."Type of Residence";
            Member."Passport Size Photo" := MemberEditing."Passport Size Photo";
            Member.Signature := MemberEditing.Signature;
            Member."Front ID Photo" := MemberEditing."Front ID Photo";
            Member."Back ID Photo" := MemberEditing."Back ID Photo";
            Member."Marital Status" := MemberEditing."Marital Status";
            Member."Type of Residence" := MemberEditing."Type of Residence";
            Member."Group/Corporate Name" := MemberEditing."Group Name";
            Member."Group/Corporate No" := MemberEditing."Group No";
            Member."E-Mail" := MemberEditing."E-Mail";
            Member.Signature := MemberEditing.Signature;
            Member."Protected Account" := MemberEditing."Protected Account";
            Member."Account Owner" := MemberEditing."Account Owner";
            Member."Mobile Transacting No" := MemberEditing."Mobile Transacting No";
            Member."ATM Limit" := MemberEditing."ATM Limit";
            Member."Mobi Loan Limit" := MemberEditing."Mobi Loan Limit";
            Member."Prior Year Dividend" := MemberEditing."Prior Year Dividend";
            Member."Date of Issue" := MemberEditing."Date of Issue";
            Member."Marketing Texts" := MemberEditing."Marketing Texts";
            Member."E-Statement" := MemberEditing."E-Statement";
            Member."E-Statement Period" := MemberEditing."E-Statement Period";
            Member.Goals := MemberEditing.Goals;
            Member.Modify();
        end;

        Vendors.Reset();
        Vendors.SetRange("Member No.", MemberEditing."Member No.");
        if Vendors.FindSet() then begin
            repeat
                Vendors."Member Name" := MemberEditing.FullName;
                Vendors.Modify(true);
            until Vendors.Next() = 0;
        end;

        MemberKins[1].Reset();
        MemberKins[1].SetRange("Source Code", MemberEditing."Member No.");
        if MemberKins[1].FindSet() then
            MemberKins[1].DeleteAll();

        MemberKins[2].Reset();
        MemberKins[2].SetRange("Source Code", MemberEditing."No.");
        if MemberKins[2].FindSet() then begin
            repeat
                MemberKins[2].CalcFields("Passport Image", "Identification Document");
                MemberKins[3].Init();
                MemberKins[3].TransferFields(MemberKins[2], false);
                MemberKins[3]."Source Code" := MemberEditing."Member No.";
                MemberKins[3]."Relative Code" := MemberKins[2]."Relative Code";
                MemberKins[3]."Identification No." := MemberKins[2]."Identification No.";
                MemberKins[3]."Document Type" := MemberKins[2]."Document Type";
                MemberKins[3].Insert();
            until MemberKins[2].Next() = 0;
        end;


        AccountInstructions[1].Reset();
        AccountInstructions[1].SetRange("Source Code", MemberEditing."Member No.");
        AccountInstructions[1].DeleteAll();
        AccountInstructions[2].Reset();
        AccountInstructions[2].SetRange("Source Code", MemberEditing."No.");
        if AccountInstructions[2].FindSet() then begin
            repeat
                AccountInstructions[3].Init();
                AccountInstructions[3].TransferFields(AccountInstructions[2], false);
                AccountInstructions[3]."Source Code" := MemberEditing."Member No.";
                AccountInstructions[3]."Line No" := AccountInstructions[2]."Line No";
                AccountInstructions[3].Insert(true);
            until AccountInstructions[2].Next() = 0;
        end;
        Signatories[1].Reset();
        Signatories[1].SetRange("Source Code", MemberEditing."Member No.");
        if Signatories[1].FindSet() then Signatories[1].DeleteAll();
        Signatories[2].Reset();
        Signatories[2].SetRange("Source Code", MemberEditing."No.");
        if Signatories[2].FindSet() then begin
            repeat
                Signatories[2].CalcFields("Passport Image", "Signature Card");
                Signatories[3].Init();
                Signatories[3].TransferFields(Signatories[2], false);
                Signatories[3]."Source Code" := MemberEditing."Member No.";
                Signatories[3]."Entry No." := Signatories[2]."Entry No.";
                Signatories[3].Type := Signatories[2].Type;
                Signatories[3].Insert();
            until Signatories[2].Next = 0;
        end;
        MemberSubscriptions[1].Reset();
        MemberSubscriptions[1].SetRange("Source Code", MemberEditing."Member No.");
        MemberSubscriptions[1].DeleteAll();
        MemberSubscriptions[2].Reset();
        MemberSubscriptions[2].SetRange("Source Code", MemberEditing."No.");
        if MemberSubscriptions[2].FindSet() then begin
            repeat
                MemberSubscriptions[3].Init();
                MemberSubscriptions[3].TransferFields(MemberSubscriptions[2], false);
                MemberSubscriptions[3]."Source Code" := MemberEditing."Member No.";
                MemberSubscriptions[3]."Account Type" := MemberSubscriptions[2]."Account Type";
                MemberSubscriptions[3].Insert(true);
            until MemberSubscriptions[2].Next() = 0;
        end;


        MemberEditing.Processed := true;
        MemberEditing.Modify();
        OnAfterProcessMemberUpdate(MemberEditing);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterProcessMemberUpdate(var MemberEditing: Record "Member Editing")
    begin
    end;

    var
        GlobalTransactionType: Enum "Sacco Transaction Type";
        GlobalAccountType: Enum "Gen. Journal Account Type";

    procedure GetMemberPhoneNo(MemberNo: Code[20]): Text[100]
    begin
        Member.Reset;
        Member.SetRange("No.", MemberNo);
        if Member.FindFirst() then begin
            if Member."Mobile Phone No." <> '' then exit(Member."Mobile Phone No.");
            if Member."Mobile Phone No." = '' then begin
                if Member."Mobile Transacting No" <> '' then exit(Member."Mobile Transacting No")
            end;
        end;
    end;

    procedure GetEmployeeNo(MemberNo: Code[20]): Code[20]
    var
        Employee: Record Employee;
    begin
        Employee.Reset;
        Employee.SetRange("Member No.", MemberNo);
        if Employee.FindFirst then
            exit(Employee."No.");
    end;

    internal procedure PostATMDeLinking(DocumentNo: Code[20])
    var
        ATMApplication: Record "ATM Application";
        ATMCards: Record "ATM Cards";
        JournalMgt: Codeunit "Journal Management";
        PostingAmount, AvailableBalance, Charges : Decimal;
        JournalBatch, JournalTemplate, Dim1, Dim2, Dim3, Dim4, Dim5, Dim6, Dim7, MemberNo, SourceCode, Dim8, ReasonCode, ExternalDocumentNo : Code[20];
        PostingDate: Date;
        LineNo: Integer;
        JournalManagement: Codeunit "Journal Management";
        LoansMgt: Codeunit "Loans Management";
        SaccoProduct: Record "Sacco Products";
        ChannelsIntegrations: Codeunit "Channels Integrations";
    begin
        ATMApplication.Get(DocumentNo);
        ATMApplication.Validate("Member No");
        Vendor[1].Get(ATMApplication."Account No.");
        Vendor[1].CalcFields(Balance, "Uncleared Funds");
        SaccoProduct.Get(Vendor[1]."Product Code");
        AvailableBalance := Vendor[1].Balance - Vendor[1]."Uncleared Funds" - SaccoProduct."Minimum Balance" - ChannelsIntegrations.GetPendingChannelsTransactions(Vendor[1]."Member No.");
        if AvailableBalance < 0 then AvailableBalance := 0;
        /*Charges := JournalMgt.GetTransactionCharges(ATMApplication."Transaction Code", 999);
        if Charges > AvailableBalance then
            Error('The Account does not have sufficient funds');*/
        if ATMApplication."Application Type" = ATMApplication."Application Type"::Delinking then begin
            Vendor[1].Reset();
            Vendor[1].SetRange("Member No.", ATMApplication."Member No");
            Vendor[1].SetRange("No.", ATMApplication."Account No.");
            if Vendor[1].FindSet() then begin
                repeat
                    Vendor[1]."Card No" := '';
                    Vendor[1].Modify();
                until Vendor[1].Next() = 0;
            end;
        end;
        ATMApplication.Processed := true;
        ATMApplication.Collected := true;
        ATMApplication."Processed At" := time;
        ATMApplication."Processed By" := UserId;
        ATMApplication."Processed On" := WorkDate;
        ATMApplication.Modify();
        Message('Successful');
    end;

    procedure MemberAccountMgmt(AccountMgmt: Record "Member Accounts Mgmt.")
    begin
        if AccountMgmt."Document Type" = AccountMgmt."Document Type"::Activation then
            ConfirmationMessage := 'You are about to Activate %1 for %2, Do you wish to continue?'
        else if AccountMgmt."Document Type" = AccountMgmt."Document Type"::Deactivation then ConfirmationMessage := 'You are about to Deactivate %1 for %2, Do you wish to continue?';
        if not Confirm(StrSubstNo(ConfirmationMessage, AccountMgmt."Account Name", AccountMgmt."Member Name"), false, false) then
            exit
        else begin
            Vendor[1].Get(AccountMgmt."Account No");
            if AccountMgmt."Document Type" = AccountMgmt."Document Type"::Activation then begin
                Vendor[1].Validate(Status, Vendor[1].Status::Active);
                Vendor[1].Validate(Blocked, Vendor[1].Blocked::" ");
                Vendor[1].Modify(true);
                PostActivationCharges(AccountMgmt);
            end
            else if AccountMgmt."Document Type" = AccountMgmt."Document Type"::Deactivation then begin
                Vendor[1].Validate(Status, Vendor[1].Status::Closed);
                Vendor[1].Validate("Blocked Reason", AccountMgmt."Deactivation Reason");
                Vendor[1].Validate(Blocked, Vendor[1].Blocked::All);
                Vendor[1].Modify(true);
            end;
            AccountMgmt.Processed := true;
            AccountMgmt."Processed By" := UserId;
            AccountMgmt."Processed Date" := WorkDate;
            AccountMgmt.Modify(true);
        end;
    end;

    local procedure PostActivationCharges(AccountMgmt: Record "Member Accounts Mgmt.")
    begin
        if AccountMgmt.Charge <> '' then begin
            JournalBatch := 'Acc. Mgmt';
            JournalTemplate := 'GENERAL';
            LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
            LineNo := JournalManagement.AddCharges(AccountMgmt.Charge, GetMemberAccount(AccountMgmt."Member No.", ProductPostingType::"Withdrawable Deposit"), 1000, LineNo, AccountMgmt."No.", AccountMgmt."Member No.", 'BCQ', 'BCQ', AccountMgmt."Member No.", JournalBatch, JournalTemplate, '', '', WorkDate, True);
            JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
        end;
    end;

    procedure MemberRegistrationFeeCheck()
    begin
        Member.Reset();
        Member.SetRange(Status, Member.Status::"Not Paid Up");
        if Member.FindSet then begin
        end;
    end;

    procedure BlockMobileMember(MemberNo: Code[20])
    var
        MobileMembers: Record "Mobile Members";
        MobileLedger: Record "Mobile Member Ledger";
        EntryNo: Integer;
    begin
        MobileMembers.Get(MemberNo);
        MobileMembers."Member Status" := MobileMembers."Member Status"::Blocked;
        MobileMembers.Modify();
        MobileLedger.Reset();
        if MobileLedger.FindLast() then
            EntryNo := MobileLedger."Entry No" + 1
        else
            EntryNo := 1;
        MobileLedger.Init();
        MobileLedger."Entry No" := EntryNo;
        MobileLedger."Document No" := Format(Today);
        MobileLedger."User ID" := UserId;
        MobileLedger."Posting Date" := Today;
        MobileLedger."Posting Time" := time;
        MobileLedger."Member No" := MemberNo;
        MobileLedger."Document Type" := MobileLedger."Document Type"::Blocking;
        MobileLedger.Insert();
    end;

    procedure PostMobileApplication(DocumentNo: Code[20])
    var
        MobileApplication: Record "Mobile Application";
        MobileMembers: Record "Mobile Members";
        MobileLedger: Record "Mobile Member Ledger";
        EntryNo: Integer;
        Members: Record Members;
        SMS: Codeunit "Notifications Management";
        SMSSource: Code[20];
        SMSBody: Text;
        SMSPhoneNo: Text;
    begin
        MobileApplication.Get(DocumentNo);
        Members.Get(MobileApplication."Member No");
        Members."Mobile Transacting No" := MobileApplication."Mobile Transacting No";
        Members.Modify(True);
        SMSPhoneNo := MobileApplication."Mobile Transacting No";
        SMSSource := 'MOBILE APP';
        SMSBody := StrSubstNo('Dear %1, Your Mobile Banking has been activated. Your Member No. is %2. Dial *882# and reply with option 2, Self-Register to onboard.', Members."Full Name", Members."No.");
        SMS.SendSms(SMSPhoneNo, SMSBody, SMSSource);
        if MobileMembers.Get(MobileApplication."Member No") then begin
            MobileMembers."Member Status" := MobileMembers."Member Status"::Active;
            MobileMembers.Modify();
            MobileLedger.Reset();
            if MobileLedger.FindLast() then
                EntryNo := MobileLedger."Entry No" + 1
            else
                EntryNo := 1;
            MobileLedger.Init();
            MobileLedger."Entry No" := EntryNo;
            MobileLedger."Document No" := DocumentNo;
            MobileLedger."User ID" := UserId;
            MobileLedger."Posting Date" := Today;
            MobileLedger."Posting Time" := time;
            MobileLedger."Member No" := MobileApplication."Member No";
            MobileLedger."Document Type" := MobileLedger."Document Type"::Reactivation;
            MobileMembers."Mobile Transacting No" := MobileApplication."Mobile Transacting No";
            MobileLedger.Insert();
        end
        else begin
            MobileLedger.Reset();
            if MobileLedger.FindLast() then
                EntryNo := MobileLedger."Entry No" + 1
            else
                EntryNo := 1;
            MobileLedger.Init();
            MobileLedger."Entry No" := EntryNo;
            MobileLedger."Document No" := DocumentNo;
            MobileLedger."User ID" := UserId;
            MobileLedger."Posting Date" := Today;
            MobileLedger."Posting Time" := time;
            MobileLedger."Member No" := MobileApplication."Member No";
            MobileLedger."Document Type" := MobileLedger."Document Type"::Activation;
            MobileLedger.Insert();
            MobileMembers.Init();
            MobileMembers."Member No" := MobileApplication."Member No";
            MobileMembers."Full Name" := MobileApplication."Full Name";
            MobileMembers."FOSA Account" := MobileApplication."FOSA Account";
            MobileMembers."Phone No" := MobileApplication."Phone No";
            MobileMembers."ID No" := MobileApplication."ID No";
            MobileMembers."Activated On" := CurrentDateTime;
            MobileMembers."Activated By" := UserId;
            MobileMembers."Mobile Transacting No" := MobileApplication."Mobile Transacting No";
            MobileMembers."Member Status" := MobileMembers."Member Status"::Active;
            MobileMembers.Insert();
        end;
        MobileApplication.Processed := true;
        MobileApplication."Processed By" := UserId;
        MobileApplication."Processed On" := CurrentDateTime;
        MobileApplication.Modify(true);
    end;

    procedure CreateMembersDefaultAccounts(MemberCategories: Record "Member Categories")
    var
        DefaultAccounts: Record "Member Default Accounts";
        ProductSetup: Record "Sacco Products";
        AccountNo: Code[20];
        Window: Dialog;
    begin
        DefaultAccounts.Reset();
        DefaultAccounts.SetRange("Category Code", MemberCategories.Code);
        if DefaultAccounts.FindSet then begin
            Window.Open('Creating Members Account \#1###\#2###\#3###');
            repeat
                if ProductSetup.Get(DefaultAccounts."Product Code") then begin
                    ProductSetup.TestField(Prefix);
                    ProductSetup.TestField("Posting Group");
                    Window.Update(1, ProductSetup.Description);
                    Member.Reset();
                    Member.SetRange(Category, MemberCategories.Code);
                    if Member.FindSet then begin
                        repeat
                            AccountNo := '';
                            AccountNo := ProductSetup.Prefix + Member."No." + ProductSetup.Suffix;
                            Window.Update(2, Member.FullName);
                            if not Vendor[1].Get(AccountNo) then begin
                                Window.Update(3, AccountNo);
                                Vendor[1].Init();
                                Vendor[1]."No." := AccountNo;
                                Vendor[1].Name := UpperCase(ProductSetup.Description);
                                Vendor[1]."Vendor Posting Group" := ProductSetup."Posting Group";
                                Vendor[1]."Member Name" := UpperCase(Member.FullName);
                                Vendor[1]."Account Type" := Vendor[1]."Account Type"::Sacco;
                                Vendor[1]."Member No." := Member."No.";
                                Vendor[1]."Product Code" := ProductSetup.Code;
                                Vendor[1]."Product Posting Type" := ProductSetup."Product Posting Type";
                                Vendor[1]."Business Account" := ProductSetup."Business Account";
                                Vendor[1]."Cash Deposit Allowed" := ProductSetup."Cash Deposit Allowed";
                                Vendor[1]."Cash Withdraw Allowed" := ProductSetup."Cash Withdraw Allowed";
                                Vendor[1]."Cash Transfer Allowed" := ProductSetup."Cash Transfer Allowed";
                                Vendor[1]."Cheque Book Allowed" := ProductSetup."Cheque Book Allowed";
                                Vendor[1].Status := Vendor[1].Status::Active;
                                Vendor[1].Insert(true);
                            end;
                        until Member.Next() = 0;
                    end;
                end;
            until DefaultAccounts.Next = 0;
            Window.Close;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Employee Management", 'OnEmployeeMemberApplication', '', false, false)]
    local procedure EmployeeMemberApplication(Emp: Record Employee)
    var
        MemberApp: Record "Member Application";
    begin
        MemberApp.Init();
        MemberApp."First Name" := Emp."First Name";
        MemberApp."Middle Name" := Emp."Middle Name";
        MemberApp."Last Name" := Emp."Last Name";
        MemberApp."Full Name" := Emp.FullName;
        MemberApp."Mobile Phone No." := Emp."Mobile Phone No.";
        MemberApp."Alt. Phone No" := Emp."Phone No.";
        MemberApp.Gender := Emp.Gender;
        MemberApp."Identification No." := Emp."National ID";
        MemberApp."Passport No." := Emp."Passport Number";
        MemberApp."Date of Birth" := Emp."Birth Date";
        MemberApp."Payroll No." := Emp."No.";
        MemberApp.Address := Emp.Address;
        MemberApp.City := Emp.City;
        MemberApp.County := Emp.County;
        MemberApp."Sub County" := Emp."Sub-County";
        MemberApp."E-Mail" := Emp."E-Mail";
        MemberApp."Marital Status" := Emp."Marital Status";
        MemberApp."KRA PIN" := Emp."KRA Number";
        MemberApp.Insert(true);
    end;

    procedure UpdateMembersAccountsOpeningBalances()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        ProductSetup: Record "Sacco Products";
        AccountNo, DocumentNo : Code[20];
        MemberAccountsBalances: Record "Member Accounts Balances";
        PostingDate: Date;
        PostingAmount: Decimal;
        PostingDescription: Text;
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.TestField("Opening Balance Acc.");
        GeneralLedgerSetup.TestField("Opening Balance Posting Date");
        DocumentNo := 'OPENBAL';
        PostingDate := GeneralLedgerSetup."Opening Balance Posting Date";
        Window.Open('Updating Member Balances \#1##\#2##\#3##\#4##\#5##');
        MemberAccountsBalances.Reset();
        MemberAccountsBalances.SetRange(Posted, false);
        if MemberAccountsBalances.FindSet then begin
            All := 0;
            Current := 0;
            All := MemberAccountsBalances.Count;
            repeat
                if Member.Get(MemberAccountsBalances."Member No.") then begin
                    Current += 1;
                    Window.Update(1, StrSubstNo('No. %1', MemberAccountsBalances."Member No."));
                    Window.Update(2, StrSubstNo('Name: %1', Member.FullName));
                    Window.Update(2, StrSubstNo('Product: %1', MemberAccountsBalances."Product Code"));
                    Window.UPDATE(3, StrSubstNo('%1%', Round((Current / All) * 100, 1)));
                    Window.UPDATE(4, FORMAT(Current) + ' of ' + FORMAT(All));
                    if ProductSetup.Get(MemberAccountsBalances."Product Code") then begin
                        ProductSetup.TestField(Prefix);
                        ProductSetup.TestField("Posting Group");
                        AccountNo := '';
                        AccountNo := ProductSetup.Prefix + MemberAccountsBalances."Member No." + ProductSetup.Suffix;
                        if ProductSetup."Product Posting Type" = ProductSetup."Product Posting Type"::"Junior Account" then begin
                            Vendor[1].Reset();
                            Vendor[1].SetRange("Member No.", MemberAccountsBalances."Member No.");
                            Vendor[1].SetRange("Product Posting Type", Vendor[1]."Product Posting Type"::"Junior Account");
                            if Vendor[1].FindLast then AccountNo := IncStr(Vendor[1]."No.");
                        end;
                        if not Vendor[1].Get(AccountNo) then begin
                            Vendor[2].Init();
                            Vendor[2]."No." := AccountNo;
                            Vendor[2]."Vendor Posting Group" := ProductSetup."Posting Group";
                            Vendor[2]."Member No." := MemberAccountsBalances."Member No.";
                            Vendor[2]."Member Name" := UpperCase(Member.FullName);
                            Vendor[2]."Account Type" := Vendor[1]."Account Type"::Sacco;
                            Vendor[2]."Product Code" := ProductSetup.Code;
                            Vendor[2]."Product Posting Type" := ProductSetup."Product Posting Type";
                            if ProductSetup."Product Posting Type" = ProductSetup."Product Posting Type"::"Junior Account" then begin
                                Vendor[2]."Member Name" := UpperCase(MemberAccountsBalances."Junior Account Name");
                                Vendor[2].Name := StrSubstNo('%1 : %2', UpperCase(ProductSetup.Description), UpperCase(MemberAccountsBalances."Junior Account Name"));
                            end
                            else begin
                                Vendor[2]."Member Name" := UpperCase(Member.FullName);
                                Vendor[2].Name := UpperCase(ProductSetup.Description);
                            end;
                            Vendor[2]."Business Account" := ProductSetup."Business Account";
                            Vendor[2]."Cash Deposit Allowed" := ProductSetup."Cash Deposit Allowed";
                            Vendor[2]."Cash Withdraw Allowed" := ProductSetup."Cash Withdraw Allowed";
                            Vendor[2]."Cash Transfer Allowed" := ProductSetup."Cash Transfer Allowed";
                            Vendor[2]."Cheque Book Allowed" := ProductSetup."Cheque Book Allowed";
                            Vendor[2].Status := Vendor[2].Status::Active;
                            Vendor[2].Insert(true);
                        end;
                        Commit;
                        DetailedVendorLedgEntry.Reset();
                        DetailedVendorLedgEntry.SetRange("Document No.", DocumentNo);
                        DetailedVendorLedgEntry.SetRange("Posting Date", PostingDate);
                        DetailedVendorLedgEntry.SetRange("Member No.", MemberAccountsBalances."Member No.");
                        DetailedVendorLedgEntry.SetRange("Vendor No.", AccountNo);
                        DetailedVendorLedgEntry.SetRange(Amount, -Round(MemberAccountsBalances.Amount));
                        if DetailedVendorLedgEntry.FindFirst() then begin
                            MemberAccountsBalances.Posted := True;
                            MemberAccountsBalances.Modify();
                        end
                        else begin
                            JournalBatch := 'OPENBAL';
                            JournalTemplate := 'GENERAL';
                            LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
                            PostingDescription := 'Opening Balance';
                            PostingAmount := 0;
                            PostingAmount := MemberAccountsBalances.Amount;
                            //Credit Member Account
                            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, '', '', MemberAccountsBalances."Member No.", DocumentNo, GlobalTransactionType::General, LineNo, '', '', '', '', 0, '', JournalTemplate, JournalBatch);
                            AccountNo := '';
                            AccountNo := GeneralLedgerSetup."Opening Balance Acc.";
                            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, PostingAmount, '', '', MemberAccountsBalances."Member No.", DocumentNo, GlobalTransactionType::General, LineNo, '', '', '', '', 0, '', JournalTemplate, JournalBatch);
                            Commit;
                            JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
                            DetailedVendorLedgEntry.Reset();
                            DetailedVendorLedgEntry.SetRange("Document No.", DocumentNo);
                            DetailedVendorLedgEntry.SetRange("Posting Date", PostingDate);
                            DetailedVendorLedgEntry.SetRange("Member No.", MemberAccountsBalances."Member No.");
                            DetailedVendorLedgEntry.SetRange("Vendor No.", AccountNo);
                            DetailedVendorLedgEntry.SetRange(Amount, -Round(MemberAccountsBalances.Amount));
                            if DetailedVendorLedgEntry.FindFirst() then begin
                                MemberAccountsBalances.Posted := True;
                                MemberAccountsBalances.Modify();
                            end;
                        end;
                    end;
                end;
            until MemberAccountsBalances.Next = 0;
        end;
        Window.Close;
    end;

    procedure CheckPosting()
    var
        MemberAccountsBalances: array[2] of Record "Member Accounts Balances";
        GeneralLedgerSetup: Record "General Ledger Setup";
        ProductSetup: Record "Sacco Products";
        AccountNo, DocumentNo : Code[20];
        PostingDate: Date;
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.TestField("Opening Balance Acc.");
        GeneralLedgerSetup.TestField("Opening Balance Posting Date");
        DocumentNo := 'OPENBAL';
        PostingDate := GeneralLedgerSetup."Opening Balance Posting Date";
        MemberAccountsBalances[1].Reset();
        if MemberAccountsBalances[1].FindSet then begin
            repeat
                MemberAccountsBalances[2].Reset();
                MemberAccountsBalances[2].SetRange("Member No.", MemberAccountsBalances[1]."Member No.");
                MemberAccountsBalances[2].SetRange("Product Code", MemberAccountsBalances[1]."Product Code");
                MemberAccountsBalances[2].SetRange(Amount, MemberAccountsBalances[1].Amount);
                if MemberAccountsBalances[2].FindFirst then begin
                    if ProductSetup.Get(MemberAccountsBalances[2]."Product Code") then begin
                        ProductSetup.TestField(Prefix);
                        ProductSetup.TestField("Posting Group");
                        AccountNo := '';
                        AccountNo := ProductSetup.Prefix + MemberAccountsBalances[2]."Member No." + ProductSetup.Suffix;
                        DetailedVendorLedgEntry.Reset();
                        DetailedVendorLedgEntry.SetRange("Document No.", DocumentNo);
                        DetailedVendorLedgEntry.SetRange("Posting Date", PostingDate);
                        DetailedVendorLedgEntry.SetRange("Member No.", MemberAccountsBalances[2]."Member No.");
                        DetailedVendorLedgEntry.SetRange("Vendor No.", AccountNo);
                        DetailedVendorLedgEntry.SetRange(Amount, -Round(MemberAccountsBalances[2].Amount));
                        if DetailedVendorLedgEntry.FindSet then begin
                            MemberAccountsBalances[2]."Already Posted" := true;
                            MemberAccountsBalances[2].Posted := true;
                            DetailedVendorLedgEntry.CalcSums(Amount);
                            MemberAccountsBalances[2]."Posted Amount" := DetailedVendorLedgEntry.Amount;
                            MemberAccountsBalances[2].Modify();
                        end;
                    end;
                end;
            until MemberAccountsBalances[1].Next = 0;
        end;
    end;

    procedure CheckPostedAmount()
    var
        MemberAccountsBalances: array[2] of Record "Member Accounts Balances";
        GeneralLedgerSetup: Record "General Ledger Setup";
        ProductSetup: Record "Sacco Products";
        AccountNo, DocumentNo : Code[20];
        PostingDate: Date;
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.TestField("Opening Balance Acc.");
        GeneralLedgerSetup.TestField("Opening Balance Posting Date");
        DocumentNo := 'OPENBAL';
        PostingDate := GeneralLedgerSetup."Opening Balance Posting Date";
        MemberAccountsBalances[1].Reset();
        MemberAccountsBalances[1].Setrange(Posted, false);
        if MemberAccountsBalances[1].FindSet then begin
            repeat
                if ProductSetup.Get(MemberAccountsBalances[1]."Product Code") then begin
                    ProductSetup.TestField(Prefix);
                    ProductSetup.TestField("Posting Group");
                    AccountNo := '';
                    AccountNo := ProductSetup.Prefix + MemberAccountsBalances[1]."Member No." + ProductSetup.Suffix;
                    DetailedVendorLedgEntry.Reset();
                    DetailedVendorLedgEntry.SetRange("Document No.", DocumentNo);
                    DetailedVendorLedgEntry.SetRange("Posting Date", PostingDate);
                    DetailedVendorLedgEntry.SetRange("Member No.", MemberAccountsBalances[1]."Member No.");
                    DetailedVendorLedgEntry.SetRange("Vendor No.", AccountNo);
                    DetailedVendorLedgEntry.SetRange(Amount, -Round(MemberAccountsBalances[1].Amount));
                    if DetailedVendorLedgEntry.FindSet then begin
                        DetailedVendorLedgEntry.CalcSums(Amount);
                        MemberAccountsBalances[1]."Posted Amount" := DetailedVendorLedgEntry.Amount;
                        // If MemberAccountsBalances[1].Amount = DetailedVendorLedgEntry.Amount then
                        //     MemberAccountsBalances[1].Posted := true;
                        MemberAccountsBalances[1].Modify();
                    end;
                end;
            until MemberAccountsBalances[1].Next = 0;
        end;
    end;

    procedure PostFinalExpenses(BenevolentFunds: Record "Benevolent Fund")
    var
        LineNo: Integer;
        PostingDescription: Text;
        DocumentNo, Dim1, Dim2, Dim3, Dim4, Dim5, Dim6, Dim7, Dim8, JournalTemplate, JournalBatch : Code[20];
        PostingDate: Date;
    begin
        JournalBatch := 'BENEVOLENT';
        JournalTemplate := 'SACCO';
        DocumentNo := BenevolentFunds."No.";
        LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
        PostingDate := BenevolentFunds."Posting Date";
        PostingDescription := BenevolentFunds."Posting Description";
        UserMgmtExt.GetUserDimensions(UserId, Dim1, Dim2);
        if PostingDescription = '' then PostingDescription := 'Payment For ' + Format(BenevolentFunds."Payment Type");
        if BenevolentFunds."Paying Account Type" = BenevolentFunds."Paying Account Type"::Payable then
            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, BenevolentFunds."Paying Account No", PostingDate, PostingDescription, BenevolentFunds."Payment Amount", Dim1, Dim2, BenevolentFunds."Member No.", DocumentNo, GlobalTransactionType::"Benevolent Fund", LineNo, '', '', BenevolentFunds."Member No.", '', 0, '', JournalTemplate, JournalBatch)
        else if BenevolentFunds."Paying Account Type" = BenevolentFunds."Paying Account Type"::"G/L Account" then
            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", BenevolentFunds."Paying Account No", PostingDate, PostingDescription, BenevolentFunds."Payment Amount", Dim1, Dim2, BenevolentFunds."Member No.", DocumentNo, GlobalTransactionType::"Benevolent Fund", LineNo, '', '', BenevolentFunds."Member No.", '', 0, '', JournalTemplate, JournalBatch)
        else if BenevolentFunds."Paying Account Type" = BenevolentFunds."Paying Account Type"::"Bank Account" then LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"Bank Account", BenevolentFunds."Paying Account No", PostingDate, PostingDescription, BenevolentFunds."Payment Amount", Dim1, Dim2, BenevolentFunds."Member No.", DocumentNo, GlobalTransactionType::"Benevolent Fund", LineNo, '', '', BenevolentFunds."Cheque Number", '', 0, '', JournalTemplate, JournalBatch);
        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, BenevolentFunds."FOSA Account", PostingDate, PostingDescription, -1 * BenevolentFunds."Payment Amount", Dim1, Dim2, BenevolentFunds."Member No.", DocumentNo, GlobalTransactionType::"Benevolent Fund", LineNo, '', '', BenevolentFunds."Member No.", '', 0, '', JournalTemplate, JournalBatch);
        JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
        BenevolentFunds.Processed := true;
        BenevolentFunds."Processed On" := CurrentDateTime;
        BenevolentFunds.Modify();
    end;

    procedure MemberWithdrawalNotifications()
    var
        MemberWithdrawal: Record "Member Withdrawal";
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
        SMSSource := 'Withdrawal';
        MemberWithdrawal.Reset;
        MemberWithdrawal.SetRange(Instant, false);
        MemberWithdrawal.SetRange(Status, MemberWithdrawal.Status::Approved);
        MemberWithdrawal.Setfilter("Maturity Date", '<=%1', WorkDate);
        MemberWithdrawal.SetRange(Posted, false);
        if MemberWithdrawal.FindSet then begin
            UserSetup.Reset;
            UserSetup.SetRange("Finance Admin", true);
            if UserSetup.FindSet then begin
                repeat
                    if Employee.Get(UserSetup."Employee No.") then begin
                        SMSPhone := Employee."Phone No.";
                        SMSText := StrSubstNo('Dear %1, You have %2 Member Withdrawals that are mature for posting', Employee."First Name", MemberWithdrawal.Count);
                        SMS.SendSms(SMSPhone, SMSText, SMSSource);
                        Recipients.Add(Employee."Company E-Mail");
                        Subject := 'Member Withdrawal';
                        Body := 'Dear ' + Employee."First Name";
                        Body := '<br></br>';
                        Body := StrSubstNo('You have %1 Member Withdrawals that are mature for posting', MemberWithdrawal.Count);
                        CommunicationMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
                    end;
                until UserSetup.Next = 0;
            end;
        end;
    end;

    procedure MemberBirthdayNotification()
    var
        CommunicationMgmt: Codeunit "Communications Mgmt";
        SMS: Codeunit "Notifications Management";
        CompanyInfo: Record "Company Information";
        SMSPhone, SMSText : Text[250];
        Recipients: List of [Text];
        Body: Text;
        Subject: Text;
        SMSSource: Code[20];
    begin
        Clear(Recipients);
        Clear(Subject);
        Clear(Body);
        Clear(SMSPhone);
        Clear(SMSText);
        SMSSource := 'Birthday';
        CompanyInfo.Get;
        Member.Reset();
        Member.Setfilter(Status, '%1|%2|%3', Member.Status::"Not Paid Up", Member.Status::Dormant, Member.Status::Active);
        Member.SetFilter("Date of Birth", '<>%1', 0D);
        Member.Setrange("Marketing Texts", true);
        if Member.FindSet then begin
            if ((Date2DMY(Member."Date of Birth", 1) = Date2DMY(WorkDate, 1)) and (Date2DMY(Member."Date of Birth", 2) = Date2DMY(WorkDate, 2))) then begin
                SMSPhone := Member."Mobile Phone No.";
                SMSText := StrSubstNo('Dear %1, %2 wishes you growth, happiness and endless wins as you start another year. Happy Birthday', Member."First Name", CompanyInfo.Name);
                SMS.SendSms(SMSPhone, SMSText, SMSSource);
                Recipients.Add(Member."E-Mail");
                Subject := 'Birthday';
                Body := '<!DOCTYPE html>';
                Body += '<html lang="en"><head><meta charset="utf-8"/><meta name="viewport" content="width=device-width,initial-scale=1.0"/></head>';
                Body += '<body style="font-family:Arial, sans-serif; margin:0; padding:0;">';
                Body += '<table width="100%"><tr><td align="center">';
                Body += '<table width="600" style="max-width:600px;"><tr><td style="padding:24px; text-align:left;">';
                Body += StrSubstNo('<h2 style="margin:0 0 12px 0; color:#333333;">Dear %1,</h2>', Member."First Name");
                Body += StrSubstNo('<p style="margin:0 0 12px 0; color:#555555; font-size:16px;">%1 wishes you growth, happiness &amp; endless wins as you start another year.</p>', CompanyInfo.Name);
                Body += '<p style="margin:0 0 12px 0; font-size:18px; color:#000000; font-weight:bold;">Happy Birthday!</p>';
                Body += '<hr style="border:none; border-top:1px solid #EEEEEE; margin:20px 0;" />';
                Body += StrSubstNo('<p style="margin:0; color:#999999; font-size:12px;">Best regards,<br/>%1</p>', CompanyInfo.Name);
                Body += '</td></tr></table>';
                Body += '</td></tr></table>';
                Body += '</body></html>';
                CommunicationMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
            end;
        end;
    end;


    procedure LogView(MemberNo: Code[20]; SourcePage: Text[50]; Reason: Text[100])
    var
        ViewLog: Record "Member View Logs";
        ActiveSession: Record "Active Session";
        CurrentSessionId: Integer;
    begin
        CurrentSessionId := SessionId();
        ViewLog.Init();
        ViewLog.Validate("Member No.", MemberNo);
        ViewLog.Reason := Reason;
        ViewLog."Viewed By" := CopyStr(UserId(), 1, MaxStrLen(ViewLog."Viewed By"));
        ViewLog."Viewed At" := CurrentDateTime();
        ViewLog."Source Page" := SourcePage;
        ViewLog."Session ID" := CurrentSessionId;
        ViewLog."Client Type" := Format(CurrentClientType());

        ActiveSession.SetRange("Server Instance ID", ServiceInstanceId());
        ActiveSession.SetRange("Session ID", CurrentSessionId);
        //if ActiveSession.FindFirst() then
        // ViewLog."Client Computer Name" := ActiveSession."Client Computer Name";

        ViewLog.Insert(true);
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeCreateMember(var MemberApplication: Record "Member Application")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterCreateMember(var MemberApplication: Record "Member Application"; Member: Record Members)
    begin
    end;


    [IntegrationEvent(false, false)]
    procedure OnAfterPostATMLinking(ATMApplication: Record "ATM Application")
    begin
    end;
}
