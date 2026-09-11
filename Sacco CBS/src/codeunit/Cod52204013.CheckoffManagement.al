codeunit 52204013 "Checkoff Management"
{
    var
        GlobalTransactionType: array[2] of Enum "Sacco Transaction Type";
        GlobalAccountType: Enum "Gen. Journal Account Type";
        GLEntry: Record "G/L Entry";
        SaccoProducts: Record "Sacco Products";
        MemberManagement: Codeunit "Member Management";
        ProductPostingType: Enum "Product Posting Type";

    procedure ApplyEmployerUpload(DocumentNo: Code[20])
    var
        CheckOff: Record "Checkoff Header";
        CheckOffUpload: array[2] of Record "Checkoff Upload";
        EmployerPayrollDetails: Record "Employer Payroll Details";
        ProgressWindow: Dialog;
        TotalRecords: Integer;
        ProcessedRecords: Integer;
        ProgressMsg: Label 'Processing payroll details...\\#1#################\Record #2###### of #3######';
    begin
        if CheckOff.Get(DocumentNo) then begin
            CheckOff.TestField("Posting Date");
            CheckOff.TestField("Employer Code");

            CheckOffUpload[1].Reset();
            CheckOffUpload[1].SetRange("Document No", CheckOff."No.");
            if CheckOffUpload[1].FindSet() then
                CheckOffUpload[1].DeleteAll();
            Commit();

            EmployerPayrollDetails.Reset();
            EmployerPayrollDetails.SetRange(Processed, false);
            EmployerPayrollDetails.SetRange("Employer Code", CheckOff."Employer Code");
            EmployerPayrollDetails.SetRange(Period, CalcDate('<-CM>', CheckOff."Posting Date"));
            If CheckOff."Upload Type" = CheckOff."Upload Type"::Checkoff then
                EmployerPayrollDetails.SetRange("Upload Type", EmployerPayrollDetails."Upload Type"::Checkoff) else
                if CheckOff."Upload Type" = CheckOff."Upload Type"::Salary then
                    EmployerPayrollDetails.SetRange("Upload Type", EmployerPayrollDetails."Upload Type"::Salary);
            if EmployerPayrollDetails.FindSet() then begin
                TotalRecords := EmployerPayrollDetails.Count();
                ProcessedRecords := 0;
                ProgressWindow.Open(ProgressMsg);
                repeat
                    ProcessedRecords += 1;
                    ProgressWindow.Update(1, EmployerPayrollDetails."Payroll Code");
                    ProgressWindow.Update(2, ProcessedRecords);
                    ProgressWindow.Update(3, TotalRecords);

                    CheckOffUpload[2].Init();
                    CheckOffUpload[2]."Document No" := CheckOff."No.";
                    CheckOffUpload[2]."Check No" := EmployerPayrollDetails."Payroll Code";
                    CheckOffUpload[2]."Product Code" := EmployerPayrollDetails."Product Code";
                    CheckOffUpload[2]."Uploaded Name" := EmployerPayrollDetails.Name;
                    CheckOffUpload[2].Amount := EmployerPayrollDetails.Amount;
                    CheckOffUpload[2].Insert();
                until EmployerPayrollDetails.Next() = 0;

                ProgressWindow.Close();
            end;
        end;
    end;

    procedure ValidateUpload(DocumentNo: Code[20])
    var
        Window: Dialog;
        All, Current : Integer;
        CheckoffUpload: array[2] of Record "Checkoff Upload";
        CheckoffLines: Record "Checkoff Lines";
        CurrentCheckNo, PreviousCheckNo, MemberNo : Code[20];
        TotalAmount: Decimal;
        LoansMgt: Codeunit "Loans Management";
        Member: Record Members;
        Vendor: Record Vendor;
        CheckOffCalculations: Record "Checkoff Calculation";
        CheckOff: Record "Checkoff Header";
    begin
        CheckOff.Get(DocumentNo);
        CheckoffLines.Reset();
        CheckoffLines.SetRange(Posted, true);
        CheckoffLines.SetRange("No.", DocumentNo);
        if CheckoffLines.FindFirst() then
            Error('The Checkoff has some posted lines. Re-calculation is not allowed');

        CheckoffLines.Reset();
        CheckoffLines.SetRange("No.", DocumentNo);
        if CheckoffLines.FindSet() then
            CheckoffLines.DeleteAll();

        CheckOffCalculations.Reset();
        CheckOffCalculations.SetRange("Document No", DocumentNo);
        if CheckOffCalculations.FindSet() then
            CheckOffCalculations.DeleteAll();

        CheckoffUpload[1].Reset();
        CheckoffUpload[1].SetRange("Document No", DocumentNo);
        CheckoffUpload[1].SetCurrentKey("Check No");
        if CheckoffUpload[1].FindSet() then begin
            All := CheckoffUpload[1].Count;
            Current := 1;
            Window.Open('Calculating \Member #1### \@2@@@');
            repeat
                Window.Update(1, ((Current / All) * 10000) div 1);
                Current += 1;
                CurrentCheckNo := CheckoffUpload[1]."Check No";
                if CurrentCheckNo <> PreviousCheckNo then begin
                    CheckoffLines.Init();
                    CheckoffLines."No." := DocumentNo;
                    CheckoffLines."Member No" := GetMemberNo(CurrentCheckNo, CheckOff."Employer Code", CheckOff."Search Type");
                    if Member.Get(CheckoffLines."Member No") then begin
                        CheckoffLines."Mobile Phone No" := Member."Mobile Phone No.";
                        CheckoffLines."Member Name" := Member."Full Name";
                        CheckoffLines."Payroll No" := Member."Payroll No.";
                        CheckoffLines."Check No" := CurrentCheckNo;
                        CheckoffUpload[1]."System Name" := UpperCase(Member.FullName);

                        If DelChr(UpperCase(Member.FullName), '=', ' ') = DelChr(UpperCase(CheckoffUpload[1]."Uploaded Name"), '=', ' ') then
                            CheckoffUpload[1].Validate(Matched, true)
                        else
                            CheckoffUpload[1].Validate(Matched, false);

                        CheckoffUpload[1].Modify(true);
                        if CheckOff."Upload Type" = CheckOff."Upload Type"::Salary then CheckoffLines."Collections Account" := LoansMgt.GetFOSAAccount(CheckoffLines."Member No");
                    end
                    else begin
                        CheckoffLines."Suspense Account" := true;
                        CheckoffLines."Member Name" := 'Suspense Account';
                        CheckoffLines."Collections Account" := CheckOff."Suspense Account";
                        CheckoffLines."Check No" := CurrentCheckNo;
                    end;
                    CheckoffLines.Insert();

                    CheckoffUpload[2].Reset();
                    CheckoffUpload[2].SetRange("Check No", CurrentCheckNo);
                    CheckoffUpload[2].SetRange("Document No", DocumentNo);
                    if CheckoffUpload[2].FindSet() then begin
                        CheckoffUpload[2].CalcSums(Amount);
                        TotalAmount := CheckoffUpload[2].Amount;
                        CheckOffCalculations.Init();
                        CheckOffCalculations."Document No" := DocumentNo;
                        CheckOffCalculations."Member No" := GetMemberNo(CurrentCheckNo, CheckOff."Employer Code", CheckOff."Search Type");
                        CheckOffCalculations."Check No" := CurrentCheckNo;
                        CheckOffCalculations."Entry No" := GetCheckOffEntryNo(DocumentNo, CheckoffLines."Member No", CheckoffLines."Check No");
                        CheckOffCalculations."Entry Type" := CheckOffCalculations."Entry Type"::"Net Amount";
                        CheckOffCalculations.Amount := TotalAmount;
                        CheckOffCalculations."Amount Base" := -TotalAmount;
                        if CheckOff."Upload Type" = CheckOff."Upload Type"::Salary then begin
                            CheckOffCalculations."Account No" := CheckoffLines."Collections Account";
                            if Vendor.Get(CheckoffLines."Collections Account") then CheckOffCalculations."Account Name" := Vendor.Name;
                        end;
                        if CheckOffCalculations.Amount <> 0 then
                            CheckOffCalculations.Insert();
                    end;
                end;
                PreviousCheckNo := CurrentCheckNo;
            until CheckoffUpload[1].Next() = 0;
            CheckOff.CalcFields("Uploaded Amount");
            CheckOff.Variance := CheckOff."Uploaded Amount" - CheckOff.Amount;
            CheckOff.Modify();
            Window.Close;
        end;
        CheckOff.Variance := CheckOff."Uploaded Amount" - CheckOff.Amount;
        CheckOff.Modify();
    end;

    procedure GetMemberLoanAccount(MemberNo: code[20]; ProductCode: code[20]; CheckoffDate: Date) LoanNo: code[20]
    var
        Loans: Record Loans;
        LoanProduct: Record "Sacco Products";
    begin
        LoanProduct.Reset();
        LoanProduct.SetRange(Code, ProductCode);
        if LoanProduct.FindFirst() then begin
            Loans.Reset();
            Loans.SetRange("Member No.", MemberNo);
            Loans.SetRange("Product Code", LoanProduct.Code);
            Loans.SetFilter("Loan Balance", '>0');
            Loans.SetFilter("Repayment Start Date", '<=%1', CheckoffDate);
            if Loans.FindFirst() then
                LoanNo := Loans."No."
            else
                LoanNo := '';
        end
        else begin
            Loans.Reset();
            Loans.SetRange("Member No.", MemberNo);
            Loans.SetRange("No.", ProductCode);
            Loans.SetFilter("Loan Balance", '>0');
            Loans.SetFilter("Repayment Start Date", '<=%1', CheckoffDate);
            if Loans.FindFirst() then
                LoanNo := Loans."No."
            else begin
                Loans.Reset();
                Loans.SetRange("Member No.", MemberNo);
                Loans.SetRange("Product Code", ProductCode);
                Loans.SetFilter("Loan Balance", '>0');
                Loans.SetFilter("Repayment Start Date", '<=%1', CheckoffDate);
                if Loans.FindFirst() then
                    LoanNo := Loans."No."
                else
                    LoanNo := '';
            end;
        end;
        exit(LoanNo);
    end;

    procedure GetExpectedAmount(MemberNo: Code[20]; ProductCode: Code[20]; AsAtDate: Date; var LoanAccountNo: Code[20]) Expected: Decimal
    var
        Loans: Record Loans;
        DateFilter: Text;
        LoansMgt: Codeunit "Loans Management";
        MonthlyInstallment, LoanBalance : Decimal;
        SaccoProduct: Record "Sacco Products";
        SaccoSetup: Record "General Ledger Setup";
    begin
        SaccoSetup.Get;
        SaccoProduct.Get(ProductCode);
        Expected := 0;
        DateFilter := '..' + Format(CalcDate('CM', AsAtDate));
        Loans.Reset();
        Loans.SetRange("Member No.", MemberNo);
        Loans.SetRange("Product Code", ProductCode);
        Loans.SetFilter("Repayment Start Date", '<=%1', CalcDate('CM', AsAtDate));
        Loans.SetRange("Recovery Mode", Loans."Recovery Mode"::Salary);
        Loans.SetFilter("Loan Balance", '>0');
        Loans.SetFilter("Date Filter", DateFilter);
        if Loans.FindSet then begin
            repeat
                if SaccoSetup."Daily Interest Accrual" then
                    LoansMgt.PostLoanInterest(AsAtDate, '', 0, MemberNo, Loans."No.");
                Loans.CalcFields("Monthly Installment", "Loan Balance");
                if Loans."Monthly Installment" < 0 then
                    Loans."Monthly Installment" := 0;
                MonthlyInstallment := Loans."Monthly Installment";
                LoanBalance := Loans."Loan Balance";
                LoanAccountNo := Loans."Loan Account";
                if MonthlyInstallment < LoanBalance then
                    Expected += MonthlyInstallment
                else
                    Expected += LoanBalance;
            until Loans.Next = 0;
        end;
        exit(Expected);
    end;

    procedure GetCheckOffEntryNo(DocumentNo: code[20]; MemberNo: code[20]; CheckNo: code[20]) EntryNo: Integer
    var
        CheckOffCalculation: Record "Checkoff Calculation";
    begin
        CheckOffCalculation.Reset();
        CheckOffCalculation.SetRange("Document No", DocumentNo);
        CheckOffCalculation.SetRange("Member No", MemberNo);
        CheckOffCalculation.SetRange("Check No", CheckNo);
        if CheckOffCalculation.FindLast() then
            exit(CheckOffCalculation."Entry No" + 1000)
        else
            exit(1000);
    end;

    procedure CalculateRecoveries(DocumentNo: Code[20])
    var
        CheckoffUpload: Record "Checkoff Upload";
        CheckOffHeader: Record "Checkoff Header";
        CheckOffCalculations: array[4] of Record "Checkoff Calculation";
        CheckoffLines: Record "Checkoff Lines";
        Vendor: Record Vendor;
        GLAccount: Record "G/L Account";
        BankAccount: Record "Bank Account";
        Window: Dialog;
        All, Current : Integer;
        AccountNo, MemberNo, LoanNo, LoanAccountNo : Code[20];
        DateFilter, AccountName : Text[100];
        LoansMgt: Codeunit "Loans Management";
        FOSAManagement: Codeunit "FOSA Management";
        ExpectedAmount, BaseAmount, STOCharge, ChargeAmount, RunningAmount, AmountDue, RecoveredAmount, SecondRecoveredAmount, STOAmount, MinBalance, DeductedAmount : Decimal;
        TransactionCharge: Record "Transaction Charges";
        TransactionChargesSetup: Record "Transaction Charges Setup";
        TransactionRecoveries: Record "Transaction Recoveries";
        Loans: Record Loans;
        StandingOrder: Record "Standing Order";
        AccountType: Record "Sacco Products";
        JournalMgt: Codeunit "Journal Management";
        MemberSubscriptions: Record "Member Subscriptions";
        FirstDayOfMonth: Date;
    begin
        CheckOffHeader.Get(DocumentNo);
        CheckOffHeader.TestField("Posting Date");
        FOSAManagement.UpdateSTO('', CheckOffHeader."Posting Date");

        CheckOffCalculations[1].Reset();
        CheckOffCalculations[1].SetRange("Document No", DocumentNo);
        CheckOffCalculations[1].SetFilter("Entry Type", '<>%1', CheckOffCalculations[1]."Entry Type"::"Net Amount");
        if CheckOffCalculations[1].FindSet() then
            CheckOffCalculations[1].DeleteAll();

        CheckoffLines.Reset();
        CheckoffLines.SetRange("No.", DocumentNo);
        CheckoffLines.SetRange("Suspense Account", false);
        if CheckoffLines.FindSet() then begin
            Window.Open('Updating Recoveries \#1###\@2@@@');
            All := CheckoffLines.Count;
            Current := 1;
            repeat
                MemberNo := '';
                MemberNo := CheckoffLines."Member No";
                Window.Update(1, CheckoffLines."Member Name" + MemberNo);
                Window.Update(2, StrSubstNo('%1%', Round((Current / All) * 100, 0.01)));
                Current += 1;
                CheckoffLines.CalcFields("Amount Earned");
                BaseAmount := 0;
                BaseAmount := Abs(Round(CheckoffLines."Amount Earned"));
                RunningAmount := 0;
                STOAmount := 0;
                STOCharge := 0;
                RunningAmount := Round(BaseAmount);
                DateFilter := '..' + Format(calcdate('CM', CheckOffHeader."Posting Date"));

                if CheckOffHeader."Upload Type" IN [CheckOffHeader."Upload Type"::Salary] then begin
                    if CheckOffHeader."Charge Code" <> '' then begin
                        if TransactionCharge.Get(CheckOffHeader."Charge Code") then begin
                            TransactionChargesSetup.Reset();
                            TransactionChargesSetup.SetRange("Transaction Code", TransactionCharge.Code);
                            if TransactionChargesSetup.FindSet then begin
                                repeat
                                    ChargeAmount := 0;
                                    ChargeAmount := JournalMgt.GetTransactionChargesAmount(TransactionChargesSetup."Transaction Code", TransactionChargesSetup.Code, BaseAmount);
                                    CheckOffCalculations[1].Init();
                                    CheckOffCalculations[1]."Document No" := DocumentNo;
                                    CheckOffCalculations[1]."Member No" := CheckoffLines."Member No";
                                    CheckOffCalculations[1]."Check No" := CheckoffLines."Check No";
                                    CheckOffCalculations[1]."Entry No" := GetCheckOffEntryNo(DocumentNo, CheckoffLines."Member No", CheckoffLines."Check No");
                                    CheckOffCalculations[1]."Account Name" := TransactionChargesSetup.Description;
                                    CheckOffCalculations[1]."Entry Type" := CheckOffCalculations[1]."Entry Type"::Commission;
                                    CheckOffCalculations[1].Amount := ChargeAmount;
                                    CheckOffCalculations[1]."Amount Base" := ChargeAmount;
                                    CheckOffCalculations[1]."Account No" := TransactionChargesSetup."Post-to Account No.";
                                    case TransactionChargesSetup."Post to Account Type" of
                                        TransactionChargesSetup."Post to Account Type"::"Bank Account":
                                            begin
                                                If BankAccount.Get(TransactionChargesSetup."Post-to Account No.") then CheckOffCalculations[1]."Account Name" := BankAccount.Name;
                                            end;
                                        TransactionChargesSetup."Post to Account Type"::"G/L Account":
                                            begin
                                                If GLAccount.Get(TransactionChargesSetup."Post-to Account No.") then CheckOffCalculations[1]."Account Name" := GLAccount.Name;
                                            end;
                                        TransactionChargesSetup."Post to Account Type"::Vendor:
                                            begin
                                                If Vendor.Get(TransactionChargesSetup."Post-to Account No.") then CheckOffCalculations[1]."Account Name" := Vendor.Name;
                                            end;
                                    end;
                                    if CheckOffCalculations[1].Amount <> 0 then CheckOffCalculations[1].Insert();
                                    BaseAmount -= ChargeAmount;
                                until TransactionChargesSetup.Next = 0;
                            end;
                        end;
                        TransactionRecoveries.Reset();
                        TransactionRecoveries.SetRange(Code, CheckOffHeader."Charge Code");
                        TransactionRecoveries.SetCurrentKey(Prioirity);
                        TransactionRecoveries.SetAscending(Prioirity, true);
                        if TransactionRecoveries.FindSet() then begin
                            repeat
                                case TransactionRecoveries."Recovery Type" of
                                    TransactionRecoveries."Recovery Type"::Loan:
                                        begin
                                            AmountDue := 0;
                                            RecoveredAmount := 0;
                                            ExpectedAmount := 0;
                                            LoanAccountNo := '';
                                            ExpectedAmount := GetExpectedAmount(MemberNo, TransactionRecoveries."Recovery Code", CheckOffHeader."Posting Date", LoanAccountNo);
                                            if ExpectedAmount < 0 then ExpectedAmount := 0;
                                            if ExpectedAmount >= BaseAmount then
                                                RecoveredAmount := BaseAmount
                                            else
                                                RecoveredAmount := ExpectedAmount;
                                            if RecoveredAmount > 0 then begin
                                                CheckOffCalculations[1].Reset();
                                                CheckOffCalculations[1].SetRange("Member No", CheckoffLines."Member No");
                                                CheckOffCalculations[1].SetRange(Posted, true);
                                                CheckOffCalculations[1].SetRange("Pay Period", CalcDate('CM', CheckOffHeader."Posting Date"));
                                                CheckOffCalculations[1].SetRange("Account No", LoanAccountNo);
                                                CheckOffCalculations[1].SetRange("Entry Type", CheckOffCalculations[1]."Entry Type"::"Loan Recovery");
                                                if ((not CheckOffCalculations[1].FindFirst) or CheckOffHeader."Allow Double Recovery") then begin
                                                    CheckOffCalculations[2].Init();
                                                    CheckOffCalculations[2]."Document No" := DocumentNo;
                                                    CheckOffCalculations[2]."Member No" := CheckoffLines."Member No";
                                                    CheckOffCalculations[2]."Check No" := CheckoffLines."Check No";
                                                    CheckOffCalculations[2]."Entry No" := GetCheckOffEntryNo(DocumentNo, CheckoffLines."Member No", CheckoffLines."Check No");
                                                    CheckOffCalculations[2]."Entry Type" := CheckOffCalculations[2]."Entry Type"::"Loan Recovery";
                                                    CheckOffCalculations[2].Amount := RecoveredAmount;
                                                    CheckOffCalculations[2]."Amount Base" := RecoveredAmount;
                                                    CheckOffCalculations[2]."Account Name" := TransactionRecoveries."Recovery Description";
                                                    CheckOffCalculations[2]."Account No" := LoanAccountNo;
                                                    //CheckOffCalculations[2]."Loan No" := LoanApplication."No.";
                                                    if CheckOffCalculations[2].Amount <> 0 then CheckOffCalculations[2].Insert();
                                                    BaseAmount -= RecoveredAmount;
                                                end
                                                else begin
                                                    If CheckOffCalculations[1].Amount < ExpectedAmount then begin
                                                        SecondRecoveredAmount := ExpectedAmount - CheckOffCalculations[1].Amount;
                                                        if SecondRecoveredAmount > RecoveredAmount then SecondRecoveredAmount := RecoveredAmount;
                                                        CheckOffCalculations[2].Init();
                                                        CheckOffCalculations[2]."Document No" := DocumentNo;
                                                        CheckOffCalculations[2]."Member No" := CheckoffLines."Member No";
                                                        CheckOffCalculations[2]."Check No" := CheckoffLines."Check No";
                                                        CheckOffCalculations[2]."Entry No" := GetCheckOffEntryNo(DocumentNo, CheckoffLines."Member No", CheckoffLines."Check No");
                                                        CheckOffCalculations[2]."Entry Type" := CheckOffCalculations[2]."Entry Type"::"Loan Recovery";
                                                        CheckOffCalculations[2].Amount := SecondRecoveredAmount;
                                                        CheckOffCalculations[2]."Amount Base" := SecondRecoveredAmount;
                                                        CheckOffCalculations[2]."Account Name" := TransactionRecoveries."Recovery Description";
                                                        CheckOffCalculations[2]."Account No" := LoanAccountNo;
                                                        //CheckOffCalculations[2]."Loan No" := LoanApplication."No.";
                                                        if CheckOffCalculations[2].Amount <> 0 then CheckOffCalculations[2].Insert();
                                                        BaseAmount -= SecondRecoveredAmount;
                                                    end;
                                                end;
                                            end;
                                        end;
                                    TransactionRecoveries."Recovery Type"::"Standing Order":
                                        begin
                                            //Message('Start here %1', TransactionRecoveries."Recovery Type"); 
                                            StandingOrder.Reset();
                                            StandingOrder.SetRange("Member No", MemberNo);
                                            StandingOrder.SetRange("STO Type", TransactionRecoveries."Recovery Code");
                                            StandingOrder.SetRange(Terminated, false);
                                            StandingOrder.SetRange(Running, true);
                                            if CheckOffHeader."Upload Type" = CheckOffHeader."Upload Type"::Salary then
                                                StandingOrder.SetRange("Salary Based", true);
                                            StandingOrder.SetFilter("Start Date", '<=%1', CalcDate('<CM>', CheckOffHeader."Posting Date"));
                                            StandingOrder.SetFilter("End Date", '>=%1', Today);
                                            StandingOrder.SetCurrentKey(Priority);
                                            StandingOrder.SetAscending(Priority, true);
                                            if StandingOrder.FindSet() then begin
                                                repeat

                                                    if StandingOrder."Amount Type" = StandingOrder."Amount Type"::Fixed then
                                                        STOAmount := StandingOrder.Amount
                                                    else begin
                                                        STOAmount := RunningAmount;
                                                        RunningAmount := 0;
                                                    end;
                                                    if StandingOrder."Standing Order Class" <> StandingOrder."Standing Order Class"::External then begin
                                                        if STOAmount > BaseAmount then STOAmount := BaseAmount;
                                                    end;
                                                    if StandingOrder."Charge Code" <> '' then begin
                                                        STOCharge := JournalMgt.GetChargesAmount(StandingOrder."Charge Code", STOAmount);
                                                    end;
                                                    CheckOffCalculations[1].Reset();
                                                    CheckOffCalculations[1].SetRange("Member No", CheckoffLines."Member No");
                                                    CheckOffCalculations[1].SetRange(Posted, true);
                                                    CheckOffCalculations[1].SetRange("Pay Period", CalcDate('CM', CheckOffHeader."Posting Date"));
                                                    CheckOffCalculations[1].SetRange("Account No", StandingOrder."No.");
                                                    CheckOffCalculations[1].SetRange("Entry Type", CheckOffCalculations[1]."Entry Type"::"Standing Order");
                                                    if ((not CheckOffCalculations[1].FindFirst) or CheckOffHeader."Allow Double Recovery") then begin
                                                        if ((STOAmount + STOCharge) <= BaseAmount) then begin
                                                            RecoveredAmount := 0;
                                                            RecoveredAmount := STOAmount;
                                                            if RecoveredAmount > 0 then begin
                                                                CheckOffCalculations[2].Init();
                                                                CheckOffCalculations[2]."Document No" := DocumentNo;
                                                                CheckOffCalculations[2]."Member No" := CheckoffLines."Member No";
                                                                CheckOffCalculations[2]."Check No" := CheckoffLines."Check No";
                                                                CheckOffCalculations[2]."Entry No" := GetCheckOffEntryNo(DocumentNo, CheckoffLines."Member No", CheckoffLines."Check No");
                                                                CheckOffCalculations[2]."Entry Type" := CheckOffCalculations[2]."Entry Type"::"Standing Order";
                                                                CheckOffCalculations[2].Amount := RecoveredAmount;
                                                                CheckOffCalculations[2]."Amount Base" := RecoveredAmount;
                                                                CheckOffCalculations[2]."Account No" := StandingOrder."No.";
                                                                CheckOffCalculations[2]."Account Name" := StrSubstNo('STO: %1', StandingOrder."Posting Description");
                                                                CheckOffCalculations[2]."Loan No" := StandingOrder."No.";
                                                                if CheckOffCalculations[2].Amount <> 0 then CheckOffCalculations[2].Insert();
                                                            end;
                                                            BaseAmount -= RecoveredAmount;
                                                            RecoveredAmount := 0;
                                                            RecoveredAmount := STOCharge;
                                                            if RecoveredAmount <> 0 then begin
                                                                CheckOffCalculations[2].Init();
                                                                CheckOffCalculations[2]."Document No" := DocumentNo;
                                                                CheckOffCalculations[2]."Member No" := CheckoffLines."Member No";
                                                                CheckOffCalculations[2]."Check No" := CheckoffLines."Check No";
                                                                CheckOffCalculations[2]."Entry No" := GetCheckOffEntryNo(DocumentNo, CheckoffLines."Member No", CheckoffLines."Check No");
                                                                CheckOffCalculations[2]."Entry Type" := CheckOffCalculations[2]."Entry Type"::Commission;
                                                                CheckOffCalculations[2].Amount := RecoveredAmount;
                                                                CheckOffCalculations[2]."Amount Base" := RecoveredAmount;
                                                                CheckOffCalculations[2]."Account No" := StandingOrder."No.";
                                                                CheckOffCalculations[2]."Account Name" := 'STO: Charges';
                                                                CheckOffCalculations[2]."Loan No" := 'COMMISSION';
                                                                if CheckOffCalculations[2].Amount <> 0 then if CheckOffCalculations[2].Amount <> 0 then CheckOffCalculations[2].Insert();
                                                            end;
                                                            BaseAmount -= RecoveredAmount;
                                                        end;
                                                    end;
                                                until StandingOrder.Next() = 0;
                                            end;
                                        end;
                                    TransactionRecoveries."Recovery Type"::"Internal Deposit":
                                        begin
                                            if SaccoProducts.GET(TransactionRecoveries."Recovery Code") then begin
                                                MinBalance := 0;
                                                MinBalance := SaccoProducts."Minimum Balance";
                                                case TransactionRecoveries."Deduction Type" of
                                                    TransactionRecoveries."Deduction Type"::"Monthly Installment":
                                                        begin
                                                            Vendor.Reset;
                                                            Vendor.SetRange("Member No.", CheckoffLines."Member No");
                                                            Vendor.SetRange("Product Code", SaccoProducts.Code);
                                                            if Vendor.FindFirst then begin
                                                                DeductedAmount := 0;
                                                                DeductedAmount := BaseAmount;
                                                                CheckOffCalculations[1].Reset();
                                                                CheckOffCalculations[1].SetRange("Member No", CheckoffLines."Member No");
                                                                CheckOffCalculations[1].SetRange(Posted, true);
                                                                CheckOffCalculations[1].SetRange("Pay Period", CalcDate('CM', CheckOffHeader."Posting Date"));
                                                                CheckOffCalculations[1].SetRange("Account No", Vendor."No.");
                                                                CheckOffCalculations[1].SetRange("Entry Type", CheckOffCalculations[1]."Entry Type"::"Internal Deposit");
                                                                if ((not CheckOffCalculations[1].FindFirst) or CheckOffHeader."Allow Double Recovery") then begin
                                                                    CheckOffCalculations[2].Init();
                                                                    CheckOffCalculations[2]."Document No" := DocumentNo;
                                                                    CheckOffCalculations[2]."Member No" := CheckoffLines."Member No";
                                                                    CheckOffCalculations[2]."Check No" := CheckoffLines."Check No";
                                                                    CheckOffCalculations[2]."Entry No" := GetCheckOffEntryNo(DocumentNo, CheckoffLines."Member No", CheckoffLines."Check No");
                                                                    CheckOffCalculations[2]."Entry Type" := CheckOffCalculations[2]."Entry Type"::"Internal Deposit";
                                                                    if DeductedAmount <= BaseAmount then begin
                                                                        CheckOffCalculations[2].Amount := ABS(DeductedAmount);
                                                                        BaseAmount -= ABS(DeductedAmount);
                                                                    end
                                                                    else begin
                                                                        CheckOffCalculations[2].Amount := ABS(BaseAmount);
                                                                        BaseAmount := 0;
                                                                    end;
                                                                    CheckOffCalculations[2]."Amount Base" := CheckOffCalculations[2].Amount;
                                                                    CheckOffCalculations[2]."Account No" := Vendor."No.";
                                                                    CheckOffCalculations[2]."Account Name" := Vendor.Name;
                                                                    CheckOffCalculations[2]."Loan No" := '';
                                                                    if CheckOffCalculations[2].Amount <> 0 then if CheckOffCalculations[2].Amount <> 0 then CheckOffCalculations[2].Insert();
                                                                end;
                                                            end;
                                                        end;
                                                    TransactionRecoveries."Deduction Type"::"Boost to Minimum":
                                                        begin
                                                            Vendor.Reset;
                                                            Vendor.SetRange("Member No.", CheckoffLines."Member No");
                                                            Vendor.SetRange("Product Code", SaccoProducts.Code);
                                                            if Vendor.FindFirst then begin
                                                                CheckOffCalculations[1].Reset();
                                                                CheckOffCalculations[1].SetRange("Member No", CheckoffLines."Member No");
                                                                CheckOffCalculations[1].SetRange(Posted, true);
                                                                CheckOffCalculations[1].SetRange("Pay Period", CalcDate('CM', CheckOffHeader."Posting Date"));
                                                                CheckOffCalculations[1].SetRange("Account No", Vendor."No.");
                                                                CheckOffCalculations[1].SetRange("Entry Type", CheckOffCalculations[1]."Entry Type"::"Internal Deposit");
                                                                if ((not CheckOffCalculations[1].FindFirst) or CheckOffHeader."Allow Double Recovery") then begin
                                                                    Vendor.CALCFIELDS(Balance);
                                                                    if Vendor.Balance < MinBalance then begin
                                                                        DeductedAmount := 0;
                                                                        DeductedAmount := MinBalance - Vendor.Balance;
                                                                        CheckOffCalculations[2].Init();
                                                                        CheckOffCalculations[2]."Document No" := DocumentNo;
                                                                        CheckOffCalculations[2]."Member No" := CheckoffLines."Member No";
                                                                        CheckOffCalculations[2]."Check No" := CheckoffLines."Check No";
                                                                        CheckOffCalculations[2]."Entry No" := GetCheckOffEntryNo(DocumentNo, CheckoffLines."Member No", CheckoffLines."Check No");
                                                                        CheckOffCalculations[2]."Entry Type" := CheckOffCalculations[2]."Entry Type"::"Internal Deposit";
                                                                        if DeductedAmount <= BaseAmount then begin
                                                                            CheckOffCalculations[2].Amount := ABS(DeductedAmount);
                                                                            BaseAmount -= ABS(DeductedAmount);
                                                                        end
                                                                        else begin
                                                                            CheckOffCalculations[2].Amount := ABS(BaseAmount);
                                                                            BaseAmount := 0;
                                                                        end;
                                                                        CheckOffCalculations[2]."Amount Base" := CheckOffCalculations[2].Amount;
                                                                        CheckOffCalculations[2]."Account No" := Vendor."No.";
                                                                        CheckOffCalculations[2]."Account Name" := Vendor.Name;
                                                                        CheckOffCalculations[2]."Loan No" := '';
                                                                        if CheckOffCalculations[2].Amount <> 0 then CheckOffCalculations[2].Insert();
                                                                    end;
                                                                end;
                                                            end;
                                                        end;
                                                end;
                                            end;
                                        end;
                                end;
                            until TransactionRecoveries.Next() = 0;
                        end;
                    end;
                end
                else if CheckOffHeader."Upload Type" in [CheckOffHeader."Upload Type"::Checkoff] then begin
                    if CheckOffHeader."Calculation Type" = CheckOffHeader."Calculation Type"::"Per Product Amount" then begin
                        CheckoffUpload.Reset();
                        CheckoffUpload.SetRange("Check No", CheckoffLines."Check No");
                        CheckoffUpload.SetRange("Document No", DocumentNo);
                        if CheckoffUpload.FindSet() then begin
                            repeat
                                if SaccoProducts.Get(CheckoffUpload."Product Code") then begin
                                    GetMemberAccountWithRefrence(CheckoffLines."Member No", CheckoffUpload."Product Code", AccountNo, AccountName);
                                    CheckOffCalculations[1].Init();
                                    CheckOffCalculations[1]."Document No" := DocumentNo;
                                    CheckOffCalculations[1]."Member No" := CheckoffLines."Member No";
                                    CheckOffCalculations[1]."Check No" := CheckoffLines."Check No";
                                    CheckOffCalculations[1]."Entry No" := GetCheckOffEntryNo(DocumentNo, CheckoffLines."Member No", CheckoffLines."Check No");
                                    CheckOffCalculations[1]."Entry Type" := CheckOffCalculations[1]."Entry Type"::"Internal Deposit";
                                    if SaccoProducts."Product Posting Type" = SaccoProducts."Product Posting Type"::"Loan Account" then begin
                                        CheckOffCalculations[1]."Entry Type" := CheckOffCalculations[1]."Entry Type"::"Loan Recovery";
                                        Loans.Reset();
                                        Loans.SetRange("Loan Account", AccountNo);
                                        Loans.SetRange("Member No.", MemberNo);
                                        if not Loans.FindFirst then
                                            CheckOffCalculations[1].UnMatched := true
                                        else
                                            CheckOffCalculations[1].UnMatched := false;
                                    end
                                    else begin
                                        CheckOffCalculations[1]."Entry Type" := CheckOffCalculations[1]."Entry Type"::"Internal Deposit";
                                        if not Vendor.Get(AccountNo) then
                                            CheckOffCalculations[1].UnMatched := true
                                        else
                                            CheckOffCalculations[1].UnMatched := false;
                                    end;
                                    CheckOffCalculations[1].Amount := Round(CheckoffUpload.Amount);
                                    CheckOffCalculations[1]."Amount Base" := Round(CheckoffUpload.Amount);
                                    CheckOffCalculations[1]."Account No" := AccountNo;
                                    CheckOffCalculations[1]."Account Name" := AccountName;
                                    if CheckOffCalculations[1].Amount <> 0 then
                                        CheckOffCalculations[1].Insert();
                                end;
                            until CheckoffUpload.Next = 0;
                        end;
                    end
                    else if CheckOffHeader."Calculation Type" = CheckOffHeader."Calculation Type"::"Block Amount" then begin
                        MemberSubscriptions.Reset;
                        MemberSubscriptions.SetRange("Source Code", CheckoffLines."Member No");
                        MemberSubscriptions.SetCurrentKey(Priority);
                        MemberSubscriptions.SetAscending(Priority, true);
                        if MemberSubscriptions.FindSet then begin
                            repeat
                                if SaccoProducts.Get(MemberSubscriptions."Account Type") then begin
                                    if BaseAmount > Round(MemberSubscriptions.Amount) then begin
                                        RecoveredAmount := Round(MemberSubscriptions.Amount);
                                        BaseAmount -= RecoveredAmount;
                                    end
                                    else begin
                                        RecoveredAmount := Round(BaseAmount);
                                        BaseAmount := 0;
                                    end;
                                    CheckOffCalculations[1].Init();
                                    CheckOffCalculations[1]."Document No" := DocumentNo;
                                    CheckOffCalculations[1]."Member No" := CheckoffLines."Member No";
                                    CheckOffCalculations[1]."Check No" := CheckoffLines."Check No";
                                    CheckOffCalculations[1]."Entry No" := GetCheckOffEntryNo(DocumentNo, CheckoffLines."Member No", CheckoffLines."Check No");
                                    CheckOffCalculations[1]."Account No" := MemberManagement.GetMemberAccountByProductCode(CheckoffLines."Member No", SaccoProducts.Code);
                                    if Vendor.Get(CheckOffCalculations[1]."Account No") then CheckOffCalculations[1]."Account Name" := Vendor.Name;
                                    if SaccoProducts."Product Posting Type" = SaccoProducts."Product Posting Type"::"Loan Account" then begin
                                        CheckOffCalculations[1]."Entry Type" := CheckOffCalculations[1]."Entry Type"::"Loan Recovery";
                                        Loans.Reset();
                                        Loans.SetRange("Loan Account", CheckOffCalculations[1]."Account No");
                                        Loans.SetRange("Member No.", MemberNo);
                                        if not Loans.FindFirst then
                                            CheckOffCalculations[1].UnMatched := true
                                        else
                                            CheckOffCalculations[1].UnMatched := false;
                                    end
                                    else begin
                                        CheckOffCalculations[1]."Entry Type" := CheckOffCalculations[1]."Entry Type"::"Internal Deposit";
                                        if not Vendor.Get(CheckOffCalculations[1]."Account No") then
                                            CheckOffCalculations[1].UnMatched := true
                                        else
                                            CheckOffCalculations[1].UnMatched := false;
                                    end;
                                    CheckOffCalculations[1].Amount := RecoveredAmount;
                                    CheckOffCalculations[1]."Amount Base" := RecoveredAmount;
                                    CheckOffCalculations[1]."Loan No" := '';
                                    if CheckOffCalculations[1].Amount <> 0 then CheckOffCalculations[1].Insert();
                                end;
                            until ((BaseAmount = 0) or (MemberSubscriptions.Next = 0));
                        end;
                        if (BaseAmount <> 0) then begin
                            RecoveredAmount := BaseAmount;
                            CheckOffCalculations[1].Init();
                            CheckOffCalculations[1]."Document No" := DocumentNo;
                            CheckOffCalculations[1]."Member No" := CheckoffLines."Member No";
                            CheckOffCalculations[1]."Check No" := CheckoffLines."Check No";
                            CheckOffCalculations[1]."Entry No" := GetCheckOffEntryNo(DocumentNo, CheckoffLines."Member No", CheckoffLines."Check No");
                            CheckOffCalculations[1]."Entry Type" := CheckOffCalculations[1]."Entry Type"::"Internal Deposit";
                            CheckOffCalculations[1].Amount := RecoveredAmount;
                            CheckOffCalculations[1]."Amount Base" := RecoveredAmount;
                            CheckOffCalculations[1]."Account No" := MemberManagement.GetMemberAccount(CheckoffLines."Member No", ProductPostingType::"School Fee Account");
                            if Vendor.Get(CheckOffCalculations[1]."Account No") then CheckOffCalculations[1]."Account Name" := Vendor.Name;
                            CheckOffCalculations[1]."Loan No" := '';
                            if CheckOffCalculations[1].Amount <> 0 then CheckOffCalculations[1].Insert();
                        end;
                    end;
                end;
            until CheckoffLines.Next() = 0;
            Window.Close;
        end;
    end;

    local procedure GetMemberAccountWithRemark(MemberNo: Code[20]; Refrence: Code[20]; var CheckoffEntriesTypes: Enum "Checkoff Entries Types"; var AccountNo: Code[20]; var AccountName: Text[150])
    var
        Vendor: Record Vendor;
        SaccoProducts: Record "Sacco Products";
    begin
        SaccoProducts.Reset();
        SaccoProducts.SetRange(Code, Refrence);
        if SaccoProducts.FindFirst() then begin
            AccountName := SaccoProducts.Description;
            Vendor.Reset();
            Vendor.SetRange("Member No.", MemberNo);
            Vendor.SetRange("Product Code", SaccoProducts.Code);
            if Vendor.FindFirst() then AccountNo := Vendor."No.";
            if SaccoProducts."Product Posting Type" = SaccoProducts."Product Posting Type"::"Loan Account" then
                CheckoffEntriesTypes := CheckoffEntriesTypes::"Loan Recovery"
            else
                CheckoffEntriesTypes := CheckoffEntriesTypes::"Internal Deposit";
        end;
    end;

    procedure GetMemberNo(CheckNo: Code[20]; EmployerCode: Code[20]; SearchType: Enum "CheckOff Search Type") MemberNo: Code[20]
    var
        Vendor: Record Vendor;
        Members: Record Members;
    begin
        case SearchType of
            SearchType::"Member Number":
                begin
                    if Members.Get(CheckNo) then begin
                        MemberNo := Members."No.";
                        exit(MemberNo);
                    end
                    else
                        exit('SUSP:' + CheckNo);
                end;
            SearchType::"ID Number":
                begin
                    Members.Reset();
                    Members.SetRange("Identification No.", CheckNo);
                    if Members.FindFirst() then begin
                        MemberNo := Members."No.";
                        exit(MemberNo);
                    end
                    else
                        exit('SUSP:' + CheckNo);
                end;
            SearchType::"FOSA Number":
                begin
                    if Vendor.get(CheckNo) then begin
                        MemberNo := Vendor."Member No.";
                        exit(MemberNo);
                    end
                    else
                        exit('SUSP:' + CheckNo);
                end;
            SearchType::"Payroll Number":
                begin
                    Members.Reset();
                    Members.SetRange("Payroll No.", CheckNo);
                    Members.SetRange("Employer Code", EmployerCode);
                    if Members.FindFirst() then begin
                        MemberNo := Members."No.";
                        exit(MemberNo);
                    end
                    else
                        exit('SUSP:' + CheckNo);
                end;
            SearchType::"Old FOSA Number":
                begin
                    if CheckNo = '' then
                        exit('SUSP:' + CheckNo)
                    else begin
                        Members.Reset();
                        Members.SetRange("Old No.", CheckNo);
                        if Members.FindFirst() then begin
                            MemberNo := Members."No.";
                            exit(MemberNo);
                        end
                        else
                            exit('SUSP:' + CheckNo);
                    end;
                end;
        end;
    end;

    procedure PostCheckoff(DocumentNo: Code[20])
    var
        CheckoffHeader: Record "Checkoff Header";
        CheckoffLines: Record "Checkoff Lines";
        CheckoffCalculation: Record "Checkoff Calculation";
        AccountNo, ExternalDocumentNo, MemberNo, JournalBatch, JournalTemplate, Dim1, Dim2, ReasonCode, SourceCode : Code[20];
        LineNo, All, Current : Integer;
        JournalManagement: Codeunit "Journal Management";
        Window: Dialog;
        PostingDate: Date;
        PostingDescription: Text[100];
        BaseAmount, PostingAmount, PenaltyBalance, InterestBalance, Principalbalance, PenaltyPaid, InterestPaid, PrincipalPaid, UnAllocatedAmount : Decimal;
        StandingOrder: Record "Standing Order";
        Loans: Record Loans;
        ProductFactory: Record "Sacco Products";
        SaccoSetup: Record "General Ledger Setup";
        LoansMgt: Codeunit "Loans Management";
        LoanProduct: Record "Sacco Products";
        OutstandingPrincipal, OutstandingInterest : decimal;
    begin
        JournalBatch := 'CHECKOFF';
        JournalTemplate := 'GENERAL';
        LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);

        CheckoffHeader.Get(DocumentNo);
        PostingDate := CheckoffHeader."Posting Date";

        CheckoffHeader.TestField("Balancing Account No");
        if CheckoffHeader."Upload Type" = CheckoffHeader."Upload Type"::Checkoff then
            GlobalTransactionType[1] := GlobalTransactionType[1] ::"Checkoff Pay"
        else
            GlobalTransactionType[1] := GlobalTransactionType[1] ::"End Month Salary";
        PostingDescription := CheckoffHeader."Posting Description";
        //Debit Balancing Account
        AccountNo := CheckoffHeader."Balancing Account No";
        PostingAmount := CheckoffHeader.Amount;
        if CheckoffHeader."Balancing Account Type" = CheckoffHeader."Balancing Account Type"::Receivable then
            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Customer, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType[1], LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, Journalbatch)
        else if CheckoffHeader."Balancing Account Type" = CheckoffHeader."Balancing Account Type"::"Bank Account" then
            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"Bank Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType[1], LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, Journalbatch)
        else if CheckoffHeader."Balancing Account Type" = CheckoffHeader."Balancing Account Type"::"G/L Account" then LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType[1], LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
        //Post Sacco 360
        if CheckoffHeader."Sacco 360" then begin
            PostingAmount := 0;
            PostingAmount := CheckoffHeader."Bank Charges";
            AccountNo := '';
            AccountNo := CheckoffHeader."Bank Charges Income Account";
            PostingDescription := '';
            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType[1], LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, Journalbatch);
        end;
        CheckoffLines.Reset();
        CheckoffLines.SetRange("No.", DocumentNo);
        CheckoffLines.SetRange(Posted, false);
        if CheckoffLines.FindSet() then begin
            All := CheckoffLines.Count;
            Current := 1;
            Window.Open('Posting \#1### \@2@@@');
            repeat
                Window.Update(1, CheckoffLines."Member Name");
                Window.Update(2, StrSubstNo('%1%', Round((Current / All) * 100, 0.01)));
                Window.HideSubsequentDialogs;
                Current += 1;
                ReasonCode := Format(PostingDate);
                MemberNo := CheckoffLines."Member No";
                AccountNo := '';
                ExternalDocumentNo := DocumentNo;
                PostingDescription := CheckoffHeader."Posting Description";
                if CheckoffLines."Suspense Account" then begin
                    PostingDescription := copystr(StrSubstNo('%1 : Supsense Check No.: %2', CheckoffHeader."Posting Description", CheckoffLines."Check No"), 1, 50);
                    AccountNo := '';
                    AccountNo := CheckoffLines."Collections Account";
                    CheckoffLines.CalcFields("Amount Earned");
                    PostingAmount := Abs(CheckoffLines."Amount Earned");
                    if CheckoffHeader."Balancing Account Type" = CheckoffHeader."Balancing Account Type"::Receivable then
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Customer, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType[1], LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch)
                    else if CheckoffHeader."Balancing Account Type" = CheckoffHeader."Balancing Account Type"::"Bank Account" then
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"Bank Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType[1], LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch)
                    else if CheckoffHeader."Balancing Account Type" = CheckoffHeader."Balancing Account Type"::"G/L Account" then LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType[1], LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                end
                else begin
                    if (CheckoffHeader."Upload Type" = CheckoffHeader."Upload Type"::Salary) then begin
                        AccountNo := '';
                        AccountNo := CheckoffLines."Collections Account";
                        CheckoffLines.CalcFields("Amount Earned", Commission);
                        PostingAmount := Abs(CheckoffLines."Amount Earned");
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType[1], LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, 'Processing Fees', CheckoffLines.Commission, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType[1], LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                        LineNo := JournalManagement.AddCharges(CheckoffHeader."Charge Code", AccountNo, PostingAmount, LineNo, DocumentNo, MemberNo, SourceCode, ReasonCode, ExternalDocumentNo, JournalBatch, JournalTemplate, Dim1, Dim2, PostingDate, false);
                    end;
                end;
                CheckoffCalculation.Reset();
                CheckoffCalculation.SetRange("Document No", DocumentNo);
                CheckoffCalculation.SetRange("Member No", CheckoffLines."Member No");
                CheckoffCalculation.SetFilter("Entry Type", '<>%1&<>%2', CheckoffCalculation."Entry Type"::Commission, CheckoffCalculation."Entry Type"::"Net Amount");
                CheckoffCalculation.SetFilter(Amount, '<>%1', 0);
                if CheckoffCalculation.FindSet() then begin
                    repeat
                        if CheckoffHeader."Upload Type" = CheckoffHeader."Upload Type"::Salary then begin
                            ReasonCode := Format(PostingDate);
                            PostingAmount := 0;
                            PostingAmount := Abs(CheckoffCalculation.Amount);
                            AccountNo := '';
                            AccountNo := CheckoffLines."Collections Account";
                            PostingDescription := '';
                            PostingDescription := CheckoffCalculation."Account Name";
                            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType[1], LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                        end;

                        case CheckoffCalculation."Entry Type" of
                            CheckoffCalculation."Entry Type"::"Internal Deposit":
                                begin
                                    ReasonCode := Format(PostingDate);
                                    PostingAmount := 0;
                                    PostingAmount := CheckoffCalculation.Amount;
                                    if CheckoffHeader."Upload Type" = CheckoffHeader."Upload Type"::Salary then
                                        PostingDescription := CheckoffCalculation."Account Name" + GetDocumentNo(CheckoffHeader."Posting Date")
                                    else
                                        PostingDescription := CheckoffHeader."Posting Description";
                                    AccountNo := '';
                                    AccountNo := CheckoffCalculation."Account No";
                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType[1], LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                end;
                            CheckoffCalculation."Entry Type"::"Standing Order":
                                begin
                                    AccountNo := '';
                                    StandingOrder.Get(CheckoffCalculation."Account No");
                                    LineNo := JournalManagement.AddCharges(StandingOrder."Charge Code", AccountNo, CheckoffCalculation.Amount, LineNo, DocumentNo, MemberNo, SourceCode, ReasonCode, ExternalDocumentNo, JournalBatch, JournalTemplate, Dim1, Dim2, PostingDate, false);

                                    case StandingOrder."Standing Order Class" of
                                        StandingOrder."Standing Order Class"::External:
                                            begin
                                                ReasonCode := Format(PostingDate);
                                                PostingDescription := StrSubstNo('STO: %1 - %2', StandingOrder."No.", StandingOrder."Posting Description");
                                                AccountNo := StandingOrder."Destination Account";
                                                PostingAmount := 0;
                                                PostingAmount := CheckoffCalculation.Amount;
                                                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"Bank Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType[1], LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                            end;
                                        StandingOrder."Standing Order Class"::Internal:
                                            begin
                                                ReasonCode := Format(PostingDate);
                                                PostingDescription := StrSubstNo('STO: %1 - %2', StandingOrder."No.", StandingOrder."Member Name");
                                                AccountNo := StandingOrder."Destination Account";
                                                PostingAmount := 0;
                                                PostingAmount := CheckoffCalculation.Amount;
                                                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType[1], LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                            end;
                                        StandingOrder."Standing Order Class"::"Loan-Principal":
                                            begin
                                                if Loans.Get(StandingOrder."Destination Account") then begin
                                                    Loans.CalcFields("Principal Balance");
                                                    AccountNo := Loans."Loan Account";
                                                    PostingDescription := CopyStr('Principal Paid ' + CheckoffHeader."Posting Description", 1, 50);
                                                    ReasonCode := Loans."No.";
                                                    if Loans."Principal Balance" < 0 then Loans."Principal Balance" := 0;
                                                    if Loans."Principal Balance" < CheckoffCalculation.Amount then begin
                                                        PostingAmount := Loans."Principal Balance";
                                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Principal Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                                        PostingDescription := CopyStr('Standing Order Refund ' + CheckoffHeader."Posting Description", 1, 50);
                                                        PostingAmount := 0;
                                                        PostingAmount := CheckoffCalculation.Amount - Loans."Principal Balance";
                                                        AccountNo := LoansMgt.GetFOSAAccount(Loans."Member No.");
                                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType[1], LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                                    end
                                                    else begin
                                                        PostingAmount := CheckoffCalculation.Amount;
                                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Principal Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                                    end;
                                                end;
                                            end;
                                        StandingOrder."Standing Order Class"::"Loan-Interest":
                                            begin
                                                if Loans.Get(StandingOrder."Destination Account") then begin
                                                    Loans.CalcFields("Interest Balance");
                                                    if Loans."Interest Balance" < 0 then Loans."Interest Balance" := 0;
                                                    AccountNo := Loans."Loan Account";
                                                    PostingDescription := CopyStr('Interest Paid ' + CheckoffHeader."Posting Description", 1, 50);
                                                    ReasonCode := Loans."No.";
                                                    if Loans."Interest Balance" < CheckoffCalculation.Amount then begin
                                                        PostingAmount := Loans."Interest Balance";
                                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                                        SaccoSetup.Get();
                                                        if SaccoSetup."Interest Accrual Type" = SaccoSetup."Interest Accrual Type"::"Cash Basis" then begin
                                                            LoanProduct.Get(Loans."Product Code");
                                                            AccountNo := LoanProduct."Interest Paid Account";
                                                            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                                            AccountNo := LoanProduct."Interest Due Account";
                                                            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                                        end;
                                                        PostingDescription := CopyStr('Standing Order Refund ' + CheckoffHeader."Posting Description", 1, 50);
                                                        PostingAmount := 0;
                                                        PostingAmount := CheckoffCalculation.Amount - Loans."Interest Balance";
                                                        ReasonCode := '';
                                                        AccountNo := LoansMgt.GetFOSAAccount(Loans."Member No.");
                                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType[1], LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                                    end
                                                    else begin
                                                        PostingAmount := CheckoffCalculation.Amount;
                                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                                        SaccoSetup.Get();
                                                        if SaccoSetup."Interest Accrual Type" = SaccoSetup."Interest Accrual Type"::"Cash Basis" then begin
                                                            LoanProduct.Get(Loans."Product Code");
                                                            AccountNo := LoanProduct."Interest Paid Account";
                                                            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                                            AccountNo := LoanProduct."Interest Due Account";
                                                            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                                        end;
                                                    end;
                                                end;
                                            end;
                                        StandingOrder."Standing Order Class"::"Loan Principal+Interest":
                                            begin
                                                if Loans.Get(StandingOrder."Destination Account") then begin
                                                    ReasonCode := Loans."No.";
                                                    Loans.CalcFields("Penalty Balance", "Interest Balance", "Principal Balance");
                                                    BaseAmount := 0;
                                                    PenaltyBalance := 0;
                                                    PenaltyPaid := 0;
                                                    InterestBalance := 0;
                                                    InterestPaid := 0;
                                                    PrincipalBalance := 0;
                                                    PrincipalPaid := 0;
                                                    UnAllocatedAmount := 0;

                                                    BaseAmount := CheckoffCalculation.Amount;
                                                    PenaltyBalance := Loans."Penalty Balance";
                                                    InterestBalance := Loans."Interest Balance";
                                                    Principalbalance := Loans."Principal Balance";

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
                                                    PostingDescription := StrSubstNo('STO : %1, Penalty Paid', StandingOrder."No.");
                                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Penalty Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);

                                                    //Interest Paid
                                                    PostingDescription := StrSubstNo('STO : %1, Interest Paid', StandingOrder."No.");
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

                                                    //Principal Paid
                                                    PostingDescription := StrSubstNo('STO : %1, Principal Paid', StandingOrder."No.");
                                                    PostingAmount := PrincipalPaid;
                                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Principal Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);

                                                    PostingDescription := CopyStr('Checkoff Standing Order Refund ' + CheckoffHeader."Posting Description", 1, 50);
                                                    PostingAmount := UnAllocatedAmount;
                                                    AccountNo := LoansMgt.GetFOSAAccount(Loans."Member No.");
                                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, LoansMgt.GetFOSAAccount(MemberNo), PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                                end;
                                            end;
                                    end;
                                end;
                            CheckoffCalculation."Entry Type"::"Loan Recovery":
                                begin
                                    BaseAmount := 0;
                                    PenaltyBalance := 0;
                                    PenaltyPaid := 0;
                                    InterestBalance := 0;
                                    InterestPaid := 0;
                                    PrincipalBalance := 0;
                                    PrincipalPaid := 0;
                                    UnAllocatedAmount := 0;
                                    BaseAmount := Abs(CheckoffCalculation.Amount);
                                    PostingDescription := '';

                                    Loans.Reset();
                                    Loans.SetRange("Loan Account", CheckoffCalculation."Account No");
                                    If CheckoffHeader."Upload Type" = CheckoffHeader."Upload Type"::Checkoff then
                                        Loans.SetFilter("Repayment Start Date", '<=%1', PostingDate);
                                    Loans.SetFilter("Loan Balance", '>%1', 0);
                                    if Loans.FindFirst then begin
                                        repeat
                                            ReasonCode := Loans."No.";
                                            Loans.CalcFields("Penalty Balance", "Principal Balance", "Interest Balance", "Loan Balance");
                                            PenaltyBalance := Loans."Penalty Balance";
                                            InterestBalance := Loans."Interest Balance";
                                            Principalbalance := Loans."Principal Balance";

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

                                            AccountNo := Loans."Loan Account";

                                            //Penalty Paid
                                            PostingAmount := 0;
                                            PostingAmount := PenaltyPaid;
                                            PostingDescription := StrSubstNo('%1, Penalty Paid', CheckoffHeader."Posting Description");
                                            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Penalty Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);

                                            //Interest Paid
                                            PostingAmount := 0;
                                            PostingAmount := InterestPaid;
                                            PostingDescription := StrSubstNo('%1, Interest Paid', CheckoffHeader."Posting Description");
                                            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                            SaccoSetup.Get();
                                            if SaccoSetup."Interest Accrual Type" = SaccoSetup."Interest Accrual Type"::"Cash Basis" then begin
                                                LoanProduct.Get(Loans."Product Code");
                                                AccountNo := LoanProduct."Interest Paid Account";
                                                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                                AccountNo := LoanProduct."Interest Due Account";
                                                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                            end;

                                            //Principal Paid
                                            PostingAmount := 0;
                                            PostingAmount := PrincipalPaid;
                                            PostingDescription := StrSubstNo('%1, Principal Paid', CheckoffHeader."Posting Description");
                                            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Principal Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                        until Loans.Next = 0;

                                        if BaseAmount <> 0 then
                                            UnAllocatedAmount := BaseAmount;

                                        if UnallocatedAmount <> 0 then begin
                                            PostingAmount := 0;
                                            PostingAmount := UnAllocatedAmount;
                                            PostingDescription := StrSubstNo('%1 : Unallocated Amount', CheckoffHeader."Posting Description");
                                            LineNo := JournalManagement.CreateUnallocationJournalLine(GlobalAccountType::Vendor, '', PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, Loans."Member No.", DocumentNo, GlobalTransactionType::"Acc. Transfer", LineNo, Loans."Product Code", Loans."No.", Loans."Member No.", JournalTemplate, JournalBatch);
                                        end;
                                    end
                                    else begin
                                        //Post Unallocated Amount
                                        PostingAmount := 0;
                                        PostingAmount := CheckoffCalculation.Amount;
                                        PostingDescription := StrSubstNo('%1 : Unallocated Amount', CheckoffHeader."Posting Description");
                                        LineNo := JournalManagement.CreateUnallocationJournalLine(GlobalAccountType::Vendor, '', PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType[1], LineNo, SourceCode, ReasonCode, ExternalDocumentNo, JournalTemplate, JournalBatch);
                                        CheckoffCalculation.UnMatched := true;
                                        CheckoffCalculation.Modify(true);
                                    end;
                                end;
                        end;
                    until CheckoffCalculation.Next() = 0;
                end;
                Commit();
            until CheckoffLines.Next() = 0;
            Window.Close;
        end;
        JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("Document Date", PostingDate);
        if GLEntry.FindFirst() then begin
            CheckoffHeader.Validate(Posted, true);
            CheckoffHeader.Modify();
            Commit();
            OnAfterCommitPostCheckoff(DocumentNo);
        end;
    end;

    procedure SendSalarySMS(SalaryNo: Code[20])
    var
        SMSText, SMSNo : Text[250];
        AvailableBalance: Decimal;
        SMSSource: Code[20];
        CheckoffHeader: Record "Checkoff Header";
        CheckoffLines: Record "Checkoff Lines";
        Members: Record Members;
        SMSSend: Codeunit "Notifications Management";
        ChannelsIntegrations: Codeunit "Channels Integrations";
        CheckoffMgt: Codeunit "Checkoff Management";
        CompanyInfo: Record "Company Information";
        Vendor: Record Vendor;
        SaccoProduct: Record "Sacco Products";
    begin
        SMSSource := 'UPLOAD_PROCESSING';
        CompanyInfo.Get;
        if CheckoffHeader.Get(SalaryNo) then begin
            CheckoffLines.Reset();
            CheckoffLines.SetRange("No.", CheckoffHeader."No.");
            CheckoffLines.SetRange(Notified, false);
            if CheckoffLines.FindSet() then begin
                repeat
                    if Members.Get(CheckoffLines."Member No") then begin
                        SMSNo := '';
                        SMSText := '';
                        SMSSource := 'Salary';
                        SMSNo := Members."Mobile Phone No.";
                        CheckoffLines.CalcFields("Amount Earned");
                        Vendor.Get(CheckoffLines."Collections Account");
                        SaccoProduct.Get(Vendor."Product Code");
                        Vendor.CalcFields(Balance, "Uncleared Funds");
                        AvailableBalance := 0;
                        AvailableBalance := Vendor.Balance - Vendor."Uncleared Funds" - SaccoProduct."Minimum Balance" - ChannelsIntegrations.GetPendingChannelsTransactions(Vendor."Member No.");
                        if AvailableBalance < 0 then
                            AvailableBalance := 0;

                        if CheckoffHeader."Upload Type" = CheckoffHeader."Upload Type"::Checkoff then
                            SMSText := 'Dear ' + Members."First Name" + ', Your CheckOff of Kshs. ' + Format(-1 * CheckoffLines."Amount Earned") + ' has been effected successfully ' + Format(CurrentDateTime) + ' .' + CompanyInfo.Name
                        else if CheckoffHeader."Upload Type" = CheckoffHeader."Upload Type"::Salary then
                            SMSText := StrSubstNo('Dear %1, Your %2 of KES %3 has been credited to your FOSA account. Current Available Balance is: %4', Members."First Name", CheckoffHeader."Posting Description", Format(CheckoffLines."Amount Earned"), AvailableBalance);
                        SMSSend.SendSms(SMSNo, SMSText, SMSSource);
                        CheckoffLines.Notified := true;
                        CheckoffLines.Modify();
                        Commit();
                    end;
                until CheckoffLines.Next() = 0;
            end;
        end;
    end;

    internal procedure GetDocumentNo(ParseDate: Date) DocumentNo: Code[20]
    begin
        DocumentNo := '-';
        case Date2DMY(ParseDate, 2) of
            1:
                DocumentNo += 'JAN-';
            2:
                DocumentNo += 'FEB-';
            3:
                DocumentNo += 'MAR-';
            4:
                DocumentNo += 'APR-';
            5:
                DocumentNo += 'MAY-';
            6:
                DocumentNo += 'JUN-';
            7:
                DocumentNo += 'JUL-';
            8:
                DocumentNo += 'AUG-';
            9:
                DocumentNo += 'SEP-';
            10:
                DocumentNo += 'OCT-';
            11:
                DocumentNo += 'NOV-';
            12:
                DocumentNo += 'DEC-';
        end;
        DocumentNo += '-' + Format(Date2DMY(ParseDate, 3));
    end;

    local procedure GetMemberAccountWithRefrence(MemberNo: Code[20]; ProductCode: Code[20]; var AccountCode: Code[20]; var AccountName: Text[150])
    var
        Vendor: Record Vendor;
        AccountType: Record "Sacco Products";
    begin
        AccountType.Reset();
        AccountType.SetRange(Code, ProductCode);
        if AccountType.FindFirst() then begin
            AccountName := AccountType.Description;
            AccountName := AccountType.Description;
            Vendor.Reset();
            Vendor.SetRange("Member No.", MemberNo);
            Vendor.SetRange("Product Code", AccountType.Code);
            if Vendor.FindFirst() then
                AccountCode := Vendor."No."
            else
                AccountCode := '';
        end
        else
            AccountCode := '';
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCommitPostCheckoff(CheckoffNo: Code[20])
    begin
    end;


}
