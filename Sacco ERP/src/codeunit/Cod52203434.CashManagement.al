codeunit 52203434 "Cash Management"
{
    var
        PaymentVoucher: Record "Payment Voucher";
        PaymentShedule: Record "Payment Schedule";
        PaymentShedule_Del: Record "Payment Schedule";
        Employee: Record Employee;
        GeneralLedgerSetup: Record "General Ledger Setup";
        Batch: Record "Gen. Journal Batch";
        Text000: Label 'Are you sure you want to Post the Petty Cash?';
        Text001: Label 'The Petty Cash No %1 has not been fully approved.';
        Text003: Label 'The petty cash amount cannot be zero.';
        PettyCashDetails: Record "Petty Cash Details";
        GLEntry: Record "G/L Entry";
        BankAccount: Record "Bank Account";
        PayrollPeriodTransaction: Record "Payroll Period Transaction";
        GlobalAccountType: Enum "Gen. Journal Account Type";

    [IntegrationEvent(false, false)]
    procedure OnBeforePostCashReceipt(var Receipt: Record "Receipt Header")
    begin
    end;

    [IntegrationEvent(FALSE, false)]
    procedure OnAfterPostReceipt(var Receipt: Record "Receipt Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforePostPaymentVoucher(var PaymentVoucher: Record "Payment Voucher")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterPostPaymentVoucher(PVNo: Code[20])
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Management", 'OnBeforePostCashReceipt', '', true, true)]
    local procedure OnBefore_PostCashReceipt(var Receipt: Record "Receipt Header")
    begin
        GLEntry.Reset;
        GLEntry.SetRange(GLEntry."Document No.", Receipt."No.");
        GLEntry.SetRange(GLEntry.Reversed, false);
        if GLEntry.FindFirst then begin
            OnAfterPostReceipt(Receipt);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Management", 'OnAfterPostReceipt', '', true, true)]
    local procedure AfterPostingReceipt(var Receipt: Record "Receipt Header")
    begin
        Receipt."Posted Date" := WorkDate;
        Receipt.Posted := true;
        Receipt.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Management", 'OnBeforePostPaymentVoucher', '', true, true)]
    local procedure OnBefore_PostPaymentVoucher(var PaymentVoucher: Record "Payment Voucher")
    begin
        GLEntry.Reset;
        GLEntry.SetRange(GLEntry."Document No.", PaymentVoucher."No.");
        GLEntry.SetRange(GLEntry.Reversed, false);
        if GLEntry.FindFirst then begin
            OnAfterPostPaymentVoucher(PaymentVoucher."No.");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Management", 'OnAfterPostPaymentVoucher', '', true, true)]
    procedure OnAfter_PostPaymentVoucher(PVNo: Code[20])
    var
        PaymentVoucher: Record "Payment Voucher";
    begin
        if PaymentVoucher.Get(PVNo) then begin
            PaymentVoucher.Validate(Posted, true);
            PaymentVoucher."Posted By" := UserId;
            PaymentVoucher."Posted Date" := WorkDate;
            PaymentVoucher."Time Posted" := Time;
            PaymentVoucher.Modify(true);
        end;
    end;


    procedure GeneratePayrollPaymentSchedule(var PVLines: Record "Payment Voucher Lines")
    var
        AmountToBePaid: Decimal;
    begin
        //Delete Existing Schedule
        PaymentShedule_Del.Reset();
        PaymentShedule_Del.SetRange("PV No.", PVLines."No.");
        If PaymentShedule_Del.FindSet() then PaymentShedule_Del.DeleteAll(true);
        AmountToBePaid := 0;
        if PaymentVoucher.Get(PVLines."No.") then begin
            PaymentVoucher.TestField("Payroll Period");
            Employee.SetFilter("Nature Of Employment", '<>%1', Employee."Nature Of Employment"::Board);
            Employee.SetFilter("FOSA Account", '<>%1', '');
            Employee.SetFilter("Employee Status", '=%1|=%2', Employee."Employee Status"::Active, Employee."Employee Status"::OnLeave);
            if Employee.FindSet then begin
                repeat
                    AmountToBePaid := AmountToBePaid + CreatePaymentScheduleLine(PaymentVoucher, Employee, PVLines);
                until Employee.Next = 0;
            end;
        end;
        PVLines.Validate(Amount, AmountToBePaid);
    end;

    procedure CreatePaymentScheduleLine(PVHeader: Record "Payment Voucher"; Employee: Record Employee; PaymentLines: Record "Payment Voucher Lines"): Decimal
    begin
        PayrollPeriodTransaction.Reset;
        PayrollPeriodTransaction.SetRange("Employee Code", Employee."No.");
        PayrollPeriodTransaction.SetRange("Payroll Period", PVHeader."Payroll Period");
        PayrollPeriodTransaction.SetRange("Transaction Code", 'NPAY');
        if PayrollPeriodTransaction.FindFirst then begin
            PaymentShedule.Init();
            PaymentShedule.Validate("PV No.", PaymentLines."No.");
            PaymentShedule."PV Line No." := PaymentLines."Line No";
            PaymentShedule.Validate("Employee No", Employee."No.");
            PaymentShedule.Amount := PayrollPeriodTransaction.Amount;
            if PaymentShedule.Amount > 0 then begin
                PaymentShedule.Insert(true);
                exit(PaymentShedule.Amount);
            end;
        end;
    end;

    procedure PostReceipt(var Receipt: Record "Receipt Header")
    var
        GenJnLine: Record "Gen. Journal Line";
        ReceiptLines: Record "Receipt Lines";
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        JournalTemplate: Code[20];
        JournalBatch: Code[20];
        DocumentNo: Code[20];
        LineNo: Integer;
        PostingDate: date;
        DocType: Enum "Gen. Journal Document Type";
        PostingDescription: Text[50];
        Dim1, Dim2, AccountNo, MemberNo : code[20];
        PostingAmount, LoanBalance, InterestBalance, BaseAmount : Decimal;
    begin
        GeneralLedgerSetup.Get;
        GeneralLedgerSetup.TestField("Receipt Template");
        GeneralLedgerSetup.TestField("Receipt Batch");
        JournalTemplate := GeneralLedgerSetup."Receipt Template";
        JournalBatch := GeneralLedgerSetup."Receipt Batch";
        OnBeforePostCashReceipt(Receipt);
        if Receipt.Amount >= Receipt."Approval Limit" then Receipt.TestField(Status, Receipt.Status::Approved);
        Receipt.CalcFields(Amount);
        Dim1 := Receipt."Global Dimension 1 Code";
        Dim2 := Receipt."Global Dimension 2 Code";
        Batch.Init;
        Batch."Journal Template Name" := GeneralLedgerSetup."Receipt Template";
        Batch.Name := GeneralLedgerSetup."Receipt Batch";
        if not Batch.Get(Batch."Journal Template Name", Batch.Name) then Batch.Insert;
        // Delete Lines Present on the General Journal Line
        GenJnLine.Reset;
        GenJnLine.SetRange(GenJnLine."Journal Template Name", GeneralLedgerSetup."Receipt Template");
        GenJnLine.SetRange(GenJnLine."Journal Batch Name", GeneralLedgerSetup."Receipt Batch");
        GenJnLine.DeleteAll;
        PostingDescription := Receipt.Description;
        AccountNo := Receipt."Bank Account";
        PostingDate := WorkDate;
        DocumentNo := Receipt."No.";
        PostingAmount := 0;
        PostingAmount := Receipt.Amount;
        GenJnLine.Init;
        GenJnLine."Journal Template Name" := GeneralLedgerSetup."Petty Cash Template";
        GenJnLine."Journal Batch Name" := GeneralLedgerSetup."Petty Cash Batch";
        GenJnLine."Line No." := LineNo;
        GenJnLine."Account Type" := GenJnLine."Account Type"::"Bank Account";
        GenJnLine."Account No." := AccountNo;
        GenJnLine."Posting Date" := PostingDate;
        GenJnLine."Document No." := DocumentNo;
        GenJnLine."External Document No." := Receipt."External Document No.";
        GenJnLine.Description := PostingDescription;
        GenJnLine.Amount := -PostingAmount;
        GenJnLine.Validate(Amount);
        GenJnLine."Shortcut Dimension 1 Code" := Receipt."Global Dimension 1 Code";
        GenJnLine.Validate("Shortcut Dimension 1 Code");
        GenJnLine."Shortcut Dimension 2 Code" := Receipt."Global Dimension 2 Code";
        GenJnLine.Validate("Shortcut Dimension 2 Code");
        if GenJnLine.Amount <> 0 then GenJnLine.Insert;
        ReceiptLines.Reset();
        ReceiptLines.SetRange("No.", Receipt."No.");
        if ReceiptLines.FindSet() then begin
            repeat
                AccountNo := ReceiptLines."Account No";
                PostingDescription := ReceiptLines.Description;
                PostingAmount := 0;
                PostingAmount := ReceiptLines.Amount;
                case ReceiptLines."Receipt Type" of
                    ReceiptLines."Receipt Type"::Customer:
                        begin
                            GlobalAccountType := GlobalAccountType::Customer;
                        end;
                    ReceiptLines."Receipt Type"::Bank:
                        begin
                            GlobalAccountType := GlobalAccountType::"Bank Account";
                        end;
                    ReceiptLines."Receipt Type"::"G/L Account":
                        begin
                            GlobalAccountType := GlobalAccountType::"G/L Account"
                        end;
                    ReceiptLines."Receipt Type"::Vendor:
                        begin
                            GlobalAccountType := GlobalAccountType::Vendor;
                        end;
                    ReceiptLines."Receipt Type"::Employee:
                        begin
                            GlobalAccountType := GlobalAccountType::Employee;
                        end;
                end;
                GenJnLine.Init;
                GenJnLine."Journal Template Name" := GeneralLedgerSetup."Petty Cash Template";
                GenJnLine."Journal Batch Name" := GeneralLedgerSetup."Petty Cash Batch";
                GenJnLine."Line No." := LineNo;
                GenJnLine."Account Type" := GlobalAccountType;
                GenJnLine."Account No." := AccountNo;
                GenJnLine."Posting Date" := PostingDate;
                GenJnLine."Document No." := DocumentNo;
                GenJnLine."External Document No." := Receipt."External Document No.";
                GenJnLine.Description := PostingDescription;
                GenJnLine.Amount := -PostingAmount;
                GenJnLine.Validate(Amount);
                GenJnLine."Shortcut Dimension 1 Code" := Receipt."Global Dimension 1 Code";
                GenJnLine.Validate("Shortcut Dimension 1 Code");
                GenJnLine."Shortcut Dimension 2 Code" := Receipt."Global Dimension 2 Code";
                GenJnLine.Validate("Shortcut Dimension 2 Code");
                if GenJnLine.Amount <> 0 then GenJnLine.Insert;
            until ReceiptLines.Next = 0;
        end;
        CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post Ext", GenJnLine);
        GLEntry.Reset();
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("Document Date", PostingDate);
        if GLEntry.FindFirst() then OnAfterPostReceipt(Receipt);
    end;

    procedure PostPettyCash(var PettyCash: Record "Petty Cash Header")
    var
        GenJnLine: Record "Gen. Journal Line";
        Batch: Record "Gen. Journal Batch";
        LineNo: Integer;
        PostingDate: Date;
    begin
        with PettyCash do begin
            if Confirm(Text000, false) = true then begin
                if Status <> Status::Approved then Error(Text001, "No.");
                TestField("Employee No.");
                TestField("Employee Name");
                TestField("Paying Account Code");
                TestField(Date);
                TestField("Pay Mode");
                //if "Pay Mode" <> 'CASH' then TestField("Payment Tx No.(Cheque No.)");
                //if "Pay Mode" = 'CHEQUE' then TestField("Cheque Date");
                //Check if the  Lines have been populated
                CalcFields("Total Amount");
                if "Total Amount" = 0 then Error(Text003);
                if Posted then GeneralLedgerSetup.Get;
                GeneralLedgerSetup.Get;
                GeneralLedgerSetup.Get;
                // Delete Lines Present on the General Journal Line
                GenJnLine.Reset;
                GenJnLine.SetRange(GenJnLine."Journal Template Name", GeneralLedgerSetup."Petty Cash Template");
                GenJnLine.SetRange(GenJnLine."Journal Batch Name", GeneralLedgerSetup."Petty Cash Batch");
                GenJnLine.DeleteAll;
                Batch.Init;
                Batch."Journal Template Name" := GeneralLedgerSetup."Petty Cash Template";
                Batch.Name := GeneralLedgerSetup."Petty Cash Batch";
                if not Batch.Get(Batch."Journal Template Name", Batch.Name) then Batch.Insert;
                //Bank
                LineNo := 10000;
                GenJnLine.Init;
                GenJnLine."Journal Template Name" := GeneralLedgerSetup."Petty Cash Template";
                GenJnLine."Journal Batch Name" := GeneralLedgerSetup."Petty Cash Batch";
                GenJnLine."Line No." := LineNo;
                GenJnLine."Account Type" := GenJnLine."Account Type"::"Bank Account";
                GenJnLine."Account No." := "Paying Account Code";
                If "Posting Date" <> 0D then
                    PostingDate := "Posting Date"
                else
                    PostingDate := WorkDate;
                GenJnLine."Posting Date" := PostingDate;
                GenJnLine."Document No." := "No.";
                GenJnLine."External Document No." := "Payment Tx No.(Cheque No.)";
                GenJnLine.Description := "Payment Narration";
                if ("Currency Code" <> '') and ("Currency Code" <> GeneralLedgerSetup."LCY Code") then GenJnLine.Validate("Currency Code", "Currency Code");
                GenJnLine.Amount := -"Total Amount";
                GenJnLine.Validate(Amount);
                GenJnLine."Shortcut Dimension 1 Code" := "Global Dimension 1 Code";
                GenJnLine.Validate("Shortcut Dimension 1 Code");
                GenJnLine."Shortcut Dimension 2 Code" := "Global Dimension 2 Code";
                GenJnLine.Validate("Shortcut Dimension 2 Code");
                if GenJnLine.Amount <> 0 then GenJnLine.Insert;
                //Expenses
                PettyCashDetails.Reset;
                PettyCashDetails.SetRange(No, "No.");
                if PettyCashDetails.Find('-') then
                    repeat begin
                        LineNo := LineNo + 1000;
                        GenJnLine.Init;
                        GenJnLine."Journal Template Name" := GeneralLedgerSetup."Petty Cash Template";
                        GenJnLine."Journal Batch Name" := GeneralLedgerSetup."Petty Cash Batch";
                        GenJnLine."Line No." := LineNo;
                        if PettyCashDetails.Type = PettyCashDetails.Type::"Fixed Asset" then
                            GenJnLine."Account Type" := GenJnLine."Account Type"::"Fixed Asset"
                        else if PettyCashDetails.Type = PettyCashDetails.Type::"G/L Account" then GenJnLine."Account Type" := GenJnLine."Account Type"::"G/L Account";
                        GenJnLine."Account No." := PettyCashDetails."Account No";
                        GenJnLine."Posting Date" := PostingDate;
                        GenJnLine."Document No." := "No.";
                        GenJnLine.Description := "Payment Narration";
                        if ("Currency Code" <> '') and ("Currency Code" <> GeneralLedgerSetup."LCY Code") then GenJnLine.Validate("Currency Code", "Currency Code");
                        GenJnLine.Amount := PettyCashDetails.Amount;
                        GenJnLine.Validate(Amount);
                        GenJnLine."Shortcut Dimension 1 Code" := PettyCashDetails."Global Dimension 1 Code";
                        GenJnLine.Validate("Shortcut Dimension 1 Code");
                        GenJnLine."Shortcut Dimension 2 Code" := PettyCashDetails."Global Dimension 2 Code";
                        GenJnLine.Validate("Shortcut Dimension 2 Code");
                        if GenJnLine.Amount <> 0 then GenJnLine.Insert;
                    end;
                    until PettyCashDetails.Next = 0;
                //
                CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post", GenJnLine);
                GLEntry.Reset;
                GLEntry.SetRange(GLEntry."Document No.", "No.");
                GLEntry.SetRange(GLEntry.Reversed, false);
                GLEntry.SetRange("Posting Date", WorkDate);
                if GLEntry.FindFirst then begin
                    Posted := true;
                    "Posted By" := UserId;
                    "Posted Date" := WorkDate;
                    Modify;
                end;
            end;
        end;
    end;

    procedure CheckForCashAvailability(var PettyCashHeader: Record "Petty Cash Header")
    begin
        if PettyCashHeader."Paying Account Code" = '' then Error('The Paying Bank Code has not been specified!');
        if BankAccount.Get(PettyCashHeader."Paying Account Code") then begin
            BankAccount.CalcFields(Balance);
            PettyCashHeader.CalcFields("Total Amount");
            if (BankAccount.Balance - PettyCashHeader."Total Amount") < BankAccount."Minimum Float" then Error('There is no sufficient cash for your request of %1 KSH, you can only request for the %2 KSH available.', PettyCashHeader."Total Amount", BankAccount.Balance - BankAccount."Minimum Float");
        end;
    end;

    procedure "Post Payment Voucher"(PVHeader: Record "Payment Voucher")
    var
        PVLines: Record "Payment Voucher Lines";
        GenJnLine: Record "Gen. Journal Line";
        LineNo: Integer;
        VATSetup: Record "VAT Posting Setup";
        VATProductPostingGroup: Record "VAT Product Posting Group";
        GLAccount: Record "G/L Account";
        Customer: Record Customer;
        Vendor: Record Vendor;
        GLEntry: Record "G/L Entry";
        PaymentMethod: Record "Payment Method";
        PaymentSchedule: Record "Payment Schedule";
        Employee: Record Employee;
    begin
        if PVHeader.Posted then Error('Payment Voucher %1 have been already paid via EFT', PVHeader."No.");
        if not Confirm(StrSubstNo('Are you sure you want to post the Payment Voucher No. %1?', PVHeader."No."), false) then exit;
        PVHeader.TestField("Pay Mode");
        PVHeader.TestField(Date);
        PaymentMethod.Get(PVHeader."Pay Mode");
        if PaymentMethod.Type = PaymentMethod.Type::Cheque then begin
            PVHeader.TestField(PVHeader."Cheque Number");
            PVHeader.TestField(PVHeader."Cheque Date");
            if PVHeader."Cheque Date" > WorkDate then Error('You cannot use a future date as Cheque Number');
        end
        else if PaymentMethod.Type <> PaymentMethod.Type::FOSA then PVHeader.TestField("Paying Bank Account");
        //Check Lines
        PVHeader.CalcFields("Total Amount");
        if PVHeader."Total Amount" = 0 then Error('Amount is cannot be zero');
        PVLines.Reset;
        PVLines.SetRange(PVLines."No.", PVHeader."No.");
        if not PVLines.FindLast then Error('Payment voucher Lines cannot be empty');

        OnBeforePostPaymentVoucher(PVHeader);

        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.TestField("Payment Voucher Template");
        GeneralLedgerSetup.TestField("Payment Voucher Batch");
        // Delete Lines Present on the General Journal Line
        GenJnLine.Reset;
        GenJnLine.SetRange(GenJnLine."Journal Template Name", GeneralLedgerSetup."Payment Voucher Template");
        GenJnLine.SetRange(GenJnLine."Journal Batch Name", GeneralLedgerSetup."Payment Voucher Batch");
        GenJnLine.DeleteAll;
        Batch.Init;
        Batch."Journal Template Name" := GeneralLedgerSetup."Payment Voucher Template";
        Batch.Name := GeneralLedgerSetup."Payment Voucher Batch";
        if not Batch.Get(Batch."Journal Template Name", Batch.Name) then Batch.Insert;
        //Bank Entries
        LineNo := LineNo + 10000;
        GenJnLine.Init;
        GenJnLine."Journal Template Name" := GeneralLedgerSetup."Payment Voucher Template";
        GenJnLine."Journal Batch Name" := GeneralLedgerSetup."Payment Voucher Batch";
        GenJnLine."Line No." := LineNo;
        GenJnLine."Account Type" := GenJnLine."Account Type"::"Bank Account";
        GenJnLine."Account No." := PVHeader."Paying Bank Account";
        GenJnLine.Validate(GenJnLine."Account No.");
        GenJnLine."Posting Date" := PVHeader.Date;
        GenJnLine."Document No." := PVHeader."No.";
        GenJnLine."External Document No." := PVHeader."Cheque Number";
        GenJnLine.Description := PVLines.Description;
        GenJnLine.Validate("Currency Code", PVHeader.Currency);
        GenJnLine.Amount := -PVHeader."Total Amount";
        GenJnLine.Validate(GenJnLine.Amount);
        GenJnLine."Shortcut Dimension 1 Code" := PVHeader."Global Dimension 1 Code";
        GenJnLine.Validate(GenJnLine."Shortcut Dimension 1 Code");
        GenJnLine."Shortcut Dimension 2 Code" := PVHeader."Global Dimension 2 Code";
        GenJnLine.Validate(GenJnLine."Shortcut Dimension 2 Code");
        if GenJnLine.Amount <> 0 then GenJnLine.Insert;
        //PV Lines Entries
        PVLines.Reset;
        PVLines.SetRange(PVLines."No.", PVHeader."No.");
        if PVLines.FindFirst then
            repeat begin
                //Debit Account No.
                PVLines.Validate(PVLines.Amount);
                GenJnLine.Init;
                LineNo := LineNo + 10000;
                GenJnLine."Journal Template Name" := GeneralLedgerSetup."Payment Voucher Template";
                GenJnLine."Journal Batch Name" := GeneralLedgerSetup."Payment Voucher Batch";
                GenJnLine."Line No." := LineNo;
                GenJnLine."Account Type" := PVLines."Account Type";
                GenJnLine."Account No." := PVLines."Account No";
                GenJnLine.Validate(GenJnLine."Account No.");
                GenJnLine."Posting Date" := PVHeader.Date;
                GenJnLine."Document No." := PVHeader."No.";
                GenJnLine."External Document No." := PVHeader."Cheque Number";
                GenJnLine.Description := CopyStr(PVLines.Description, 1, 50);
                GenJnLine.Validate(Amount, PVLines."Net Amount");
                GenJnLine.Validate("Currency Code", PVLines."Currency Code");
                GenJnLine."Shortcut Dimension 1 Code" := PVLines."Global Dimension 1 Code";
                GenJnLine.Validate(GenJnLine."Shortcut Dimension 1 Code");
                GenJnLine."Shortcut Dimension 2 Code" := PVLines."Global Dimension 2 Code";
                GenJnLine.Validate(GenJnLine."Shortcut Dimension 2 Code");
                if PVLines."Applies to Doc. No" <> '' then begin
                    GenJnLine.Validate("Applies-to Doc. Type", GenJnLine."Applies-to Doc. Type"::Invoice);
                    GenJnLine.Validate(GenJnLine."Applies-to Doc. No.", PVLines."Applies to Doc. No");
                end;
                if GenJnLine.Amount <> 0 then GenJnLine.Insert;
                //Post VAT
                if GeneralLedgerSetup."Post VAT" then begin
                    if ((PVLines."VAT Code" <> '') and (PVLines."VAT Amount" <> 0)) then begin
                        PVLines.Validate(PVLines.Amount);
                        LineNo := LineNo + 10000;
                        GenJnLine.Init;
                        GenJnLine."Journal Template Name" := GeneralLedgerSetup."Payment Voucher Template";
                        GenJnLine."Journal Batch Name" := GeneralLedgerSetup."Payment Voucher Batch";
                        GenJnLine."Line No." := LineNo;
                        GenJnLine."Account Type" := PVLines."Account Type";
                        GenJnLine."Account No." := PVLines."Account No";
                        GenJnLine.Validate(GenJnLine."Account No.");
                        GenJnLine."Posting Date" := PVHeader.Date;
                        GenJnLine."Document No." := PVHeader."No.";
                        GenJnLine."External Document No." := PVHeader."Cheque Number";
                        GenJnLine.Description := PVLines.Description;
                        GenJnLine.Validate("Currency Code", PVLines."Currency Code");
                        GenJnLine.Amount := PVLines."VAT Amount";
                        GenJnLine.Validate(GenJnLine.Amount);
                        //Set these fields to blanks
                        GenJnLine."Gen. Posting Type" := GenJnLine."Gen. Posting Type"::" ";
                        GenJnLine.Validate("Gen. Posting Type");
                        GenJnLine."Gen. Bus. Posting Group" := '';
                        GenJnLine.Validate("Gen. Bus. Posting Group");
                        GenJnLine."Gen. Prod. Posting Group" := '';
                        GenJnLine.Validate("Gen. Prod. Posting Group");
                        GenJnLine."VAT Bus. Posting Group" := '';
                        GenJnLine.Validate("VAT Bus. Posting Group");
                        GenJnLine."VAT Prod. Posting Group" := '';
                        GenJnLine.Validate("VAT Prod. Posting Group");
                        //
                        GenJnLine."Shortcut Dimension 1 Code" := PVLines."Global Dimension 1 Code";
                        GenJnLine.Validate(GenJnLine."Shortcut Dimension 1 Code");
                        GenJnLine."Shortcut Dimension 2 Code" := PVLines."Global Dimension 2 Code";
                        GenJnLine.Validate(GenJnLine."Shortcut Dimension 2 Code");
                        if PVLines."Applies to Doc. No" <> '' then begin
                            GenJnLine.Validate("Applies-to Doc. Type", GenJnLine."Applies-to Doc. Type"::Invoice);
                            GenJnLine.Validate(GenJnLine."Applies-to Doc. No.", PVLines."Applies to Doc. No");
                        end;
                        if GenJnLine.Amount <> 0 then GenJnLine.Insert;
                        LineNo := LineNo + 10000;
                        GenJnLine.Init;
                        GenJnLine."Journal Template Name" := GeneralLedgerSetup."Payment Voucher Template";
                        GenJnLine."Journal Batch Name" := GeneralLedgerSetup."Payment Voucher Batch";
                        GenJnLine."Line No." := LineNo;
                        GenJnLine."Account Type" := GenJnLine."Account Type"::"G/L Account";
                        case PVLines."Account Type" of
                            PVLines."Account Type"::"G/L Account":
                                begin
                                    GLAccount.Get(PVLines."Account No");
                                    GLAccount.TestField("VAT Bus. Posting Group");
                                    if VATSetup.Get(GLAccount."VAT Bus. Posting Group", PVLines."VAT Code") then GenJnLine."Account No." := VATSetup."Purchase VAT Account";
                                    GenJnLine.Validate(GenJnLine."Account No.");
                                end;
                            PVLines."Account Type"::Vendor:
                                begin
                                    Vendor.Get(PVLines."Account No");
                                    Vendor.TestField("VAT Bus. Posting Group");
                                    if VATSetup.Get(Vendor."VAT Bus. Posting Group", PVLines."VAT Code") then GenJnLine."Account No." := VATSetup."Purchase VAT Account";
                                    GenJnLine.Validate(GenJnLine."Account No.");
                                end;
                            PVLines."Account Type"::Customer:
                                begin
                                    Customer.Get(PVLines."Account No");
                                    Customer.TestField("VAT Bus. Posting Group");
                                    if VATSetup.Get(Customer."VAT Bus. Posting Group", PVLines."VAT Code") then GenJnLine."Account No." := VATSetup."Purchase VAT Account";
                                    GenJnLine.Validate(GenJnLine."Account No.");
                                end;
                        end;
                        GenJnLine."Posting Date" := PVHeader.Date;
                        GenJnLine."Document No." := PVHeader."No.";
                        GenJnLine."External Document No." := PVHeader."Cheque Number";
                        GenJnLine.Description := PVLines.Description;
                        GenJnLine.Validate("Currency Code", PVLines."Currency Code");
                        GenJnLine.Amount := -PVLines."VAT Amount";
                        GenJnLine.Validate(GenJnLine.Amount);
                        //Set these fields to blanks
                        GenJnLine."Gen. Posting Type" := GenJnLine."Gen. Posting Type"::" ";
                        GenJnLine.Validate("Gen. Posting Type");
                        GenJnLine."Gen. Bus. Posting Group" := '';
                        GenJnLine.Validate("Gen. Bus. Posting Group");
                        GenJnLine."Gen. Prod. Posting Group" := '';
                        GenJnLine.Validate("Gen. Prod. Posting Group");
                        GenJnLine."VAT Bus. Posting Group" := '';
                        GenJnLine.Validate("VAT Bus. Posting Group");
                        GenJnLine."VAT Prod. Posting Group" := '';
                        GenJnLine.Validate("VAT Prod. Posting Group");
                        //
                        GenJnLine."Shortcut Dimension 1 Code" := PVLines."Global Dimension 1 Code";
                        GenJnLine.Validate(GenJnLine."Shortcut Dimension 1 Code");
                        GenJnLine."Shortcut Dimension 2 Code" := PVLines."Global Dimension 2 Code";
                        GenJnLine.Validate(GenJnLine."Shortcut Dimension 2 Code");
                        if GenJnLine.Amount <> 0 then GenJnLine.Insert;
                    end;
                    //End of Posting VAT
                end;
                //Post Withholding Tax One
                if ((PVLines."WHT Code One" <> '') and (PVLines."WHT Amount One" <> 0)) then begin
                    //Debit Payable Account Withholding Tax Amount;
                    VATProductPostingGroup.Get(PVLines."WHT Code One");
                    LineNo := LineNo + 10000;
                    GenJnLine.Init;
                    GenJnLine."Journal Template Name" := GeneralLedgerSetup."Payment Voucher Template";
                    GenJnLine."Journal Batch Name" := GeneralLedgerSetup."Payment Voucher Batch";
                    GenJnLine."Line No." := LineNo;
                    GenJnLine."Account Type" := PVLines."Account Type";
                    GenJnLine."Account No." := PVLines."Account No";
                    GenJnLine.Validate(GenJnLine."Account No.");
                    if PVHeader.Date = 0D then Error('You must specify the PV date');
                    GenJnLine."Posting Date" := PVHeader.Date;
                    GenJnLine."Document No." := PVHeader."No.";
                    GenJnLine."External Document No." := PVHeader."Cheque Number";
                    GenJnLine.Description := VATProductPostingGroup.Description;
                    GenJnLine.Validate("Currency Code", PVLines."Currency Code");
                    GenJnLine.Amount := PVLines."WHT Amount One";
                    GenJnLine.Validate(GenJnLine.Amount);
                    //Set these fields to blanks
                    GenJnLine."Gen. Posting Type" := GenJnLine."Gen. Posting Type"::" ";
                    GenJnLine."Gen. Bus. Posting Group" := '';
                    GenJnLine.Validate("Gen. Bus. Posting Group");
                    GenJnLine."Gen. Prod. Posting Group" := '';
                    GenJnLine.Validate("Gen. Prod. Posting Group");
                    GenJnLine."VAT Bus. Posting Group" := '';
                    GenJnLine.Validate("VAT Bus. Posting Group");
                    GenJnLine."VAT Prod. Posting Group" := '';
                    GenJnLine.Validate("VAT Prod. Posting Group");
                    //
                    GenJnLine."Shortcut Dimension 1 Code" := PVLines."Global Dimension 1 Code";
                    GenJnLine.Validate(GenJnLine."Shortcut Dimension 1 Code");
                    GenJnLine."Shortcut Dimension 2 Code" := PVLines."Global Dimension 2 Code";
                    GenJnLine.Validate(GenJnLine."Shortcut Dimension 2 Code");
                    if PVLines."Applies to Doc. No" <> '' then begin
                        GenJnLine.Validate("Applies-to Doc. Type", GenJnLine."Applies-to Doc. Type"::Invoice);
                        GenJnLine.Validate(GenJnLine."Applies-to Doc. No.", PVLines."Applies to Doc. No");
                    end;
                    if GenJnLine.Amount <> 0 then GenJnLine.Insert;
                    //Credit Withholding Tax Account;
                    LineNo := LineNo + 10000;
                    GenJnLine.Init;
                    GenJnLine."Journal Template Name" := GeneralLedgerSetup."Payment Voucher Template";
                    GenJnLine."Journal Batch Name" := GeneralLedgerSetup."Payment Voucher Batch";
                    GenJnLine."Line No." := LineNo;
                    GenJnLine."Account Type" := GenJnLine."Account Type"::"G/L Account";
                    case PVLines."Account Type" of
                        PVLines."Account Type"::"G/L Account":
                            begin
                                GLAccount.Get(PVLines."Account No");
                                GLAccount.TestField("VAT Bus. Posting Group");
                                if VATSetup.Get(GLAccount."VAT Bus. Posting Group", PVLines."WHT Code One") then GenJnLine."Account No." := VATSetup."Purchase VAT Account";
                                GenJnLine.Validate(GenJnLine."Account No.");
                            end;
                        PVLines."Account Type"::Vendor:
                            begin
                                Vendor.Get(PVLines."Account No");
                                Vendor.TestField("VAT Bus. Posting Group");
                                if VATSetup.Get(Vendor."VAT Bus. Posting Group", PVLines."WHT Code One") then GenJnLine."Account No." := VATSetup."Purchase VAT Account";
                                GenJnLine.Validate(GenJnLine."Account No.");
                            end;
                        PVLines."Account Type"::Customer:
                            begin
                                Customer.Get(PVLines."Account No");
                                Customer.TestField("VAT Bus. Posting Group");
                                if VATSetup.Get(Customer."VAT Bus. Posting Group", PVLines."WHT Code One") then GenJnLine."Account No." := VATSetup."Purchase VAT Account";
                                GenJnLine.Validate(GenJnLine."Account No.");
                            end;
                    end;
                    GenJnLine."Posting Date" := PVHeader.Date;
                    GenJnLine."Document No." := PVHeader."No.";
                    GenJnLine."External Document No." := PVHeader."Cheque Number";
                    GenJnLine.Description := VATProductPostingGroup.Description;
                    GenJnLine.Validate("Currency Code", PVLines."Currency Code");
                    GenJnLine.Amount := -PVLines."WHT Amount One";
                    GenJnLine.Validate(GenJnLine.Amount);
                    //Set these fields to blanks
                    GenJnLine."Gen. Posting Type" := GenJnLine."Gen. Posting Type"::" ";
                    GenJnLine.Validate("Gen. Posting Type");
                    GenJnLine."Gen. Bus. Posting Group" := '';
                    GenJnLine.Validate("Gen. Bus. Posting Group");
                    GenJnLine."Gen. Prod. Posting Group" := '';
                    GenJnLine.Validate("Gen. Prod. Posting Group");
                    GenJnLine."VAT Bus. Posting Group" := '';
                    GenJnLine.Validate("VAT Bus. Posting Group");
                    GenJnLine."VAT Prod. Posting Group" := '';
                    GenJnLine.Validate("VAT Prod. Posting Group");
                    //
                    GenJnLine."Shortcut Dimension 1 Code" := PVLines."Global Dimension 1 Code";
                    GenJnLine.Validate(GenJnLine."Shortcut Dimension 1 Code");
                    GenJnLine."Shortcut Dimension 2 Code" := PVLines."Global Dimension 2 Code";
                    GenJnLine.Validate(GenJnLine."Shortcut Dimension 2 Code");
                    if GenJnLine.Amount <> 0 then GenJnLine.Insert;
                end;
                //Post Withholding Tax One
                if ((PVLines."WHT Code Two" <> '') and (PVLines."WHT Amount Two" <> 0)) then begin
                    //Debit Payable Account Withholding Tax Amount;
                    VATProductPostingGroup.Get(PVLines."WHT Code Two");
                    LineNo := LineNo + 10000;
                    GenJnLine.Init;
                    GenJnLine."Journal Template Name" := GeneralLedgerSetup."Payment Voucher Template";
                    GenJnLine."Journal Batch Name" := GeneralLedgerSetup."Payment Voucher Batch";
                    GenJnLine."Line No." := LineNo;
                    GenJnLine."Account Type" := PVLines."Account Type";
                    GenJnLine."Account No." := PVLines."Account No";
                    GenJnLine.Validate(GenJnLine."Account No.");
                    if PVHeader.Date = 0D then Error('You must specify the PV date');
                    GenJnLine."Posting Date" := PVHeader.Date;
                    GenJnLine."Document No." := PVHeader."No.";
                    GenJnLine."External Document No." := PVHeader."Cheque Number";
                    GenJnLine.Description := VATProductPostingGroup.Description;
                    GenJnLine.Validate("Currency Code", PVLines."Currency Code");
                    GenJnLine.Amount := PVLines."WHT Amount Two";
                    GenJnLine.Validate(GenJnLine.Amount);
                    //Set these fields to blanks
                    GenJnLine."Gen. Posting Type" := GenJnLine."Gen. Posting Type"::" ";
                    GenJnLine."Gen. Bus. Posting Group" := '';
                    GenJnLine.Validate("Gen. Bus. Posting Group");
                    GenJnLine."Gen. Prod. Posting Group" := '';
                    GenJnLine.Validate("Gen. Prod. Posting Group");
                    GenJnLine."VAT Bus. Posting Group" := '';
                    GenJnLine.Validate("VAT Bus. Posting Group");
                    GenJnLine."VAT Prod. Posting Group" := '';
                    GenJnLine.Validate("VAT Prod. Posting Group");
                    //
                    GenJnLine."Shortcut Dimension 1 Code" := PVLines."Global Dimension 1 Code";
                    GenJnLine.Validate(GenJnLine."Shortcut Dimension 1 Code");
                    GenJnLine."Shortcut Dimension 2 Code" := PVLines."Global Dimension 2 Code";
                    GenJnLine.Validate(GenJnLine."Shortcut Dimension 2 Code");
                    if PVLines."Applies to Doc. No" <> '' then begin
                        GenJnLine.Validate("Applies-to Doc. Type", GenJnLine."Applies-to Doc. Type"::Invoice);
                        GenJnLine.Validate(GenJnLine."Applies-to Doc. No.", PVLines."Applies to Doc. No");
                    end;
                    if GenJnLine.Amount <> 0 then GenJnLine.Insert;
                    //Credit Withholding Tax Account;
                    LineNo := LineNo + 10000;
                    GenJnLine.Init;
                    GenJnLine."Journal Template Name" := GeneralLedgerSetup."Payment Voucher Template";
                    GenJnLine."Journal Batch Name" := GeneralLedgerSetup."Payment Voucher Batch";
                    GenJnLine."Line No." := LineNo;
                    GenJnLine."Account Type" := GenJnLine."Account Type"::"G/L Account";
                    case PVLines."Account Type" of
                        PVLines."Account Type"::"G/L Account":
                            begin
                                GLAccount.Get(PVLines."Account No");
                                GLAccount.TestField("VAT Bus. Posting Group");
                                if VATSetup.Get(GLAccount."VAT Bus. Posting Group", PVLines."WHT Code One") then GenJnLine."Account No." := VATSetup."Purchase VAT Account";
                                GenJnLine.Validate(GenJnLine."Account No.");
                            end;
                        PVLines."Account Type"::Vendor:
                            begin
                                Vendor.Get(PVLines."Account No");
                                Vendor.TestField("VAT Bus. Posting Group");
                                if VATSetup.Get(Vendor."VAT Bus. Posting Group", PVLines."WHT Code One") then GenJnLine."Account No." := VATSetup."Purchase VAT Account";
                                GenJnLine.Validate(GenJnLine."Account No.");
                            end;
                        PVLines."Account Type"::Customer:
                            begin
                                Customer.Get(PVLines."Account No");
                                Customer.TestField("VAT Bus. Posting Group");
                                if VATSetup.Get(Customer."VAT Bus. Posting Group", PVLines."WHT Code One") then GenJnLine."Account No." := VATSetup."Purchase VAT Account";
                                GenJnLine.Validate(GenJnLine."Account No.");
                            end;
                    end;
                    GenJnLine."Posting Date" := PVHeader.Date;
                    GenJnLine."Document No." := PVHeader."No.";
                    GenJnLine."External Document No." := PVHeader."Cheque Number";
                    GenJnLine.Description := VATProductPostingGroup.Description;
                    GenJnLine.Validate("Currency Code", PVLines."Currency Code");
                    GenJnLine.Amount := -PVLines."WHT Amount Two";
                    GenJnLine.Validate(GenJnLine.Amount);
                    //Set these fields to blanks
                    GenJnLine."Gen. Posting Type" := GenJnLine."Gen. Posting Type"::" ";
                    GenJnLine.Validate("Gen. Posting Type");
                    GenJnLine."Gen. Bus. Posting Group" := '';
                    GenJnLine.Validate("Gen. Bus. Posting Group");
                    GenJnLine."Gen. Prod. Posting Group" := '';
                    GenJnLine.Validate("Gen. Prod. Posting Group");
                    GenJnLine."VAT Bus. Posting Group" := '';
                    GenJnLine.Validate("VAT Bus. Posting Group");
                    GenJnLine."VAT Prod. Posting Group" := '';
                    GenJnLine.Validate("VAT Prod. Posting Group");
                    //
                    GenJnLine."Shortcut Dimension 1 Code" := PVLines."Global Dimension 1 Code";
                    GenJnLine.Validate(GenJnLine."Shortcut Dimension 1 Code");
                    GenJnLine."Shortcut Dimension 2 Code" := PVLines."Global Dimension 2 Code";
                    GenJnLine.Validate(GenJnLine."Shortcut Dimension 2 Code");
                    if GenJnLine.Amount <> 0 then GenJnLine.Insert;
                end;
            end;
            //End of Posting Withholding Tax 
            until PVLines.Next = 0;
        CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post Ext", GenJnLine);
        GLEntry.Reset;
        GLEntry.SetRange(GLEntry."Document No.", PVHeader."No.");
        GLEntry.SetRange(GLEntry.Reversed, false);
        if GLEntry.FindFirst then begin
            OnAfterPostPaymentVoucher(PVHeader."No.");
        end;
    end;
}
