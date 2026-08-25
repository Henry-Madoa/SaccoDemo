codeunit 52204021 "CBS Cash Management"
{
    var
        SaccoSetup: Record "General Ledger Setup";
        GLEntry: Record "G/L Entry";
        GlobalTransactionType: Enum "Sacco Transaction Type";
        GlobalAccountType: Enum "Gen. Journal Account Type";
        AppliesToDocType: Enum "Gen. Journal Document Type";
        JournalManagement: Codeunit "Journal Management";



    [IntegrationEvent(false, false)]
    procedure OnBeforePostPaymentVoucher(var PaymentVoucher: Record "Payment Voucher")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterPostPaymentVoucher(PVNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforePostCashReceipt(var Receipt: Record "Receipt Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterPostReceipt(var Receipt: Record "Receipt Header")
    begin
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CBS Cash Management", 'OnBeforePostCashReceipt', '', true, true)]
    local procedure OnBefore_Post_CashReceipt(var Receipt: Record "Receipt Header")
    begin
        GLEntry.Reset;
        GLEntry.SetRange(GLEntry."Document No.", Receipt."No.");
        GLEntry.SetRange(GLEntry.Reversed, false);
        if GLEntry.FindFirst then begin
            OnAfterPostReceipt(Receipt);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CBS Cash Management", 'OnAfterPostReceipt', '', true, true)]
    local procedure AfterPostingReceipt(var Receipt: Record "Receipt Header")
    begin
        Receipt."Posted Date" := WorkDate;
        Receipt.Posted := true;
        Receipt.Modify(true);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CBS Cash Management", 'OnBeforePostPaymentVoucher', '', true, true)]
    local procedure OnBefore_PostPaymentVoucher(var PaymentVoucher: Record "Payment Voucher")
    begin
        GLEntry.Reset;
        GLEntry.SetRange(GLEntry."Document No.", PaymentVoucher."No.");
        GLEntry.SetRange(GLEntry.Reversed, false);
        if GLEntry.FindFirst then begin
            OnAfterPostPaymentVoucher(PaymentVoucher."No.");
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CBS Cash Management", 'OnAfterPostPaymentVoucher', '', true, true)]
    procedure OnAfter_PostPaymentVoucher(PVNo: Code[20])
    var
        PaymentVoucher: Record "Payment Voucher";
        CommunicationMgmt: Codeunit "Communications Mgmt";
        SMSSource: Code[20];
        PhoneNo: Text[250];
        SMS: Text[250];
        Members: Record Members;
        NotificationsMgt: Codeunit "Notifications Management";
    begin
        if PaymentVoucher.Get(PVNo) then begin
            PaymentVoucher.Validate(Posted, true);
            PaymentVoucher."Posted By" := UserId;
            PaymentVoucher."Posted Date" := WorkDate;
            PaymentVoucher."Time Posted" := Time;
            PaymentVoucher.Modify(true);
            PaymentVoucher.CalcFields("Total Amount");
            if PaymentVoucher."Payment Type" in [PaymentVoucher."Payment Type"::"Staff Bulk Payment"] then CommunicationMgmt.NotificationOnPaymentVoucherDisbursement(PaymentVoucher);
            if PaymentVoucher."Payment Type" in [PaymentVoucher."Payment Type"::"RTGS/SWIFT"] then begin
                SMSSource := 'EFT/RTGS';
                if Members.Get(PaymentVoucher."Member No") then begin
                    SMS := StrSubstNo('Dear %1, We’ve Processed an EFT Debit of KES %2 into your FOSA account', Members."First Name", PaymentVoucher."Total Amount");
                    if PhoneNo <> '' then begin
                        PhoneNo := Members."Mobile Phone No.";
                        NotificationsMgt.SendSms(PhoneNo, SMS, SMSSource);
                    end
                end;
            end;
        end;
    end;

    procedure PostReceipt(var Receipt: Record "Receipt Header")
    var
        ReceiptLines: Record "Receipt Lines";
        LoansMgt: Codeunit "Loans Management";
        MembersMgt: Codeunit "Member Management";
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        DocumentNo, SourceCode, ReasonCode, MemberNo, JournalBatch, JournalTemplate, ExternalDocumentNo, AccountNo : Code[20];
        LineNo: Integer;
        PostingDate: date;
        JournalManagement: Codeunit "Journal Management";
        PostingDescription: Text[100];
        Dim1, Dim2 : Code[20];
        PostingAmount, PenaltyBalance, InterestBalance, PrincipalBalance, PenaltyPaid, InterestPaid, PrincipalPaid, BaseAmount, ChargeAmount, UnallocatedAmount : Decimal;
        Loans: Record Loans;
        SaccoSetup: Record "General Ledger Setup";
        LoanProduct: Record "Sacco Products";
        ProductPostingType: Enum "Product Posting Type";
    begin
        SaccoSetup.Get;
        SaccoSetup.TestField("Receipt Template");
        SaccoSetup.TestField("Receipt Batch");

        JournalTemplate := SaccoSetup."Receipt Template";
        JournalBatch := SaccoSetup."Receipt Batch";
        Receipt.OnBeforeSendForApproval;
        OnBeforePostCashReceipt(Receipt);
        Receipt.CalcFields(Amount);
        Receipt.Testfield("Posting Date");
        Dim1 := Receipt."Global Dimension 1 Code";
        Dim2 := Receipt."Global Dimension 2 Code";
        LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
        PostingDescription := Receipt.Description;
        AccountNo := Receipt."Bank Account";
        PostingDate := Receipt."Posting Date";
        DocumentNo := Receipt."No.";
        PostingAmount := 0;
        PostingAmount := Receipt.Amount;
        MemberNo := Receipt."Member No.";
        If Receipt."Receipt Type" = Receipt."Receipt Type"::Member then
            PostingDescription := StrSubstNo('%1 : %2', Receipt."Pay Mode", Receipt."Member Name")
        else
            PostingDescription := Receipt.Description;
        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"Bank Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::General, LineNo, '', '', DocumentNo, '', 0, '', JournalTemplate, JournalBatch);

        ReceiptLines.Reset();
        ReceiptLines.SetRange("No.", Receipt."No.");
        if ReceiptLines.FindSet() then begin
            repeat
                PostingAmount := 0;
                PostingAmount := ReceiptLines.Amount;
                MemberNo := '';
                PostingDescription := Format(ReceiptLines."Transaction Type");
                MemberNo := ReceiptLines."Member No.";
                case ReceiptLines."Receipt Type" of
                    ReceiptLines."Receipt Type"::Customer:
                        begin
                            PostingDescription := StrSubstNo('%1 : %2', Receipt."Pay Mode", Receipt.Description);
                            AccountNo := ReceiptLines."Account No";
                            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Customer, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Cash Deposit", LineNo, '', '', DocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                        end;
                    ReceiptLines."Receipt Type"::Bank:
                        begin
                            PostingDescription := StrSubstNo('%1 : %2', Receipt."Pay Mode", Receipt.Description);
                            AccountNo := ReceiptLines."Account No";
                            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"Bank Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Cash Deposit", LineNo, '', '', DocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                        end;
                    ReceiptLines."Receipt Type"::Member:
                        begin
                            if Loans.Get(ReceiptLines."Loan No.") then begin

                                if SaccoSetup."Daily Interest Accrual" then
                                    LoansMgt.PostLoanInterest(Receipt."Posting Date", '', 0, ReceiptLines."Member No.", ReceiptLines."Loan No.");

                                Loans.CalcFields("Loan Balance", "Penalty Balance", "Interest Balance", "Principal Balance");
                                ReasonCode := Loans."No.";
                                SourceCode := Loans."Product Code";

                                ExternalDocumentNo := DocumentNo;
                                LoanProduct.Get(Loans."Product Code");
                                AccountNo := '';
                                AccountNo := Loans."Loan Account";
                                MemberNo := Loans."Member No.";

                                BaseAmount := 0;
                                PenaltyBalance := 0;
                                PenaltyPaid := 0;
                                InterestBalance := 0;
                                InterestPaid := 0;
                                PrincipalBalance := 0;
                                PrincipalPaid := 0;
                                ChargeAmount := 0;
                                UnAllocatedAmount := 0;

                                ChargeAmount := ReceiptLines."Charge Amount";
                                BaseAmount := ReceiptLines.Amount - ChargeAmount;
                                PenaltyBalance := ReceiptLines."Penalty Balance";
                                InterestBalance := ReceiptLines."Interest Balance";
                                Principalbalance := ReceiptLines."Principal Balance";

                                if BaseAmount > PenaltyBalance then begin
                                    PenaltyPaid := PenaltyBalance;
                                    BaseAmount -= PenaltyPaid;
                                end
                                else begin
                                    PenaltyPaid := BaseAmount;
                                    BaseAmount := 0;
                                end;

                                if BaseAmount > InterestBalance then begin
                                    InterestPaid := InterestBalance;
                                    BaseAmount -= InterestPaid;
                                end
                                else begin
                                    InterestPaid := BaseAmount;
                                    BaseAmount := 0;
                                end;

                                if BaseAmount > PrincipalBalance then begin
                                    PrincipalPaid := PrincipalBalance;
                                    BaseAmount -= PrincipalPaid;
                                end
                                else begin
                                    PrincipalPaid := BaseAmount;
                                    BaseAmount := 0;
                                end;

                                if BaseAmount <> 0 then
                                    UnAllocatedAmount := BaseAmount;

                                AccountNo := Loans."Loan Account";
                                //Penalty Paid
                                PostingAmount := 0;
                                PostingAmount := PenaltyPaid;
                                PostingDescription := StrSubstNo('%1 : %2 : Penalty Paid %3', Receipt."Pay Mode", Receipt.Description, ReasonCode);
                                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Penalty Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);

                                //Pay Interest
                                PostingDescription := StrSubstNo('%1 : %2 : Interest Paid %3', Receipt."Pay Mode", Receipt.Description, ReasonCode);
                                PostingAmount := 0;
                                PostingAmount := InterestPaid;
                                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                SaccoSetup.Get();
                                if SaccoSetup."Interest Accrual Type" = SaccoSetup."Interest Accrual Type"::"Cash Basis" then begin
                                    LoanProduct.Get(Loans."Product Code");
                                    AccountNo := LoanProduct."Interest Paid Account";
                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                    AccountNo := LoanProduct."Interest Due Account";
                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                end;

                                //Pay Principal
                                PostingDescription := StrSubstNo('%1 : %2 : Principal Paid %3', Receipt."Pay Mode", Receipt.Description, ReasonCode);
                                AccountNo := Loans."Loan Account";
                                PostingAmount := 0;
                                PostingAmount := PrincipalPaid;
                                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Principal Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);

                                if UnallocatedAmount <> 0 then begin
                                    PostingDescription := StrSubstNo('%1 : %2 : Unallocated.', Receipt."Pay Mode", Receipt.Description);
                                    AccountNo := MembersMgt.GetMemberAccount(MemberNo, ProductPostingType::"School Fee Account");
                                    PostingAmount := 0;
                                    PostingAmount := UnallocatedAmount;
                                    LineNo := JournalManagement.CreateUnallocationJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Cash Deposit", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, JournalTemplate, JournalBatch);
                                end;

                                //Add Charge
                                AccountNo := '';
                                PostingAmount := 0;
                                PostingAmount := ReceiptLines.Amount;
                                LineNo := JournalManagement.AddCharges(ReceiptLines."Charge Code", AccountNo, PostingAmount, LineNo, DocumentNo, MemberNo, SourceCode, ReasonCode, ExternalDocumentNo, JournalBatch, JournalTemplate, Dim1, Dim2, PostingDate, false);
                            end
                            else begin
                                PostingDescription := Receipt.Description;
                                AccountNo := ReceiptLines."Account No";
                                MemberNo := Receipt."Member No.";
                                ExternalDocumentNo := DocumentNo;
                                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Cash Deposit", LineNo, '', '', DocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                            end;
                        end;
                    ReceiptLines."Receipt Type"::"G/L Account":
                        begin
                            PostingDescription := StrSubstNo('%1 : %2', Receipt."Pay Mode", Receipt.Description);
                            AccountNo := ReceiptLines."Account No";
                            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::General, LineNo, '', '', DocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                        end;
                    ReceiptLines."Receipt Type"::Vendor:
                        begin
                            PostingDescription := StrSubstNo('%1 : %2', Receipt."Pay Mode", Receipt.Description);
                            AccountNo := ReceiptLines."Account No";
                            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::General, LineNo, '', '', DocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                        end;
                    ReceiptLines."Receipt Type"::Employee:
                        begin
                            PostingDescription := StrSubstNo('%1 : %2', Receipt."Pay Mode", Receipt.Description);
                            AccountNo := ReceiptLines."Account No";
                            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Employee, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::General, LineNo, '', '', DocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                        end;
                end;
            until ReceiptLines.Next = 0;
        end;
        JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
        GLEntry.Reset();
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("Document Date", PostingDate);
        if GLEntry.FindFirst() then OnAfterPostReceipt(Receipt);
    end;

    procedure GenerateEFTPaymentLines(PVHeader: Record "Payment Voucher")
    var
        UnclearedEffect: Record "Uncleared Funds";
        PVLines: Record "Payment Voucher Lines";
        CreatedOn_Min: DateTime;
        CreatedOn_Max: DateTime;
        Time_Min: Time;
        Time_Max: Time;
        LineNo: Integer;
        LineCount: Integer;
    begin
        PVHeader.TestField("Clearing Date");
        if Confirm(StrSubstNo('You are about to generate EFT for %1, Do you wish to continue?', PVHeader."No."), true) then begin
            PVLines.Reset();
            PVLines.SetRange("No.", PVHeader."No.");
            PVLines.DeleteAll(true);
            LineNo := 10000;
            LineCount := 0;
            Time_Min := 000000.000T;
            Time_Max := 235959.999T;
            CreatedOn_Min := CreateDateTime(PVHeader."Clearing Date", Time_Min);
            CreatedOn_Max := CreateDateTime(PVHeader."Clearing Date", Time_Max);
            UnclearedEffect.Reset();
            UnclearedEffect.SetRange(Cleared, false);
            UnclearedEffect.SetFilter(SystemCreatedAt, '%1..%2', CreatedOn_Min, CreatedOn_Max);
            if UnclearedEffect.FindSet() then begin
                repeat
                    LineNo := LineNo + 1000;
                    if InsertMemberEFTPaymentLine(PVHeader, UnclearedEffect, LineNo) then LineCount += 1;
                until UnclearedEffect.Next = 0;
                Message(StrSubstNo('%1 Lines Generated', Format(LineCount)));
            end;
        end;
    end;

    local procedure InsertMemberEFTPaymentLine(PVHeader: Record "Payment Voucher"; UnclearedEffect: Record "Uncleared Funds"; LineNo: Integer) Inserted: Boolean
    var
        PVLines: array[3] of Record "Payment Voucher Lines";
        Loans: Record Loans;
    begin
        if Loans.Get(UnclearedEffect."Document No") then begin
            PVLines[1].Init;
            PVLines[1].Validate("No.", PVHeader."No.");
            PVLines[1]."Line No" := LineNo;
            PVLines[1]."Uncleared Funds Entry No." := UnclearedEffect."Entry No";
            PVLines[1]."Member No." := UnclearedEffect."Member No";
            PVLines[1].Validate("Account No", UnclearedEffect."Account No");
            PVLines[1].Validate("Account Name", Loans."Member Name");
            PVLines[1].Validate("Payee Bank Code", Loans."Pay to Bank Code");
            PVLines[1].Validate("Payee Bank Branch Code", Loans."Pay to Branch Code");
            PVLines[1].Validate("Payee Account No.", Loans."Pay to Account No");
            PVLines[1].Payee := Loans."Member Name";
            PVLines[1]."Payee Account Name" := Loans."Member Name";
            PVLines[1].Validate(Amount, UnclearedEffect.Amount);
            PVLines[2].Reset();
            PVLines[2].SetRange("Member No.", UnclearedEffect."Member No");
            PVLines[2].SetRange("Uncleared Funds Entry No.", UnclearedEffect."Entry No");
            if not PVLines[2].FindFirst() then begin
                PVLines[1].Insert;
                Inserted := true;
            end;
        end;
    end;

    local procedure TotalPaymentEFTLineCharges(PVEFTCharges: Record "PV EFT Charges") TotalLineCharge: Decimal
    var
        PVLines: Record "Payment Voucher Lines";
        LineCount: Integer;
    begin
        If PVEFTCharges.Amount <> 0 then begin
            PVLines.Reset();
            PVLines.SetRange("No.", PVEFTCharges."No.");
            PVLines.SetFilter(Amount, '<>%1', 0);
            PVLines.SetRange("Payment Type", PVLines."Payment Type"::"EFT Loan Payment");
            if PVLines.FindSet() then begin
                LineCount := PVLines.Count;
                TotalLineCharge := Round((PVEFTCharges.Amount * LineCount), 1);
            end;
        end;
    end;

    local procedure TotalPaymentEFTCharges(PVHeader: Record "Payment Voucher") TotalCharge: Decimal
    var
        PVLines: Record "Payment Voucher Lines";
        LineCount: Integer;
    begin
        PVHeader.CalcFields("EFT Charges");
        PVLines.Reset();
        PVLines.SetRange("No.", PVHeader."No.");
        PVLines.SetFilter(Amount, '<>%1', 0);
        PVLines.SetRange("Payment Type", PVLines."Payment Type"::"EFT Loan Payment");
        if PVLines.FindSet() then begin
            LineCount := PVLines.Count;
            TotalCharge := Round((PVHeader."EFT Charges" * LineCount), 1);
        end;
    end;

    procedure PostPaymentVoucher(PaymentVoucher: Record "Payment Voucher")
    var
        PaymentVoucherLines: Record "Payment Voucher Lines";
        GenJnLine: Record "Gen. Journal Line";
        JournalBatch, JournalTemplate, DocumentNo, AccountNo, Dim1, Dim2, Dim3, Dim4, Dim5, Dim6, Dim7, Dim8, MemberNo, SourceCode, ReasonCode, ExternalDocumentNo, CurrencyCode, AppliesToDocNo : Code[20];
        PostingDate: Date;
        PostingDescription: Text[100];
        PostingAmount: Decimal;
        LineNo: Integer;
        VATProductPostingGroup: Record "VAT Product Posting Group";
        VATSetup: Record "VAT Posting Setup";
        GLAccount: Record "G/L Account";
        Customer: Record Customer;
        Vendor: Record Vendor;
        GLEntry: Record "G/L Entry";
        PaymentMethod: Record "Payment Method";
        PaymentSchedule: Record "Payment Schedule";
        Employee: Record Employee;
        BoardAllowancesSetup: Record "Allowances Setup";
        UnclearedEffects: Record "Uncleared Funds";
        PVEFTCharges: Record "PV EFT Charges";
        AvailableBal: Decimal;
        SaccoProduct: Record "Sacco Products";
        ChannelsIntegrations: Codeunit "Channels Integrations";
    begin
        if PaymentVoucher.Status <> PaymentVoucher.Status::Approved then
            Error('The Payment Voucher No %1 has not been fully approved', PaymentVoucher."No.");
        if PaymentVoucher.Posted then
            Error('Payment Voucher %1 have been already paid via EFT', PaymentVoucher."No.");
        if not Confirm(StrSubstNo('Are you sure you want to post the Payment Voucher No. %1?', PaymentVoucher."No."), false)
        then
            exit;
        If PaymentVoucher."Payment Type" = PaymentVoucher."Payment Type"::"EFT Loan Payment" then
            PaymentVoucher.TestField("EFT Charges");

        PaymentVoucher.TestField("Pay Mode");
        PaymentVoucher.TestField(Date);
        PaymentMethod.Get(PaymentVoucher."Pay Mode");
        if PaymentMethod.Type = PaymentMethod.Type::Cheque then begin
            PaymentVoucher.TestField(PaymentVoucher."Cheque Number");
            PaymentVoucher.TestField(PaymentVoucher."Cheque Date");
            if PaymentVoucher."Cheque Date" > WorkDate then
                Error('You cannot use a future date as Cheque Number');
        end
        else if PaymentMethod.Type <> PaymentMethod.Type::FOSA then
            PaymentVoucher.TestField("Paying Bank Account");
        //Check Lines
        PaymentVoucher.CalcFields("Total Amount");
        if PaymentVoucher."Total Amount" = 0 then
            Error('Amount is cannot be zero');
        PaymentVoucherLines.Reset;
        PaymentVoucherLines.SetRange(PaymentVoucherLines."No.", PaymentVoucher."No.");
        if not PaymentVoucherLines.FindLast then
            Error('Payment voucher Lines cannot be empty');

        OnBeforePostPaymentVoucher(PaymentVoucher);

        SaccoSetup.Get();
        SaccoSetup.TestField("Payment Voucher Template");
        SaccoSetup.TestField("Payment Voucher Batch");
        JournalBatch := SaccoSetup."Payment Voucher Batch";
        JournalTemplate := SaccoSetup."Payment Voucher Template";
        PostingDate := WorkDate;
        DocumentNo := PaymentVoucher."No.";
        CurrencyCode := PaymentVoucher.Currency;
        PostingDescription := CopyStr(PaymentVoucher.Description, 1, 50);
        LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
        if PaymentVoucher."Payment Type" in [PaymentVoucher."Payment Type"::"Payroll Settlement", PaymentVoucher."Payment Type"::"Board Allowances", PaymentVoucher."Payment Type"::"Staff Bulk Payment"] then begin
            PaymentSchedule.Reset;
            PaymentSchedule.SetFilter(Amount, '<>%1', 0);
            PaymentSchedule.SetRange("PV No.", PaymentVoucher."No.");
            if PaymentSchedule.FindSet() then
                repeat begin
                    AccountNo := '';
                    AccountNo := PaymentSchedule."FOSA Account";
                    MemberNo := Employee."Member No.";
                    Dim1 := Employee."Global Dimension 1 Code";
                    Dim2 := Employee."Global Dimension 2 Code";
                    if PaymentVoucher."Payment Type" = PaymentVoucher."Payment Type"::"Board Allowances" then
                        PostingAmount := -PaymentSchedule."Net Allowance Amount"
                    else
                        PostingAmount := -PaymentSchedule.Amount;
                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::General, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, CurrencyCode, 0, '', JournalTemplate, JournalBatch);
                    if PaymentVoucher."Payment Type" = PaymentVoucher."Payment Type"::"Board Allowances" then begin
                        BoardAllowancesSetup.Get(PaymentSchedule."Allowance Code", Employee."Board Category");
                        BoardAllowancesSetup.TestField("GL Account No.");
                        VATSetup.Get('', PaymentSchedule."Tax Code");
                        AccountNo := '';
                        AccountNo := VATSetup."Purchase VAT Account";
                        MemberNo := Employee."Member No.";
                        Dim1 := Employee."Global Dimension 1 Code";
                        Dim2 := Employee."Global Dimension 2 Code";
                        PostingAmount := -PaymentSchedule."Tax Amount";
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::General, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, CurrencyCode, 0, '', JournalTemplate, JournalBatch);
                    end;
                end;
                until PaymentSchedule.Next = 0;
        end
        else if PaymentVoucher."Payment Type" = PaymentVoucher."Payment Type"::"EFT Loan Payment" then begin
            PaymentVoucher.CalcFields("EFT Charges");
            PVEFTCharges.Reset();
            PVEFTCharges.SetRange("No.", PaymentVoucher."No.");
            PVEFTCharges.SetRange(Posted, false);
            if PVEFTCharges.FindSet() then begin
                repeat
                    AccountNo := '';
                    AccountNo := PVEFTCharges."GL Account";
                    Dim1 := PaymentVoucher."Global Dimension 1 Code";
                    Dim2 := PaymentVoucher."Global Dimension 2 Code";
                    PostingAmount := -(TotalPaymentEFTLineCharges(PVEFTCharges));
                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::General, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, CurrencyCode, 0, '', JournalTemplate, JournalBatch);
                    PVEFTCharges.Posted := true;
                    PVEFTCharges.Modify(true);
                until PVEFTCharges.Next = 0;
            end;
            AccountNo := '';
            AccountNo := PaymentVoucher."Paying Bank Account";
            Dim1 := PaymentVoucher."Global Dimension 1 Code";
            Dim2 := PaymentVoucher."Global Dimension 2 Code";
            PostingAmount := -(PaymentVoucher."Total Amount" - (TotalPaymentEFTCharges(PaymentVoucher)));
            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"Bank Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::General, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, CurrencyCode, 0, '', JournalTemplate, JournalBatch);
        end
        else begin
            AccountNo := '';
            AccountNo := PaymentVoucher."Paying Bank Account";
            Dim1 := PaymentVoucher."Global Dimension 1 Code";
            Dim2 := PaymentVoucher."Global Dimension 2 Code";
            PostingAmount := -PaymentVoucher."Total Amount";
            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"Bank Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::General, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, CurrencyCode, 0, '', JournalTemplate, JournalBatch);
        end;
        //PV Lines Entries
        PaymentVoucherLines.Reset;
        PaymentVoucherLines.SetRange(PaymentVoucherLines."No.", PaymentVoucher."No.");
        if PaymentVoucherLines.FindFirst then
            repeat begin

                if Vendor.Get(PaymentVoucherLines."Account No") then begin
                    if Vendor."Account Type" = Vendor."Account Type"::Sacco then begin
                        Vendor.CalcFields(Balance, "Uncleared Funds");
                        SaccoProduct.Get(Vendor."Product Code");
                        if Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Withdrawable Deposit" then
                            AvailableBal := Vendor.Balance - Vendor."Uncleared Funds" - SaccoProduct."Minimum Balance" - ChannelsIntegrations.GetPendingChannelsTransactions(Vendor."Member No.")
                        else
                            AvailableBal := Vendor.Balance - Vendor."Uncleared Funds" - SaccoProduct."Minimum Balance";

                        if PaymentVoucherLines."Net Amount" > AvailableBal then
                            Error(StrSubstNo('You cannot overdraw Account, The Available Balance is %1', Format(AvailableBal)));
                    end;
                end;

                Dim1 := PaymentVoucher."Global Dimension 1 Code";
                Dim2 := PaymentVoucher."Global Dimension 2 Code";
                ReasonCode := PaymentVoucherLines."Loan No.";
                MemberNo := PaymentVoucherLines."Member No.";
                AppliesToDocNo := PaymentVoucherLines."Applies to Doc. No";
                AppliesToDocType := AppliesToDocType::Payment;
                PaymentVoucherLines.Validate(PaymentVoucherLines.Amount);
                AccountNo := '';
                AccountNo := PaymentVoucherLines."Account No";
                PostingAmount := PaymentVoucherLines."Net Amount";
                GlobalAccountType := PaymentVoucherLines."Account Type";
                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Cash Withdrawal", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, CurrencyCode, AppliesToDocType, AppliesToDocNo, JournalTemplate, JournalBatch);
                if PaymentVoucher."Charge Code" <> '' then begin
                    LineNo := JournalManagement.AddCharges(PaymentVoucher."Charge Code", AccountNo, PostingAmount, LineNo, DocumentNo, MemberNo, SourceCode, ReasonCode, ExternalDocumentNo, JournalBatch, JournalTemplate, Dim1, Dim2, PostingDate, true);
                end;
                if SaccoSetup."Post VAT" then begin
                    if ((PaymentVoucherLines."VAT Code" <> '') and (PaymentVoucherLines."VAT Amount" <> 0)) then begin
                        PaymentVoucherLines.Validate(PaymentVoucherLines.Amount);
                        AccountNo := '';
                        GlobalAccountType := PaymentVoucherLines."Account Type";
                        AccountNo := PaymentVoucherLines."Account No";
                        PostingAmount := PaymentVoucherLines."VAT Amount";
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::General, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, CurrencyCode, AppliesToDocType, AppliesToDocNo, JournalTemplate, JournalBatch);
                        GlobalAccountType := GlobalAccountType::"G/L Account";
                        AccountNo := '';
                        AccountNo := GetVATAccounNo(PaymentVoucherLines, PaymentVoucherLines."VAT Code");
                        PostingDescription := PaymentVoucherLines."Account Name";
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::General, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, CurrencyCode, AppliesToDocType, AppliesToDocNo, JournalTemplate, JournalBatch);
                    end;
                end;
                if ((PaymentVoucherLines."WHT Code One" <> '') and (PaymentVoucherLines."WHT Amount One" <> 0)) then begin
                    VATProductPostingGroup.Get(PaymentVoucherLines."WHT Code One");
                    AccountNo := '';
                    GlobalAccountType := PaymentVoucherLines."Account Type";
                    AccountNo := PaymentVoucherLines."Account No";
                    PostingAmount := PaymentVoucherLines."WHT Amount One";
                    PostingDescription := VATProductPostingGroup.Description;
                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::General, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, CurrencyCode, AppliesToDocType, AppliesToDocNo, JournalTemplate, JournalBatch);
                    GlobalAccountType := GlobalAccountType::"G/L Account";
                    AccountNo := '';
                    AccountNo := GetVATAccounNo(PaymentVoucherLines, PaymentVoucherLines."WHT Code One");
                    PostingDescription := PaymentVoucherLines."Account Name";
                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::General, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, CurrencyCode, AppliesToDocType, AppliesToDocNo, JournalTemplate, JournalBatch);
                end;
                if ((PaymentVoucherLines."WHT Code Two" <> '') and (PaymentVoucherLines."WHT Amount Two" <> 0)) then begin
                    VATProductPostingGroup.Get(PaymentVoucherLines."WHT Code Two");
                    AccountNo := '';
                    GlobalAccountType := PaymentVoucherLines."Account Type";
                    AccountNo := PaymentVoucherLines."Account No";
                    PostingAmount := PaymentVoucherLines."WHT Amount Two";
                    PostingDescription := VATProductPostingGroup.Description;
                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::General, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, CurrencyCode, AppliesToDocType, AppliesToDocNo, JournalTemplate, JournalBatch);
                    GlobalAccountType := GlobalAccountType::"G/L Account";
                    AccountNo := '';
                    AccountNo := GetVATAccounNo(PaymentVoucherLines, PaymentVoucherLines."WHT Code Two");
                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::General, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, CurrencyCode, AppliesToDocType, AppliesToDocNo, JournalTemplate, JournalBatch);
                end;
            end;
            if UnclearedEffects.Get(PaymentVoucherLines."Uncleared Funds Entry No.") then begin
                UnclearedEffects.Cleared := true;
                UnclearedEffects.Modify(true);
            end;
            if UnclearedEffects.Get(PaymentVoucherLines."Uncleared Funds Entry No.") then begin
                UnclearedEffects.Cleared := true;
                UnclearedEffects.Modify(true);
            end;
            until PaymentVoucherLines.Next = 0;
        JournalManagement.CompletePosting(JournalTemplate, JournalBatch);

        GLEntry.Reset;
        GLEntry.SetRange(GLEntry."Document No.", DocumentNo);
        GLEntry.SetRange(GLEntry.Reversed, false);
        if GLEntry.FindFirst then begin
            OnAfterPostPaymentVoucher(DocumentNo);
        end;
    end;

    local procedure GetVATAccounNo(var
                                       PVLines: Record "Payment Voucher Lines";
                                       VATCode: Code[20]): Code[20]
    var
        VATProductPostingGroup: Record "VAT Product Posting Group";
        VATSetup: Record "VAT Posting Setup";
        GLAccount: Record "G/L Account";
        Customer: Record Customer;
        Vendor: Record Vendor;
        AccountNo: Code[20];
    begin
        case PVLines."Account Type" of
            PVLines."Account Type"::"G/L Account":
                begin
                    GLAccount.Get(PVLines."Account No");
                    GLAccount.TestField("VAT Bus. Posting Group");
                    if VATSetup.Get(GLAccount."VAT Bus. Posting Group", VATCode) then AccountNo := VATSetup."Purchase VAT Account";
                end;
            PVLines."Account Type"::Vendor:
                begin
                    Vendor.Get(PVLines."Account No");
                    Vendor.TestField("VAT Bus. Posting Group");
                    if VATSetup.Get(Vendor."VAT Bus. Posting Group", VATCode) then AccountNo := VATSetup."Purchase VAT Account";
                end;
            PVLines."Account Type"::Customer:
                begin
                    Customer.Get(PVLines."Account No");
                    Customer.TestField("VAT Bus. Posting Group");
                    if VATSetup.Get(Customer."VAT Bus. Posting Group", VATCode) then AccountNo := VATSetup."Purchase VAT Account";
                end;
        end;
        exit(AccountNo);
    end;
}
