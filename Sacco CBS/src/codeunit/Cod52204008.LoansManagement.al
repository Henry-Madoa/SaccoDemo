codeunit 52204008 "Loans Management"
{
    var
        DocumentNo, AccountNo, ExternalDocumentNo, JournalBatch, JournalTemplate, Dim1, Dim2, MemberNo, ReasonCode, SourceCode : Code[20];
        PostingDescription: Text[100];
        PostingAmount, PrincipalBalance, ArrearsAmount, PenaltyAmount : Decimal;
        LineNo: Integer;
        PostingDate: Date;
        Loans: Record Loans;
        SaccoProducts: Record "Sacco Products";
        GlobalTransactionType: Enum "Sacco Transaction Type";
        GlobalAccountType: Enum "Gen. Journal Account Type";
        GLEntry: Record "G/L Entry";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        UserMgmtExt: Codeunit "User Management Ext";
        SaccoSetup: Record "General Ledger Setup";
        CompanyInformation: Record "Company Information";
        JournalManagement: Codeunit "Journal Management";

    procedure PostLoanRepayment(DocumentNo: Code[20])
    var
        LoanRepayment: Record "Loan Repayment Header";
        LoanRepaymentLines: Record "Loan Repayment Lines";
        PostingAmount, PenaltyPaid, InterestPaid, PrincipalPaid, BaseAmount, PenaltyBalance, InterestBalance, PrincipalBalance, ChargeAmount, UnallocatedAmount : Decimal;
        SMSText, SMSNo : Text[250];
        SMSMgt: Codeunit "Notifications Management";
        SMSSource: Code[20];
        Members: Record Members;
    begin
        SaccoSetup.Get;
        LoanRepayment.Get(DocumentNo);
        LoanRepayment.CalcFields("Payment Amount");
        if LoanRepayment."Payment Amount" > LoanRepayment."Available Balance" then
            Error('You Cannot Overdraw a Members Account');
        UserMgmtExt.GetUserDimensions(UserId, Dim1, Dim2);
        JournalBatch := 'REPAY';
        JournalTemplate := 'GENERAL';
        LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
        PostingDate := LoanRepayment."Posting Date";
        MemberNo := LoanRepayment."Member No";
        LoanRepaymentLines.Reset();
        LoanRepaymentLines.SetRange("No.", DocumentNo);
        if LoanRepaymentLines.FindSet() then begin
            repeat
                ReasonCode := LoanRepaymentLines."Loan No";
                Loans.Get(ReasonCode);
                if SaccoSetup."Daily Interest Accrual" then
                    PostLoanInterest(LoanRepayment."Posting Date", '', 0, LoanRepayment."Member No", LoanRepaymentLines."Loan No");

                Loans.CalcFields("Penalty Balance", "Interest Balance", "Principal Balance");
                SourceCode := Loans."Product Code";
                SaccoProducts.Get(SourceCode);

                BaseAmount := 0;
                PenaltyBalance := 0;
                PenaltyPaid := 0;
                InterestBalance := 0;
                InterestPaid := 0;
                PrincipalBalance := 0;
                PrincipalPaid := 0;
                UnAllocatedAmount := 0;
                ChargeAmount := 0;
                ChargeAmount := LoanRepaymentLines."Charge Amount";
                BaseAmount := LoanRepaymentLines."Payment Amount" - ChargeAmount;

                PenaltyBalance := Loans."Penalty Balance";
                InterestBalance := Loans."Interest Balance";
                PrincipalBalance := Loans."Principal Balance";

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

                //Penalty Paid
                PostingAmount := 0;
                PostingAmount := PenaltyPaid;
                PostingDescription := 'Penalty Paid ' + Loans."Product Description";
                AccountNo := Loans."Loan Account";
                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Penalty Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                AccountNo := LoanRepayment."Account No";
                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Penalty Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);

                //Pay Interest
                PostingDescription := 'Interest Paid ' + Loans."Product Description";
                AccountNo := Loans."Loan Account";
                PostingAmount := 0;
                PostingAmount := InterestPaid;
                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                AccountNo := LoanRepayment."Account No";
                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                SaccoSetup.Get();
                if SaccoSetup."Interest Accrual Type" = SaccoSetup."Interest Accrual Type"::"Cash Basis" then begin
                    SaccoProducts.Get(Loans."Product Code");
                    AccountNo := SaccoProducts."Interest Paid Account";
                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                    AccountNo := SaccoProducts."Interest Due Account";
                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                end;


                //Pay Principal
                PostingDescription := 'Principal Paid ' + Loans."Product Description";
                AccountNo := Loans."Loan Account";
                PostingAmount := 0;
                PostingAmount := PrincipalPaid;
                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Principal Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                AccountNo := LoanRepayment."Account No";
                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Principal Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);

                if UnallocatedAmount <> 0 then begin
                    //Post Unallocated Amount
                    PostingDescription := 'Unallocated Transfer';
                    AccountNo := LoanRepayment."Account No";
                    PostingAmount := 0;
                    PostingAmount := UnallocatedAmount;
                    LineNo := JournalManagement.CreateUnallocationJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Principal Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, JournalTemplate, JournalBatch);
                end;

                //Add Charge
                AccountNo := LoanRepayment."Account No";
                PostingAmount := 0;
                PostingAmount := LoanRepaymentLines."Payment Amount";
                LineNo := JournalManagement.AddCharges(LoanRepaymentLines."Charge Code", AccountNo, PostingAmount, LineNo, DocumentNo, MemberNo, SourceCode, ReasonCode, ExternalDocumentNo, JournalBatch, JournalTemplate, Dim1, Dim2, PostingDate, true);
            until LoanRepaymentLines.Next() = 0;
        end;
        JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
        GLEntry.Reset();
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("Document Date", PostingDate);
        if GLEntry.FindFirst() then begin
            LoanRepayment.Posted := true;
            LoanRepayment.Modify();
            Members.Get(MemberNo);
            SMSText := 'Dear ' + Members."First Name" + ', Your ' + LoanRepayment."Account Name" + ' has been debited with ' + Format(LoanRepayment."Payment Amount") + ' to pay your loan';
            SMSNo := Members."Mobile Phone No.";
            SMSSource := 'TELLER_LOAN_REP';
            SMSMgt.SendSms(SMSNo, SMSText, SMSSource);
        end;
    end;

    procedure HasDoubleLoan(MemberNo: Code[20]) DoubleLoan: Boolean
    var
        LoanProducts: Record "Sacco Products";
        Loans: Record Loans;
    begin
        DoubleLoan := false;
        LoanProducts.Reset();
        LoanProducts.SetRange("Product Posting Type", LoanProducts."Product Posting Type"::"Loan Account");
        if LoanProducts.FindSet() then begin
            repeat
                Loans.Reset();
                Loans.SetFilter("Loan Balance", '>0');
                Loans.SetRange("Product Code", LoanProducts.Code);
                Loans.SetRange("Member No.", MemberNo);
                if Loans.FindSet() then begin
                    if Loans.Count > 1 then exit(true);
                end;
            until LoanProducts.Next() = 0;
        end;
        exit(DoubleLoan);
        //info@equitybank.co.ke
    end;

    procedure GetExcludedLoans(LoanNo: Code[20]) ExcludedLoans: Decimal
    var
        Loans: array[2] of Record Loans;
        Balance: Decimal;
    begin
        if Loans[1].Get(LoanNo) then begin
            Balance := 0;
            Loans[2].Reset();
            Loans[2].SetRange("Dividend Based", true);
            Loans[2].SetRange("Mobile Loan", true);
            Loans[2].SetRange("Member No.", Loans[1]."Member No.");
            Loans[2].SetRange(Status, Loans[2].Status::Approved);
            Loans[2].SetFilter("Loan Balance", '>0');
            if Loans[2].FindSet then begin
                repeat
                    Loans[2].CalcFields("Loan Balance");
                    Balance += Loans[2]."Loan Balance";
                until Loans[2].Next = 0;
                ExcludedLoans := Balance;
            end;
        end;
        exit(ExcludedLoans);
    end;

    procedure GetOutstandingLoans(LoanNo: Code[20]) OutstandingLoans: Decimal
    var
        LoanRecoveries: Record "Loan Recoveries";
        BridgedAmount, ProratedInterest, Loans : Decimal;
        LoanApplication, LoanApplication12 : Record Loans;
        Member: Record Members;
    begin
        OutstandingLoans := 0;
        BridgedAmount := 0;
        ProratedInterest := 0;
        Loans := 0;
        if LoanApplication.Get(LoanNo) then begin
            /*LoanApplication12.Reset();
            LoanApplication12.SetRange("Member No.", LoanApplication."Member No.");
            LoanApplication12.SetFilter("Loan Balance", '>0');
            if LoanApplication12.FindSet() then begin
                repeat
                    LoanApplication12.CalcFields("Loan Balance");
                    Loans += LoanApplication12."Loan Balance";
                until LoanApplication12.Next() = 0;
              end;*/
            if Member.Get(LoanApplication."Member No.") then begin
                Member.CalcFields("Outstanding Loans");
                Loans := Member."Outstanding Loans";
            end;
            LoanRecoveries.Reset();
            LoanRecoveries.SetRange("Loan No", LoanNo);
            LoanRecoveries.SetRange("Recovery Type", LoanRecoveries."Recovery Type"::Loan);
            if LoanRecoveries.FindSet() then begin
                LoanRecoveries.CalcSums(Amount, "Prorated Interest");
                BridgedAmount := LoanRecoveries.Amount;
            end;
            OutstandingLoans := Loans - BridgedAmount;
            exit(OutstandingLoans);
        end
        else
            exit(0);
    end;

    procedure GetBatchNo(Loans: Record Loans) BatchNo: Code[20]
    var
        LoanBatchLines: Record "Loan Batch Lines";
    begin
        BatchNo := '';
        LoanBatchLines.Reset();
        LoanBatchLines.SetRange("Loan No", Loans."No.");
        if LoanBatchLines.FindFirst() then exit(LoanBatchLines."No.");
    end;

    procedure GetLoanAge(LoanNo: Code[20]; AsAtDate: Date; var DefaultedPrincipal: Decimal; var PrincipalPaid: Decimal; var PrincipalDue: Decimal; var MonthlyPrincipal: Decimal) LAge: Integer
    var
        Loans: Record Loans;
        DateFilter: Text;
        LoanSchedule: Record "Loan Schedule";
    begin
        DateFilter := '..' + Format(AsAtDate);
        MonthlyPrincipal := 0;
        LoanSchedule.Reset();
        LoanSchedule.SetRange("Loan No.", LoanNo);
        LoanSchedule.SetFilter("Expected Date", DateFilter);
        if LoanSchedule.FindLast() then MonthlyPrincipal := LoanSchedule."Principal Repayment";
        Loans.Reset();
        Loans.SetFilter("Date Filter", DateFilter);
        Loans.SetRange("No.", LoanNo);
        if Loans.FindSet() then begin
            if Loans."Repayment Start Date" = 0D then begin
                DefaultedPrincipal := 0;
                exit(0);
            end;
            Loans.CalcFields("Principal Repayment", "Net Change-Principal");
            PrincipalDue := Loans."Principal Repayment";
            PrincipalPaid := Loans."Approved Amount" - Loans."Net Change-Principal";
            if PrincipalPaid < 0 then PrincipalPaid := 0;
        end;
        LAge := AsAtDate - Loans."Repayment Start Date";
        LAge := Round((LAge / 30), 1, '>');
        DefaultedPrincipal := 0;
        DefaultedPrincipal := PrincipalDue - PrincipalPaid;
        if DefaultedPrincipal < 0 then DefaultedPrincipal := 0;
        exit(LAge);
    end;

    procedure GetGrossAmount(LoanApplication: Code[20]) GrossAmount: Decimal
    var
        AppraisalParameters: Record "Loanees Payroll Codes";
        LoanPayslip: Record "Loanees Payroll Transactions";
    begin
        GrossAmount := 0;
        LoanPayslip.Reset();
        LoanPayslip.SetRange("Source No.", LoanApplication);
        if LoanPayslip.FindSet() then begin
            repeat
                if AppraisalParameters.Get(LoanPayslip.Code, AppraisalParameters.Type::Income) then begin
                    GrossAmount += LoanPayslip.Amount;
                end;
            until LoanPayslip.Next() = 0;
        end;
        exit(GrossAmount);
    end;

    procedure GetCollateralValueOnLoan(DocumentNo: Code[20]; LoanNo: Code[20]) OutstandingValue: Decimal
    var
        LoanColateral: Record "Loan Securities";
        Loans: Record Loans;
        Ratio1, Ratio2 : Decimal;
        ColateralRegister: Record "Collateral Register";
    begin
        if ColateralRegister.Get(DocumentNo) then begin
            LoanColateral.Reset();
            LoanColateral.SetRange("Loan No", LoanNo);
            LoanColateral.SetRange("Security Type", LoanColateral."Security Type"::Collateral);
            LoanColateral.SetRange("Security Code", DocumentNo);
            if LoanColateral.FindFirst() then begin
                if Loans.Get(LoanColateral."Loan No") then begin
                    Loans.CalcFields("Loan Balance", "Total Securities", "Total Guarantees");
                    if Loans."Loan Balance" <= 0 then
                        exit(ColateralRegister."Collateral Value")
                    else begin
                        if Loans."Total Guarantees" > 0 then
                            Ratio1 := Loans."Total Securities" / Loans."Total Guarantees"
                        else
                            Ratio1 := 1;
                        if Loans."Total Securities" = 0 then
                            exit(ColateralRegister."Collateral Value")
                        else begin
                            Ratio2 := LoanColateral.Guarantee / Loans."Total Securities";
                            OutstandingValue := Ratio1 * Ratio2 * Loans."Loan Balance";
                            exit(OutstandingValue);
                        end;
                    end;
                end
                else
                    exit(0);
            end
            else
                exit(ColateralRegister."Collateral Value");
        end
        else
            exit(0);
    end;

    procedure GetCollateralValue(DocumentNo: Code[20]) CurrentValue: Decimal
    var
        ColateralRegister: Record "Collateral Register";
        LoanColateral: Record "Loan Securities";
        LoanAmount, LoanBalance, Ratio : Decimal;
    begin
        if ColateralRegister.Get(DocumentNo) then begin
            LoanColateral.Reset();
            LoanColateral.SetRange("Security Code", DocumentNo);
            if LoanColateral.FindSet() then begin
                repeat
                    CurrentValue += GetCollateralValueOnLoan(DocumentNo, LoanColateral."Loan No");
                until LoanColateral.Next() = 0;
                exit(CurrentValue);
            end
            else
                exit(ColateralRegister."Collateral Value");
        end
        else
            exit(0);
    end;

    procedure ClassifyLoan(LoanNo: Code[20]; AsAtDate: Date)
    var
        DateFilter: Text;
        Loans: Record Loans;
        DefaultedDays, TenureDefaultedDays : Integer;
        ProductFactory: Record "Sacco Products";
        DefaultedInstallments, ExpectedPrincipal, ExpectedInterest, PrincipalPaid, InterestPaid, PrincipalArrears, InterestArrears, TotalArrears, PrincipalInstallment, MonthlyInstallment : Decimal;
    begin
        DateFilter := '..' + Format(AsAtDate);

        if Loans.Get(LoanNo) then begin
            Loans.CalcFields("Monthly Installment", "Monthly Principal");
            MonthlyInstallment := Loans."Monthly Installment";
            PrincipalInstallment := Loans."Monthly Principal";
        end;

        Loans.Reset();
        Loans.SetFilter("Date Filter", DateFilter);
        Loans.SetRange("No.", LoanNo);
        if Loans.FindSet() then begin
            if ProductFactory.Get(Loans."Product Code") then begin
                if ((ProductFactory."Dividend Based") or (Loans.Category = Loans.Category::HR) or (Loans.Category = Loans.Category::DEBT)) then begin
                    DefaultedDays := 0;
                    Loans."Loan Classification" := Loans."Loan Classification"::Performing;
                    Loans."Defaulted Days" := 0;
                    Loans."Defaulted Installments" := 0;
                    Loans."Total Arrears" := 0;
                    Loans."Principal Arrears" := 0;
                    Loans."Interest Arrears" := 0;
                end
                else begin
                    Loans.CalcFields("Principal Balance", "Principal Repayment", "Interest Paid", "Total Interest Due", "Loan Balance");
                    if Loans."Loan Balance" > 0 then begin
                        ExpectedPrincipal := Loans."Principal Repayment";
                        PrincipalPaid := Loans."Approved Amount" - Loans."Principal Balance";
                        if PrincipalPaid < 0 then
                            PrincipalPaid := 0;
                        InterestPaid := Loans."Interest Paid";
                        ExpectedInterest := Loans."Total Interest Due";
                        InterestArrears := ExpectedInterest + InterestPaid;
                        if InterestArrears < 0 then
                            InterestArrears := 0;
                        PrincipalArrears := ExpectedPrincipal - PrincipalPaid;

                        if PrincipalArrears < 0 then
                            PrincipalArrears := 0;

                        TotalArrears := PrincipalArrears + InterestArrears;

                        // if MonthlyInstallment > 0 then
                        //     DefaultedInstallments := TotalArrears / MonthlyInstallment
                        // else
                        //     DefaultedInstallments := 0;

                        if PrincipalInstallment > 0 then
                            DefaultedInstallments := PrincipalArrears / PrincipalInstallment
                        else
                            DefaultedInstallments := 0;

                        DefaultedDays := Round((DefaultedInstallments * 30), 1, '>');

                        If Loans."Repayment End Date" < AsAtDate then
                            TenureDefaultedDays := Round((AsAtDate - Loans."Repayment End Date"), 1, '>');

                        If TenureDefaultedDays > DefaultedDays then
                            DefaultedDays := TenureDefaultedDays;

                        if DefaultedDays < 0 then DefaultedDays := 0;

                        IF DefaultedDays = 0 THEN BEGIN
                            Loans."Loan Classification" := Loans."Loan Classification"::Performing;
                            Loans."Defaulted Days" := 0;
                            Loans."Defaulted Installments" := 0;
                            Loans."Total Arrears" := 0;
                            Loans."Principal Arrears" := 0;
                            Loans."Interest Arrears" := 0;
                        END
                        ELSE IF ((DefaultedDays > 0) AND (DefaultedDays <= 30)) THEN BEGIN
                            Loans."Loan Classification" := Loans."Loan Classification"::Performing;
                            Loans."Defaulted Days" := 0;
                            Loans."Defaulted Installments" := 0;
                            Loans."Total Arrears" := 0;
                            Loans."Principal Arrears" := 0;
                            Loans."Interest Arrears" := 0;
                        END
                        ELSE IF ((DefaultedDays > 30) AND (DefaultedDays <= 90)) THEN BEGIN
                            Loans."Loan Classification" := Loans."Loan Classification"::Watch;
                        END
                        ELSE IF ((DefaultedDays > 90) AND (DefaultedDays <= 180)) THEN BEGIN
                            Loans."Loan Classification" := Loans."Loan Classification"::Substandard;
                        END
                        ELSE IF ((DefaultedDays > 180) AND (DefaultedDays <= 365)) THEN BEGIN
                            Loans."Loan Classification" := Loans."Loan Classification"::Doubtfull;
                        END
                        ELSE BEGIN
                            Loans."Loan Classification" := Loans."Loan Classification"::Loss;
                        end;
                        DefaultedDays := DefaultedDays - 30;
                        If DefaultedDays < 0 then
                            DefaultedDays := 0;
                        Loans."Defaulted Days" := DefaultedDays;
                        Loans.Closed := false;
                        Loans."Total Arrears" := TotalArrears;
                        Loans."Principal Arrears" := PrincipalArrears;
                        Loans."Interest Arrears" := InterestArrears;
                        Loans."Defaulted Installments" := Round((DefaultedDays / 30), 1, '>');
                    end
                    else begin
                        Loans."Loan Classification" := Loans."Loan Classification"::Performing;
                        Loans."Defaulted Days" := 0;
                        Loans."Defaulted Installments" := 0;
                        Loans."Total Arrears" := 0;
                        Loans."Principal Arrears" := 0;
                        Loans."Interest Arrears" := 0;
                    end;
                end;
                Loans.Modify();
            end;
        end;
    end;

    procedure PopulateGuarantorRatios(DocumentNo: Code[20])
    var
        SaccoSetup: Record "General Ledger Setup";
        RecoveryHeader: Record "Loan Recovery Header";
        LoanRecoveryAccounts: Record "Loan Recovey Accounts";
        Ratio, TotalGuarantee : Decimal;
        RecoveryLines: Record "Loan Recovery Lines";
        LoanGuarantees: Record "Loan Guarantees";
        Vendor: Record Vendor;
        LoansMgt: Codeunit "Loans Management";
        MemberMgt: Codeunit "Member Management";
        LoanBal: Decimal;
    begin
        SaccoSetup.Get();
        RecoveryHeader.Get(DocumentNo);
        LoanRecoveryAccounts.Reset();
        LoanRecoveryAccounts.SetRange("Document No", RecoveryHeader."No.");
        if LoanRecoveryAccounts.FindSet() then
            LoanRecoveryAccounts.DeleteAll();

        RecoveryLines.Reset();
        RecoveryLines.SetRange("No.", RecoveryHeader."No.");
        if RecoveryLines.FindSet() then
            RecoveryLines.DeleteAll();

        LoanBal := RecoveryHeader."Total Recoverable";

        Vendor.Reset();
        Vendor.SetRange("Member No.", RecoveryHeader."Member No");
        Vendor.SetFilter(Balance, '>0');
        Vendor.SetRange("Product Posting Type", Vendor."Product Posting Type"::"Non Withdrawable Deposit");
        Vendor.SetCurrentKey("Loan Recovery Priority");
        Vendor.SetAscending("Loan Recovery Priority", true);
        Vendor.SetRange(Blocked, 0);
        if Vendor.FindSet() then begin
            repeat
                Vendor.CalcFields(Balance);
                LoanRecoveryAccounts.Init();
                LoanRecoveryAccounts."Document No" := RecoveryHeader."No.";
                LoanRecoveryAccounts."Account No" := Vendor."No.";
                LoanRecoveryAccounts."Account Name" := Vendor.Name;
                LoanRecoveryAccounts."Current Balance" := Vendor.Balance;
                if LoanBal > Vendor.Balance then begin
                    LoanRecoveryAccounts."Recovery Amount" := Vendor.Balance;
                    LoanBal -= Vendor.Balance;
                end
                else begin
                    LoanRecoveryAccounts."Recovery Amount" := LoanBal;
                    LoanBal := 0;
                end;
                LoanRecoveryAccounts.Insert();
            until ((Vendor.Next() = 0) or (LoanBal = 0));
        end;
        RecoveryHeader.CalcFields("Self Recovery Amount");

        if (RecoveryHeader."Total Recoverable" - RecoveryHeader."Self Recovery Amount") > 0 then begin
            LoanGuarantees.Reset();
            LoanGuarantees.SetRange("Loan No", RecoveryHeader."Loan No");
            LoanGuarantees.SetRange(Substituted, false);
            if LoanGuarantees.FindSet() then begin
                LoanGuarantees.CalcSums("Guaranteed Amount");
                TotalGuarantee := LoanGuarantees."Guaranteed Amount";
            end;
            LoanGuarantees.Reset();
            LoanGuarantees.SetRange(Substituted, false);
            LoanGuarantees.SetRange("Loan No", RecoveryHeader."Loan No");
            if LoanGuarantees.FindSet() then begin
                repeat
                    RecoveryLines.Init();
                    RecoveryLines."No." := RecoveryHeader."No.";
                    RecoveryLines."Member No" := LoanGuarantees."Member No.";
                    RecoveryLines."Member Name" := LoanGuarantees."Member Name";
                    RecoveryLines."Member Deposits" := LoansMgt.GetMemberDeposits(RecoveryLines."Member No");
                    RecoveryLines."Outstanding Guarantee" := MemberMgt.GetOutstandingGuarantee(RecoveryHeader."Loan No", LoanGuarantees."Member No.");
                    RecoveryLines.Insert();
                until LoanGuarantees.Next() = 0;

                RecoveryLines.Reset();
                RecoveryLines.SetRange("No.", DocumentNo);
                if RecoveryLines.FindSet() then begin
                    repeat
                        LoanGuarantees.Reset();
                        LoanGuarantees.SetRange("Loan No", RecoveryHeader."Loan No");
                        LoanGuarantees.SetRange("Member No.", RecoveryLines."Member No");
                        if LoanGuarantees.FindSet() then Ratio := LoanGuarantees."Guaranteed Amount" / TotalGuarantee;
                        RecoveryLines."Recovery Type" := RecoveryLines."Recovery Type"::"Guarantor Liability Loan";
                        RecoveryLines."Product Code" := SaccoSetup."Defaulter Loan Product";
                        RecoveryLines."Recovery Amount" := Round(Ratio * (RecoveryHeader."Total Recoverable" - RecoveryHeader."Self Recovery Amount"));
                        RecoveryLines.Modify();
                    until RecoveryLines.Next() = 0;
                end;
            end;
        end;
    end;

    procedure GetReversalAmortizationAmount(AvailableAmount: Decimal; InterestRate: Decimal; Period: Integer) Principal: Decimal;
    var
        AvailableForLoan, RatePerMonth : Decimal;
        LoanPeriod: Integer;
        CalcVar1, CalcVar2, CalcVar3, CalcVar4 : decimal;
    begin
        RatePerMonth := InterestRate / 12;
        LoanPeriod := Period;
        CalcVar3 := LoanPeriod;
        CalcVar4 := 1 + (RatePerMonth / 100);
        AvailableForLoan := AvailableAmount;
        CalcVar1 := 0;
        CalcVar1 := (Power(CalcVar4, CalcVar3)) - 1;
        CalcVar2 := 0;
        CalcVar2 := RatePerMonth * Power(CalcVar4, LoanPeriod);
        Principal := 0;
        Principal := AvailableForLoan * (CalcVar1 / CalcVar2) * 100;
        exit(Principal)
    end;

    procedure GetRefinancedLoans(LoanNo: Code[20]) Recoveries: Decimal
    var
        LoanRecovery: Record "Loan Recoveries";
    begin
        Recoveries := 0;
        LoanRecovery.Reset();
        LoanRecovery.SetRange("Loan No", LoanNo);
        LoanRecovery.SetRange("Recovery Type", LoanRecovery."Recovery Type"::Loan);
        if LoanRecovery.FindSet() then begin
            LoanRecovery.CalcSums(Amount);
            Recoveries := LoanRecovery.Amount;
        end;
        exit(Recoveries);
    end;

    internal procedure CreateLoan(LoanNo: Code[20]) NewLoan: Code[20]
    var
        ChannelLoanApplication: Record "Channel Loan Application";
        Loans: Record Loans;
        OnlineGuarantorRequests: Record "Channel Guarantor Requests";
        LoanGuarantees: Record "Loan Guarantees";
        SaccoSetup: Record "General Ledger Setup";
        NewLoanNo: Code[20];
        NoSeries: Codeunit NoSeriesManagement;
        PayslipInfo, PayslipInfo2 : Record "Loanees Payroll Transactions";
        LoanRecovery, LoanRecovery2 : Record "Loan Recoveries";
    begin
        SaccoSetup.Get();
        SaccoSetup.TestField("Loan Nos.");
        NewLoanNo := NoSeries.GetNextNo(SaccoSetup."Loan Nos.", Today, true);
        ChannelLoanApplication.get(LoanNo);
        Loans.Init();
        Loans.TransferFields(ChannelLoanApplication, false);
        Loans."No." := NewLoanNo;
        Loans."Source Type" := Loans."Source Type"::Channels;
        Loans."Portal Application No." := ChannelLoanApplication."No.";
        Loans."Loan Created By" := UserId;
        Loans."Loan Created On" := CurrentDateTime;
        OnlineGuarantorRequests.Reset();
        OnlineGuarantorRequests.SetRange("Loan No", LoanNo);
        OnlineGuarantorRequests.SetRange(Status, OnlineGuarantorRequests.Status::Approved);
        OnlineGuarantorRequests.SetRange("Request Type", OnlineGuarantorRequests."Request Type"::Guarantor);
        if OnlineGuarantorRequests.FindSet() then begin
            repeat
                LoanGuarantees.Reset();
                LoanGuarantees.SetRange("Loan No", LoanNo);
                LoanGuarantees.SetRange("Member No.", OnlineGuarantorRequests."Member No");
                if LoanGuarantees.FindSet() then LoanGuarantees.DeleteAll();
                if Loans.Get(NewLoanNo) then begin
                    LoanGuarantees.Init();
                    LoanGuarantees."Loan No" := NewLoanNo;
                    LoanGuarantees.Validate("Member No.", OnlineGuarantorRequests."Member No");
                    LoanGuarantees."Guaranteed Amount" := OnlineGuarantorRequests."Amount Accepted";
                    LoanGuarantees."Loan Owner" := Loans."Member No.";
                    LoanGuarantees.Insert(true);
                end;
            until OnlineGuarantorRequests.Next() = 0;
        end;
        PayslipInfo.Reset();
        PayslipInfo.SetRange("Source No.", LoanNo);
        if not PayslipInfo.FindSet() then begin
            repeat
                PayslipInfo2.Init();
                PayslipInfo2.TransferFields(PayslipInfo, false);
                PayslipInfo2."Source No." := NewLoanNo;
                PayslipInfo2.Code := PayslipInfo.Code;
                if PayslipInfo2.Amount <> 0 then PayslipInfo2.Insert();
            until PayslipInfo.Next() = 0;
        end;
        LoanRecovery.Reset();
        LoanRecovery.SetRange("Loan No", LoanNo);
        if LoanRecovery.FindSet() then begin
            repeat
                LoanRecovery2.Init();
                LoanRecovery2.TransferFields(LoanRecovery, false);
                LoanRecovery2."Loan No" := NewLoan;
                LoanRecovery2."Recovery Type" := LoanRecovery."Recovery Type";
                LoanRecovery2."Recovery Code" := LoanRecovery."Recovery Code";
                LoanRecovery2.Insert();
            until LoanRecovery.Next() = 0;
        end;
        ChannelLoanApplication."Loan Created By" := UserId;
        ChannelLoanApplication."Loan Created On" := CurrentDateTime;
        ChannelLoanApplication."Portal Status" := ChannelLoanApplication."Portal Status"::Processing;
        ChannelLoanApplication.Modify();
        exit(NewLoanNo);
    end;

    procedure PopulateMinimumContribution(ApplicationNo: Code[20]) Amount: Decimal
    var
        Members: Record Members;
        Products: Record "Sacco Products";
        SaccoSetup: Record "General Ledger Setup";
        Loans: Record Loans;
        OnlineLoanApplication: Record "Channel Loan Application";
        MemberNo, ProductCode : Code[20];
        AppliedAmount: Decimal;
    begin
        SaccoSetup.Get();
        ProductCode := '';
        MemberNo := '';
        AppliedAmount := 0;
        Amount := SaccoSetup."Minimum Deposit Cont.";
        if OnlineLoanApplication.Get(ApplicationNo) then begin
            MemberNo := OnlineLoanApplication."Member No.";
            ProductCode := OnlineLoanApplication."Product Code";
            AppliedAmount := OnlineLoanApplication."Applied Amount";
        end
        else begin
            if Loans.Get(ApplicationNo) then begin
                ProductCode := Loans."Product Code";
                MemberNo := Loans."Member No.";
                AppliedAmount := OnlineLoanApplication."Applied Amount";
            end;
        end;
    end;

    internal procedure SendGuarantorRequestCommunication(GuarantorRequest: Record "Channel Guarantor Requests"; RequestedAmount: Decimal)
    var
        SMSText, SMSNo : Text;
        Notifications: Codeunit "Notifications Management";
        Members, Members2 : Record Members;
        LoanApplication: Record "Channel Loan Application";
        Portal: Codeunit "Channels Integrations";
        RespCode, SMSSource : Code[20];
        TempResponse: BigText;
    begin
        CompanyInformation.Get;
        SMSSource := 'GUARANTOR-REQ';
        if Members.Get(GuarantorRequest."Member No") then begin
            if LoanApplication.Get(GuarantorRequest."Loan No") then begin
                if Members2.Get(LoanApplication."Member No.") then begin
                    Message('This is the Requested Amount %1', GuarantorRequest."Requested Amount");
                    if GuarantorRequest."Request Type" = GuarantorRequest."Request Type"::Guarantor then
                        SMSText := 'Dear ' + Members."Full Name" + ', ' + Members2."Full Name" + ' has requested loan Guarantorship of  ' + format(GuarantorRequest."Requested Amount") + '. Kindly login to the portal to accept or reject the request. ' + CompanyInformation."Home Page" + ' Phone: ' + CompanyInformation."Phone No."
                    else if GuarantorRequest."Request Type" = GuarantorRequest."Request Type"::Witness then SMSText := 'Dear ' + Members."Full Name" + ',' + Members2."Full Name" + ' has requested you to witness a loan for them.Please Log In to the App/Members Portal to process the request.';
                    SMSNo := Members."Mobile Phone No.";
                    Notifications.SendSms(SMSNo, SMSText, SMSSource);
                    if Members."No." = Members2."No." then Portal.ProcessGuarantorRequest(GuarantorRequest."Loan No", Members."Identification No.", 0, GuarantorRequest.AppliedAmount, 0, RespCode, TempResponse);
                end;
            end;
        end;
    end;

    procedure GetProratedInterest(LoanNo: Code[20]; AsAtDate: Date) ProratedInterest: Decimal
    var
        Loans: array[2] of Record Loans;
        DateFilter: Text;
        Days: Integer;
        SDate: Date;
        BalanceAtDate: Decimal;
        SaccoProducts: Record "Sacco Products";
        SaccoSetup: Record "General Ledger Setup";
    begin
        SaccoSetup.Get;
        SaccoSetup.TestField("Opening Balance Posting Date");

        Loans[1].Reset();
        Loans[1].SetRange("No.", LoanNo);
        if Loans[1].FindFirst then begin
            Loans[1].CalcFields("Last Interest Charge");
            if AsAtDate < Loans[1]."Last Interest Charge" then
                exit(0)
            else begin
                DateFilter := '..' + Format(AsAtDate);
                Loans[2].Reset();
                Loans[2].SetFilter("Date Filter", DateFilter);
                Loans[2].SetRange("No.", LoanNo);
                if Loans[2].FindFirst then begin
                    Loans[2].CalcFields("Net Change-Principal", "Last Interest Charge");
                    BalanceAtDate := Loans[2]."Net Change-Principal";
                    SDate := Loans[2]."Last Interest Charge";

                    if SDate = 0D then
                        SDate := Loans[2]."Posting Date";

                    Days := AsAtDate - SDate;

                    if SDate < SaccoSetup."Opening Balance Posting Date" then
                        Days := AsAtDate - SaccoSetup."Opening Balance Posting Date";

                    if Days < 0 then
                        Days := 0;

                    ProratedInterest := BalanceAtDate * Loans[2]."Interest Rate" * 0.01 * (Days / 365);
                    if SaccoProducts.Get(Loans[2]."Product Code") then begin
                        if ((SaccoProducts."Exclude Billing & Interest") or (SaccoProducts."Charge UpFront Interest")) then begin
                            ProratedInterest := 0;
                        end;
                    end;
                    exit(ProratedInterest);
                end
                else
                    exit(0);
            end;
        end;
    end;

    internal procedure CheckOkToGuarantee(MemberNo: Code[20]; LoanNo: Code[20])
    var
        Loans: Record Loans;
    begin
        if Loans.Get(LoanNo) then begin
            if MemberNo = Loans.Witness then Error('You Cannot Be a Guarantor Since you are a Witness');
        end;
    end;

    internal procedure CheckOkToWitness(MemberNo: Code[20]; LoanNo: Code[20])
    var
        Loans: Record Loans;
        LoanGguarantors: Record "Loan Guarantees";
    begin
        if Loans.Get(LoanNo) then begin
            LoanGguarantors.Reset();
            LoanGguarantors.SetRange("Loan No", LoanNo);
            LoanGguarantors.SetRange("Member No.", MemberNo);
            if LoanGguarantors.FindFirst() then Error('You Cannot Be a Guarantor Since you are a Witness');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Loans Management", 'OnAfterPostLoan', '', true, true)]
    procedure CreateAdvice(var LoanNo: Code[20])
    var
        CheckOffAdvice: Record "Checkoff Advice";
        EntryNo: Integer;
        LoanRecoveries: Record "Loan Recoveries";
        Loans: array[2] of Record Loans;
        SaccoProducts: Record "Sacco Products";
        Subscriptions: Record "Member Subscriptions";
        Vendor: Record Vendor;
    begin
        Loans[1].Get(LoanNo);
        if ((Loans[1].Category <> Loans[1].Category::HR) and (Loans[1].Category <> Loans[1].Category::DEBT)) then begin
            SaccoProducts.Get(Loans[1]."Product Code");
            If ((not SaccoProducts."Salary Based") and (not SaccoProducts."Charge UpFront Interest") and (not SaccoProducts."Mobile Loan")) then begin
                CheckOffAdvice.Reset();
                CheckOffAdvice.setrange("Member No", Loans[1]."Member No.");
                CheckOffAdvice.setrange("Loan No", Loans[1]."No.");
                if CheckOffAdvice.FindSet then CheckOffAdvice.DeleteAll;
                CheckOffAdvice.Reset();
                if CheckOffAdvice.FindLast() then
                    EntryNo := CheckOffAdvice."Entry No" + 1
                else
                    EntryNo := 1;
                Loans[1].CalcFields("Monthly Installment", "Monthly Principal");
                CheckOffAdvice.Init();
                CheckOffAdvice."Entry No" := EntryNo;
                EntryNo += 1;
                CheckOffAdvice."Member No" := Loans[1]."Member No.";
                CheckOffAdvice."Amount Off" := 0;
                if Loans[1]."Interest Repayment Method" = Loans[1]."Interest Repayment Method"::Amortised then
                    CheckOffAdvice."Amount On" := round(Loans[1]."Monthly Installment", 100, '=')
                else
                    CheckOffAdvice."Amount On" := round(Loans[1]."Monthly Principal", 100, '=');
                CheckOffAdvice."Current Balance" := Loans[1]."Approved Amount";
                CheckOffAdvice.Validate("Loan No", Loans[1]."No.");
                CheckOffAdvice."Product Code" := Loans[1]."Product Code";
                CheckOffAdvice."Product Name" := Loans[1]."Product Description";
                CheckOffAdvice."Advice Type" := CheckOffAdvice."Advice Type"::"New Loan";
                CheckOffAdvice."Advice Date" := Loans[1]."Repayment Start Date";
                CheckOffAdvice."Posting Date" := WorkDate;
                CheckOffAdvice.Insert();
                if Loans[1]."New Monthly Installment" > 0 then begin
                    Vendor.Reset();
                    Vendor.SetRange("Member No.", Loans[1]."Member No.");
                    Vendor.SetRange("Product Code", SaccoProducts.Code);
                    if Vendor.FindFirst() then begin
                        CheckOffAdvice.Init();
                        CheckOffAdvice."Entry No" := EntryNo;
                        EntryNo += 1;
                        CheckOffAdvice."Member No" := Loans[1]."Member No.";
                        Subscriptions.Reset();
                        Subscriptions.SetRange("Account Type", SaccoProducts.Code);
                        Subscriptions.SetRange("Source Code", Loans[1]."Member No.");
                        if Subscriptions.FindFirst() then begin
                            CheckOffAdvice."Amount Off" := Subscriptions.Amount;
                            Subscriptions.Amount := Loans[1]."New Monthly Installment";
                            Subscriptions.Modify;
                        end
                        else begin
                            Subscriptions.Init();
                            Subscriptions."Source Code" := Loans[1]."Member No.";
                            Subscriptions."Account Type" := SaccoProducts.Code;
                            Subscriptions."Account Name" := SaccoProducts.Description;
                            Subscriptions."Start Date" := Loans[1]."Posting Date";
                            Subscriptions.Amount := Loans[1]."New Monthly Installment";
                            Subscriptions.Insert();
                        end;
                        CheckOffAdvice."Amount On" := Loans[1]."New Monthly Installment";
                        CheckOffAdvice."Current Balance" := Vendor.Balance;
                        CheckOffAdvice."Product Code" := SaccoProducts.Code;
                        CheckOffAdvice."Product Name" := SaccoProducts.Description;
                        CheckOffAdvice."Advice Type" := CheckOffAdvice."Advice Type"::Adjustment;
                        CheckOffAdvice."Advice Date" := Loans[1]."Repayment Start Date";
                        CheckOffAdvice."Posting Date" := WorkDate;
                        CheckOffAdvice.Insert();
                    end;
                end;
                LoanRecoveries.Reset();
                LoanRecoveries.SetRange("Loan No", LoanNo);
                if LoanRecoveries.FindSet() then begin
                    repeat
                        if LoanRecoveries."Recovery Type" = LoanRecoveries."Recovery Type"::Loan then begin
                            if Loans[2].Get(LoanRecoveries."Recovery Code") then begin
                                CheckOffAdvice.Init();
                                CheckOffAdvice."Entry No" := EntryNo;
                                EntryNo += 1;
                                CheckOffAdvice."Member No" := Loans[1]."Member No.";
                                CheckOffAdvice."Amount Off" := 0;
                                if Loans[2]."New Monthly Installment" <> 0 then
                                    CheckOffAdvice."Amount On" := Loans[2]."New Monthly Installment"
                                else
                                    CheckOffAdvice."Amount On" := round(Loans[2]."Monthly Installment", 1, '>');
                                CheckOffAdvice."Current Balance" := Loans[2]."Approved Amount";
                                CheckOffAdvice."Loan No" := Loans[2]."No.";
                                CheckOffAdvice."Recovery Mode" := Loans[2]."Recovery Mode";
                                CheckOffAdvice."Product Code" := Loans[2]."Product Code";
                                CheckOffAdvice."Product Name" := Loans[2]."Product Description";
                                CheckOffAdvice."Advice Type" := CheckOffAdvice."Advice Type"::Stoppage;
                                CheckOffAdvice."Advice Date" := WorkDate;
                                CheckOffAdvice."Posting Date" := WorkDate;
                                CheckOffAdvice.Insert();
                            end;
                        end;
                    until LoanRecoveries.Next() = 0;
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Loans Management", 'OnAfterPostLoanRestructure', '', true, true)]
    procedure LoanRestructureCheckoffAdvice(var LoanRestructure: Record "Loan Moratorium")
    var
        CheckOffAdvice: Record "Checkoff Advice";
        EntryNo: Integer;
        LoanRecoveries: Record "Loan Recoveries";
        Loans: Record Loans;
        ProductType: Record "Sacco Products";
        Subscriptions: Record "Member Subscriptions";
        Vendor: Record Vendor;
    begin
        CheckOffAdvice.Reset();
        CheckOffAdvice.setrange("Member No", LoanRestructure."Member No.");
        CheckOffAdvice.setrange("Loan No", LoanRestructure."Loan No.");
        if CheckOffAdvice.FindFirst() then CheckOffAdvice.DeleteAll;
        CheckOffAdvice.Reset();
        if CheckOffAdvice.FindLast() then
            EntryNo := CheckOffAdvice."Entry No" + 1
        else
            EntryNo := 1;
        If Loans.Get(LoanRestructure."Loan No.") then begin
            Loans.CalcFields("Monthly Installment", "Monthly Principal");
            CheckOffAdvice.Init();
            CheckOffAdvice."Entry No" := EntryNo;
            EntryNo += 1;
            CheckOffAdvice."Member No" := LoanRestructure."Member No.";
            CheckOffAdvice."Amount Off" := LoanRestructure."Monthly Installment";
            CheckOffAdvice."Amount On" := LoanRestructure."New Monthly Installment";
            CheckOffAdvice."Current Balance" := Loans."Approved Amount";
            CheckOffAdvice.Validate("Loan No", Loans."No.");
            CheckOffAdvice."Product Code" := Loans."Product Code";
            CheckOffAdvice."Product Name" := Loans."Product Description";
            CheckOffAdvice."Advice Type" := CheckOffAdvice."Advice Type"::Adjustment;
            CheckOffAdvice."Advice Date" := Loans."Repayment Start Date";
            CheckOffAdvice."Posting Date" := WorkDate;
            CheckOffAdvice.Insert();
        end;
    end;

    procedure PostVariation(DocumentNo: code[20])
    var
        VariationHeader: Record "Checkoff Variation Header";
        VariationLines: Record "Checkoff Variation Lines";
        CheckOffAdvice: Record "Checkoff Advice";
        EntryNo: Integer;
        Loans: Record Loans;
        ObjMember: Record Members;
    begin
        CheckOffAdvice.Reset();
        if CheckOffAdvice.FindLast() then
            EntryNo := CheckOffAdvice."Entry No" + 1
        else
            EntryNo := 1;
        VariationHeader.Get(DocumentNo);
        VariationLines.Reset();
        VariationLines.SetRange("No.", DocumentNo);
        VariationLines.SetRange(Modified, True);
        if VariationLines.FindSet() then begin
            repeat
                CheckOffAdvice.Init();
                CheckOffAdvice."Entry No" := EntryNo;
                EntryNo += 1;
                CheckOffAdvice."Member No" := VariationHeader."Member No";
                CheckOffAdvice."Amount Off" := VariationLines."Current Contribution";
                CheckOffAdvice."Amount On" := VariationLines."New Contribution";
                CheckOffAdvice."Current Balance" := VariationLines."Account Balance";
                CheckOffAdvice."Product Code" := VariationLines."Product Code";
                CheckOffAdvice."Product Name" := VariationLines.Description;
                CheckOffAdvice."Advice Type" := CheckOffAdvice."Advice Type"::Adjustment;
                CheckOffAdvice."Advice Date" := VariationHeader."Effective Date";
                CheckOffAdvice."Posting Date" := WorkDate;
                CheckOffAdvice.Validate("Loan No", VariationLines."Loan Account");
                if Loans.Get(VariationLines."Application No.") then begin
                    Loans.CalcFields("Loan Balance");
                    CheckOffAdvice."Current Balance" := Loans."Loan Balance";
                end;
                CheckOffAdvice.Insert();
                if Loans.Get(VariationLines."Product Code") then begin
                    Loans.Restructured := true;
                    Loans."Rescheduled Installment" := VariationLines."New Contribution";
                    Loans.Modify();
                end;
            until VariationLines.Next() = 0;
        end;
        VariationHeader.Processed := true;
        VariationHeader.Modify();
    end;

    procedure PopulateDefaulters(DocumentNo: code[20])
    var
        DefaulerNoticeLines: array[2] of Record "Defaulter Notice Lines";
        DefaultNotice: Record "Defaulter Notice";
        Loans: Record Loans;
        Window: Dialog;
        Member: Record Members;
        All, Current : integer;
        Ok: Boolean;
    begin
        DefaultNotice.Get(DocumentNo);
        DefaultNotice.TestField("Notice Date");
        DefaulerNoticeLines[1].RESET;
        DefaulerNoticeLines[1].SETRANGE("No.", DefaultNotice."No.");
        DefaulerNoticeLines[1].SETRANGE(Notified, FALSE);
        IF DefaulerNoticeLines[1].FINDSET THEN DefaulerNoticeLines[1].DELETEALL;
        Loans.RESET;
        Loans.SETFILTER("Total Arrears", '>0');
        Loans.SETFILTER("Loan Balance", '>0');
        IF Loans.FINDSET THEN BEGIN
            Window.Open('Populating \#1##\@2@@');
            All := Loans.COUNT;
            Current := 0;
            REPEAT
                ClassifyLoan(Loans."No.", DefaultNotice."Notice Date");
                Window.Update(1, Loans."Member Name");
                Window.Update(2, StrSubstNo('%1%', Round((Current / All) * 100, 0.01)));
                Loans.CalcFields("Loan Balance");
                Current += 1;
                DefaulerNoticeLines[1].INIT;
                DefaulerNoticeLines[1]."No." := DefaultNotice."No.";
                DefaulerNoticeLines[1]."Member No" := Loans."Member No.";
                DefaulerNoticeLines[1]."Member Name" := Loans."Member Name";
                DefaulerNoticeLines[1]."Loan No" := Loans."No.";
                DefaulerNoticeLines[1]."Product Code" := Loans."Product Code";
                DefaulerNoticeLines[1]."Product Description" := Loans."Product Description";
                DefaulerNoticeLines[1]."Loan Balance" := Loans."Loan Balance";
                DefaulerNoticeLines[1]."Defaulted Days" := Loans."Defaulted Days";
                DefaulerNoticeLines[1]."Total Arrears" := ROUND(Loans."Total Arrears", 1, '=');
                IF ((Loans."Defaulted Days" <= 30) AND (Loans."Defaulted Days" > 0)) THEN
                    DefaulerNoticeLines[1]."Notice Type" := DefaulerNoticeLines[1]."Notice Type"::"1st"
                ELSE IF ((Loans."Defaulted Days" > 30) AND (Loans."Defaulted Days" <= 60)) THEN
                    DefaulerNoticeLines[1]."Notice Type" := DefaulerNoticeLines[1]."Notice Type"::"2nd"
                ELSE
                    DefaulerNoticeLines[1]."Notice Type" := DefaulerNoticeLines[1]."Notice Type"::"3rd";
                IF Member.GET(Loans."Member No.") THEN DefaulerNoticeLines[1]."E-Mail" := Member."E-Mail";
                Loans.CALCFIELDS("Total Guarantees", "Self Guarantee");
                IF Loans."Total Guarantees" = Loans."Self Guarantee" THEN DefaulerNoticeLines[1]."Self Guarantee" := TRUE;
                DefaulerNoticeLines[1]."Defaulted Installments" := Loans."Defaulted Installments";
                IF DefaulerNoticeLines[1]."Defaulted Days" > 0 THEN Ok := DefaulerNoticeLines[1].INSERT;
            UNTIL Loans.NEXT = 0;
            Window.Close;
        END
        else
            Message('No Loans in the filter ' + Loans.GetFilters);
    end;

    procedure SendNotice(var DocumentNo: Code[20]; NoticeType: Option "1st","2nd","3rd");
    var
        DefaulerNoticeLines: array[2] of Record "Defaulter Notice Lines";
        DefaultNotice: Record "Defaulter Notice";
        Member: Record Members;
        CompanyInformation: Record "Company Information";
        Window: Dialog;
        Body: Text;
        Subject: Text[100];
        Recipients: List of [Text];
        LoanGuarantees: Record "Loan Guarantees";
        TempBlob: Codeunit "Temp Blob";
        outStreamReport: OutStream;
        inStreamReport: InStream;
        Recordr: RecordRef;
        Mail: Codeunit "Email Message";
        Email: Codeunit Email;
    begin
        Clear(Body);
        Clear(Subject);
        Clear(Recipients);
        CompanyInformation.GET;
        SaccoSetup.Get;
        DefaultNotice.Get(DocumentNo);
        DefaulerNoticeLines[1].RESET;
        DefaulerNoticeLines[1].SETRANGE("No.", DefaultNotice."No.");
        DefaulerNoticeLines[1].SetRange(Skip, false);
        CASE NoticeType OF
            NoticeType::"1st":
                DefaulerNoticeLines[1].SETRANGE("Notice Type", DefaulerNoticeLines[1]."Notice Type"::"1st");
            NoticeType::"2nd":
                DefaulerNoticeLines[1].SETRANGE("Notice Type", DefaulerNoticeLines[1]."Notice Type"::"2nd");
            NoticeType::"3rd":
                DefaulerNoticeLines[1].SETRANGE("Notice Type", DefaulerNoticeLines[1]."Notice Type"::"3rd");
        end;
        DefaulerNoticeLines[1].SETRANGE(Notified, FALSE);
        DefaulerNoticeLines[1].SETFILTER("E-Mail", '<>%1', '');
        IF DefaulerNoticeLines[1].FINDSET THEN BEGIN
            Window.Open('Sending \#1###');
            REPEAT
                Window.Update(1, DefaulerNoticeLines[1]."Member Name");
                IF DefaulerNoticeLines[1]."E-Mail" <> '' THEN BEGIN
                    CASE NoticeType OF
                        NoticeType::"1st":
                            BEGIN
                                Clear(Recipients);
                                Subject := '';
                                Clear(Body);
                                Member.GET(DefaulerNoticeLines[1]."Member No");
                                Recipients.Add(Member."E-Mail");
                                if SaccoSetup."Credit Department Email" <> '' then Recipients.Add(SaccoSetup."Credit Department Email");
                                Subject := 'Loan Repayment Default 1st Notice-' + DefaulerNoticeLines[1]."Member No";
                                Body += '<p style="font-family:Times New Roman">Dear ' + DefaulerNoticeLines[1]."Member Name" + ',<br></br><br>';
                                Body += 'Please find attached letter from the Society.<br>';
                                Body += '<br>This is a system generated email.';
                                Body += '<br></br>Thanks & Regards.<br></br>';
                                Body += '<br></br>.******************.<br></br>';
                                Body += '<br></br>For any complains/compliments call.<br></br>';
                                Body += '<br>' + CompanyInformation."Phone No." + CompanyInformation."E-Mail" + '<br>,<br>';
                                Body += '<br>';
                                Body += CompanyInformation.Name;
                                Mail.Create(Recipients, Subject, Body, true);
                                DefaulerNoticeLines[2].Reset();
                                DefaulerNoticeLines[2].SetRange("No.", DefaulerNoticeLines[1]."No.");
                                DefaulerNoticeLines[2].SetRange("Loan No", DefaulerNoticeLines[1]."Loan No");
                                if DefaulerNoticeLines[2].FindFirst then begin
                                    Recordr.GetTable(DefaulerNoticeLines[2]);
                                    TempBlob.CreateOutStream(outStreamReport);
                                    TempBlob.CreateInStream(inStreamReport);
                                    Report.SaveAs(Report::"Defaulter 1st Notice", DefaulerNoticeLines[1]."Loan No", ReportFormat::Pdf, outStreamReport, Recordr);
                                    Mail.AddAttachment(DefaulerNoticeLines[1]."Loan No" + '.pdf', 'PDF', inStreamReport);
                                end;
                                //Email.Send(Mail);
                            end;
                        NoticeType::"2nd":
                            BEGIN
                                Clear(Recipients);
                                Subject := '';
                                Clear(Body);
                                Member.GET(DefaulerNoticeLines[1]."Member No");
                                Recipients.Add(Member."E-Mail");
                                if SaccoSetup."Credit Department Email" <> '' then Recipients.Add(SaccoSetup."Credit Department Email");
                                LoanGuarantees.RESET;
                                LoanGuarantees.SETRANGE(Substituted, false);
                                LoanGuarantees.SETRANGE("Loan No", DefaulerNoticeLines[1]."Loan No");
                                IF LoanGuarantees.FINDSET then begin
                                    repeat
                                        if Member.GET(LoanGuarantees."Member No.") then begin
                                            if Member."E-Mail" <> '' then Recipients.Add(Member."E-Mail");
                                        end;
                                    until LoanGuarantees.NEXT = 0;
                                end;
                                Subject := 'Loan Repayment Default 2nd Notice-' + DefaulerNoticeLines[1]."Member Name";
                                Body += '<p style="font-family:Times New Roman">Dear ' + DefaulerNoticeLines[1]."Member Name" + ',<br></br><br>';
                                Body += 'Please find attached letter from the Society.<br>';
                                Body += '<br>This is a system generated email.';
                                Body += '<br></br>Thanks & Regards.<br></br>';
                                Body += '<br></br>.******************.<br></br>';
                                Body += '<br></br>For any complains/compliments call.<br></br>';
                                Body += '<br>' + CompanyInformation."Phone No." + CompanyInformation."E-Mail" + '<br>,<br>';
                                Body += '<br>';
                                Body += CompanyInformation.Name;
                                Mail.Create(Recipients, Subject, Body, true);
                                DefaulerNoticeLines[2].Reset();
                                DefaulerNoticeLines[2].SetRange("No.", DefaulerNoticeLines[1]."No.");
                                DefaulerNoticeLines[2].SetRange("Loan No", DefaulerNoticeLines[1]."Loan No");
                                if DefaulerNoticeLines[2].FindFirst then begin
                                    Recordr.GetTable(DefaulerNoticeLines[2]);
                                    TempBlob.CreateOutStream(outStreamReport);
                                    TempBlob.CreateInStream(inStreamReport);
                                    Report.SaveAs(Report::"Defaulter 2nd Notice", DefaulerNoticeLines[1]."Loan No", ReportFormat::Pdf, outStreamReport, Recordr);
                                    Mail.AddAttachment(DefaulerNoticeLines[1]."Loan No" + '.pdf', 'PDF', inStreamReport);
                                end;
                                //Email.Send(Mail);
                            end;
                        NoticeType::"3rd":
                            BEGIN
                                Clear(Recipients);
                                Subject := '';
                                Clear(Body);
                                Member.GET(DefaulerNoticeLines[1]."Member No");
                                Recipients.add(Member."E-Mail");
                                if SaccoSetup."Credit Department Email" <> '' then Recipients.Add(SaccoSetup."Credit Department Email");
                                LoanGuarantees.RESET;
                                LoanGuarantees.SETRANGE(Substituted, false);
                                LoanGuarantees.SETRANGE("Loan No", DefaulerNoticeLines[1]."Loan No");
                                IF LoanGuarantees.FINDSET then begin
                                    repeat
                                        if Member.GET(LoanGuarantees."Member No.") then begin
                                            if Member."E-Mail" <> '' then Recipients.Add(Member."E-Mail");
                                        end;
                                    until LoanGuarantees.NEXT = 0;
                                end;
                                Subject := 'Loan Repayment Default 3rd Notice-' + DefaulerNoticeLines[1]."Member No";
                                Body += '<p style="font-family:Times New Roman">Dear ' + DefaulerNoticeLines[1]."Member Name" + ',<br></br><br>';
                                Body += 'Dear ' + DefaulerNoticeLines[1]."Member Name" + ',<br></br><br>';
                                Body += 'Please find attached letter from the Society.<br>';
                                Body += '<br>This is a system generated email.';
                                Body += '<br></br>Thanks & Regards.<br></br>';
                                Body += '<br></br>.******************.<br></br>';
                                Body += '<br></br>For any complains/compliments call.<br></br>';
                                Body += '<br>' + CompanyInformation."Phone No." + CompanyInformation."E-Mail" + '<br>,<br>';
                                Body += '<br>';
                                Body += CompanyInformation.Name;
                                Mail.Create(Recipients, Subject, Body, true);
                                DefaulerNoticeLines[2].Reset();
                                DefaulerNoticeLines[2].SetRange("No.", DefaulerNoticeLines[1]."No.");
                                DefaulerNoticeLines[2].SetRange("Loan No", DefaulerNoticeLines[1]."Loan No");
                                if DefaulerNoticeLines[2].FindFirst then begin
                                    Recordr.GetTable(DefaulerNoticeLines[2]);
                                    TempBlob.CreateOutStream(outStreamReport);
                                    TempBlob.CreateInStream(inStreamReport);
                                    Report.SaveAs(Report::"Defaulter 3rd Notice", DefaulerNoticeLines[1]."Loan No", ReportFormat::Pdf, outStreamReport, Recordr);
                                    Mail.AddAttachment(DefaulerNoticeLines[1]."Loan No" + '.pdf', 'PDF', inStreamReport);
                                end;
                                //Email.Send(Mail);
                            end;
                    end;
                    DefaulerNoticeLines[1].Notified := TRUE;
                    DefaulerNoticeLines[1].MODIFY;
                    COMMIT;
                end;
            UNTIL DefaulerNoticeLines[1].NEXT = 0;
            Window.Close;
        end;
    end;

    procedure GetNetAmount(LoanNo: code[20]) NetAmount: Decimal;
    var
        Loans: Record Loans;
        LoanRecoveries: Record "Loan Recoveries";
        LoanProducts: Record "Sacco Products";
        JournalManagement: Codeunit "Journal Management";
    begin
        NetAmount := 0;
        if Loans.Get(LoanNo) then begin
            NetAmount := Loans."Approved Amount";
            LoanRecoveries.Reset();
            LoanRecoveries.SetRange("Loan No", LoanNo);
            if LoanRecoveries.FindSet() then begin
                LoanRecoveries.CalcSums(Amount, "Commission Amount");
                NetAmount -= (LoanRecoveries.Amount + LoanRecoveries."Commission Amount");
            end;
            NetAmount -= GetLoanProductChargesAmount(Loans."Product Code", Loans."Approved Amount");
        end;
        exit(NetAmount);
    end;

    procedure PostLoanRecovery(DocumentNo: Code[20])
    var
        RecoveryHeader: Record "Loan Recovery Header";
        RecoveryLines: Record "Loan Recovery Lines";
        Loan: array[2] of Record Loans;
        SaccoSetup: Record "General Ledger Setup";
        LoanProduct, NewLoanProduct : Record "Sacco Products";
        LineNo: Integer;
        MemberMgt: Codeunit "Member Management";
        JournalManagement: Codeunit "Journal Management";
        JournalBatch, JournalTemplate, ReasonCode, SourceCode, Dim1, Dim2, MemberNo, ExternalDocumentNo, AccountNo : code[20];
        NewMemberNo, NewReasonCode, NewSourceCode : Code[20];
        NoSeries: Codeunit NoSeriesManagement;
        PostingDate: Date;
        PostingAmount, TotalRecoveredAmount, PenaltyBalance, InterestBalance, PrincipalBalance, PenaltyPaid, InterestPaid, PrincipalPaid, BaseAmount : Decimal;
        RecoveryAccounts: Record "Loan Recovey Accounts";
        PostingDescription: Text[100];
        ProductPostingType: Enum "Product Posting Type";
    begin
        SaccoSetup.Get();
        RecoveryHeader.Get(DocumentNo);
        RecoveryHeader.CalcFields("Self Recovery Amount");
        JournalBatch := 'LREC';
        JournalTemplate := 'GENERAL';
        LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
        RecoveryHeader.TestField(Status, RecoveryHeader.Status::Approved);
        RecoveryHeader.CalcFields("Guarantor Deposit Recovery", "Guarantor Liability Recovery");
        TotalRecoveredAmount := RecoveryHeader."Guarantor Deposit Recovery" + RecoveryHeader."Self Recovery Amount" + RecoveryHeader."Guarantor Liability Recovery";
        Loan[1].Get(RecoveryHeader."Loan No");
        PostingDate := RecoveryHeader."Posting Date";
        LoanProduct.Get(Loan[1]."Product Code");
        ReasonCode := Loan[1]."No.";
        SourceCode := Loan[1]."Product Code";
        MemberNo := Loan[1]."Member No.";
        if RecoveryHeader."Self Recovery Amount" > 0 then begin
            RecoveryAccounts.Reset();
            RecoveryAccounts.SetRange("Document No", DocumentNo);
            RecoveryAccounts.SetFilter("Recovery Amount", '>0');
            if RecoveryAccounts.FindSet() then begin
                repeat
                    AccountNo := '';
                    AccountNo := RecoveryAccounts."Account No";
                    PostingDescription := 'Loan Recovery';
                    PostingAmount := 0;
                    PostingAmount := RecoveryAccounts."Recovery Amount";
                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::General, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                until RecoveryAccounts.Next() = 0;
            end;
        end;
        RecoveryLines.Reset();
        RecoveryLines.SetRange("No.", DocumentNo);
        if RecoveryLines.FindSet() then begin
            repeat
                case RecoveryLines."Recovery Type" of
                    RecoveryLines."Recovery Type"::Deposits:
                        begin
                            PostingAmount := 0;
                            PostingAmount := RecoveryLines."Recovery Amount";
                            PostingDescription := 'Loan Recovery ' + RecoveryHeader."Member Name";
                            NewMemberNo := '';
                            NewMemberNo := RecoveryLines."Member No";
                            AccountNo := '';
                            AccountNo := MemberMgt.GetMemberAccount(NewMemberNo, ProductPostingType::"Non Withdrawable Deposit");
                            //Debit Depositor
                            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, NewMemberNo, DocumentNo, GlobalTransactionType::General, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                        end;
                    RecoveryLines."Recovery Type"::"Guarantor Liability Loan":
                        begin
                            PostingAmount := 0;
                            PostingAmount := RecoveryLines."Recovery Amount";
                            NewMemberNo := '';
                            NewMemberNo := RecoveryLines."Member No";
                            NewReasonCode := '';
                            NewReasonCode := NoSeries.GetNextNo(SaccoSetup."Loan Nos.", Today, true);
                            NewLoanProduct.Get(RecoveryLines."Product Code");
                            Loan[2].Init();
                            Loan[2]."No." := NewReasonCode;
                            Loan[2]."Product Code" := NewLoanProduct.Code;
                            Loan[2]."Product Description" := NewLoanProduct.Description;
                            Loan[2]."Member No." := NewMemberNo;
                            Loan[2]."Member Name" := RecoveryLines."Member Name";
                            Loan[2]."Application Date" := PostingDate;
                            Loan[2]."Posting Date" := PostingDate;
                            Loan[2]."Posted On" := CurrentDateTime;
                            Loan[2]."Loan Account" := CreateLoanAccounts(Loan[2]);
                            Loan[2]."Loan Amount" := RecoveryLines."Recovery Amount";
                            Loan[2]."Approved Amount" := Loan[2]."Loan Amount";
                            Loan[2].Status := Loan[2].Status::Approved;
                            Loan[2]."Application Status" := Loan[2]."Application Status"::Disbursed;
                            Loan[2]."Loan Classification" := Loan[2]."Loan Classification"::Loss;
                            Loan[2].Posted := true;
                            Loan[2].Disbursed := true;
                            Loan[2].Insert();
                            PostingDescription := 'Guarantor Liability Loan Disbursal';
                            AccountNo := Loan[2]."Loan Account";
                            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, NewMemberNo, DocumentNo, GlobalTransactionType::"Loan Disbursal", LineNo, NewLoanProduct.Code, NewReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                        end;
                end;
            until RecoveryLines.Next() = 0;
        end;

        PostLoanRecoveryAccruedInterest(RecoveryHeader."Posting Date", RecoveryHeader."Loan No", RecoveryHeader."Accrued Interest");

        Loan[1].Get(RecoveryHeader."Loan No");
        Loan[1].CalcFields("Penalty Balance", "Interest Balance", "Principal Balance");
        BaseAmount := 0;
        PenaltyBalance := 0;
        PenaltyPaid := 0;
        InterestBalance := 0;
        InterestPaid := 0;
        PrincipalBalance := 0;
        PrincipalPaid := 0;

        BaseAmount := TotalRecoveredAmount;
        PenaltyBalance := Loan[1]."Penalty Balance";
        InterestBalance := Loan[1]."Interest Balance";
        Principalbalance := Loan[1]."Principal Balance";

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

        //Penalty Paid
        PostingAmount := 0;
        PostingAmount := PenaltyPaid;
        PostingDescription := 'Penalty Paid';
        AccountNo := '';
        AccountNo := Loan[1]."Loan Account";
        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Penalty Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);

        //Interest Paid
        PostingAmount := 0;
        PostingAmount := InterestPaid;
        PostingDescription := 'Interest Paid';
        AccountNo := '';
        AccountNo := Loan[1]."Loan Account";
        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);

        LoanProduct.Get(Loan[1]."Product Code");
        if SaccoSetup."Interest Accrual Type" = SaccoSetup."Interest Accrual Type"::"Cash Basis" then begin
            AccountNo := '';
            AccountNo := LoanProduct."Interest Paid Account";
            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
            AccountNo := '';
            AccountNo := LoanProduct."Interest Due Account";
            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
        end;


        //Principal Paid
        PostingAmount := 0;
        PostingAmount := PrincipalPaid;
        PostingDescription := 'Principal Paid';
        AccountNo := '';
        AccountNo := Loan[1]."Loan Account";
        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Principal Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);

        JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
        GLEntry.Reset();
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("Document Date", PostingDate);
        if GLEntry.FindFirst() then begin
            RecoveryHeader.Processed := true;
            RecoveryHeader.Modify();
            OnAfterPostLoanRecovery(RecoveryHeader);
        end;
    end;

    procedure GetArrearsAmount(LoanNo: Code[20]; AsAtDate: Date)
    var
        DateFilter: Text[100];
        Loans: Record Loans;
        ExpectedPrincipal, ExpectedInterest, PrincipalPaid, InterestPaid, InterestArrears, PrincipalArrears, TotalArrears : decimal;
        DefaultedInstallments, DefaultedDays : integer;
    begin
        DateFilter := '..' + Format(AsAtDate);
        Loans.Reset();
        Loans.SetFilter("Date Filter", DateFilter);
        Loans.SetRange("No.", LoanNo);
        if Loans.FindSet() then begin
            Loans.CalcFields("Monthly Installment", "Interest Paid", "Principal Repayment", "Total Interest Due", "Net Change-Principal");
            if ((Loans."Loan Balance" > 0) AND (Loans."Monthly Installment" > 0)) then begin
                if Loans."Repayment End Date" < AsAtDate then begin
                    DefaultedDays := AsAtDate - Loans."Repayment End Date";
                    DefaultedInstallments := Round((DefaultedDays / 365), 1, '>');
                    if DefaultedDays < 365 then begin
                        DefaultedDays := 365;
                        DefaultedInstallments := 12;
                    end;
                end
                else begin
                    ExpectedPrincipal := Loans."Principal Repayment";
                    PrincipalPaid := Loans."Approved Amount" - Loans."Net Change-Principal";
                    ExpectedInterest := Loans."Total Interest Due";
                    InterestPaid := Loans."Interest Paid";
                    InterestArrears := ExpectedInterest + InterestPaid;
                    PrincipalArrears := ExpectedPrincipal - PrincipalPaid;
                    TotalArrears := PrincipalArrears + InterestArrears;
                    DefaultedInstallments := Round((TotalArrears / Loans."Monthly Installment"), 1, '>');
                    DefaultedInstallments := DefaultedInstallments * 30;
                end;
                Loans."Interest Arrears" := InterestArrears;
                Loans."Principal Arrears" := PrincipalArrears;
                Loans."Total Arrears" := TotalArrears;
                Loans."Defaulted Installments" := DefaultedInstallments;
                Loans."Defaulted Days" := DefaultedDays;
                IF DefaultedDays = 0 THEN
                    Loans."Loan Classification" := Loans."Loan Classification"::Performing
                ELSE IF ((DefaultedDays > 0) AND (DefaultedDays <= 30)) THEN
                    Loans."Loan Classification" := Loans."Loan Classification"::Watch
                ELSE IF ((DefaultedDays > 30) AND (DefaultedDays <= 60)) THEN
                    Loans."Loan Classification" := Loans."Loan Classification"::Substandard
                ELSE IF ((DefaultedDays > 60) AND (DefaultedDays <= 180)) THEN
                    Loans."Loan Classification" := Loans."Loan Classification"::Doubtfull
                ELSE
                    Loans."Loan Classification" := Loans."Loan Classification"::Loss;
                Loans.Modify();
            end
            else begin
                Loans."Loan Classification" := Loans."Loan Classification"::Performing;
                Loans."Total Arrears" := 0;
                Loans."Interest Arrears" := 0;
                Loans."Principal Arrears" := 0;
                Loans.Modify();
            end;
        end;
    end;

    procedure GetLoanBandsTest(MemberNo: Code[20]; LoanCode: Code[20]; var ResponseCode: Code[20]; var ResponseMessage: Text)
    var
        ProductInterestBands: Record "Product Interest Bands";
        NestedProductInterestBandsObj: JsonObject;
        LoanProductObj: JsonObject;
        LoanProductArr: JsonArray;
        count: Integer; //30OCT
        j: Integer; //30OCT
    begin
        j := 1; //30OCT
        Clear(ResponseMessage);
        responseCode := '00';
        ProductInterestBands.Reset();
        ProductInterestBands.SetRange(ProductInterestBands."Source Code", LoanCode);
        ProductInterestBands.SetRange(ProductInterestBands.Active, true);
        if ProductInterestBands.FindSet then begin
            count := ProductInterestBands.Count;
            repeat
                NestedProductInterestBandsObj.Add('Min Installments', ProductInterestBands."Min Installments");
                NestedProductInterestBandsObj.Add('Max Installments', ProductInterestBands."Max Installments");
                NestedProductInterestBandsObj.Add('Interest Rate', ProductInterestBands."Interest Rate");
                if j <> count then LoanProductArr.Add(NestedProductInterestBandsObj);
                j += 1;
            until ProductInterestBands.Next() = 0;
            LoanProductObj.Add('ProductInterestBands', LoanProductArr);
        end;
        LoanProductObj.WriteTo(ResponseMessage);
    end;

    procedure GetLoanProductChargesAmount(Product: Code[20]; BaseAmount: Decimal) ChargeAmount: Decimal
    var
        ProductChargeSetup: Record "Product Charge Setup";
        TransactionCalcScheme: array[2] of Record "Transaction Calc. Scheme";
        PostingAmount, TotalCharges, TempBase : Decimal;
        strExtractedFrml: Text[250];
    begin
        TotalCharges := 0;
        ProductChargeSetup.Reset();
        ProductChargeSetup.SetRange("Source Code", Product);
        if ProductChargeSetup.FindSet() then begin
            repeat
                PostingAmount := 0;
                IF ProductChargeSetup."Calculation Type" = ProductChargeSetup."Calculation Type"::"Calculation Scheme" THEN BEGIN
                    TransactionCalcScheme[1].RESET;
                    TransactionCalcScheme[1].SETFILTER("Lower Limit", '<=%1', BaseAmount);
                    TransactionCalcScheme[1].SETFILTER("Upper Limit", '>=%1', BaseAmount);
                    TransactionCalcScheme[1].SETRANGE("Source Code", ProductChargeSetup."Source Code");
                    TransactionCalcScheme[1].SETRANGE("Charge Code", ProductChargeSetup."Charge Code");
                    IF TransactionCalcScheme[1].FINDFIRST THEN BEGIN
                        PostingAmount := TransactionCalcScheme[1].Rate;
                        if TransactionCalcScheme[1]."Rate Type" = TransactionCalcScheme[1]."Rate Type"::Percentage THEN begin
                            PostingAmount := ((TransactionCalcScheme[1].Rate) / 100) * BaseAmount;
                            if ((TransactionCalcScheme[1]."Upper Charge Limit" <> 0) and ((((TransactionCalcScheme[1].Rate) / 100) * BaseAmount) > TransactionCalcScheme[1]."Upper Charge Limit")) then
                                PostingAmount := TransactionCalcScheme[1]."Upper Charge Limit"
                            else if ((TransactionCalcScheme[1]."Lower Charge Limit" <> 0) and ((((TransactionCalcScheme[1].Rate) / 100) * BaseAmount) < TransactionCalcScheme[1]."Lower Charge Limit")) then PostingAmount := TransactionCalcScheme[1]."Lower Charge Limit";
                        end;
                    end;
                end
                else if ProductChargeSetup."Calculation Type" = ProductChargeSetup."Calculation Type"::"Percentage of Charge" then begin
                    strExtractedFrml := '';
                    strExtractedFrml := fnPureFormula(ProductChargeSetup."Source Charge", Product, BaseAmount);
                    PostingAmount := Round(fnFormulaResult(strExtractedFrml), 1, '=');
                end;
                TotalCharges += PostingAmount;
            until ProductChargeSetup.Next = 0;
        end;
        Exit(TotalCharges);
    end;

    procedure fnPureFormula(strFormula: Text[250]; ProductCode: Code[30]; BaseAmount: Decimal) Formula: Text[250]
    var
        Where: Text[30];
        Which: Text[30];
        i: Integer;
        Char: Text[1];
        FirstBracket: Integer;
        StartCopy: Boolean;
        FinalFormula: Text[250];
        TransCode: Text[250];
        TransCodeAmount: Decimal;
        AccSchedLine: Record "Acc. Schedule Line";
        ColumnLayout: Record "Column Layout";
        CalcAddCurr: Boolean;
        AccSchedMgt: Codeunit AccSchedManagement;
    begin
        TransCode := '';
        for i := 1 to StrLen(strFormula) do begin
            Char := CopyStr(strFormula, i, 1);
            if Char = '[' then StartCopy := true;
            if StartCopy then TransCode := TransCode + Char;
            //Copy Characters as long as is not within []
            if not StartCopy then FinalFormula := FinalFormula + Char;
            if Char = ']' then begin
                StartCopy := false;
                //Get Transcode
                Where := '=';
                Which := '[]';
                TransCode := DelChr(TransCode, Where, Which);
                //Get TransCodeAmount
                TransCodeAmount := fnGetTransAmount(ProductCode, TransCode, BaseAmount);
                //ERROR('Format %1',TransCodeAmount);
                //Reset Transcode
                TransCode := '';
                //Get Final Formula
                FinalFormula := FinalFormula + Format(TransCodeAmount);
                //End Get Transcode
            end;
        end;
        Formula := FinalFormula;
    end;

    procedure fnGetTransAmount(ProductCode: Code[20]; ChargeCode: Code[20]; BaseAmount: Decimal) ChargeAmount: Decimal
    var
        ProductChargeSetup: Record "Product Charge Setup";
        TransactionCalcScheme: array[2] of Record "Transaction Calc. Scheme";
        PostingAmount, TotalCharges, TempBase : Decimal;
        strExtractedFrml: Text[250];
    begin
        TotalCharges := 0;
        ProductChargeSetup.Reset();
        ProductChargeSetup.SetRange("Source Code", ProductCode);
        ProductChargeSetup.SetRange("Charge Code", ChargeCode);
        if ProductChargeSetup.FindFirst then begin
            PostingAmount := 0;
            IF ProductChargeSetup."Calculation Type" = ProductChargeSetup."Calculation Type"::"Calculation Scheme" THEN BEGIN
                TransactionCalcScheme[1].RESET;
                TransactionCalcScheme[1].SETFILTER("Lower Limit", '<=%1', BaseAmount);
                TransactionCalcScheme[1].SETFILTER("Upper Limit", '>=%1', BaseAmount);
                TransactionCalcScheme[1].SETRANGE("Source Code", ProductChargeSetup."Source Code");
                TransactionCalcScheme[1].SETRANGE("Charge Code", ProductChargeSetup."Charge Code");
                IF TransactionCalcScheme[1].FINDFIRST THEN BEGIN
                    PostingAmount := TransactionCalcScheme[1].Rate;
                    if TransactionCalcScheme[1]."Rate Type" = TransactionCalcScheme[1]."Rate Type"::Percentage THEN begin
                        PostingAmount := ((TransactionCalcScheme[1].Rate) / 100) * BaseAmount;
                        if ((TransactionCalcScheme[1]."Upper Charge Limit" <> 0) and ((((TransactionCalcScheme[1].Rate) / 100) * BaseAmount) > TransactionCalcScheme[1]."Upper Charge Limit")) then
                            PostingAmount := TransactionCalcScheme[1]."Upper Charge Limit"
                        else if ((TransactionCalcScheme[1]."Lower Charge Limit" <> 0) and ((((TransactionCalcScheme[1].Rate) / 100) * BaseAmount) < TransactionCalcScheme[1]."Lower Charge Limit")) then PostingAmount := TransactionCalcScheme[1]."Lower Charge Limit";
                    end;
                end;
            end
            else if ProductChargeSetup."Calculation Type" = ProductChargeSetup."Calculation Type"::"Percentage of Charge" then begin
                TransactionCalcScheme[1].RESET;
                TransactionCalcScheme[1].SETFILTER("Lower Limit", '<=%1', BaseAmount);
                TransactionCalcScheme[1].SETFILTER("Upper Limit", '>=%1', BaseAmount);
                TransactionCalcScheme[1].SETRANGE("Source Code", ProductChargeSetup."Source Code");
                TransactionCalcScheme[1].SETRANGE("Charge Code", ProductChargeSetup."Source Charge");
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
                    TransactionCalcScheme[2].SETRANGE("Source Code", ProductChargeSetup."Source Code");
                    TransactionCalcScheme[2].SETRANGE("Charge Code", ProductChargeSetup."Charge Code");
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
        end;
        Exit(Round(TotalCharges));
    end;

    procedure fnFormulaResult(strFormula: Text[250]) Results: Decimal
    var
        AccSchedLine: Record "Acc. Schedule Line";
        ColumnLayout: Record "Column Layout";
        CalcAddCurr: Boolean;
        AccSchedMgt: Codeunit "AccSchedManagement Ext";
    begin
        Results := AccSchedMgt.EvaluateExpression(true, strFormula, AccSchedLine, ColumnLayout, CalcAddCurr);
    end;

    procedure AppraiseZeroDeposits(Loans: Record Loans)
    var
        LoanProducts: Record "Sacco Products";
        LoanRecoveries: Record "Loan Recoveries";
        MemberDeposits, ExpectedDeposits, Variance : Decimal;
        Ok: Boolean;
        AccountNo: Code[20];
        MemberMgt: Codeunit "Member Management";
        ProductPostingType: Enum "Product Posting Type";
    begin
        AccountNo := '';
        ExpectedDeposits := 0;
        if LoanProducts.Get(Loans."Product Code") then begin
            if Loans."Loan Multiplier" <> 0 then
                ExpectedDeposits := Loans."Loan Amount" / Loans."Loan Multiplier"
            else
                ExpectedDeposits := Loans."Loan Amount" / 4;
            if LoanProducts."Appraise with 0 Deposits" then begin
                MemberDeposits := GetMemberDeposits(Loans."Member No.");
                Variance := ExpectedDeposits - MemberDeposits;
                if Variance < 0 then Variance := 0;
                AccountNo := MemberMgt.GetMemberAccount(Loans."Member No.", ProductPostingType::"Non Withdrawable Deposit");
                if AccountNo = '' then AccountNo := MemberMgt.GetMemberAccount(Loans."Member No.", ProductPostingType::"Withdrawable Deposit");
                // if not LoanRecoveries.Get(LoanApplication."No.", LoanRecoveries."Recovery Type"::Account, AccountNo) then begin
                //     LoanRecoveries.Init();
                //     LoanRecoveries."Loan No" := LoanApplication."No.";
                //     LoanRecoveries."Recovery Type" := LoanRecoveries."Recovery Type"::Account;
                //     LoanRecoveries.Validate("Recovery Code", 'DEP-' + LoanApplication."Member No.");
                //     LoanRecoveries.Amount := Variance;
                //     LoanRecoveries.Validate(Amount);
                //     if Variance <> 0 then Ok := LoanRecoveries.Insert();
                // end;
            end;
        end;
        Commit();
    end;

    procedure GetFOSAAccount(MemberNo: Code[20]) FOSAAccount: Code[20]
    var
        AccountType: Record "Sacco Products";
        Vendor: Record Vendor;
        MemberMgt: Codeunit "Member Management";
        ProductPostingType: Enum "Product Posting Type";
    begin
        FOSAAccount := MemberMgt.GetMemberAccount(MemberNo, ProductPostingType::"Withdrawable Deposit");
        exit(FOSAAccount);
    end;

    procedure PopulateAppraisalParameters(Loan: Record Loans)
    var
        LoanAppraisalParameters: Record "Loanees Payroll Transactions";
        AppraisalParameters: Record "Loanees Payroll Codes";
        Vendor: Record Vendor;
        AccountTypes: Record "Sacco Products";
        AppraisalAccounts: Record "Appraisal Accounts";
        Loans: Record Loans;
        LoanProducts: Record "Sacco Products";
        LoanApp: Record Loans;
        LoanRecoveries: Record "Loan Recoveries";
        ProductFactory: Record "Sacco Products";
        CommissionPercent: Decimal;
    begin
        LoanAppraisalParameters.Reset();
        LoanAppraisalParameters.SetRange("Source No.", loan."No.");
        if LoanAppraisalParameters.Findset then LoanAppraisalParameters.DeleteAll();
        AppraisalAccounts.Reset();
        AppraisalAccounts.SetRange("Loan No", Loan."No.");
        if AppraisalAccounts.FindSet() then AppraisalAccounts.DeleteAll();
        if LoanProducts.Get(Loan."Product Code") then begin
            Loans.Reset();
            Loans.SetRange("Member No.", Loan."Member No.");
            loans.SetFilter("Loan Balance", '>0');
            if Loans.FindSet() then begin
                repeat
                    loans.CalcFields("Loan Balance");
                    AppraisalAccounts.Init();
                    AppraisalAccounts."Loan No" := Loan."No.";
                    AppraisalAccounts."Account Type" := AppraisalAccounts."Account Type"::Loan;
                    AppraisalAccounts."Account No" := Loans."No.";
                    AppraisalAccounts."Account Description" := Loans."Product Description";
                    AppraisalAccounts.Balance := Loans."Loan Balance";
                    AppraisalAccounts.Insert();
                until Loans.Next() = 0;
            end;
            Vendor.Reset();
            Vendor.SetRange("Member No.", Loan."Member No.");
            if Vendor.FindSet() then begin
                repeat
                    Vendor.CalcFields("Net Change");
                    AppraisalAccounts.Init();
                    AppraisalAccounts."Loan No" := Loan."No.";
                    AppraisalAccounts."Account Type" := AppraisalAccounts."Account Type"::"Member Account";
                    AppraisalAccounts."Account No" := Vendor."No.";
                    AppraisalAccounts."Account Description" := Vendor.Name;
                    AppraisalAccounts.Balance := Vendor."Net Change";
                    if Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Non Withdrawable Deposit" then
                        AppraisalAccounts."Mulltipled Value" := Vendor."Net Change" * Loan."Loan Multiplier";
                    AppraisalAccounts.Insert();
                until Vendor.Next() = 0;
            end;
            AppraisalParameters.Reset();
            if AppraisalParameters.FindSet() then begin
                repeat
                    LoanAppraisalParameters.Init();
                    LoanAppraisalParameters."Source No." := Loan."No.";
                    LoanAppraisalParameters.Code := AppraisalParameters.Code;
                    LoanAppraisalParameters.Name := AppraisalParameters.Name;
                    LoanAppraisalParameters.Type := AppraisalParameters.Type;
                    LoanAppraisalParameters."Transaction Type" := AppraisalParameters."Transaction Type";
                    LoanAppraisalParameters.Insert();
                until AppraisalParameters.Next() = 0;
            end;
        end;

        LoanApp.Reset();
        LoanApp.SetFilter("Loan Balance", '>0');
        LoanApp.SetRange("Member No.", Loan."Member No.");
        LoanApp.SetRange("Product Code", Loan."Product Code");
        LoanApp.SetFilter(Category, '<>%1&<>%2', Loan.Category::DEBT, Loan.Category::HR);
        if LoanApp.FindSet() then begin
            ProductFactory.Get(LoanApp."Product Code");
            if ProductFactory."Max. Running Loans" <= 1 then begin
                CommissionPercent := 0;
                CommissionPercent := ProductFactory."Bridging Commision %";
                LoanRecoveries.Reset();
                LoanRecoveries.SetRange("Loan No", Loan."No.");
                LoanRecoveries.SetRange("Recovery Type", LoanRecoveries."Recovery Type"::Loan);
                LoanRecoveries.SetRange("Recovery Code", LoanApp."No.");
                if LoanRecoveries.Findfirst then begin
                    LoanRecoveries."Recovery Description" := ProductFactory.Description;
                    LoanRecoveries."Commission %" := CommissionPercent;
                    LoanRecoveries."Commission Account" := ProductFactory."Commission Account";
                    LoanApp.CalcFields("Loan Balance");
                    LoanRecoveries."Current Balance" := LoanApp."Loan Balance";
                    LoanRecoveries.Validate(Amount, LoanRecoveries."Current Balance");
                    LoanRecoveries.Modify();
                end
                else begin
                    LoanRecoveries.Init();
                    LoanRecoveries."Loan No" := Loan."No.";
                    LoanRecoveries."Recovery Type" := LoanRecoveries."Recovery Type"::Loan;
                    LoanRecoveries.Validate("Recovery Code", LoanApp."No.");
                    ProductFactory.Get(LoanApp."Product Code");
                    LoanRecoveries."Recovery Code" := LoanApp."No.";
                    LoanRecoveries."Recovery Description" := ProductFactory.Description;
                    LoanRecoveries."Commission %" := CommissionPercent;
                    LoanRecoveries."Commission Account" := ProductFactory."Commission Account";
                    LoanApp.CalcFields("Loan Balance");
                    LoanRecoveries."Current Balance" := LoanApp."Loan Balance";
                    LoanRecoveries.Validate(Amount, LoanRecoveries."Current Balance");
                    LoanRecoveries.Insert();
                end;
            end;
        end;
    end;

    procedure PopulatePreAppraisalParameters(LoanCalculator: Record "Loan Calculator")
    var
        LoanAppraisalParameters: array[3] of Record "Loanees Payroll Transactions";
        AppraisalParameters: Record "Loanees Payroll Codes";
    begin
        LoanAppraisalParameters[1].Reset();
        LoanAppraisalParameters[1].SetRange("Source No.", LoanCalculator."No.");
        if LoanAppraisalParameters[1].Findset then LoanAppraisalParameters[1].DeleteAll();
        AppraisalParameters.Reset();
        if AppraisalParameters.FindSet() then begin
            repeat
                LoanAppraisalParameters[2].Init();
                LoanAppraisalParameters[2]."Source No." := LoanCalculator."No.";
                LoanAppraisalParameters[2].Type := AppraisalParameters.Type;
                LoanAppraisalParameters[2].Validate(Code, AppraisalParameters.Code);
                LoanAppraisalParameters[2].Name := AppraisalParameters.Name;
                LoanAppraisalParameters[2].Type := AppraisalParameters.Type;
                LoanAppraisalParameters[2]."Transaction Type" := AppraisalParameters."Transaction Type";
                if not LoanAppraisalParameters[3].Get(LoanCalculator."No.", AppraisalParameters.Type, AppraisalParameters.Code) then LoanAppraisalParameters[2].Insert(true);
            until AppraisalParameters.Next() = 0;
        end
        else
            error('No Appraisal Parameter is set.');
    end;

    procedure GetBoostedDeposits(Application: Code[20]) BoostedAmount: Decimal
    var
        Recoveries: Record "Loan Recoveries";
    begin
        Recoveries.Reset();
        Recoveries.SetRange("Recovery Type", Recoveries."Recovery Type"::Account);
        Recoveries.SetRange("Loan No", Application);
        Recoveries.SetFilter(Amount, '>0');
        if Recoveries.FindSet() then begin
            Recoveries.CalcSums(Amount);
            BoostedAmount := Recoveries.Amount;
        end;
        exit(BoostedAmount);
    end;

    procedure PopulateChannelAppraisalParameters(Loan: Record "Channel Loan Application")
    var
        LoanAppraisalParameters: Record "Loanees Payroll Transactions";
        AppraisalParameters: Record "Loanees Payroll Codes";
        Vendor: Record Vendor;
        AccountTypes: Record "Sacco Products";
        AppraisalAccounts: Record "Appraisal Accounts";
        Loans: Record Loans;
        LoanProducts: Record "Sacco Products";
        LoanApp: Record Loans;
        LoanRecoveries: Record "Loan Recoveries";
        ProductFactory: Record "Sacco Products";
        CommissionPercent: Decimal;
    begin
        LoanAppraisalParameters.Reset();
        LoanAppraisalParameters.SetRange("Source No.", loan."No.");
        if LoanAppraisalParameters.findset then LoanAppraisalParameters.DeleteAll();
        AppraisalAccounts.Reset();
        AppraisalAccounts.SetRange("Loan No", Loan."No.");
        if AppraisalAccounts.FindSet() then AppraisalAccounts.DeleteAll();
        if LoanProducts.Get(Loan."Product Code") then begin
            Loans.Reset();
            Loans.SetRange("Member No.", Loan."Member No.");
            loans.SetFilter("Loan Balance", '>0');
            if Loans.FindSet() then begin
                repeat
                    loans.CalcFields("Loan Balance");
                    AppraisalAccounts.Init();
                    AppraisalAccounts."Loan No" := Loan."No.";
                    AppraisalAccounts."Account Type" := AppraisalAccounts."Account Type"::Loan;
                    AppraisalAccounts."Account No" := Loans."No.";
                    AppraisalAccounts."Account Description" := Loans."Product Description";
                    AppraisalAccounts.Balance := Loans."Loan Balance";
                    AppraisalAccounts.Insert();
                until Loans.Next() = 0;
            end;
            Vendor.Reset();
            Vendor.SetRange("Member No.", Loan."Member No.");
            if Vendor.FindSet() then begin
                repeat
                    Vendor.CalcFields("Net Change");
                    AppraisalAccounts.Init();
                    AppraisalAccounts."Loan No" := Loan."No.";
                    AppraisalAccounts."Account Type" := AppraisalAccounts."Account Type"::"Member Account";
                    AppraisalAccounts."Account No" := Vendor."No.";
                    AppraisalAccounts."Account Description" := Vendor.Name;
                    AppraisalAccounts.Balance := Vendor."Net Change";
                    if Vendor."Product Posting Type" = Vendor."Product Posting Type"::"Non Withdrawable Deposit" then AppraisalAccounts."Mulltipled Value" := (Vendor."Net Change" + GetBoostedDeposits(Loan."No.")) * LoanProducts."Loan Multiplier";
                    AppraisalAccounts.Insert();
                until Vendor.Next() = 0;
            end;
            AppraisalParameters.Reset();
            if AppraisalParameters.FindSet() then begin
                repeat
                    LoanAppraisalParameters.Init();
                    LoanAppraisalParameters."Source No." := Loan."No.";
                    LoanAppraisalParameters.Code := AppraisalParameters.Code;
                    LoanAppraisalParameters.Name := AppraisalParameters.Name;
                    LoanAppraisalParameters.Type := AppraisalParameters.Type;
                    LoanAppraisalParameters."Transaction Type" := AppraisalParameters."Transaction Type";
                    LoanAppraisalParameters.Insert();
                until AppraisalParameters.Next() = 0;
            end;
        end;
        LoanApp.Reset();
        LoanApp.SetFilter("Loan Balance", '>0');
        LoanApp.SetRange("Member No.", Loan."Member No.");
        LoanApp.SetRange("Product Code", Loan."Product Code");
        if LoanApp.FindSet() then begin
            ProductFactory.Get(LoanApp."Product Code");
            CommissionPercent := 0;
            CommissionPercent := ProductFactory."Bridging Commision %";
            LoanRecoveries.Reset();
            LoanRecoveries.SetRange("Loan No", Loan."No.");
            LoanRecoveries.SetRange("Recovery Type", LoanRecoveries."Recovery Type"::Loan);
            LoanRecoveries.SetRange("Recovery Code", LoanApp."No.");
            if LoanRecoveries.findfirst then begin
                LoanRecoveries."Recovery Description" := ProductFactory.Description;
                LoanRecoveries."Commission %" := CommissionPercent;
                LoanRecoveries."Commission Account" := ProductFactory."Commission Account";
                LoanApp.CalcFields("Loan Balance");
                LoanRecoveries."Current Balance" := LoanApp."Loan Balance";
                LoanRecoveries.Validate(Amount, LoanRecoveries."Current Balance");
                LoanRecoveries.Modify();
            end
            else begin
                ProductFactory.Get(LoanApp."Product Code");
                LoanRecoveries.Init();
                LoanRecoveries."Loan No" := Loan."No.";
                LoanRecoveries."Recovery Type" := LoanRecoveries."Recovery Type"::Loan;
                LoanRecoveries.Validate("Recovery Code", LoanApp."No.");
                ProductFactory.Get(LoanApp."Product Code");
                LoanRecoveries."Recovery Code" := LoanApp."No.";
                LoanRecoveries."Recovery Description" := ProductFactory.Description;
                LoanRecoveries."Commission %" := CommissionPercent;
                LoanRecoveries."Commission Account" := ProductFactory."Commission Account";
                LoanApp.CalcFields("Loan Balance");
                LoanRecoveries."Current Balance" := LoanApp."Loan Balance";
                LoanRecoveries.Validate(Amount, LoanRecoveries."Current Balance");
                LoanRecoveries.Insert();
            end;
        end;
    end;

    procedure GetMemberLoans(MemberNo: Code[20]) LoanBalance: Decimal
    var
        Members: Record Members;
    begin
        LoanBalance := 0;
        if Members.Get(MemberNo) then begin
            Members.CalcFields("Outstanding Loans");
            LoanBalance := Members."Outstanding Loans";
        end;
        if LoanBalance < 0 then LoanBalance := 0;
        exit(LoanBalance);
    end;

    procedure GetMemberShares(MemberNo: Code[20]) SharesBalance: Decimal
    var
        Vendor: Record Vendor;
    begin
        Vendor.Reset();
        Vendor.setrange("Member No.", MemberNo);
        Vendor.SetRange("Product Posting Type", Vendor."Product Posting Type"::"Share Capital Account");
        if Vendor.FindSet() then begin
            repeat
                Vendor.CalcFields("Net Change");
                SharesBalance += Vendor."Net Change";
            until Vendor.Next() = 0;
        end;
        if SharesBalance < 0 then SharesBalance := 0;
        exit(SharesBalance);
    end;

    procedure GetSelfGuaranteeEligibility(MemberNo: code[20]) SelfGuaranteeAmount: Decimal
    var
        Vendor: Record Vendor;
        SelfG, NonSelfG, Deposits, DepositBalance, MultipliedDeposit, ProratedDeposits : Decimal;
        LoanGuarantee: Record "Loan Guarantees";
        AccountType: Record "Sacco Products";
        Member: Record Members;
    begin
        if Member.Get(MemberNo) then begin
            Member.CalcFields("Self Guarantee", "Non-Self Guarantee");
            SelfG := 0;
            NonSelfG := 0;
            GetSelfGuaranteeAmount(MemberNo, SelfG, NonSelfG);
            Deposits := 0;
            Deposits := GetMemberDeposits(MemberNo);
            ProratedDeposits := 0;
            ProratedDeposits := Deposits * GetSelfGuarantorMultiplier;
            if NonSelfG = 0 then
                SelfGuaranteeAmount := (Deposits * GetSelfGuarantorMultiplier) - SelfG
            else begin
                if GetGuarantorMultiplier <> 0 then
                    SelfGuaranteeAmount := (ProratedDeposits - ((NonSelfG / GetGuarantorMultiplier) + SelfG))
                else
                    SelfGuaranteeAmount := 0;
            end;
            exit(SelfGuaranteeAmount);
        end;
    end;

    procedure GetGuarantorMultiplier() Multiplier: Decimal
    var
        SaccoSetup: Record "General Ledger Setup";
    begin
        SaccoSetup.Get();
        if SaccoSetup."Guarantor Multiplier" = 0 then
            Multiplier := 1
        else
            Multiplier := SaccoSetup."Guarantor Multiplier";
        exit(Multiplier);
    end;

    procedure GetSelfGuarantorMultiplier() Multiplier: Decimal
    var
        SaccoSetup: Record "General Ledger Setup";
    begin
        SaccoSetup.Get();
        if SaccoSetup."Self Guarantor Multiplier" = 0 then
            Multiplier := 1
        else
            Multiplier := SaccoSetup."Self Guarantor Multiplier";
        exit(Multiplier);
    end;

    procedure GetSelfGuaranteeAmount(MemberNo: Code[20]; var SelfAmount: Decimal; var NonSelfAmount: Decimal)
    var
        LoanGuarantee: Record "Loan Guarantees";
        MembebrMgt: Codeunit "Member Management";
    begin
        SelfAmount := 0;
        NonSelfAmount := 0;
        LoanGuarantee.Reset();
        LoanGuarantee.SetRange(Substituted, false);
        LoanGuarantee.SetRange("Member No.", MemberNo);
        if LoanGuarantee.FindSet() then begin
            repeat
                LoanGuarantee.CalcFields("Loan Owner");
                if LoanGuarantee."Loan Owner" = MemberNo then
                    SelfAmount += MembebrMgt.GetOutstandingGuarantee(LoanGuarantee."Loan No", LoanGuarantee."Member No.")
                else
                    NonSelfAmount += MembebrMgt.GetOutstandingGuarantee(LoanGuarantee."Loan No", LoanGuarantee."Member No.");
            until LoanGuarantee.next() = 0;
        end;
    end;

    procedure GetNonSelfGuaranteeEligibility(MemberNo: code[20]) NonSelfGuaranteeAmount: Decimal
    var
        Vendor: Record Vendor;
        SelfG, NonSelfG, Deposits, DepositBalance, MultipliedDeposit, OutstandingGuarantee : Decimal;
        LoanGuarantee: Record "Loan Guarantees";
        AccountType: Record "Sacco Products";
        Member: Record Members;
        MemberMgt: Codeunit "Member Management";
        Multiplier: Decimal;
    begin
        if Member.Get(MemberNo) then begin
            Member.CalcFields("Self Guarantee", "Non-Self Guarantee");
            Deposits := 0;
            SelfG := 0;
            NonSelfG := 0;
            Deposits := GetMemberDeposits(MemberNo);
            Multiplier := 0;
            Multiplier := GetGuarantorMultiplier;
            OutstandingGuarantee := 0;
            OutstandingGuarantee := GetMemberOutstandingGuarantee(MemberNo);
            NonSelfGuaranteeAmount := (Deposits * Multiplier) - OutstandingGuarantee;
            if NonSelfGuaranteeAmount > GetMemberDeposits(MemberNo) then NonSelfGuaranteeAmount := GetMemberDeposits(MemberNo);
            exit(NonSelfGuaranteeAmount);
        end;
    end;

    procedure GetMemberOutstandingGuarantee(MemberNo: Code[20]) OutStandingGuarantee: Decimal
    var
        LoanGuarantee: Record "Loan Guarantees";
        MemberMgt: Codeunit "Member Management";
    begin
        OutStandingGuarantee := 0;
        LoanGuarantee.Reset();
        LoanGuarantee.SetRange(Substituted, false);
        LoanGuarantee.SetRange("Member No.", MemberNo);
        if LoanGuarantee.FindSet() then begin
            repeat
                OutStandingGuarantee += MemberMgt.GetOutstandingGuarantee(LoanGuarantee."Loan No", MemberNo);
            until LoanGuarantee.Next() = 0;
        end;
        exit(OutStandingGuarantee);
    end;

    procedure GetMemberSpecialLoanAmount(MemberNo: Code[20]; LoanNo: Code[20]; var TotalLoanBalance: Decimal; var SpecialShare: Decimal)
    var
        LoanProduct: Record "Sacco Products";
        Loans: Record Loans;
        LoanRecoveries: Record "Loan Recoveries";
    begin
        LoanProduct.Reset();
        LoanProduct.SetRange("Special Loan Multiplier", true);
        if LoanProduct.FindSet() then begin
            repeat
                Loans.Reset();
                Loans.SetFilter("Loan Balance", '>0');
                Loans.SetRange("Member No.", MemberNo);
                Loans.SetRange("Product Code", LoanProduct.Code);
                if Loans.FindSet() then begin
                    repeat
                        LoanRecoveries.Reset();
                        LoanRecoveries.SetRange("Loan No", LoanNo);
                        LoanRecoveries.SetRange("Recovery Type", LoanRecoveries."Recovery Type"::Loan);
                        LoanRecoveries.SetRange("Recovery Code", Loans."No.");
                        if LoanRecoveries.IsEmpty then begin
                            Loans.CalcFields("Loan Balance");
                            TotalLoanBalance += Loans."Loan Balance";
                            SpecialShare += (Loans."Loan Balance" / Loans."Loan Multiplier");
                        end;
                    until Loans.Next() = 0;
                end;
            until LoanProduct.Next() = 0;
        end;
    end;

    procedure GetMemberDeposits(MemberNo: Code[20]) Deposits: Decimal
    var
        Vendor: Record Vendor;
        FormatedNo: code[20];
        AccountType: Record "Sacco Products";
        Member: Record Members;
    begin
        Deposits := 0;
        if Member.Get(MemberNo) then begin
            Member.CalcFields("Total Deposits");
            Deposits := Member."Total Deposits";
        end;
        if Deposits < 0 then Deposits := 0;
        exit(Deposits);
    end;

    procedure GetMemberAvailableBalance(MemberNo: Code[20]) AvailableBalance: Decimal
    var
        Vendor: Record Vendor;
        FormatedNo: code[20];
        AccountType: Record "Sacco Products";
        Member: Record Members;
        ChannelsIntegrations: Codeunit "Channels Integrations";
    begin
        AvailableBalance := 0;
        AccountType.Reset();
        AccountType.SetRange("Product Posting Type", AccountType."Product Posting Type"::"Withdrawable Deposit");
        if AccountType.FindSet then begin
            if Member.Get(MemberNo) then begin
                Member.CalcFields("Total Withdrawable Deposits", "Uncleared Funds");
                AvailableBalance := Member."Total Withdrawable Deposits" - Member."Uncleared Funds" - AccountType."Minimum Balance" - ChannelsIntegrations.GetPendingChannelsTransactions(MemberNo);
            end;
        end;
        if AvailableBalance < 0 then AvailableBalance := 0;
        exit(AvailableBalance);
    end;

    internal procedure AppraiseFosaSalary(MemberNo: Code[20]; ProductCode: Code[20]; LoanNo: Code[20]) Eligibility: Decimal
    var
        LProducts: Record "Sacco Products";
        SDate, EndDate : Date;
        DateFilter: Text;
        CurrentDocNo, PrevDocNo : Code[20];
        SalaryCount: Integer;
        CheckOffLines, CheckOffLines2 : Record "Checkoff Lines";
        NetAmount, LowestAmount, BaseAmount : Decimal;
    begin
        BaseAmount := 0;
        EndDate := WorkDate;
        SalaryCount := 0;
        if LProducts.Get(ProductCode) then begin
            /*Henry if LProducts."Salary Based" then begin
                             SDate := CalcDate(StrSubstNo('-%1M', LProducts."Min. Salary Count"), EndDate);
                             SDate := DMY2Date(1, Date2DMY(SDate, 2), Date2DMY(SDate, 3));

                             DateFilter := Format(SDate) + '..' + Format(EndDate);
                             SalaryCount := 0;
                             CheckOffLines.Reset();
                             CheckOffLines.SetRange("Member No", MemberNo);
                             CheckOffLines.SetFilter("Posting Date", DateFilter);
                             CheckOffLines.SetRange("Upload Type", CheckOffLines."Upload Type"::Salary);
                             CheckOffLines.SetRange(Posted, true);
                             if CheckOffLines.FindSet() then begin
                                 PrevDocNo := 'PREV';
                                 repeat
                                     CurrentDocNo := CheckOffLines."No.";
                                     if CurrentDocNo <> PrevDocNo then begin
                                         SalaryCount += 1;
                                         PrevDocNo := CurrentDocNo;
                                         CheckOffLines2.Reset();
                                         CheckOffLines2.CopyFilters(CheckOffLines);
                                         CheckOffLines2.SetRange("No.", CurrentDocNo);
                                         if CheckOffLines2.FindSet() then begin
                                             CheckOffLines2.CalcFields("Net Amount", "Posting Date", "Amount Earned", Recoveries);
                                             NetAmount := -1 * CheckOffLines2."Net Amount";
                                             if ((LowestAmount = 0) OR (NetAmount < LowestAmount)) then
                                                 LowestAmount := NetAmount;
                                             BaseAmount += NetAmount;
                                           end;
                                       end;
                                 until CheckOffLines.Next() = 0;
                               end;
                             if ((LProducts."Min. Salary Count" <> 0) AND (SalaryCount < LProducts."Min. Salary Count")) then
                                 Error('You must have processed at least %1 salaries between %2', LProducts."Min. Salary Count", DateFilter);
                             case LProducts."Salary Appraisal Type" of
                                 LProducts."Salary Appraisal Type"::"Average Net":
                                     begin
                                         If SalaryCount <> 0 then
                                             BaseAmount := BaseAmount / SalaryCount;
                                       end;
                                 LProducts."Salary Appraisal Type"::"Lowest Net":
                                     BaseAmount := LowestAmount;
                               end;

                             Eligibility := BaseAmount * LProducts."Salary %" * 0.01;
                           end;
                         */
        end;
        exit(Eligibility);
    end;

    procedure OnBeforeSendLoanRestructureForApproval(DocumentNo: Code[20])
    var
        LoanRestructure: Record "Loan Moratorium";
    begin
        LoanRestructure.Get(DocumentNo);
        LoanRestructure.TestField("Member No.");
        LoanRestructure.TestField("Loan No.");
        If LoanRestructure.Type = LoanRestructure.Type::Restructure then begin
            LoanRestructure.TestField(Installments);
            LoanRestructure.TestField("Restructure Date");
        end else begin
            LoanRestructure.TestField("Moratorium Date");
            LoanRestructure.TestField("Moratorium Period");
        end;
    end;

    procedure PostLoanMoratorium(DocumentNo: Code[20])
    var
        LoanMoratorium: array[2] of Record "Loan Moratorium";
        VersionCount, i, EntryNo : Integer;
        RepaymentSchedule: Record "Loan Schedule";
        LoanProducts: Record "Sacco Products";
        StartDate, EndDate : Date;
        Window: Dialog;
        Loans: Record Loans;
        InstallmentNo: Code[20];
        PrincipalBalance, TotalMRepay, PrincipalAmnt, InterestBalance, LBalance, LPrincipal, LInterest, RefinancedDividend : Decimal;
    begin

        LoanMoratorium[1].Get(DocumentNo);
        if LoanMoratorium[1].Type = LoanMoratorium[1].Type::Restructure then
            PostLoanRestructure(LoanMoratorium[1]."No.")
        else begin

            Loans.Get(LoanMoratorium[1]."Loan No.");

            i := (Loans.Installments - (LoanMoratorium[1]."Moratorium Period" + LoanMoratorium[1]."Remaining Installments Months")) + 1;
            LoanMoratorium[2].Reset();
            LoanMoratorium[2].SetRange(Posted, true);
            LoanMoratorium[2].SetRange("Loan No.", LoanMoratorium[1]."Loan No.");
            if LoanMoratorium[2].FindSet() then begin
                VersionCount := LoanMoratorium[2].Count;
            end;

            RepaymentSchedule.Reset();
            RepaymentSchedule.SetRange("Loan No.", LoanMoratorium[1]."Loan No.");
            RepaymentSchedule.SetFilter("Expected Date", '>=%1', LoanMoratorium[1]."Moratorium Start Date");
            if RepaymentSchedule.FindSet() then
                RepaymentSchedule.DeleteAll();

            RepaymentSchedule.Reset();
            if RepaymentSchedule.FindLast() then
                EntryNo := RepaymentSchedule."Entry No" + 1
            else
                EntryNo := 1;

            //Recreate Schedule
            Window.Open('Creating Schedule \#1## \#2##');
            LoanProducts.GET(LoanMoratorium[1]."Product Code");
            EndDate := Loans."Repayment End Date";
            StartDate := LoanMoratorium[1]."Moratorium Start Date";


            PrincipalBalance := LoanMoratorium[1]."Current Principal Balance";

            PrincipalAmnt := 0;
            InterestBalance := 0;
            LBalance := PrincipalBalance;
            PrincipalAmnt := PrincipalBalance;
            Window.Update(2, EndDate);
            if LoanProducts."Rate Type" = LoanProducts."Rate Type"::Fixed then begin
                i += 1;
                LPrincipal := PrincipalAmnt / LoanMoratorium[1]."Remaining Installments Months";

                IF LoanProducts."Rate Type" = LoanProducts."Rate Type"::"Per-Annum" THEN
                    LInterest := (Loans."Interest Rate" / 12 / 100) * (PrincipalAmnt - RefinancedDividend)
                ELSE
                    LInterest := (Loans."Interest Rate" / 100) * (PrincipalAmnt - RefinancedDividend);

                // LPrincipal := Round(LPrincipal, 1, '>');
                // LInterest := Round(LInterest, 1, '>');


                If StartDate <= LoanMoratorium[1]."Moratorium End Date" then begin
                    if LoanMoratorium[1].Type = LoanMoratorium[1].Type::"Principal Moratorium" then
                        LPrincipal := 0;
                    if LoanMoratorium[1].Type = LoanMoratorium[1].Type::"Interest Moratorium" then
                        LInterest := 0;
                    if LoanMoratorium[1].Type = LoanMoratorium[1].Type::"Full Repayment Moratorium" then begin
                        LPrincipal := 0;
                        LInterest := 0;
                    end;
                end;

                LBalance := LBalance - LPrincipal;

                InstallmentNo := GetDocumentNo(StartDate, false);
                RepaymentSchedule.INIT;
                RepaymentSchedule."Entry No" := EntryNo;
                EntryNo += 1;
                RepaymentSchedule."Document No." := InstallmentNo;
                RepaymentSchedule."Expected Date" := StartDate;
                RepaymentSchedule.Description := 'Monthly Installment';
                RepaymentSchedule."Principal Repayment" := LPrincipal;
                RepaymentSchedule."Interest Repayment" := LInterest;
                RepaymentSchedule."Monthly Repayment" := LPrincipal + LInterest;
                RepaymentSchedule."Running Balance" := LBalance;
                RepaymentSchedule."Loan No." := Loans."No.";
                RepaymentSchedule.INSERT;
                Window.Update(1, InstallmentNo);
            end
            else begin
                repeat
                    i += 1;
                    LoanMoratorium[1].TESTFIELD("Remaining Installments Months");
                    IF Loans."Interest Repayment Method" = Loans."Interest Repayment Method"::Amortised THEN BEGIN
                        IF LoanProducts."Rate Type" = LoanProducts."Rate Type"::"Per-Annum" THEN
                            TotalMRepay := ROUND((Loans."Interest Rate" / 12 / 100) / (1 - POWER((1 + (Loans."Interest Rate" / 12 / 100)), -(LoanMoratorium[1]."Remaining Installments Months"))) * (PrincipalAmnt), 0.0001, '>')
                        ELSE
                            TotalMRepay := ROUND((Loans."Interest Rate" / 100) / (1 - POWER((1 + (Loans."Interest Rate" / 100)), -(LoanMoratorium[1]."Remaining Installments Months"))) * (PrincipalAmnt), 0.0001, '>');

                        LInterest := LBalance / 100 / 12 * Loans."Interest Rate";

                        LPrincipal := TotalMRepay - LInterest;
                    end;
                    IF Loans."Interest Repayment Method" = Loans."Interest Repayment Method"::"Straight Line" THEN BEGIN
                        LPrincipal := PrincipalAmnt / LoanMoratorium[1]."Remaining Installments Months";
                        IF LoanProducts."Rate Type" = LoanProducts."Rate Type"::"Per-Annum" THEN
                            LInterest := (Loans."Interest Rate" / 12 / 100) * PrincipalAmnt
                        ELSE
                            LInterest := (Loans."Interest Rate" / 100) * PrincipalAmnt;

                        LInterest := LInterest;
                    end;
                    IF Loans."Interest Repayment Method" = Loans."Interest Repayment Method"::"Reducing Balance" THEN BEGIN
                        LPrincipal := PrincipalAmnt / LoanMoratorium[1]."Remaining Installments Months";
                        IF LoanProducts."Rate Type" = LoanProducts."Rate Type"::"Per-Annum" THEN
                            LInterest := (Loans."Interest Rate" / 12 / 100) * LBalance
                        ELSE
                            LInterest := (Loans."Interest Rate" / 100) * LBalance;
                        LInterest := LInterest;
                    end;

                    // LPrincipal := Round(LPrincipal, 1, '>');
                    // LInterest := Round(LInterest, 1, '>');

                    If StartDate <= LoanMoratorium[1]."Moratorium End Date" then begin
                        if LoanMoratorium[1].Type = LoanMoratorium[1].Type::"Principal Moratorium" then
                            LPrincipal := 0;
                        if LoanMoratorium[1].Type = LoanMoratorium[1].Type::"Interest Moratorium" then
                            LInterest := 0;
                        if LoanMoratorium[1].Type = LoanMoratorium[1].Type::"Full Repayment Moratorium" then begin
                            LPrincipal := 0;
                            LInterest := 0;
                        end;
                    end;

                    LBalance := LBalance - LPrincipal;

                    InstallmentNo := GetDocumentNo(StartDate, false);
                    RepaymentSchedule.INIT;
                    RepaymentSchedule."Entry No" := EntryNo;
                    EntryNo += 1;
                    RepaymentSchedule."Document No." := InstallmentNo;
                    RepaymentSchedule."Expected Date" := StartDate;
                    RepaymentSchedule.Description := 'Monthly Installment';
                    RepaymentSchedule."Principal Repayment" := LPrincipal;
                    RepaymentSchedule."Interest Repayment" := LInterest;
                    RepaymentSchedule."Monthly Repayment" := LPrincipal + LInterest;
                    RepaymentSchedule."Running Balance" := LBalance;
                    RepaymentSchedule."Loan No." := Loans."No.";
                    RepaymentSchedule.INSERT;
                    Window.Update(1, InstallmentNo);
                    StartDate := CalcDate('1M', StartDate);
                    IF StartDate > EndDate THEN BEGIN
                        StartDate := EndDate;
                    end;
                until i > Loans.Installments;
            end;
            Window.Close;

            Loans."Moratorium Start Date" := LoanMoratorium[1]."Moratorium Start Date";
            Loans."Moratorium End Date" := LoanMoratorium[1]."Moratorium End Date";
            Loans."New Monthly Installment" := LoanMoratorium[1]."New Monthly Installment";
            Loans.Modify(true);

            LoanMoratorium[1].Posted := true;
            LoanMoratorium[1]."Posted On" := WorkDate;
            LoanMoratorium[1].Modify();
            OnAfterPostLoanRestructure(LoanMoratorium[1]);
        end;
    end;

    procedure PostLoanRestructure(DocumentNo: Code[20])
    var
        LoanRestructure: array[2] of Record "Loan Moratorium";
        VersionCount, i, EntryNo : Integer;
        RepaymentSchedule: Record "Loan Schedule";
        LoanProducts: Record "Sacco Products";
        StartDate, EndDate, ExpectedDate : Date;
        Window: Dialog;
        Loans: Record Loans;
        InstallmentNo: Code[20];
        PrincipalBalance, TotalMRepay, PrincipalAmnt, InterestBalance, LBalance, LPrincipal, LInterest, RefinancedDividend : Decimal;
    begin
        LoanRestructure[1].Get(DocumentNo);

        Loans.Get(LoanRestructure[1]."Loan No.");

        LoanRestructure[2].Reset();
        LoanRestructure[2].SetRange(Posted, true);
        LoanRestructure[2].SetRange("Loan No.", LoanRestructure[1]."Loan No.");
        if LoanRestructure[2].FindSet() then begin
            VersionCount := LoanRestructure[2].Count;
        end;

        RepaymentSchedule.Reset();
        RepaymentSchedule.SetRange("Loan No.", LoanRestructure[1]."Loan No.");
        if RepaymentSchedule.FindSet() then
            RepaymentSchedule.ModifyAll("Loan No.", LoanRestructure[1]."Loan No." + '_V' + Format(VersionCount + 1));

        RepaymentSchedule.Reset();
        RepaymentSchedule.SetRange("Loan No.", LoanRestructure[1]."Loan No.");
        if RepaymentSchedule.FindSet() then
            RepaymentSchedule.DeleteAll();

        RepaymentSchedule.Reset();
        if RepaymentSchedule.FindLast() then
            EntryNo := RepaymentSchedule."Entry No" + 1
        else
            EntryNo := 1;

        //Recreate Schedule
        Window.Open('Creating Schedule \#1## \#2##');
        LoanProducts.GET(LoanRestructure[1]."Product Code");
        EndDate := LoanRestructure[1]."Repayment End Date";
        StartDate := LoanRestructure[1]."Repayment Start Date";
        PrincipalBalance := LoanRestructure[1]."Current Principal Balance";
        PrincipalAmnt := 0;
        InterestBalance := 0;
        LBalance := PrincipalBalance;
        PrincipalAmnt := PrincipalBalance;
        Window.Update(2, EndDate);
        if LoanProducts."Rate Type" = LoanProducts."Rate Type"::Fixed then begin
            i += 1;
            LPrincipal := PrincipalAmnt / LoanRestructure[1]."Installments";
            IF LoanProducts."Rate Type" = LoanProducts."Rate Type"::"Per-Annum" THEN
                LInterest := (Loans."Interest Rate" / 12 / 100) * (PrincipalAmnt - RefinancedDividend)
            ELSE
                LInterest := (Loans."Interest Rate" / 100) * (PrincipalAmnt - RefinancedDividend);
            // LPrincipal := Round(LPrincipal, 1, '>');
            // LInterest := Round(LInterest, 1, '>');
            LBalance := LBalance - LPrincipal;
            ExpectedDate := StartDate;
            InstallmentNo := GetDocumentNo(StartDate, false);
            RepaymentSchedule.INIT;
            RepaymentSchedule."Entry No" := EntryNo;
            EntryNo += 1;
            RepaymentSchedule."Document No." := InstallmentNo;
            RepaymentSchedule."Expected Date" := StartDate;
            RepaymentSchedule.Description := 'Monthly Installment';
            RepaymentSchedule."Principal Repayment" := LPrincipal;
            RepaymentSchedule."Interest Repayment" := LInterest;
            RepaymentSchedule."Monthly Repayment" := LPrincipal + LInterest;
            RepaymentSchedule."Running Balance" := LBalance;
            RepaymentSchedule."Loan No." := Loans."No.";
            // RepaymentSchedule."Member No" := LoanApplication."Member No.";
            // RepaymentSchedule."Due Date" := CalcDate('1M', StartDate);
            RepaymentSchedule.INSERT;
            Window.Update(1, InstallmentNo);
        end
        else begin
            REPEAT
                i += 1;
                IF Loans."Interest Repayment Method" = Loans."Interest Repayment Method"::Amortised THEN BEGIN
                    LoanRestructure[1].TESTFIELD("Installments");
                    IF LoanProducts."Rate Type" = LoanProducts."Rate Type"::"Per-Annum" THEN
                        TotalMRepay := ROUND((Loans."Interest Rate" / 12 / 100) / (1 - POWER((1 + (Loans."Interest Rate" / 12 / 100)), -(LoanRestructure[1]."Installments"))) * (PrincipalAmnt), 0.0001, '>')
                    ELSE
                        TotalMRepay := ROUND((Loans."Interest Rate" / 100) / (1 - POWER((1 + (Loans."Interest Rate" / 100)), -(LoanRestructure[1]."Installments"))) * (PrincipalAmnt), 0.0001, '>');
                    LInterest := LBalance / 100 / 12 * Loans."Interest Rate";
                    LPrincipal := TotalMRepay - LInterest;
                end;
                IF Loans."Interest Repayment Method" = Loans."Interest Repayment Method"::"Straight Line" THEN BEGIN
                    LoanRestructure[1].TESTFIELD("Installments");
                    LPrincipal := PrincipalAmnt / LoanRestructure[1]."Installments";
                    IF LoanProducts."Rate Type" = LoanProducts."Rate Type"::"Per-Annum" THEN
                        LInterest := (Loans."Interest Rate" / 12 / 100) * PrincipalAmnt
                    ELSE
                        LInterest := (Loans."Interest Rate" / 100) * PrincipalAmnt;
                    LInterest := LInterest;
                end;
                IF Loans."Interest Repayment Method" = Loans."Interest Repayment Method"::"Reducing Balance" THEN BEGIN
                    LoanRestructure[1].TESTFIELD("Installments");
                    LPrincipal := PrincipalAmnt / LoanRestructure[1]."Installments";
                    IF LoanProducts."Rate Type" = LoanProducts."Rate Type"::"Per-Annum" THEN
                        LInterest := (Loans."Interest Rate" / 12 / 100) * LBalance
                    ELSE
                        LInterest := (Loans."Interest Rate" / 100) * LBalance;
                    LInterest := LInterest;
                end;

                // LPrincipal := Round(LPrincipal, 1, '>');
                // LInterest := Round(LInterest, 1, '>');
                LBalance := LBalance - LPrincipal;

                ExpectedDate := StartDate;

                InstallmentNo := GetDocumentNo(StartDate, false);
                RepaymentSchedule.INIT;
                RepaymentSchedule."Entry No" := EntryNo;
                EntryNo += 1;
                RepaymentSchedule."Document No." := InstallmentNo;
                RepaymentSchedule."Expected Date" := StartDate;
                RepaymentSchedule.Description := 'Monthly Installment';
                RepaymentSchedule."Principal Repayment" := LPrincipal;
                RepaymentSchedule."Interest Repayment" := LInterest;
                RepaymentSchedule."Monthly Repayment" := LPrincipal + LInterest;
                RepaymentSchedule."Running Balance" := LBalance;
                RepaymentSchedule."Loan No." := Loans."No.";
                RepaymentSchedule.INSERT;
                Window.Update(1, InstallmentNo);
                StartDate := CalcDate('1M', StartDate);
                IF StartDate > EndDate THEN BEGIN
                    StartDate := EndDate;
                end;
            UNTIL LBalance <= 0;
        end;
        Window.Close;
        Loans."Repayment End Date" := LoanRestructure[1]."Repayment End Date";
        Loans.Installments := LoanRestructure[1].Installments;
        Loans."New Monthly Installment" := LoanRestructure[1]."New Monthly Installment";
        Loans.Modify(true);
        LoanRestructure[1].Posted := true;
        LoanRestructure[1]."Posted On" := WorkDate;
        LoanRestructure[1].Modify();
        OnAfterPostLoanRestructure(LoanRestructure[1]);
    end;

    procedure InterestSuspending(LoanNo: Code[20])
    var
        Loans: Record Loans;
        UserSetup: Record "User Setup";
    begin
        UserSetup.Get(UserId);
        UserSetup.TestField("Can Suspend Interest");
        if Loans.Get(LoanNo) then begin
            if Loans."Interest Suspended" then begin
                if Confirm(StrSubstNo('You are about to Unsuspend %1\\Do you wish to continue?', Loans."No.")) then begin
                    Loans."Interest Suspended" := false;
                    Loans.Modify(true);
                end;
            end
            else begin
                if Confirm(StrSubstNo('You are about to Suspend %1\\Do you wish to continue?', Loans."No.")) then begin
                    Loans."Interest Suspended" := true;
                    Loans.Modify(true);
                end;
            end;
        end;
    end;

    procedure GenerateLoanRepaymentSchedule(var Loans: Record Loans)
    var
        Window: Dialog;
        RepaymentSchedule: Record "Loan Schedule";
        LoanProducts: Record "Sacco Products";
        EntryNo, i, j : Integer;
        InstallmentNo: Code[20];
        EndDate: Date;
        LInterest, LPrincipal, PrincipalBalance, RefinancedDividend, PrincipalAmnt, InterestBalance, LBalance, TotalMRepay : Decimal;
        StartDate: date;
        ExpectedDate: date;
        TempEDate: Date;
        AnniversaryDay: Integer;
        NextMonth: Integer;
        Year: Integer;
        ExistingLoan: Record Loans;
        LoanMoratorium: Record "Loan Moratorium";
        OutstandingBalance: Decimal;
        InterestPerPeriod: Decimal;
        TotalInterest: Decimal;
        PeriodInterestRate: Decimal;
    begin
        if ((Loans.Category <> Loans.Category::DEBT) and (Loans.Category <> Loans.Category::HR)) then begin
            i := 1;
            RepaymentSchedule.Reset();
            RepaymentSchedule.SetRange("Loan No.", Loans."No.");
            if RepaymentSchedule.FindSet() then
                RepaymentSchedule.DeleteAll();
            if LoanProducts.GET(Loans."Product Code") then begin
                Window.Open('Creating Schedule \#1## \#2##');
                Loans.CalcFields(Disbursements);
                Loans."Repayment Start Date" := GetRepaymentStartDate(Loans);
                Loans.TESTFIELD("Repayment Start Date");
                Loans.TESTFIELD(Installments);
                Loans."Repayment End Date" := CalcDate(Format(Loans.Installments) + 'M', Loans."Repayment Start Date");
                Loans.Modify();
                AnniversaryDay := Date2DMY(Loans."Repayment Start Date", 1);
                RepaymentSchedule.RESET;
                IF RepaymentSchedule.FINDLAST THEN
                    EntryNo := RepaymentSchedule."Entry No" + 1
                ELSE
                    EntryNo := 1;

                SaccoSetup.Get;

                if Loans."Mode of Disbursement" = Loans."Mode of Disbursement"::"FOSA (Partial)" then begin
                    If Loans."Posting Date" < SaccoSetup."Opening Balance Posting Date" then
                        PrincipalBalance := Loans."Openning Disbursed Balance"
                    else
                        PrincipalBalance := Loans.Disbursements;

                    if PrincipalBalance = 0 then begin
                        Loans.TestField("First Disbursement");
                        PrincipalBalance := Loans."First Disbursement";
                    end;

                end else
                    PrincipalBalance := Loans."Approved Amount";

                if PrincipalBalance = 0 then
                    PrincipalBalance := Loans."Openning Disbursed Balance";

                if PrincipalBalance = 0 then
                    PrincipalBalance := Loans."Approved Amount";

                if PrincipalBalance = 0 then
                    PrincipalBalance := Loans."Loan Amount";


                RefinancedDividend := 0;

                EndDate := CalcDate('CM', Loans."Repayment End Date");
                StartDate := CalcDate('CM', Loans."Repayment Start Date");

                PrincipalAmnt := 0;
                PrincipalAmnt := PrincipalBalance;
                InterestBalance := 0;
                LBalance := PrincipalBalance;
                PrincipalAmnt := PrincipalBalance;
                NextMonth := 0;
                Year := 0;
                OutstandingBalance := PrincipalAmnt;

                if (LoanProducts."Mobile Loan" and (not LoanProducts."Dividend Based")) then begin
                    for j := 1 to Loans.Installments do begin
                        IF LoanProducts."Rate Type" = LoanProducts."Rate Type"::"Per-Annum" THEN
                            InterestPerPeriod := (Loans."Interest Rate" / 12 / 100) * OutstandingBalance
                        ELSE
                            InterestPerPeriod := (Loans."Interest Rate" / 100) * OutstandingBalance;

                        TotalInterest += InterestPerPeriod;
                        OutstandingBalance -= PrincipalAmnt / Loans."Installments";
                    end;
                end;

                Window.Update(2, EndDate);
                if LoanProducts."Rate Type" = LoanProducts."Rate Type"::Fixed then begin
                    i += 1;
                    LPrincipal := PrincipalAmnt / Loans."Installments";
                    If Loans."Interest Rate" <> 0 then begin
                        IF LoanProducts."Rate Type" = LoanProducts."Rate Type"::"Per-Annum" THEN
                            LInterest := (Loans."Interest Rate" / 12 / 100) * (PrincipalAmnt - RefinancedDividend)
                        ELSE
                            LInterest := (Loans."Interest Rate" / 100) * (PrincipalAmnt - RefinancedDividend);
                    end;

                    LBalance := LBalance - LPrincipal;
                    ExpectedDate := StartDate;
                    InstallmentNo := GetDocumentNo(StartDate, false);
                    RepaymentSchedule.INIT;
                    RepaymentSchedule."Entry No" := EntryNo;
                    EntryNo += 1;
                    RepaymentSchedule."Document No." := InstallmentNo;
                    RepaymentSchedule."Expected Date" := StartDate;
                    RepaymentSchedule.Description := 'Monthly Installment';
                    RepaymentSchedule."Principal Repayment" := LPrincipal;
                    RepaymentSchedule."Interest Repayment" := LInterest;
                    RepaymentSchedule."Monthly Repayment" := LPrincipal + LInterest;
                    RepaymentSchedule."Running Balance" := LBalance;
                    RepaymentSchedule."Loan No." := Loans."No.";
                    RepaymentSchedule.INSERT;
                    Window.Update(1, InstallmentNo);
                end
                else begin
                    REPEAT
                        i += 1;
                        If Loans."Interest Rate" <> 0 then begin
                            IF Loans."Interest Repayment Method" = Loans."Interest Repayment Method"::Amortised THEN BEGIN
                                Loans.TESTFIELD("Installments");
                                IF LoanProducts."Rate Type" = LoanProducts."Rate Type"::"Per-Annum" THEN
                                    TotalMRepay := ROUND((Loans."Interest Rate" / 12 / 100) / (1 - POWER((1 + (Loans."Interest Rate" / 12 / 100)), -(Loans."Installments"))) * (PrincipalAmnt), 0.0001, '>')
                                ELSE
                                    TotalMRepay := ROUND((Loans."Interest Rate" / 100) / (1 - POWER((1 + (Loans."Interest Rate" / 100)), -(Loans."Installments"))) * (PrincipalAmnt), 0.0001, '>');

                                LInterest := LBalance / 100 / 12 * Loans."Interest Rate";
                                LPrincipal := TotalMRepay - LInterest;
                            end;
                            IF Loans."Interest Repayment Method" = Loans."Interest Repayment Method"::"Straight Line" THEN BEGIN
                                Loans.TESTFIELD("Installments");
                                LPrincipal := PrincipalAmnt / Loans."Installments";
                                IF LoanProducts."Rate Type" = LoanProducts."Rate Type"::"Per-Annum" THEN
                                    LInterest := (Loans."Interest Rate" / 12 / 100) * PrincipalAmnt
                                ELSE
                                    LInterest := (Loans."Interest Rate" / 100) * PrincipalAmnt;
                                LInterest := LInterest;
                            end;

                            IF Loans."Interest Repayment Method" = Loans."Interest Repayment Method"::"Reducing Balance" THEN BEGIN
                                Loans.TESTFIELD("Installments");
                                LPrincipal := PrincipalAmnt / Loans."Installments";
                                IF LoanProducts."Rate Type" = LoanProducts."Rate Type"::"Per-Annum" THEN
                                    LInterest := (Loans."Interest Rate" / 12 / 100) * LBalance
                                ELSE
                                    LInterest := (Loans."Interest Rate" / 100) * LBalance;
                                LInterest := LInterest;
                            end;

                            if (LoanProducts."Mobile Loan" and (not LoanProducts."Dividend Based")) then
                                LInterest := TotalInterest / Loans.Installments;
                        end
                        else begin
                            LPrincipal := PrincipalAmnt / Loans."Installments";
                            LInterest := 0;
                        end;


                        LBalance := LBalance - LPrincipal;
                        StartDate := CalcDate('CM', StartDate);
                        ExpectedDate := StartDate;
                        InstallmentNo := GetDocumentNo(StartDate, false);
                        RepaymentSchedule.INIT;
                        RepaymentSchedule."Entry No" := EntryNo;
                        EntryNo += 1;
                        RepaymentSchedule."Document No." := InstallmentNo;
                        RepaymentSchedule."Expected Date" := StartDate;
                        RepaymentSchedule.Description := 'Monthly Installment';
                        RepaymentSchedule."Principal Repayment" := LPrincipal;
                        RepaymentSchedule."Interest Repayment" := LInterest;
                        RepaymentSchedule."Monthly Repayment" := LPrincipal + LInterest;
                        RepaymentSchedule."Running Balance" := LBalance;
                        RepaymentSchedule."Loan No." := Loans."No.";
                        RepaymentSchedule.INSERT;
                        Window.Update(1, InstallmentNo);
                        StartDate := CalcDate('1M', StartDate);
                        IF StartDate > EndDate THEN BEGIN
                            StartDate := EndDate;
                        end;
                    UNTIL i > Loans.Installments;
                end;
                Window.Close;
            end;

            LoanMoratorium.Reset();
            LoanMoratorium.Setfilter(Type, '<>%1', LoanMoratorium.Type::Restructure);
            LoanMoratorium.Setrange("Loan No.", Loans."No.");
            LoanMoratorium.Setrange(Posted, true);
            LoanMoratorium.SetCurrentKey("No.");
            LoanMoratorium.SetAscending("No.", false);
            if LoanMoratorium.FindFirst then begin
                PostLoanMoratorium(LoanMoratorium."No.")
            end;

        end;
    end;

    procedure GeneratePartialLoanRepaymentSchedule(LoanDisbursement: Record "Loan Disbursement")
    var
        Window: Dialog;
        Loans: array[2] of Record Loans;
        RepaymentSchedule: Record "Loan Schedule";
        SaccoProducts: Record "Sacco Products";
        EntryNo, i, AnniversaryDay, NextMonth, Year, RemainingRepaymentsPeriods : Integer;
        InstallmentNo: Code[20];
        StartDate, EndDate, ExpectedDate, TempEDate, CalculatedDate, RepaymentStartDate : Date;
        LInterest, LPrincipal, PrincipalBalance, RefinancedDividend, PrincipalAmnt, InterestBalance, LBalance, TotalMRepay : Decimal;
        SameMonth: Boolean;
    begin
        i := 1;
        Loans[1].Get(LoanDisbursement."Loan No.");

        SaccoSetup.Get;
        SaccoSetup.TestField("Opening Balance Posting Date");
        SaccoProducts.Get(Loans[1]."Product Code");
        if SaccoProducts."Repayment Cutoff Date" = 0 then
            SameMonth := true
        else begin
            if Date2DMY(LoanDisbursement."Processed On", 1) > SaccoProducts."Repayment Cutoff Date" then
                SameMonth := false
            else
                SameMonth := true;
        end;

        CalculatedDate := DMY2Date(1, Date2DMY(LoanDisbursement."Processed On", 2), Date2DMY(LoanDisbursement."Processed On", 3));

        if SameMonth then begin
            if SaccoSetup."Loan Repayment Start" = SaccoSetup."Loan Repayment Start"::"Begining of the Month" then
                RepaymentStartDate := CalculatedDate
            else
                RepaymentStartDate := CalcDate('CM', CalculatedDate);
        end
        else begin
            if SaccoSetup."Loan Repayment Start" = SaccoSetup."Loan Repayment Start"::"Begining of the Month" then begin
                RepaymentStartDate := CalcDate('1M', CalculatedDate);
            end
            else begin
                RepaymentStartDate := CalcDate('CM+1M', CalculatedDate);
            end;
        end;

        RemainingRepaymentsPeriods := GetMonthsDifference(RepaymentStartDate, Loans[1]."Repayment End Date");
        RepaymentSchedule.Reset();
        RepaymentSchedule.SetRange("Loan No.", Loans[1]."No.");
        RepaymentSchedule.SetFilter("Expected Date", '>=%1', RepaymentStartDate);
        if RepaymentSchedule.FindSet() then
            RepaymentSchedule.DeleteAll();

        Window.Open('Creating Schedule \#1## \#2##');
        Loans[1].CalcFields(Disbursements, "Loan Balance");
        AnniversaryDay := Date2DMY(Loans[1]."Repayment Start Date", 1);
        RepaymentSchedule.RESET;
        IF RepaymentSchedule.FINDLAST THEN
            EntryNo := RepaymentSchedule."Entry No" + 1
        ELSE
            EntryNo := 1;

        Loans[2].Reset();
        Loans[2].SetRange("No.", Loans[1]."No.");
        Loans[2].SetFilter("Date Filter", '..%1', RepaymentStartDate);
        if Loans[2].FindFirst then begin
            Loans[2].CalcFields("Principal Repayment");
            if Loans[2]."Posting Date" < SaccoSetup."Opening Balance Posting Date" then
                PrincipalBalance := ((Loans[1]."Openning Disbursed Balance" + LoanDisbursement.Amount) - Loans[2]."Principal Repayment")
            else
                PrincipalBalance := ((Loans[1].Disbursements) - Loans[2]."Principal Repayment");
        end;

        RefinancedDividend := 0;
        EndDate := Loans[1]."Repayment End Date";
        StartDate := RepaymentStartDate;

        PrincipalAmnt := 0;
        PrincipalAmnt := PrincipalBalance;
        InterestBalance := 0;
        LBalance := PrincipalBalance;
        PrincipalAmnt := PrincipalBalance;
        NextMonth := 0;
        Year := 0;
        Window.Update(2, EndDate);
        if SaccoProducts."Rate Type" = SaccoProducts."Rate Type"::Fixed then begin
            i += 1;
            LPrincipal := PrincipalAmnt / RemainingRepaymentsPeriods;
            If Loans[1]."Interest Rate" <> 0 then begin
                IF SaccoProducts."Rate Type" = SaccoProducts."Rate Type"::"Per-Annum" THEN
                    LInterest := (Loans[1]."Interest Rate" / 12 / 100) * (PrincipalAmnt - RefinancedDividend)
                ELSE
                    LInterest := (Loans[1]."Interest Rate" / 100) * (PrincipalAmnt - RefinancedDividend);
            end;
            LBalance := LBalance - LPrincipal;
            ExpectedDate := StartDate;
            InstallmentNo := GetDocumentNo(StartDate, false);
            RepaymentSchedule.INIT;
            RepaymentSchedule."Entry No" := EntryNo;
            EntryNo += 1;
            RepaymentSchedule."Document No." := InstallmentNo;
            RepaymentSchedule."Expected Date" := StartDate;
            RepaymentSchedule.Description := 'Monthly Installment';
            RepaymentSchedule."Principal Repayment" := LPrincipal;
            RepaymentSchedule."Interest Repayment" := LInterest;
            RepaymentSchedule."Monthly Repayment" := LPrincipal + LInterest;
            RepaymentSchedule."Running Balance" := LBalance;
            RepaymentSchedule."Loan No." := Loans[1]."No.";
            RepaymentSchedule.INSERT;
            Window.Update(1, InstallmentNo);
        end
        else begin
            REPEAT
                i += 1;
                If Loans[1]."Interest Rate" <> 0 then begin
                    IF Loans[1]."Interest Repayment Method" = Loans[1]."Interest Repayment Method"::Amortised THEN BEGIN
                        Loans[1].TESTFIELD("Installments");
                        IF SaccoProducts."Rate Type" = SaccoProducts."Rate Type"::"Per-Annum" THEN
                            TotalMRepay := ROUND((Loans[1]."Interest Rate" / 12 / 100) / (1 - POWER((1 + (Loans[1]."Interest Rate" / 12 / 100)), -(RemainingRepaymentsPeriods))) * (PrincipalAmnt), 0.0001, '>')
                        ELSE
                            TotalMRepay := ROUND((Loans[1]."Interest Rate" / 100) / (1 - POWER((1 + (Loans[1]."Interest Rate" / 100)), -(RemainingRepaymentsPeriods))) * (PrincipalAmnt), 0.0001, '>');
                        LInterest := LBalance / 100 / 12 * Loans[1]."Interest Rate";
                        LPrincipal := TotalMRepay - LInterest;
                    end;
                    IF Loans[1]."Interest Repayment Method" = Loans[1]."Interest Repayment Method"::"Straight Line" THEN BEGIN
                        Loans[1].TESTFIELD("Installments");
                        LPrincipal := PrincipalAmnt / RemainingRepaymentsPeriods;
                        IF SaccoProducts."Rate Type" = SaccoProducts."Rate Type"::"Per-Annum" THEN
                            LInterest := (Loans[1]."Interest Rate" / 12 / 100) * PrincipalAmnt
                        ELSE
                            LInterest := (Loans[1]."Interest Rate" / 100) * PrincipalAmnt;
                        LInterest := LInterest;
                    end;
                    IF Loans[1]."Interest Repayment Method" = Loans[1]."Interest Repayment Method"::"Reducing Balance" THEN BEGIN
                        Loans[1].TESTFIELD("Installments");
                        LPrincipal := PrincipalAmnt / RemainingRepaymentsPeriods;
                        IF SaccoProducts."Rate Type" = SaccoProducts."Rate Type"::"Per-Annum" THEN
                            LInterest := (Loans[1]."Interest Rate" / 12 / 100) * LBalance
                        ELSE
                            LInterest := (Loans[1]."Interest Rate" / 100) * LBalance;
                        LInterest := LInterest;
                    end;
                end
                else begin
                    LPrincipal := PrincipalAmnt / RemainingRepaymentsPeriods;
                    LInterest := 0;
                end;

                LBalance := LBalance - LPrincipal;
                ExpectedDate := StartDate;
                InstallmentNo := GetDocumentNo(StartDate, false);

                RepaymentSchedule.INIT;
                RepaymentSchedule."Entry No" := EntryNo;
                EntryNo += 1;
                RepaymentSchedule."Document No." := InstallmentNo;
                RepaymentSchedule."Expected Date" := StartDate;
                RepaymentSchedule.Description := 'Monthly Installment';
                RepaymentSchedule."Principal Repayment" := LPrincipal;
                RepaymentSchedule."Interest Repayment" := LInterest;
                RepaymentSchedule."Monthly Repayment" := LPrincipal + LInterest;
                RepaymentSchedule."Running Balance" := LBalance;
                RepaymentSchedule."Loan No." := Loans[1]."No.";
                RepaymentSchedule.INSERT;
                Window.Update(1, InstallmentNo);
                StartDate := CalcDate('1M', StartDate);
                IF StartDate > EndDate THEN BEGIN
                    StartDate := EndDate;
                end;
            UNTIL i > RemainingRepaymentsPeriods;
        end;
        Window.Close;
    end;

    procedure GenerateOnlineLoanRepaymentSchedule(var LoanApplication: Record "Channel Loan Application")
    var
        Window: Dialog;
        RepaymentSchedule: Record "Loan Schedule";
        LoanProducts: Record "Sacco Products";
        EntryNo, i : Integer;
        InstallmentNo: Code[20];
        EndDate: Date;
        PrincipalBalance: Decimal;
        StartDate: date;
        PrincipalAmnt: Decimal;
        InterestBalance: Decimal;
        LBalance, RunningBalance : Decimal;
        TotalMRepay: Decimal;
        LPrincipal: Decimal;
        LInterest: Decimal;
        ExpectedDate: date;
        TempEDate: Date;
        AnniversaryDay: Integer;
        NextMonth: Integer;
        Year: Integer;
    begin
        if ((LoanApplication.Installments <> 0) and (LoanApplication."Application Date" <> 0D)) then begin
            i := 1;
            RepaymentSchedule.Reset();
            RepaymentSchedule.SetRange("Loan No.", LoanApplication."No.");
            if RepaymentSchedule.FindSet() then RepaymentSchedule.DeleteAll();
            Window.Open('Creating Schedule \#1## \#2##');

            LoanProducts.GET(LoanApplication."Product Code");
            LoanApplication."Repayment Start Date" := GetRepaymentChannelStartDate(LoanApplication);
            LoanApplication.TESTFIELD("Repayment Start Date");
            LoanApplication."Repayment End Date" := CalcDate(Format(LoanApplication.Installments) + 'M', LoanApplication."Repayment Start Date");
            LoanApplication.Modify();
            Commit;

            AnniversaryDay := Date2DMY(LoanApplication."Repayment Start Date", 1);
            RepaymentSchedule.RESET;
            IF RepaymentSchedule.FINDLAST THEN
                EntryNo := RepaymentSchedule."Entry No" + 1
            ELSE
                EntryNo := 1;
            PrincipalBalance := LoanApplication."Approved Amount";
            if PrincipalBalance = 0 then
                PrincipalBalance := LoanApplication."Applied Amount";

            EndDate := LoanApplication."Repayment End Date";
            StartDate := LoanApplication."Repayment Start Date";
            PrincipalAmnt := 0;
            PrincipalAmnt := PrincipalBalance;
            InterestBalance := 0;
            LBalance := PrincipalBalance;
            PrincipalAmnt := PrincipalBalance;
            RunningBalance := LBalance;
            NextMonth := 0;
            Year := 0;
            Window.Update(2, EndDate);
            REPEAT
                i += 1;
                IF LoanApplication."Interest Repayment Method" = LoanApplication."Interest Repayment Method"::Amortised THEN BEGIN
                    LoanApplication.TESTFIELD("Installments");
                    IF LoanProducts."Rate Type" = LoanProducts."Rate Type"::"Per-Annum" THEN
                        TotalMRepay := ROUND((LoanApplication."Interest Rate" / 12 / 100) / (1 - POWER((1 + (LoanApplication."Interest Rate" / 12 / 100)), -(LoanApplication."Installments"))) * (PrincipalAmnt), 0.0001, '>')
                    ELSE
                        TotalMRepay := ROUND((LoanApplication."Interest Rate" / 100) / (1 - POWER((1 + (LoanApplication."Interest Rate" / 100)), -(LoanApplication."Installments"))) * (PrincipalAmnt), 0.0001, '>');
                    LInterest := LBalance / 100 / 12 * LoanApplication."Interest Rate";
                    LPrincipal := TotalMRepay - LInterest;
                end;
                IF LoanApplication."Interest Repayment Method" = LoanApplication."Interest Repayment Method"::"Straight Line" THEN BEGIN
                    LoanApplication.TESTFIELD("Installments");
                    LPrincipal := PrincipalAmnt / LoanApplication."Installments";
                    IF LoanProducts."Rate Type" = LoanProducts."Rate Type"::"Per-Annum" THEN
                        LInterest := (LoanApplication."Interest Rate" / 12 / 100) * PrincipalAmnt
                    ELSE
                        LInterest := (LoanApplication."Interest Rate" / 100) * PrincipalAmnt;
                    LInterest := LInterest;
                end;
                IF LoanApplication."Interest Repayment Method" = LoanApplication."Interest Repayment Method"::"Reducing Balance" THEN BEGIN
                    LoanApplication.TESTFIELD("Installments");
                    LPrincipal := PrincipalAmnt / LoanApplication."Installments";
                    IF LoanProducts."Rate Type" = LoanProducts."Rate Type"::"Per-Annum" THEN
                        LInterest := (LoanApplication."Interest Rate" / 12 / 100) * LBalance
                    ELSE
                        LInterest := (LoanApplication."Interest Rate" / 100) * LBalance;
                    LInterest := LInterest;
                end;
                RunningBalance -= LPrincipal;
                ExpectedDate := StartDate;
                InstallmentNo := GetDocumentNo(StartDate, false);
                RepaymentSchedule.INIT;
                RepaymentSchedule."Entry No" := EntryNo;
                EntryNo += 1;
                RepaymentSchedule."Document No." := InstallmentNo;
                RepaymentSchedule."Expected Date" := StartDate;
                RepaymentSchedule.Description := 'Monthly Installment';
                RepaymentSchedule."Principal Repayment" := LPrincipal;
                RepaymentSchedule."Interest Repayment" := LInterest;
                RepaymentSchedule."Monthly Repayment" := LPrincipal + LInterest;
                RepaymentSchedule."Running Balance" := RunningBalance;
                RepaymentSchedule."Loan No." := LoanApplication."No.";
                RepaymentSchedule.INSERT;
                LBalance := LBalance - LPrincipal;
                Window.Update(1, InstallmentNo);
                StartDate := CalcDate('1M', StartDate);
                IF StartDate > EndDate THEN BEGIN
                    StartDate := EndDate;
                end;
            UNTIL i > LoanApplication.Installments;
            Window.Close;
        end;
    end;

    procedure GetDocumentNo(ParseDate: Date; DailyAccrual: Boolean) DocumentNo: Code[20]
    begin
        if DailyAccrual then
            DocumentNo := Format(ParseDate, 0, '<Day,2>-<Month Text,3>-<Year4>')
        else
            DocumentNo := Format(ParseDate, 0, '<Month Text,3>-<Year4>');
        exit(DocumentNo);
    end;

    procedure CreateLoanAccounts(var Loans: Record Loans) AccountNo: Code[20]
    var
        Vendor: Record Vendor;
        LoanProduct: Record "Sacco Products";
        AccType: Record "Sacco Products";
    begin
        LoanProduct.Get(Loans."Product Code");
        LoanProduct.TestField("Posting Group");
        AccountNo := LoanProduct.Prefix + Loans."Member No." + LoanProduct.Suffix;
        if not Vendor.Get(AccountNo) then begin
            Vendor.Init();
            Vendor."No." := AccountNo;
            Vendor.Name := UpperCase(LoanProduct.Description);
            Vendor."Vendor Posting Group" := LoanProduct."Posting Group";
            Vendor."Member No." := Loans."Member No.";
            Vendor."Member Name" := UpperCase(Loans."Member Name");
            Vendor."Account Type" := Vendor."Account Type"::Loan;
            Vendor."Product Code" := LoanProduct.Code;
            Vendor.Status := Vendor.Status::Active;
            Vendor."Product Posting Type" := Vendor."Product Posting Type"::"Loan Account";
            Vendor.Insert();
        end;
        exit(AccountNo);
    end;


    local procedure CreateUnclearedEffec(LoanNo: Code[20])
    var
        UnclearedEffect: Record "Uncleared Funds";
        EntryNo: Integer;
        Loans: Record Loans;
        DetailedVendorLedger: Record "Detailed Vendor Ledg. Entry";
        NetAmount: Decimal;
    begin
        if Loans.Get(LoanNo) then begin
            if Loans."Pay to Account No" <> '' then begin
                DetailedVendorLedger.Reset();
                DetailedVendorLedger.SetRange("Vendor No.", Loans."Disbursement Account");
                DetailedVendorLedger.SetRange("Document No.", LoanNo);
                if DetailedVendorLedger.FindSet() then begin
                    DetailedVendorLedger.CalcSums(Amount);
                    NetAmount := DetailedVendorLedger.Amount;
                end;
                EntryNo := 1;
                UnclearedEffect.reset;
                if UnclearedEffect.FindLast() then EntryNo := UnclearedEffect."Entry No" + 1;
                UnclearedEffect.Init();
                UnclearedEffect."Entry No" := EntryNo;
                UnclearedEffect."Document No" := LoanNo;
                UnclearedEffect.Amount := -1 * NetAmount;
                UnclearedEffect.Validate("Member No", Loans."Member No.");
                UnclearedEffect."Account No" := Loans."Disbursement Account";
                UnclearedEffect.Insert();
            end
        end;
    end;

    procedure PostBatch(var BatchNo: Code[20])
    var
        LoanBatchLines: Record "Loan Batch Lines";
        Window: Dialog;
        Loans: Record Loans;
        LoanBatch: Record "Loan Batch Header";
    begin
        LoanBatchLines.Reset();
        LoanBatchLines.SetRange("No.", BatchNo);
        LoanBatchLines.SetRange(Posted, false);
        if LoanBatchLines.FindSet() then begin
            Window.Open('Posting \#1##');
            repeat
                Window.Update(1, LoanBatchLines."Loan No");
                if Loans.Get(LoanBatchLines."Loan No") then begin
                    DisburseLoan(Loans);
                    LoanBatchLines.Posted := true;
                    LoanBatchLines.Modify();
                    Commit();
                end;
            until LoanBatchLines.Next() = 0;
            Window.Close;
        end;
        if LoanBatch.Get(BatchNo) then begin
            LoanBatch.Posted := true;
            LoanBatch."Posted By" := UserId;
            LoanBatch."Posted On" := CurrentDateTime;
            LoanBatch.Modify(true);
        end;
    end;

    procedure PostLoansOpeningBalances()
    var
        Loans: Record Loans;
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        LineNo: Integer;
        PostingDate: date;
        LoanCharges: Record "Product Charge Setup";
        PostingAmount, RemainingAmount : Decimal;
        GLEntry: Record "G/L Entry";
        SrcCode, RsnCode, JournalBatch, JournalTemplate, AccountNo, ReasonCode, SourceCode, MemberNo, DocumentNo, ExternalDocumentNo : Code[20];
        LoanRecoveries: Record "Loan Recoveries";
        JournalManagement: Codeunit "Journal Management";
        PostingDescription: Text[100];
        ExternalRecSetup: Record "External Recoveries Setup";
        LoanApp: Record Loans;
        LoanProduct: Record "Sacco Products";
        BaseAmount, PrincipalBalance, InterestBalance, PenaltyBalance, PenaltyPaid, InterestPaid, PrincipalPaid : Decimal;
        GeneralLedgerSetup: Record "General Ledger Setup";
        Window: Dialog;
        All, Current : Decimal;
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.TestField("Opening Balance Acc.");
        GeneralLedgerSetup.TestField("Opening Balance Posting Date");
        Window.Open('Posting Loans Opening Balances. \#1##\#2##\#3##\#4##');
        Loans.Reset();
        Loans.SetRange(Status, Loans.Status::Approved);
        Loans.SetRange(Posted, false);
        Loans.SetFilter("Openning Balance", '>%1', 0);
        if Loans.FindSet then begin
            All := 0;
            Current := 0;
            All := Loans.Count;
            repeat
                Current += 1;
                Window.Update(1, StrSubstNo('Loan No. %1', Loans."No."));
                Window.Update(2, StrSubstNo('Name: %1', Loans."Member Name"));
                Window.UPDATE(3, StrSubstNo('%1%', Round((Current / All) * 100, 1)));
                Window.UPDATE(4, FORMAT(Current) + ' of ' + FORMAT(All));
                DocumentNo := Loans."No.";
                PostingDate := GeneralLedgerSetup."Opening Balance Posting Date";
                GLEntry.Reset();
                GLEntry.SetRange("Document No.", DocumentNo);
                GLEntry.SetRange("Posting Date", PostingDate);
                if GLEntry.FindFirst() then begin
                    Loans."Posting Date" := Loans."Application Date";
                    Loans."Application Status" := Loans."Application Status"::Disbursed;
                    Loans.Posted := True;
                    Loans."Loan Account" := CreateLoanAccounts(Loans);
                    Loans."Appraisal Commited" := true;
                    Loans.Modify(true);
                end
                else begin
                    JournalBatch := 'OPENBAL';
                    JournalTemplate := 'GENERAL';
                    LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
                    ReasonCode := Loans."No.";
                    SourceCode := Loans."Product Code";
                    MemberNo := Loans."Member No.";
                    Loans."Loan Account" := CreateLoanAccounts(Loans);
                    RemainingAmount := 0;
                    RemainingAmount := Loans."Openning Balance";
                    AccountNo := '';
                    ExternalDocumentNo := Loans."Cheque No.";
                    AccountNo := Loans."Loan Account";
                    PostingDescription := 'Loan Opening Balance';
                    PostingAmount := 0;
                    PostingAmount := Loans."Openning Balance";
                    AccountNo := Loans."Loan Account";
                    //Debit Loan
                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Loan Disbursal", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                    AccountNo := '';
                    AccountNo := GeneralLedgerSetup."Opening Balance Acc.";
                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Loan Disbursal", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                    Commit;
                    JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
                    GLEntry.Reset();
                    GLEntry.SetRange("Document No.", DocumentNo);
                    GLEntry.SetRange("Document Date", PostingDate);
                    if GLEntry.FindFirst() then begin
                        Loans."Application Status" := Loans."Application Status"::Disbursed;
                        Loans.Posted := True;
                        Loans."Posted By" := UserId;
                        Loans."Posted On" := CurrentDateTime;
                        Loans.Modify();
                        GenerateLoanRepaymentSchedule(Loans);
                    end;
                end;
            until Loans.Next = 0;
        end;
    end;

    procedure PostUploadedLoans()
    var
        Loans: Record Loans;
        Window: Dialog;
        All, Current : Integer;
    begin
        Loans.Reset();
        Loans.SetFilter(Category, '%1|%2', Loans.Category::DEBT, Loans.Category::HR);
        Loans.SetFilter("Approved Amount", '>0');
        Loans.SetFilter("Disbursement Account", '<>%1', '');
        Loans.SetRange(Status, Loans.Status::Approved);
        Loans.SetRange(Posted, false);
        if Loans.FindSet() then begin
            All := Loans.Count;
            Current := 0;
            if Confirm(StrSubstNo('You are about to Post %1 Uploaded Loans\\Do you wish to continue?', All)) then begin
                Window.Open('Checking \#1### \#2##');
                repeat
                    Window.Update(1, Loans."No.");
                    Window.Update(2, Format(Current) + ' of ' + Format(All));
                    Current += 1;
                    DisburseLoan(Loans);
                until Loans.Next() = 0;
                Window.Close;
            end;
        end;
    end;

    procedure PostLoansInterstDueOpeningBalances()
    var
        Loans: Record Loans;
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        LineNo: Integer;
        PostingDate: date;
        LoanCharges: Record "Product Charge Setup";
        PostingAmount, RemainingAmount : Decimal;
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        SrcCode, RsnCode, JournalBatch, JournalTemplate, AccountNo, ReasonCode, SourceCode, MemberNo, DocumentNo, ExternalDocumentNo : Code[20];
        JournalManagement: Codeunit "Journal Management";
        PostingDescription: Text[100];
        ExternalRecSetup: Record "External Recoveries Setup";
        LoanApp: Record Loans;
        LoanProduct: Record "Sacco Products";
        SaccoSetup: Record "General Ledger Setup";
        Window: Dialog;
        All, Current : Decimal;
        VendPostingGroup: Record "Vendor Posting Group";
    begin
        SaccoSetup.Get();
        SaccoSetup.TestField("Opening Balance Acc.");
        SaccoSetup.TestField("Opening Balance Posting Date");
        Window.Open('Posting Loans Interest Due Opening Balances. \#1##\#2##\#3##\#4##');
        Loans.Reset();
        Loans.SetRange(Status, Loans.Status::Approved);
        Loans.SetRange(Posted, true);
        Loans.SetFilter("Openning Interest Due Balance", '<>%1', 0);
        if Loans.FindSet then begin
            All := 0;
            Current := 0;
            All := Loans.Count;
            repeat
                Current += 1;
                Window.Update(1, StrSubstNo('Loan No. %1', Loans."No."));
                Window.Update(2, StrSubstNo('Name: %1', Loans."Member Name"));
                Window.UPDATE(3, StrSubstNo('%1%', Round((Current / All) * 100, 1)));
                Window.UPDATE(4, FORMAT(Current) + ' of ' + FORMAT(All));
                JournalBatch := 'OPENBAL';
                JournalTemplate := 'GENERAL';
                LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
                DocumentNo := Loans."No.";
                PostingDate := SaccoSetup."Opening Balance Posting Date";
                DetailedVendorLedgEntry.Reset();
                DetailedVendorLedgEntry.SetRange("Document No.", DocumentNo);
                DetailedVendorLedgEntry.SetRange("Posting Date", PostingDate);
                DetailedVendorLedgEntry.SetRange("Sacco Transaction Type", DetailedVendorLedgEntry."Sacco Transaction Type"::"Interest Due");
                if not DetailedVendorLedgEntry.FindFirst() then begin
                    ReasonCode := Loans."No.";
                    SourceCode := Loans."Product Code";
                    MemberNo := Loans."Member No.";
                    Loans."Loan Account" := CreateLoanAccounts(Loans);
                    RemainingAmount := 0;
                    RemainingAmount := Loans."Openning Balance";
                    AccountNo := '';
                    ExternalDocumentNo := Loans."Cheque No.";
                    AccountNo := Loans."Loan Account";
                    PostingDate := SaccoSetup."Opening Balance Posting Date";
                    PostingDescription := 'Loan Interst Due Opening Balance';
                    PostingAmount := 0;
                    PostingAmount := Loans."Openning Interest Due Balance";
                    AccountNo := Loans."Loan Account";
                    LoanProduct.Get(Loans."Product Code");
                    LoanProduct.TestField("Interest Paid Account");
                    if VendPostingGroup.Get(LoanProduct."Posting Group") then VendPostingGroup.TestField("Interest Accrual Account");
                    //Debit Loan
                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Due", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                    AccountNo := '';
                    AccountNo := LoanProduct."Interest Paid Account";
                    //AccountNo := GeneralSetup."Opening Balance Acc.";
                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Due", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                    Commit;
                    JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
                end;
            until Loans.Next = 0;
        end;
    end;

    procedure DisburseLoan(var Loans: Record Loans)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        LineNo: Integer;
        PostingDate: date;
        LoanCharges: Record "Product Charge Setup";
        PostingAmount, RemainingAmount : Decimal;
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        SrcCode, RsnCode, JournalBatch, JournalTemplate, AccountNo, ReasonCode, SourceCode, MemberNo, DocumentNo, ExternalDocumentNo : Code[20];
        LoanRecoveries: Record "Loan Recoveries";
        JournalManagement: Codeunit "Journal Management";
        PostingDescription: Text[100];
        ExternalRecSetup: Record "External Recoveries Setup";
        LoanApp: Record Loans;
        LoanProduct: Record "Sacco Products";
        BaseAmount, PrincipalBalance, InterestBalance, PenaltyBalance, PenaltyPaid, InterestPaid, PrincipalPaid : Decimal;
        SaccoSetup: Record "General Ledger Setup";
        LoanGuarantee: Record "Loan Guarantees";
        Guarantors: Integer;
        ProcessingFee, IntRate : Decimal;
        TPInt: Codeunit "Channels Integrations";
        Loan_Charges: array[2] of Record "Loan Charges";
        LoansManagement: Codeunit "Loans Management";
        LoansPayableAdvice: Record "Loans Payable Advice";
    begin
        SaccoSetup.Get;
        MemberNo := '';
        DocumentNo := Loans."No.";
        ProcessingFee := 0;
        IntRate := TPInt.GetInterestRate(Loans."Product Code", Loans.Installments, ProcessingFee);
        DetailedVendorLedgEntry.Reset();
        DetailedVendorLedgEntry.SetRange("Document No.", DocumentNo);
        DetailedVendorLedgEntry.SetRange("Member No.", Loans."Member No.");
        DetailedVendorLedgEntry.SetRange("Loan No.", Loans."No.");
        DetailedVendorLedgEntry.SetRange("Sacco Transaction Type", DetailedVendorLedgEntry."Sacco Transaction Type"::"Loan Disbursal");
        if DetailedVendorLedgEntry.FindFirst() then begin
            Loans."Posting Date" := WorkDate;
            Loans."Loan Account" := CreateLoanAccounts(Loans);
            Loans."Application Status" := Loans."Application Status"::Disbursed;
            Loans.Posted := True;
            Loans."Appraisal Commited" := true;
            Loans.Modify(true);
        end
        else begin
            OnBeforePostLoan(Loans."No.");
            if Loans."Mobile Loan" then
                JournalBatch := 'MLOAN'
            else
                JournalBatch := 'LOAN';

            JournalTemplate := 'GENERAL';
            LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
            ReasonCode := Loans."No.";
            SourceCode := Loans."Product Code";
            MemberNo := Loans."Member No.";
            Loans."Loan Account" := CreateLoanAccounts(Loans);
            RemainingAmount := 0;
            RemainingAmount := Loans."Approved Amount";
            ExternalDocumentNo := Loans."Cheque No.";
            AccountNo := Loans."Loan Account";
            PostingDate := WorkDate;
            PostingDescription := StrSubstNo('Loan Disbursal : %1', Loans."Product Description");
            PostingAmount := 0;
            If Loans."Mode of Disbursement" = Loans."Mode of Disbursement"::"FOSA (Partial)" then
                PostingAmount := Loans."First Disbursement"
            else
                PostingAmount := Loans."Approved Amount";

            If Loans."Mode of Disbursement" <> Loans."Mode of Disbursement"::Payables then begin
                AccountNo := '';
                AccountNo := Loans."Loan Account";
                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Loan Disbursal", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                AccountNo := '';
                AccountNo := Loans."Disbursement Account";

                if Loans."Mode of Disbursement" = Loans."Mode of Disbursement"::BOSA then
                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Loan Disbursal", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch)
                else
                    if Loans."Mode of Disbursement" = Loans."Mode of Disbursement"::"Receivable Account" then
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Customer, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Loan Disbursal", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch)
                    else
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Loan Disbursal", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
            end;

            If Loans."Mode of Disbursement" = Loans."Mode of Disbursement"::Payables then begin
                AccountNo := '';
                AccountNo := Loans."Loan Account";
                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Loan Disbursal", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                AccountNo := '';
                AccountNo := GetFOSAAccount(Loans."Member No.");
                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Loan Disbursal", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                LoansPayableAdvice.Reset();
                LoansPayableAdvice.SetRange("Loan No", Loans."No.");
                LoansPayableAdvice.SetFilter(Amount, '>0');
                if LoansPayableAdvice.FindSet then begin
                    repeat
                        PostingAmount := LoansPayableAdvice.Amount;
                        AccountNo := '';
                        AccountNo := GetFOSAAccount(Loans."Member No.");
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::General, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                        AccountNo := '';
                        AccountNo := LoansPayableAdvice."Vendor No.";
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::General, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                    until LoansPayableAdvice.Next = 0;
                end;
            end;


            LoanProduct.Get(Loans."Product Code");
            LoanRecoveries.Reset();
            LoanRecoveries.SetRange("Loan No", DocumentNo);
            if LoanRecoveries.FindSet() then begin
                repeat
                    case LoanRecoveries."Recovery Type" of
                        LoanRecoveries."Recovery Type"::Account:
                            begin
                                PostingDescription := LoanRecoveries."Recovery Description";
                                AccountNo := '';
                                AccountNo := LoanRecoveries."Recovery Code";
                                PostingAmount := 0;
                                PostingAmount := LoanRecoveries.Amount;
                                RemainingAmount -= PostingAmount;
                                PostingDescription := 'Recovery for ' + AccountNo;
                                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Disb. Rec", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                PostingAmount := 0;
                                PostingAmount := LoanRecoveries."Commission Amount";
                                RemainingAmount -= PostingAmount;
                                AccountNo := '';
                                AccountNo := LoanRecoveries."Commission Account";
                                PostingDescription := '';
                                PostingDescription := 'Commision On Recovery ' + LoanRecoveries."Recovery Code";
                                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Disb. Rec", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                PostingAmount := 0;
                                PostingAmount := LoanRecoveries."Commission Amount";
                                AccountNo := '';
                                AccountNo := Loans."Disbursement Account";
                                PostingDescription := '';
                                PostingDescription := 'Commision On ' + LoanRecoveries."Recovery Description";
                                if Loans."Mode of Disbursement" = Loans."Mode of Disbursement"::BOSA then
                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Disb. Rec", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch) else
                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Disb. Rec", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                PostingAmount := 0;
                                PostingAmount := LoanRecoveries.Amount;
                                PostingDescription := 'Recovery for ' + AccountNo;
                                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Disb. Rec", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                            end;
                        LoanRecoveries."Recovery Type"::External:
                            begin
                                PostingDescription := LoanRecoveries."Recovery Description";
                                AccountNo := '';
                                ExternalRecSetup.Get(LoanRecoveries."Recovery Code");
                                AccountNo := ExternalRecSetup."Post To Account No";
                                PostingAmount := 0;
                                PostingAmount := LoanRecoveries.Amount;
                                RemainingAmount -= PostingAmount;
                                PostingDescription := LoanRecoveries."Recovery Description";
                                IF ExternalRecSetup."Post To Account Type" = ExternalRecSetup."Post To Account Type"::"Payable Account" then begin
                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Disb. Rec", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                end
                                else begin
                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Disb. Rec", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                end;
                                PostingAmount := 0;
                                PostingAmount := LoanRecoveries."Commission Amount";
                                RemainingAmount -= PostingAmount;
                                AccountNo := '';
                                AccountNo := LoanRecoveries."Commission Account";
                                PostingDescription := '';
                                PostingDescription := 'Commision On ' + LoanRecoveries."Recovery Description";
                                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Disb. Rec", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                PostingAmount := 0;
                                PostingAmount := LoanRecoveries."Commission Amount";
                                AccountNo := '';
                                AccountNo := Loans."Disbursement Account";
                                PostingDescription := '';
                                PostingDescription := 'Commision On ' + LoanRecoveries."Recovery Description";
                                if Loans."Mode of Disbursement" = Loans."Mode of Disbursement"::BOSA then
                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Disb. Rec", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch)
                                else
                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Disb. Rec", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                PostingDescription := LoanRecoveries."Recovery Description";
                                PostingAmount := 0;
                                PostingAmount := LoanRecoveries.Amount;
                                if Loans."Mode of Disbursement" = Loans."Mode of Disbursement"::BOSA then
                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Disb. Rec", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch) else
                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Disb. Rec", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch)
                            end;
                        LoanRecoveries."Recovery Type"::Loan:
                            begin

                                BaseAmount := 0;
                                PenaltyBalance := 0;
                                PenaltyPaid := 0;
                                InterestBalance := 0;
                                InterestPaid := 0;
                                PrincipalBalance := 0;
                                PrincipalPaid := 0;

                                BaseAmount := LoanRecoveries.Amount;
                                SrcCode := '';
                                RsnCode := '';
                                if LoanApp.Get(LoanRecoveries."Recovery Code") then begin

                                    if SaccoSetup."Daily Interest Accrual" then
                                        PostLoanInterest(Loans."Application Date", '', 0, Loans."Member No.", Loans."No.");
                                    LoanApp.CalcFields("Principal Balance", "Penalty Balance", "Interest Balance");
                                    LoanProduct.Get(LoanApp."Product Code");

                                    PenaltyBalance := LoanApp."Penalty Balance";
                                    InterestBalance := LoanApp."Interest Balance";
                                    Principalbalance := LoanApp."Principal Balance";

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

                                    SrcCode := LoanApp."Product Code";
                                    RsnCode := LoanApp."No.";
                                    PostingDescription := LoanRecoveries."Recovery Description";

                                    //Penalty Paid
                                    AccountNo := '';
                                    AccountNo := LoanApp."Loan Account";
                                    PostingAmount := 0;
                                    PostingAmount := PenaltyPaid;
                                    PostingDescription := 'Penalty Paid';
                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Penalty Paid", LineNo, SrcCode, RsnCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);

                                    //Prorated Interest
                                    PostingAmount := 0;
                                    PostingAmount := LoanRecoveries."Prorated Interest";
                                    PostingDescription := 'Prorated Interest';
                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SrcCode, RsnCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);

                                    //Prorated Interest
                                    PostingAmount := 0;
                                    PostingAmount := InterestPaid;
                                    PostingDescription := 'Interest Paid';
                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SrcCode, RsnCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                    SaccoSetup.Get();
                                    if SaccoSetup."Interest Accrual Type" = SaccoSetup."Interest Accrual Type"::"Cash Basis" then begin
                                        AccountNo := LoanProduct."Penalty Paid Account";
                                        PostingAmount := 0;
                                        PostingAmount := PenaltyPaid;
                                        PostingDescription := 'Penalty Paid';
                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Penalty Paid", LineNo, SrcCode, RsnCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                        AccountNo := '';
                                        AccountNo := LoanProduct."Penalty Due Account";
                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Penalty Paid", LineNo, SrcCode, RsnCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                        PostingAmount := 0;
                                        PostingAmount := InterestPaid;
                                        PostingDescription := 'Interest Paid';
                                        AccountNo := '';
                                        AccountNo := LoanProduct."Interest Paid Account";
                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SrcCode, RsnCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                        AccountNo := '';
                                        AccountNo := LoanProduct."Interest Due Account";
                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SrcCode, RsnCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                        //Prorated Interest
                                        PostingAmount := 0;
                                        PostingAmount := LoanRecoveries."Prorated Interest";
                                        PostingDescription := 'Prorated Interest';
                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SrcCode, RsnCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                    end
                                    else begin
                                        //Prorated Interest
                                        PostingDescription := 'Prorated Interest';
                                        PostingAmount := 0;
                                        PostingAmount := LoanRecoveries."Prorated Interest";
                                        AccountNo := '';
                                        AccountNo := LoanProduct."Interest Paid Account";
                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SrcCode, RsnCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                    end;

                                    //Principal Paid
                                    PostingAmount := 0;
                                    PostingAmount := PrincipalPaid;
                                    AccountNo := '';
                                    AccountNo := LoanApp."Loan Account";
                                    PostingDescription := 'Principal Paid';
                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Principal Paid", LineNo, SrcCode, RsnCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);


                                    PostingAmount := 0;
                                    PostingAmount := LoanRecoveries."Commission Amount";
                                    RemainingAmount -= (PostingAmount + PrincipalPaid + PenaltyPaid + InterestPaid);
                                    AccountNo := '';
                                    AccountNo := LoanRecoveries."Commission Account";
                                    PostingDescription := '';
                                    PostingDescription := 'Commision On ' + LoanRecoveries."Recovery Description";
                                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Disb. Rec", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                    PostingAmount := 0;
                                    PostingAmount := LoanRecoveries."Commission Amount";
                                    AccountNo := '';
                                    AccountNo := Loans."Disbursement Account";
                                    PostingDescription := '';
                                    PostingDescription := LoanRecoveries."Recovery Description";
                                    if Loans."Mode of Disbursement" = Loans."Mode of Disbursement"::BOSA then
                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Disb. Rec", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch)
                                    else
                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Disb. Rec", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                    PostingAmount := 0;
                                    PostingAmount := LoanRecoveries.Amount;
                                    if Loans."Mode of Disbursement" = Loans."Mode of Disbursement"::BOSA then
                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Disb. Rec", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch)
                                    else
                                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Disb. Rec", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                                    LoanApp.Restructured := true;
                                    LoanApp.Modify(true);
                                end;
                            end;
                    end;
                until LoanRecoveries.Next() = 0;
            end;
            if Loans."Insurance Amount" > 0 then begin
                LoanProduct.Get(Loans."Product Code");
                PostingDescription := 'RMF Premium';
                PostingAmount := Loans."Insurance Amount";
                AccountNo := Loans."Disbursement Account";
                if Loans."Mode of Disbursement" = Loans."Mode of Disbursement"::BOSA then
                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Disb. Rec", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch)
                else
                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Disb. Rec", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                AccountNo := '';
                AccountNo := LoanProduct."Insurance Account";
                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * ((100 - LoanProduct."Insurance Income %") * PostingAmount * 0.01), Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Disb. Rec", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                AccountNo := '';
                AccountNo := LoanProduct."Insurance Income Account";
                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * ((LoanProduct."Insurance Income %") * PostingAmount * 0.01), Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Disb. Rec", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
            end;

            Loan_Charges[1].Reset();
            Loan_Charges[1].SetRange("No.", Loans."No.");
            Loan_Charges[1].SetFilter(Amount, '<>%1', 0);
            if Loan_Charges[1].FindSet then begin
                Loan_Charges[1].CalcSums(Amount);
                PostingDescription := 'Charges';
                PostingAmount := Loan_Charges[1].Amount;
                AccountNo := Loans."Disbursement Account";
                if Loans."Mode of Disbursement" = Loans."Mode of Disbursement"::BOSA then
                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Disb. Rec", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch)
                else
                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Disb. Rec", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
            end;
            Loan_Charges[2].Reset();
            Loan_Charges[2].SetRange("No.", Loans."No.");
            Loan_Charges[2].SetFilter(Amount, '<>%1', 0);
            if Loan_Charges[2].FindSet then begin
                repeat
                    PostingDescription := Loan_Charges[2]."Charge Description";
                    PostingAmount := Loan_Charges[2].Amount;
                    AccountNo := '';
                    AccountNo := Loan_Charges[2]."Post-to Account No.";
                    if Loan_Charges[2]."Post to Account Type" = Loan_Charges[2]."Post to Account Type"::"G/L Account" then
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, '', DocumentNo, GlobalTransactionType::"Disb. Rec", LineNo, '', '', ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch)
                    else
                        If Loan_Charges[2]."Post to Account Type" = Loan_Charges[2]."Post to Account Type"::"Liability Account" then LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, '', DocumentNo, GlobalTransactionType::"Disb. Rec", LineNo, '', '', ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                until Loan_Charges[2].Next = 0;
            end;
            // if ((LoanApplication."Prorated Days" > 0) and (LoanProduct."Salary Based" = false)) then begin
            //     LoanProduct.TestField("Interest Paid Account");
            //     PostingDescription := 'Interest Recovered';
            //     PostingAmount := LoanApplication."Approved Amount" * LoanApplication."Interest Rate" * 0.01;
            //     PostingAmount := PostingAmount * (LoanApplication."Prorated Days" / 365);
            //     AccountNo := LoanApplication."Disbursement Account";
            //     LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Disb. Rec", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '',JournalTemplate, JournalBatch);
            //     AccountNo := LoanProduct."Interest Paid Account";
            //     LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Disb. Rec", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '',JournalTemplate, JournalBatch);
            // end;
            // if (LoanProduct."Charge UpFront Interest" and (not LoanProduct."Salary Based")) then begin
            //     LoanProduct.TestField("Interest Paid Account");
            //     LoanApplication.CalcFields("Interest Repayment");
            //     PostingAmount := LoanApplication."Interest Repayment";
            //     PostingDescription := 'Interest Recovered';
            //     AccountNo := LoanApplication."Disbursement Account";
            //     LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Disb. Rec", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '',JournalTemplate, JournalBatch);
            //     AccountNo := LoanProduct."Interest Paid Account";
            //     LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Disb. Rec", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '',JournalTemplate, JournalBatch);
            // end;
            if SaccoSetup."Guarantor Notice Charge" > 0 then begin
                LoanGuarantee.Reset();
                LoanGuarantee.SetRange("Loan No", Loans."No.");
                if LoanGuarantee.FindSet() then begin
                    Guarantors := LoanGuarantee.Count;
                    AccountNo := '';
                    AccountNo := SaccoSetup."Guarantor Notice Inc. Acc.";
                    PostingDescription := 'Guarantor Notice Charges ' + Format(Guarantors) + ' guarantors';
                    PostingAmount := 0;
                    PostingAmount := Guarantors * SaccoSetup."Guarantor Notice Charge";
                    LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Loan Disbursal", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                    AccountNo := '';
                    AccountNo := Loans."Disbursement Account";
                    if Loans."Mode of Disbursement" = Loans."Mode of Disbursement"::BOSA then
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Loan Disbursal", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch)
                    else
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Loan Disbursal", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                end;
            end;
            // LoanProduct.Get(Loan."Product Code");
            // if LoanProduct."Mobile Appraisal Type" = LoanProduct."Mobile Appraisal Type"::"Dividend Percentage" then
            //     LineNo := JournalManagement.AddCharges(LoanProduct.Category, Loan."Disbursement Account", Loan."Approved Amount" - GetRefinancedDividend(Loan."No."), LineNo, DocumentNo, MemberNo, SourceCode, ReasonCode, ExternalDocumentNo, JournalBatch, JournalTemplate, Dim1, Dim2, PostingDate, True)
            // else
            //     LineNo := JournalManagement.AddCharges(LoanProduct.Category, Loan."Disbursement Account", Loan."Approved Amount", LineNo, DocumentNo, MemberNo, SourceCode, ReasonCode, ExternalDocumentNo, JournalBatch, JournalTemplate, Dim1, Dim2, PostingDate, True);
            Commit();
            JournalManagement.CompletePosting(JournalTemplate, JournalBatch);

            DetailedVendorLedgEntry.Reset();
            DetailedVendorLedgEntry.SetRange("Document No.", DocumentNo);
            DetailedVendorLedgEntry.SetRange("Member No.", Loans."Member No.");
            DetailedVendorLedgEntry.SetRange("Loan No.", Loans."No.");
            DetailedVendorLedgEntry.SetRange("Sacco Transaction Type", DetailedVendorLedgEntry."Sacco Transaction Type"::"Loan Disbursal");
            if DetailedVendorLedgEntry.FindFirst() then begin
                Loans."Application Status" := Loans."Application Status"::Disbursed;
                Loans.Posted := true;
                Loans."Posting Date" := WorkDate;
                Loans."Posted By" := UserId;
                Loans."Posted On" := CurrentDateTime;
                Loans.Modify();

                GenerateLoanRepaymentSchedule(Loans);
                CreateUnclearedEffec(DocumentNo);
                OnAfterPostLoan(Loans."No.");
                LoanProduct.Get(Loans."Product Code");
                if LoanProduct."Dividend Based" or LoanProduct."Mobile Loan" then
                    PostLoanUpFrontInterest(DocumentNo);
            end;
        end;
    end;

    procedure ProcessPartialDisbursement(LoanDisbursement: Record "Loan Disbursement")
    var
        Loans: Record Loans;
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        LineNo: Integer;
        PostingDate: Date;
        JournalBatch, JournalTemplate, AccountNo, ReasonCode, SourceCode, MemberNo, DocumentNo, ExternalDocumentNo : Code[20];
        JournalManagement: Codeunit "Journal Management";
        PostingDescription: Text[100];
        PostingAmount: Decimal;
    begin
        if not Confirm('You are about to post Loan Disbursement,\\ Do you wish to continue?') then exit;
        Loans.Get(LoanDisbursement."Loan No.");
        Loans.CalcFields(Disbursements);
        MemberNo := '';
        DocumentNo := LoanDisbursement."No.";
        GLEntry.Reset();
        GLEntry.SetRange("Document No.", DocumentNo);
        if GLEntry.FindFirst() then begin
            LoanDisbursement.Processed := true;
            LoanDisbursement."Processed On" := WorkDate;
            LoanDisbursement."Processed By" := UserId;
            LoanDisbursement.Modify(true);
            if Loans.Disbursements = Loans."Approved Amount" then begin
                Loans."Fully Disbursed" := true;
                Loans.Modify(true);
            end;
        end
        else begin
            JournalBatch := 'LOANS';
            JournalTemplate := 'GENERAL';
            LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
            ReasonCode := Loans."No.";
            SourceCode := Loans."Product Code";
            MemberNo := Loans."Member No.";
            ExternalDocumentNo := Loans."Cheque No.";
            PostingDate := WorkDate;
            PostingDescription := StrSubstNo('Loan Disbursal : %1', Loans."Product Description");
            PostingAmount := 0;
            PostingAmount := LoanDisbursement.Amount;
            AccountNo := '';
            AccountNo := Loans."Loan Account";
            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Loan Disbursal", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
            AccountNo := '';
            AccountNo := Loans."Disbursement Account";
            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Loan Disbursal", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
            LineNo := JournalManagement.AddCharges(LoanDisbursement."Charge Code", Loans."Disbursement Account", LoanDisbursement.Amount, LineNo, DocumentNo, MemberNo, SourceCode, ReasonCode, ExternalDocumentNo, JournalBatch, JournalTemplate, Dim1, Dim2, PostingDate, True);
            Commit();
            JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
            GLEntry.Reset();
            GLEntry.SetRange("Document No.", DocumentNo);
            GLEntry.SetRange("Document Date", PostingDate);
            if GLEntry.FindFirst() then begin
                LoanDisbursement.Processed := true;
                LoanDisbursement."Processed On" := WorkDate;
                LoanDisbursement."Processed By" := UserId;
                LoanDisbursement.Modify(true);
                GeneratePartialLoanRepaymentSchedule(LoanDisbursement);
                OnAfterPostLoanDisbursement(LoanDisbursement);
            end;
        end;
    end;

    internal procedure GetRefinancedDividend(LoanNo: Code[20]) RefinancedDividendValue: Decimal
    var
        ExistingLoan, LoanApplication : Record Loans;
    begin
        RefinancedDividendValue := 0;
        LoanApplication.Get(LoanNo);
        ExistingLoan.Reset;
        ExistingLoan.SetFilter("Loan Balance", '>0');
        ExistingLoan.Setrange("Product Code", LoanApplication."Product Code");
        ExistingLoan.SetRange("Member No.", LoanApplication."Member No.");
        if ExistingLoan.findset then begin
            ExistingLoan.CalcSums("Approved Amount");
            RefinancedDividendValue := ExistingLoan."Approved Amount";
        end;
        exit(RefinancedDividendValue);
    end;

    procedure PostCollateralRegistration(CollateralApplication: Record "Collateral Application")
    var
        CollateralRegister: Record "Collateral Register";
    begin
        if not CollateralRegister.Get(CollateralApplication."No.") then begin
            CollateralRegister.Init();
            CollateralRegister."No." := CollateralApplication."No.";
            CollateralRegister."Member No." := CollateralApplication."Member No";
            CollateralRegister."Member Name" := CollateralApplication."Member Name";
            CollateralRegister.Category := CollateralApplication.Category;
            CollateralRegister."Collateral Type" := CollateralApplication."Collateral Type";
            CollateralRegister."Collateral Description" := CollateralApplication."Collateral Description";
            CollateralRegister."Collateral Value" := CollateralApplication."Collateral Value";
            CollateralRegister.County := CollateralApplication.County;
            CollateralRegister.Guarantee := CollateralApplication.Guarantee;
            CollateralApplication."Serial/Reg No." := CollateralApplication."Serial/Reg No.";
            CollateralRegister."Posting Date" := WorkDate;
            CollateralRegister."Owner ID No" := CollateralApplication."Owner ID No";
            CollateralRegister."Owner Name" := CollateralApplication."Owner Name";
            CollateralRegister."Insurance Expiry Date" := CollateralApplication."Insurance Expiry Date";
            CollateralRegister."Car Track Due Date" := CollateralApplication."Car Track Due Date";
            CollateralRegister.Insert();
            CollateralApplication.Posted := true;
            CollateralApplication.Modify();
        end
        else begin
            CollateralRegister.Category := CollateralApplication.Category;
            CollateralRegister."Collateral Type" := CollateralApplication."Collateral Type";
            CollateralRegister."Collateral Description" := CollateralApplication."Collateral Description";
            CollateralRegister."Collateral Value" := CollateralApplication."Collateral Value";
            CollateralRegister.County := CollateralApplication.County;
            CollateralRegister.Guarantee := CollateralApplication.Guarantee;
            CollateralApplication."Serial/Reg No." := CollateralApplication."Serial/Reg No.";
            CollateralRegister."Posting Date" := WorkDate;
            CollateralRegister."Owner ID No" := CollateralApplication."Owner ID No";
            CollateralRegister."Owner Name" := CollateralApplication."Owner Name";
            CollateralRegister."Insurance Expiry Date" := CollateralApplication."Insurance Expiry Date";
            CollateralRegister."Car Track Due Date" := CollateralApplication."Car Track Due Date";
            CollateralApplication.Posted := true;
            CollateralApplication."Processed On" := WorkDate;
            CollateralApplication.Modify();
        end;
        OnAfterAcceptCollateral(CollateralApplication);
    end;

    procedure AccrueLoanInterest(Loans: Record Loans)
    var
        AccrualEntries: Record "Loan Interest Accrual";
        LineNo: Integer;
        MonthlyInstallment: Decimal;
        Days: Integer;
        ScheduleStartDate: Date;
        ScheduleEndDate: Date;
        StartDate: Date;
        EndDate: Date;
        LoanSchedule: Record "Loan Schedule";
        AnniversaryDay: Integer;
        DateRec: Record Date;
        IsMobileLoan: Boolean;
        ObjLonaProducts: Record "Sacco Products";
    begin
        StartDate := 0D;
        EndDate := 0D;
        ScheduleStartDate := 0D;
        ScheduleEndDate := 0D;
        LineNo := 1;
        AnniversaryDay := Date2DMY(Loans."Repayment Start Date", 1);
        Loans.Modify();
        if AnniversaryDay = 31 then begin
            if Date2DMY(Today, 2) in [4, 6, 9, 11] then
                StartDate := DMY2Date(30, Date2DMY(Today, 2), Date2DMY(Today, 3))
            else begin
                if Date2DMY(Today, 2) = 2 then begin
                    if Date2DMY(Today, 3) MOD 4 = 0 then
                        StartDate := DMY2Date(29, Date2DMY(Today, 2), Date2DMY(Today, 3))
                    else
                        StartDate := DMY2Date(28, Date2DMY(Today, 2), Date2DMY(Today, 3));
                end
                else
                    StartDate := DMY2Date(31, Date2DMY(Today, 2), Date2DMY(Today, 3));
            end;
        end
        else if AnniversaryDay = 30 then begin
            if Date2DMY(Today, 2) = 2 then begin
                if Date2DMY(Today, 3) MOD 4 = 0 then
                    StartDate := DMY2Date(29, Date2DMY(Today, 2), Date2DMY(Today, 3))
                else
                    StartDate := DMY2Date(28, Date2DMY(Today, 2), Date2DMY(Today, 3));
            end
            else
                StartDate := DMY2Date(AnniversaryDay, Date2DMY(Today, 2), Date2DMY(Today, 3));
        end
        else if AnniversaryDay = 29 then begin
            if Date2DMY(Today, 2) = 2 then begin
                if Date2DMY(Today, 3) MOD 4 = 0 then
                    StartDate := DMY2Date(29, Date2DMY(Today, 2), Date2DMY(Today, 3))
                else
                    StartDate := DMY2Date(28, Date2DMY(Today, 2), Date2DMY(Today, 3));
            end
            else
                StartDate := DMY2Date(AnniversaryDay, Date2DMY(Today, 2), Date2DMY(Today, 3));
        end
        else
            StartDate := DMY2Date(AnniversaryDay, Date2DMY(Today, 2), Date2DMY(Today, 3));
        EndDate := StartDate;
        StartDate := CalcDate('-1M', StartDate);
        if StartDate < Loans."Repayment Start Date" then StartDate := Loans."Repayment Start Date";
        ScheduleStartDate := DMY2Date(1, Date2DMY(Today, 2), Date2DMY(Today, 3));
        if DateRec.Get(DateRec."Period Type"::Month, ScheduleStartDate) then ScheduleEndDate := DateRec."Period End";
        Days := EndDate - StartDate;
        if Days = 0 then days := 31;
        //Fred.....Exclude Mobile Loans as advised By Caroline Ogutu
        ObjLonaProducts.reset;
        ObjLonaProducts.SetRange(code, Loans."Product Code");
        ObjLonaProducts.SetRange(ObjLonaProducts."Exclude Billing & Interest", true);
        IsMobileLoan := ObjLonaProducts.FindFirst();
        //Message('IsMobileLoan %1', Format(IsMobileLoan));
        if not IsMobileLoan then begin
            LoanSchedule.Reset();
            LoanSchedule.SetRange("Loan No.", Loans."No.");
            LoanSchedule.SetRange("Expected Date", ScheduleStartDate, ScheduleEndDate);
            if LoanSchedule.FindFirst() then MonthlyInstallment := LoanSchedule."Interest Repayment";
            AccrualEntries.Reset();
            if AccrualEntries.FindLast() then LineNo := AccrualEntries."Entry No." + 1;
            repeat
                AccrualEntries.Reset();
                AccrualEntries.SetRange("Loan No.", Loans."No.");
                AccrualEntries.SetRange("Entry Date", StartDate);
                if AccrualEntries.IsEmpty then begin
                    AccrualEntries.Init();
                    AccrualEntries."Entry No." := LineNo;
                    LineNo += 1;
                    AccrualEntries."Loan No." := Loans."No.";
                    AccrualEntries."Created By" := UserId;
                    AccrualEntries."Created On" := CurrentDateTime;
                    AccrualEntries.Description := 'Interest Accrual - ' + Format(StartDate);
                    AccrualEntries."Entry Date" := StartDate;
                    AccrualEntries."Entry Type" := AccrualEntries."Entry Type"::"Interest Accrual";
                    AccrualEntries."Member Name" := Loans."Member Name";
                    AccrualEntries."Member No." := Loans."Member No.";
                    AccrualEntries.Amount := MonthlyInstallment / Days;
                    AccrualEntries.Open := true;
                    AccrualEntries.Insert();
                end;
                StartDate := CalcDate('1D', StartDate);
            until (StartDate > Today);
        end;
    end;

    procedure GetLoanCalculatorRepaymentStartDate(LoanCalculator: Record "Loan Calculator") RepaymentStartDate: date
    var
        dayNo: integer;
        Mnth: integer;
        year: integer;
        VendorLedger: Record "Vendor Ledger Entry";
        LoanProduct: Record "Sacco Products";
    begin
        if LoanCalculator."Repayment Start Date" <> 0D then begin
            LoanProduct.Get(LoanCalculator."Loan Product");
            dayNo := Date2DMY(LoanCalculator."Repayment Start Date", 1);
            if ((LoanProduct."Repayment Cutoff Date" = 0) or (dayNo < LoanProduct."Repayment Cutoff Date")) then
                RepaymentStartDate := CalcDate('CM', LoanCalculator."Repayment Start Date")
            else
                RepaymentStartDate := CalcDate('CM+1M', LoanCalculator."Repayment Start Date")
        end;
        if LoanProduct.Get(LoanCalculator."Repayment Start Date") then begin
            if LoanProduct."Mobile Loan" then RepaymentStartDate := LoanCalculator."Repayment Start Date";
        end;
        exit(RepaymentStartDate);
    end;

    procedure GetRepaymentStartDate(Loans: Record Loans) RepaymentStartDate: date
    var
        dayNo: integer;
        Mnth: integer;
        year: integer;
        VendorLedger: Record "Vendor Ledger Entry";
        LoanProduct: Record "Sacco Products";
        Members: Record Members;
    begin
        if Loans."Posting Date" = 0D then begin
            VendorLedger.Reset();
            VendorLedger.SetRange("Sacco Transaction Type", VendorLedger."Sacco Transaction Type"::"Loan Disbursal");
            VendorLedger.SetRange("Loan No.", Loans."No.");
            if VendorLedger.FindFirst() then
                Loans."Posting Date" := VendorLedger."Posting Date";
        end;
        if Loans."Posting Date" <> 0D then begin
            LoanProduct.Get(Loans."Product Code");
            dayNo := Date2DMY(Loans."Posting Date", 1);
            if ((LoanProduct."Repayment Cutoff Date" = 0) or (dayNo < LoanProduct."Repayment Cutoff Date")) then
                RepaymentStartDate := CalcDate('CM', Loans."Posting Date")
            else
                RepaymentStartDate := CalcDate('CM+1M', Loans."Posting Date");
        end
        else begin
            LoanProduct.Get(Loans."Product Code");
            dayNo := Date2DMY(Loans."Application Date", 1);
            if ((LoanProduct."Repayment Cutoff Date" = 0) or (dayNo < LoanProduct."Repayment Cutoff Date")) then
                RepaymentStartDate := CalcDate('CM', Loans."Application Date")
            else
                RepaymentStartDate := CalcDate('CM+1M', Loans."Application Date")
        end;
        if LoanProduct.Get(Loans."Product Code") then begin
            if LoanProduct."Mobile Loan" then begin
                Members.Get(Loans."Member No.");
                if not Members.Salaried then
                    RepaymentStartDate := CalcDate('+1M', Loans."Application Date");
            end;
        end;
        exit(RepaymentStartDate);
    end;

    procedure GetRepaymentChannelStartDate(ChannelLoanApplication: Record "Channel Loan Application") RepaymentStartDate: date
    var
        dayNo: integer;
        Mnth: integer;
        year: integer;
        VendorLedger: Record "Vendor Ledger Entry";
        LoanProduct: Record "Sacco Products";
        Members: Record Members;
    begin
        if ChannelLoanApplication."Posting Date" = 0D then begin
            VendorLedger.Reset();
            VendorLedger.SetRange("Sacco Transaction Type", VendorLedger."Sacco Transaction Type"::"Loan Disbursal");
            VendorLedger.SetRange("Loan No.", ChannelLoanApplication."No.");
            if VendorLedger.FindFirst() then
                ChannelLoanApplication."Posting Date" := VendorLedger."Posting Date";
        end;
        if ChannelLoanApplication."Posting Date" <> 0D then begin
            LoanProduct.Get(ChannelLoanApplication."Product Code");
            dayNo := Date2DMY(ChannelLoanApplication."Posting Date", 1);
            if ((LoanProduct."Repayment Cutoff Date" = 0) or (dayNo < LoanProduct."Repayment Cutoff Date")) then
                RepaymentStartDate := CalcDate('CM', ChannelLoanApplication."Posting Date")
            else
                RepaymentStartDate := CalcDate('CM+1M', ChannelLoanApplication."Posting Date");
        end
        else begin
            LoanProduct.Get(ChannelLoanApplication."Product Code");
            dayNo := Date2DMY(ChannelLoanApplication."Application Date", 1);
            if ((LoanProduct."Repayment Cutoff Date" = 0) or (dayNo < LoanProduct."Repayment Cutoff Date")) then
                RepaymentStartDate := CalcDate('CM', ChannelLoanApplication."Application Date")
            else
                RepaymentStartDate := CalcDate('CM+1M', ChannelLoanApplication."Application Date")
        end;
        if LoanProduct.Get(ChannelLoanApplication."Product Code") then begin
            if LoanProduct."Mobile Loan" then begin
                Members.Get(ChannelLoanApplication."Member No.");
                if not Members.Salaried then
                    RepaymentStartDate := CalcDate('+1M', ChannelLoanApplication."Application Date");
            end;
        end;
        exit(RepaymentStartDate);
    end;

    procedure CalculatePenalty(Loans: Record Loans; DateAt: Date) Penalty: Decimal
    var
        DetailedVendorLedgerEntry: Record "Detailed Vendor Ledg. Entry";
        Schedule: Record "Loan Schedule";
        InstallmentDue: Decimal;
        InstallmentPaid: Decimal;
        DefaultedInstallment: Decimal;
        Product: Record "Sacco Products";
        AnnivarsaryDay: Integer;
        AnnivarsadyDate: date;
    begin
        Penalty := 0;
        InstallmentDue := 0;
        InstallmentPaid := 0;
        AnnivarsaryDay := 0;
        DefaultedInstallment := 0;
        AnnivarsadyDate := 0D;
        AnnivarsaryDay := Date2DMY(Loans."Repayment Start Date", 1);
        if AnnivarsaryDay > 28 then begin
            if Date2DMY(DateAt, 2) in [1, 3, 5, 7, 8, 10, 12] then
                AnnivarsadyDate := DMY2Date(AnnivarsaryDay, Date2DMY(DateAt, 2), Date2DMY(DateAt, 3))
            else if Date2DMY(DateAt, 2) in [4, 6, 9, 11] then begin
                if AnnivarsaryDay > 30 then
                    AnnivarsadyDate := DMY2Date(30, Date2DMY(DateAt, 2), Date2DMY(DateAt, 3))
                else
                    AnnivarsadyDate := DMY2Date(AnnivarsaryDay, Date2DMY(DateAt, 2), Date2DMY(DateAt, 3))
            end
            else begin
                if Date2DMY(DateAt, 3) mod 4 = 0 then
                    AnnivarsadyDate := DMY2Date(29, Date2DMY(DateAt, 2), Date2DMY(DateAt, 3))
                else
                    AnnivarsadyDate := DMY2Date(28, Date2DMY(DateAt, 2), Date2DMY(DateAt, 3));
            end;
        end
        else
            AnnivarsadyDate := DMY2Date(AnnivarsaryDay, Date2DMY(DateAt, 2), Date2DMY(DateAt, 3));
        if AnnivarsadyDate >= Today then exit(0);
        Schedule.Reset();
        Schedule.SetRange("Loan No.", Loans."No.");
        Schedule.SetRange("Document No.", GetDocumentNo(DateAt, false));
        if Schedule.FindFirst() then begin
            InstallmentDue := Schedule."Principal Repayment";
        end;
        DetailedVendorLedgerEntry.Reset();
        DetailedVendorLedgerEntry.SetRange("Vendor No.", Loans."Loan Account");
        DetailedVendorLedgerEntry.SetRange("Loan No.", Loans."No.");
        DetailedVendorLedgerEntry.SetRange("Sacco Transaction Type", DetailedVendorLedgerEntry."Sacco Transaction Type"::"Interest Due");
        if DetailedVendorLedgerEntry.FindSet() then begin
            DetailedVendorLedgerEntry.CalcSums(Amount);
            InstallmentDue += DetailedVendorLedgerEntry.Amount;
        end;
        DetailedVendorLedgerEntry.Reset();
        DetailedVendorLedgerEntry.SetRange("Vendor No.", Loans."Loan Account");
        DetailedVendorLedgerEntry.SetRange("Loan No.", Loans."No.");
        DetailedVendorLedgerEntry.SetFilter("Sacco Transaction Type", '%1|%2', DetailedVendorLedgerEntry."Sacco Transaction Type"::"Interest Paid", DetailedVendorLedgerEntry."Sacco Transaction Type"::"Principal Paid");
        if DetailedVendorLedgerEntry.FindSet() then begin
            DetailedVendorLedgerEntry.CalcSums(Amount);
            InstallmentPaid += DetailedVendorLedgerEntry.Amount;
        end;
        DefaultedInstallment := InstallmentDue + InstallmentPaid;
        if DefaultedInstallment < 0 then exit(0);
        Penalty := DefaultedInstallment * Product."Penalty Rate" * 0.01;
        exit(Penalty);
    end;

    procedure PostCollateralCollection(Collection: Record "Collateral Release")
    var
        CollateralRegister: Record "Collateral Register";
    begin
        if CollateralRegister.Get(Collection."Collateral Code") then begin
            CollateralRegister.Status := CollateralRegister.Status::Collected;
            CollateralRegister.Modify(true);
            Collection.Posted := true;
            Collection."Processed On" := WorkDate;
            Collection.Modify();
        end;
    end;

    procedure PostLoanInterest(PDate: Date; EmployerCode: Code[20]; BillType: Option All,FOSA,BOSA,"Loan Recovery"; BillingMemberNo: Code[20]; BillingLoanNo: Code[20])
    var
        PostingDate, Enddate, SDate, LastInterestCharge : Date;
        LoanSchedule, LoanSchedule1 : Record "Loan Schedule";
        PostingAmount: Decimal;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        DocumentNo, JournalBatch, JournalTemplate : code[20];
        LineNo: Integer;
        LoanProduct: Record "Sacco Products";
        ToDateBalance, BalanceAtDate, InterestDue : Decimal;
        ToDateFilter, DateFilter, PostingDescription : Text[200];
        Loans: array[2] of Record Loans;
        Dim3, Dim4, Dim5, Dim6, Dim7, Dim8, SourceCode, ReasonCode, MemberNo, AccountNo : Code[20];
        JournalManagement: Codeunit "Journal Management";
        SaccoSetup: Record "General Ledger Setup";
        Window: Dialog;
        Current, All, Days : Integer;
    begin
        SaccoSetup.Get;
        DateFilter := '..' + Format(PDate);
        Loans[1].Reset();
        Loans[1].SetCurrentKey("Product Code");
        Loans[1].SetFilter("Date Filter", DateFilter);
        Loans[1].SetRange(Posted, true);
        Loans[1].SetRange("Mobile Loan", false);
        Loans[1].SetRange("Dividend Based", false);
        Loans[1].SetRange("Interest Suspended", false);
        Loans[1].SetFilter("Loan Balance", '>%1', 0);
        Loans[1].SetFilter("Loan Classification", '<>%1', Loans[1]."Loan Classification"::Loss);
        if EmployerCode <> '' then
            Loans[1].SetRange("Employer Code", EmployerCode);
        if BillingMemberNo <> '' then
            Loans[1].SetRange("Member No.", BillingMemberNo);
        if BillingLoanNo <> '' then
            Loans[1].SetRange("No.", BillingLoanNo);
        if BillType = BillType::BOSA then
            Loans[1].SetRange("Salary Based", false)
        else if BillType = BillType::FOSA then
            Loans[1].SetRange("Salary Based", true);
        if Loans[1].FindSet() then begin
            All := Loans[1].Count;
            Current := 0;
            Window.Open('Billing \#1### \#2###\@3@@\Interest #4##\Employer Code #5###');
            JournalBatch := 'INT-BILL';
            JournalTemplate := 'GENERAL';
            LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
            repeat
                Window.Update(5, Loans[1]."Employer Code");
                InterestDue := 0;
                BalanceAtDate := 0;
                ToDateBalance := 0;

                Current += 1;
                Window.Update(1, Loans[1]."Product Description");
                Window.Update(2, Loans[1]."Member Name");
                Window.Update(3, ((Current / all) * 10000) div 1);
                Loans[1].CalcFields("Net Change-Principal");
                BalanceAtDate := Loans[1]."Net Change-Principal";

                ToDateFilter := '..' + Format(WorkDate);

                Loans[2].Reset();
                Loans[2].SetRange("No.", Loans[1]."No.");
                Loans[2].SetFilter("Date Filter", ToDateFilter);
                if Loans[2].FindFirst then begin
                    Loans[2].CalcFields("Last Interest Charge", "Loan Balance");
                    LastInterestCharge := Loans[2]."Last Interest Charge";
                    ToDateBalance := Loans[2]."Loan Balance";
                end;

                if ((BalanceAtDate > 0) and (ToDateBalance > 0) and (PDate > LastInterestCharge)) then begin
                    Loans[1].CalcFields("Last Interest Charge", "Loan Balance");
                    SDate := Loans[1]."Last Interest Charge";

                    if SDate = 0D then
                        SDate := Loans[1]."Posting Date";
                    Days := PDate - SDate;

                    if SaccoSetup."Daily Interest Accrual" then
                        InterestDue := BalanceAtDate * Loans[1]."Interest Rate" * 0.01 * (Days / 365)
                    else
                        InterestDue := BalanceAtDate * Loans[1]."Interest Rate" * 0.01 * (1 / 12);

                    Window.Update(4, InterestDue);
                    UserMgmtExt.GetUserDimensions(UserId, Dim1, Dim2);
                    LoanProduct.Get(Loans[1]."Product Code");
                    PostingAmount := 0;
                    if ((LoanProduct."Mobile Loan") OR (LoanProduct."Dividend Based") OR (LoanProduct."Charge UpFront Interest") OR (LoanProduct."Exclude Billing & Interest")) then InterestDue := 0;
                    PostingAmount := InterestDue;
                    if SaccoSetup."Daily Interest Accrual" then
                        DocumentNo := GetDocumentNo(PDate, true)
                    else
                        DocumentNo := GetDocumentNo(PDate, false);
                    if PostingAmount <> 0 then begin
                        VendorLedgerEntry.Reset();
                        VendorLedgerEntry.SetRange("Loan No.", Loans[1]."No.");
                        VendorLedgerEntry.SetRange("Sacco Transaction Type", VendorLedgerEntry."Sacco Transaction Type"::"Interest Due");
                        VendorLedgerEntry.SetRange(Reversed, false);
                        VendorLedgerEntry.SetRange("Document No.", DocumentNo);
                        VendorLedgerEntry.SetRange("Vendor No.", Loans[1]."Loan Account");
                        if VendorLedgerEntry.IsEmpty then begin
                            ReasonCode := Loans[1]."No.";
                            SourceCode := Loans[1]."Product Code";
                            MemberNo := Loans[1]."Member No.";
                            Loans[1]."Loan Account" := CreateLoanAccounts(Loans[1]);
                            PostingDescription := 'Interest Due ' + DocumentNo;
                            PostingAmount := 0;
                            PostingAmount := InterestDue;
                            PostingDate := PDate;
                            //Debit Loan
                            AccountNo := '';
                            AccountNo := Loans[1]."Loan Account";
                            Loans[1].TestField("Loan Account");
                            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Due", LineNo, SourceCode, ReasonCode, DocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                            LoanProduct.Get(Loans[1]."Product Code");
                            AccountNo := '';

                            if SaccoSetup."Interest Accrual Type" = SaccoSetup."Interest Accrual Type"::"Cash Basis" then begin
                                LoanProduct.TestField("Interest Due Account");
                                AccountNo := LoanProduct."Interest Due Account";
                                //Message('LoanProduct.Code %1 and AccountNo %2', LoanProduct.Code, AccountNo);
                            end
                            else begin
                                LoanProduct.TestField("Interest Paid Account");
                                AccountNo := LoanProduct."Interest Paid Account";
                            end;

                            //Credit Income
                            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Due", LineNo, SourceCode, ReasonCode, DocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                        end;
                    end;
                end;
            until Loans[1].Next() = 0;
            JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
            GLEntry.Reset();
            GLEntry.SetRange("Document No.", DocumentNo);
            GLEntry.SetRange("Document Date", PostingDate);
            if GLEntry.FindFirst() then Window.Close;
        end;
    end;

    procedure PostLoanRecoveryAccruedInterest(PDate: Date; BillingLoanNo: Code[20]; AccruedInterest: Decimal)
    var
        PostingAmount: Decimal;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        DocumentNo, JournalBatch, JournalTemplate, Dim3, Dim4, Dim5, Dim6, Dim7, Dim8, SourceCode, ReasonCode, MemberNo, AccountNo : code[20];
        LineNo: Integer;
        LoanProduct: Record "Sacco Products";
        Loans: Record Loans;
        JournalManagement: Codeunit "Journal Management";
    begin
        if Loans.Get(BillingLoanNo) then begin
            DocumentNo := GetDocumentNo(PDate, true);
            JournalBatch := 'LREC-BILL';
            JournalTemplate := 'GENERAL';
            LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
            VendorLedgerEntry.Reset();
            VendorLedgerEntry.SetRange("Loan No.", Loans."No.");
            VendorLedgerEntry.SetRange("Sacco Transaction Type", VendorLedgerEntry."Sacco Transaction Type"::"Interest Due");
            VendorLedgerEntry.SetRange(Reversed, false);
            VendorLedgerEntry.SetRange("Document No.", DocumentNo);
            VendorLedgerEntry.SetRange("Vendor No.", Loans."Loan Account");
            if VendorLedgerEntry.IsEmpty then begin
                ReasonCode := Loans."No.";
                SourceCode := Loans."Product Code";
                MemberNo := Loans."Member No.";
                Loans."Loan Account" := CreateLoanAccounts(Loans);
                PostingDescription := 'Interest Accrued ' + DocumentNo;
                PostingAmount := 0;
                PostingAmount := AccruedInterest;
                PostingDate := PDate;
                //Debit Loan
                AccountNo := '';
                AccountNo := Loans."Loan Account";
                Loans.TestField("Loan Account");
                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Due", LineNo, SourceCode, ReasonCode, DocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                LoanProduct.Get(Loans."Product Code");
                AccountNo := '';

                if SaccoSetup."Interest Accrual Type" = SaccoSetup."Interest Accrual Type"::"Cash Basis" then begin
                    LoanProduct.TestField("Interest Due Account");
                    AccountNo := LoanProduct."Interest Due Account";
                    //Message('LoanProduct.Code %1 and AccountNo %2', LoanProduct.Code, AccountNo);
                end
                else begin
                    LoanProduct.TestField("Interest Paid Account");
                    AccountNo := LoanProduct."Interest Paid Account";
                end;

                //Credit Income
                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Due", LineNo, SourceCode, ReasonCode, DocumentNo, '', 0, '', JournalTemplate, JournalBatch);
            end;
        end;
        JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
    end;

    procedure PostLoanUpFrontInterest(LoanNo: Code[20])
    var
        PostingDate, enddate : Date;
        PostingAmount: Decimal;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        DocumentNo, JournalBatch, JournalTemplate : code[20];
        LineNo: Integer;
        LoanProduct: Record "Sacco Products";
        InterestDue: Decimal;
        DateFilter, PostingDescription : Text[200];
        Loans: Record Loans;
        Dim3, Dim4, Dim5, Dim6, Dim7, Dim8, SourceCode, ReasonCode, MemberNo, AccountNo : Code[20];
        JournalManagement: Codeunit "Journal Management";
        SaccoSetup: Record "General Ledger Setup";
    begin
        Loans.Reset();
        Loans.SetRange("No.", LoanNo);
        Loans.SetRange(Posted, true);
        Loans.SetFilter("Loan Balance", '>%1', 0);
        Loans.SetFilter("Loan Classification", '<>%1', Loans."Loan Classification"::Loss);
        if Loans.FindFirst then begin
            if LoanProduct.Get(Loans."Product Code") then begin
                JournalBatch := 'INT-BILL';
                JournalTemplate := 'GENERAL';
                LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
                repeat
                    InterestDue := 0;
                    Loans.CalcFields("Interest Repayment");
                    InterestDue := Loans."Interest Repayment";
                    if InterestDue > 0 then begin
                        InterestDue := Loans."Interest Repayment";
                        UserMgmtExt.GetUserDimensions(UserId, Dim1, Dim2);
                        LoanProduct.Get(Loans."Product Code");
                        PostingAmount := 0;
                        if LoanProduct."Exclude Billing & Interest" then InterestDue := 0;
                        PostingAmount := InterestDue;
                        DocumentNo := Loans."No.";
                        VendorLedgerEntry.Reset();
                        VendorLedgerEntry.SetRange("Loan No.", Loans."No.");
                        VendorLedgerEntry.SetRange("Sacco Transaction Type", VendorLedgerEntry."Sacco Transaction Type"::"Interest Due");
                        VendorLedgerEntry.SetRange(Reversed, false);
                        VendorLedgerEntry.SetRange("Document No.", DocumentNo);
                        VendorLedgerEntry.SetRange("Vendor No.", Loans."Loan Account");
                        if VendorLedgerEntry.IsEmpty then begin
                            ReasonCode := Loans."No.";
                            SourceCode := Loans."Product Code";
                            ReasonCode := Loans."No.";
                            SourceCode := Loans."Product Code";
                            MemberNo := Loans."Member No.";
                            Loans."Loan Account" := CreateLoanAccounts(Loans);
                            PostingDescription := 'Interest Due ' + DocumentNo;
                            PostingAmount := 0;
                            PostingAmount := InterestDue;
                            PostingDate := Loans."Posting Date";
                            //Debit Loan
                            AccountNo := '';
                            AccountNo := Loans."Loan Account";
                            Loans.TestField("Loan Account");
                            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Due", LineNo, SourceCode, ReasonCode, DocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                            LoanProduct.Get(Loans."Product Code");
                            AccountNo := '';
                            SaccoSetup.Get();
                            if SaccoSetup."Interest Accrual Type" = SaccoSetup."Interest Accrual Type"::"Cash Basis" then begin
                                LoanProduct.TestField("Interest Due Account");
                                AccountNo := LoanProduct."Interest Due Account";
                            end
                            else begin
                                LoanProduct.TestField("Interest Paid Account");
                                AccountNo := LoanProduct."Interest Paid Account";
                            end;
                            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Due", LineNo, SourceCode, ReasonCode, DocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                        end;
                    end;
                until Loans.Next() = 0;
            end;
            JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
        end;
    end;

    procedure GetPriorDividendAmount(MemberNo: Code[20]): Decimal
    var
        Loans: Record Loans;
        PreviousAmount: Decimal;
    begin
        PreviousAmount := 0;
        Loans.Reset();
        Loans.SetRange("Member No.", MemberNo);
        Loans.SetRange("Dividend Based", true);
        Loans.SetFilter("Loan Balance", '>0');
        If Loans.FindSet then begin
            repeat
                Loans.CalcFields("Net Change-Principal");
                PreviousAmount += Loans."Net Change-Principal";
            until Loans.Next = 0;
        end;
        exit(PreviousAmount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Loans Management", 'OnBeforeSendLoanForApproval', '', true, true)]
    local procedure checkLoanFields(Loans: Record Loans)
    var
        MemberLoans: Record Loans;
        LoanRecoveries: Record "Loan Recoveries";
        LoanProduct: Record "Sacco Products";
        LoanGuarantees: Record "Loan Guarantees";
        UserSetup: Record "User Setup";
        Employee: Record Employee;
    begin
        Loans.TestField(Category);
        Loans.TestField("Approved Amount");
        Loans.TestField("Disbursement Account");

        if ((Loans.Category <> Loans.Category::HR) and (Loans.Category <> Loans.Category::DEBT)) then begin
            Loans.CalcFields("Total Repayment", "Total Guarantees", "Total Securities");
            Loans.TestField("Total Repayment");

            if Loans."Mode of Disbursement" = Loans."Mode of Disbursement"::Payables then begin
                Loans.CalcFields("Payable Advice");
                Loans.TestField("Payable Advice");
                If Loans."Payable Advice" > (Loans."Total Recoveries" + Loans."Charges Amount") then Error('You cannot Schedule more than %1', (Loans."Total Recoveries" + Loans."Charges Amount"));
            end;
            If Loans."Recovery Mode" = Loans."Recovery Mode"::Checkoff then Loans.TestField("New Monthly Installment");
            if Loans."Recovery Mode" in [Loans."Recovery Mode"::Cash, Loans."Recovery Mode"::Mpesa, Loans."Recovery Mode"::"Direct_Debit"] then Loans.TestField("Payment Date");
            if Loans."Mode of Disbursement" = Loans."Mode of Disbursement"::"FOSA (Partial)" then Loans.TestField("First Disbursement");
            LoanProduct.Get(Loans."Product Code");
            if LoanProduct."Unsecured Product" = false then begin
                if (Loans."Total Securities" + Loans."Total Guarantees") < Loans."Approved Amount" then
                    Error('The Loan is Unsecured');
            end;
            if Loans."Loan Amount" > Loans."Approved Amount" then
                Error(StrSubstNo('You cannot apply more than the Recommended Amount (%1)', Loans."Approved Amount"));

            If Loans."Loan Type" = Loans."Loan Type"::" " then
                Error('Kindly specify the Loan Type!');

            MemberLoans.Reset();
            MemberLoans.SetRange("Product Code", Loans."Product Code");
            MemberLoans.SetRange("Member No.", Loans."Member No.");
            MemberLoans.SetFilter("No.", '<>%1', Loans."No.");
            MemberLoans.SetRange(Posted, true);
            MemberLoans.SetRange(Closed, false);
            MemberLoans.SetFilter("Loan Balance", '>0');
            if MemberLoans.FindFirst() then begin
                LoanRecoveries.Reset();
                LoanRecoveries.SetRange("Loan No", Loans."No.");
                LoanRecoveries.SetRange("Recovery Code", MemberLoans."No.");
                if (LoanRecoveries.IsEmpty) and (LoanProduct."Max. Running Loans" <= 1) then Error('The Member %1 has a running %2 loan %3. Please Close the Account first! %4', Loans."Member Name", Loans."Product Description", MemberLoans."No.", MemberLoans.GetFilters);
            end;
            LoanGuarantees.Reset();
            LoanGuarantees.SetRange("Loan No", Loans."No.");
            LoanGuarantees.SetRange("Member No.", Loans."Member No.");
            LoanGuarantees.SetRange(Self, false);
            LoanGuarantees.SetFilter("Guaranteed Amount", '<>%1', 0);
            if LoanGuarantees.FindSet then begin
                repeat
                    LoanGuarantees.FnSendSMSToGuarantor(LoanGuarantees."Loan No", LoanGuarantees."Member No.");
                until LoanGuarantees.Next = 0;
            end;
        end;
    end;

    procedure GenerateCalculatorSchedule(var LoanCalculator: Record "Loan Calculator")
    var
        Window: Dialog;
        CalculatorLines: Record "Loan Calculator Lines";
        LoanProducts: Record "Sacco Products";
        EntryNo: Integer;
        InstallmentNo: Code[20];
        EndDate: Date;
        PrincipalBalance: Decimal;
        StartDate: date;
        PrincipalAmnt: Decimal;
        InterestBalance: Decimal;
        LBalance: Decimal;
        TotalMRepay: Decimal;
        LPrincipal: Decimal;
        LInterest: Decimal;
        ExpectedDate: date;
        TempEDate: Date;
        AnniversaryDay: Integer;
        NextMonth: Integer;
        Year: Integer;
    begin
        CalculatorLines.Reset();
        CalculatorLines.SetRange("Calculator No", LoanCalculator."No.");
        if CalculatorLines.FindSet() then CalculatorLines.DeleteAll();
        Window.Open('Creating Schedule \#1##');
        LoanProducts.GET(LoanCalculator."Loan Product");
        LoanCalculator.TestField("Repayment Start Date");
        CalculatorLines.Reset();
        if CalculatorLines.FindLast() then
            EntryNo := CalculatorLines."Entry No" + 1
        else
            EntryNo := 1;
        PrincipalBalance := LoanCalculator."Principal Amount";
        StartDate := GetLoanCalculatorRepaymentStartDate(LoanCalculator);
        EndDate := CalcDate(Format(LoanCalculator."Installments (Months)") + 'M', StartDate);
        PrincipalAmnt := 0;
        PrincipalAmnt := PrincipalBalance;
        InterestBalance := 0;
        LBalance := PrincipalBalance;
        PrincipalAmnt := PrincipalBalance;
        NextMonth := 0;
        Year := 0;
        REPEAT
            IF LoanCalculator."Rate Type" = LoanCalculator."Rate Type"::Amortised THEN BEGIN
                LoanCalculator.TestField("Installments (Months)");
                TotalMRepay := ROUND((LoanCalculator."Interest Rate" / 12 / 100) / (1 - POWER((1 + (LoanCalculator."Interest Rate" / 12 / 100)), -(LoanCalculator."Installments (Months)"))) * (PrincipalAmnt), 0.0001, '>');
                LInterest := LBalance / 100 / 12 * LoanCalculator."Interest Rate";
                LPrincipal := TotalMRepay - LInterest;
            end;
            IF LoanCalculator."Rate Type" = LoanCalculator."Rate Type"::"Straight Line" THEN BEGIN
                LoanCalculator.TESTFIELD("Installments (Months)");
                LPrincipal := PrincipalAmnt / LoanCalculator."Installments (Months)";
                LInterest := (LoanCalculator."Interest Rate" / 12 / 100) * PrincipalAmnt;
                LInterest := LInterest;
            end;
            IF LoanCalculator."Rate Type" = LoanCalculator."Rate Type"::"Reducing Balance" THEN BEGIN
                LoanCalculator.TESTFIELD("Installments (Months)");
                LPrincipal := PrincipalAmnt / LoanCalculator."Installments (Months)";
                LInterest := (LoanCalculator."Interest Rate" / 12 / 100) * LBalance;
                LInterest := LInterest;
            end;
            LBalance := LBalance - LPrincipal;
            ExpectedDate := StartDate;
            InstallmentNo := GetDocumentNo(StartDate, false);
            CalculatorLines.INIT;
            CalculatorLines."Entry No" := EntryNo;
            EntryNo += 1;
            CalculatorLines.Month := InstallmentNo;
            CalculatorLines."Expected Date" := StartDate;
            CalculatorLines."Principal Amount" := LPrincipal;
            CalculatorLines."Interest Amount" := LInterest;
            CalculatorLines."Installment Amount" := LPrincipal + LInterest;
            CalculatorLines."Running Balance" := LBalance;
            CalculatorLines."Calculator No" := LoanCalculator."No.";
            CalculatorLines.INSERT;
            StartDate := CalcDate('1M', StartDate);
            Window.Update(1, InstallmentNo);
        UNTIL CalcDate('-CM', StartDate) = CalcDate('-CM', EndDate);
        Window.Close;
    end;

    procedure ValidateAppraisal(Loans: Record Loans)
    var
        LoanProduct: Record "Sacco Products";
        LoanApplication2: Record Loans;
        LoanRecoveries: Record "Loan Recoveries";
        ProductCharges: Record "Product Charge Setup";
        LoanCharges: array[7] of Record "Loan Charges";
        ProductIntrestBand: Record "Product Interest Bands";
    begin
        LoanApplication2.Reset();
        LoanApplication2.SetRange("Member No.", Loans."Member No.");
        LoanApplication2.SetRange("Product Code", Loans."Product Code");
        LoanApplication2.SetFilter("Loan Balance", '>0');
        if LoanApplication2.FindFirst() then begin
            LoanProduct.Get(LoanApplication2."Product Code");
            LoanRecoveries.Reset();
            LoanRecoveries.SetRange("Loan No", Loans."No.");
            LoanRecoveries.SetRange("Recovery Code", LoanApplication2."No.");
            if LoanRecoveries.IsEmpty then begin
                if LoanProduct."Max. Running Loans" = 1 then
                    Error('You have a running loan of ' + Loans."Product Description");
            end
        end;
        LoanProduct.Get(Loans."Product Code");
        // if LoanProduct."Minimum Deposit Balance" > GetMemberDeposits(LoanApplication."Member No.") then
        //     Error('You must have at least Kes. %1 to qualify for this loan', LoanProduct."Minimum Deposit Balance");
        LoanCharges[1].Reset;
        LoanCharges[1].SetRange("No.", Loans."No.");
        if LoanCharges[1].FindSet then LoanCharges[1].DeleteAll;
        ProductCharges.Reset();
        ProductCharges.SetRange("Source Code", Loans."Product Code");
        if ProductCharges.FindSet then begin
            repeat
                ProductCharges.TestField("Post-to Account No.");
                LoanCharges[2].Init();
                LoanCharges[2]."No." := Loans."No.";
                LoanCharges[2].Validate("Charge Code", ProductCharges."Charge Code");
                LoanCharges[2].Validate("Post to Account Type", ProductCharges."Post to Account Type");
                LoanCharges[2].Validate("Post-to Account No.", ProductCharges."Post-to Account No.");
                LoanCharges[2].Validate(Editable, ProductCharges.Editable);
                If Loans."Approved Amount" <> 0 then
                    LoanCharges[2].Amount := fnGetTransAmount(Loans."Product Code", ProductCharges."Charge Code", Loans."Approved Amount")
                else
                    LoanCharges[2].Amount := fnGetTransAmount(Loans."Product Code", ProductCharges."Charge Code", Loans."Loan Amount");
                if not LoanCharges[3].Get(Loans."No.", ProductCharges."Charge Code") then LoanCharges[2].Insert(true);
            until ProductCharges.Next = 0;
        end;
    end;

    procedure ValidateChannelAppraisal(LoanApplication: Record "Channel Loan Application")
    var
        LoanProduct: Record "Sacco Products";
        LoanApplication2: Record Loans;
        LoanRecoveries: Record "Loan Recoveries";
    begin
        LoanApplication2.Reset();
        LoanApplication2.SetRange("Member No.", LoanApplication."Member No.");
        LoanApplication2.SetRange("Product Code", LoanApplication."Product Code");
        LoanApplication2.SetFilter("Loan Balance", '>0');
        if LoanApplication2.FindFirst() then begin
            LoanRecoveries.Reset();
            LoanRecoveries.SetRange("Loan No", LoanApplication."No.");
            LoanRecoveries.SetRange("Recovery Code", LoanApplication2."No.");
            if LoanRecoveries.IsEmpty then Error('You have a running loan of ' + LoanApplication."Product Description");
        end;
        LoanProduct.Get(LoanApplication."Product Code");
        if LoanProduct."Minimum Deposit Balance" > GetMemberDeposits(LoanApplication."Member No.") then Error('You must have at least Kes. %1 to qualify for this loan', LoanProduct."Minimum Deposit Balance");
    end;

    procedure PopulateGuarantorSubLines(DocumentNo: Code[20])
    var
        GuarantorLines: Record "Loan Security Mgmt Lines";
        LoanGuarantors: Record "Loan Guarantees";
        LoanSecurities: Record "Loan Securities";
        GuarantorHeader: Record "Loan Security Mgmt";
        LineNo: Integer;
        MemberMgt: Codeunit "Member Management";
        Loans: Record Loans;
    begin
        GuarantorHeader.Get(DocumentNo);

        GuarantorLines.Reset();
        GuarantorLines.SetRange("No.", DocumentNo);
        if GuarantorLines.FindSet() then
            GuarantorLines.DeleteAll();

        LoanGuarantors.Reset();
        LoanGuarantors.SetRange(Substituted, false);
        LoanGuarantors.SetRange("Loan No", GuarantorHeader."Loan No");
        if LoanGuarantors.FindSet() then begin
            repeat
                if Loans.Get(LoanGuarantors."Loan No") then begin
                    Loans.CalcFields("Loan Balance");
                    GuarantorLines.Init();
                    GuarantorLines."No." := DocumentNo;
                    GuarantorLines."Line No" := LineNo;
                    LineNo += 1;
                    GuarantorLines."Loan No." := GuarantorHeader."Loan No";
                    GuarantorLines."Security Type" := GuarantorLines."Security Type"::Guarantor;
                    GuarantorLines."Security Code" := LoanGuarantors."Member No.";
                    GuarantorLines."Security Name" := LoanGuarantors."Member Name";
                    GuarantorLines."Intial Guaranteed" := LoanGuarantors."Guaranteed Amount";
                    GuarantorLines."Loan Balance" := Loans."Loan Balance";
                    GuarantorLines."Loan Principal" := Loans."Approved Amount";
                    GuarantorLines."Product Code" := Loans."Product Code";
                    GuarantorLines."Product Description" := Loans."Product Description";
                    GuarantorLines."Outstanding Guaranteed" := MemberMgt.GetOutstandingGuarantee(Loans."No.", LoanGuarantors."Member No.");
                    GuarantorLines.Insert();
                end;
            until LoanGuarantors.Next() = 0;
        end;
        LoanSecurities.Reset();
        LoanSecurities.SetRange(Substituted, false);
        LoanSecurities.SetRange("Loan No", GuarantorHeader."Loan No");
        if LoanSecurities.FindSet() then begin
            repeat
                if Loans.Get(LoanGuarantors."Loan No") then begin
                    Loans.CalcFields("Loan Balance");
                    GuarantorLines.Init();
                    GuarantorLines."No." := DocumentNo;
                    GuarantorLines."Line No" := LineNo;
                    LineNo += 1;
                    GuarantorLines."Loan No." := GuarantorHeader."Loan No";
                    GuarantorLines."Security Type" := LoanSecurities."Security Type";
                    GuarantorLines."Security Code" := LoanSecurities."Security Code";
                    GuarantorLines."Security Name" := LoanSecurities.Description;
                    GuarantorLines."Intial Guaranteed" := LoanSecurities.Guarantee;
                    GuarantorLines."Loan Balance" := Loans."Loan Balance";
                    GuarantorLines."Loan Principal" := Loans."Approved Amount";
                    GuarantorLines."Product Code" := Loans."Product Code";
                    GuarantorLines."Product Description" := Loans."Product Description";
                    GuarantorLines."Outstanding Guaranteed" := MemberMgt.GetOutstandingCollateralGuarantee(Loans."No.", LoanSecurities."Security Code");
                    GuarantorLines.Insert();
                end;
            until LoanGuarantors.Next() = 0;
        end;
    end;

    procedure ProcessGuarantorSubstitution(DocumentNo: Code[20])
    var
        GuarantorHeader: Record "Loan Security Mgmt";
        GuarantorLines: Record "Loan Security Mgmt Lines";
        GuarantorDetLines: Record "Loan Security Mgmt Det. Lines";
        LoanGuarantee: array[4] of Record "Loan Guarantees";
        LoanSecurities: array[4] of Record "Loan Securities";
        OriginalGuarantee: Decimal;
    begin
        GuarantorHeader.Get(DocumentNo);
        GuarantorHeader.TestField(Processed, false);
        GuarantorHeader.TestField(Status, GuarantorHeader.Status::Approved);
        GuarantorLines.Reset();
        GuarantorLines.SetRange("No.", DocumentNo);
        if GuarantorLines.FindSet() then begin
            repeat
                GuarantorLines.CalcFields(Substitution);
                if GuarantorLines."Security Type" = GuarantorLines."Security Type"::Guarantor then begin
                    if GuarantorLines.Release then begin
                        LoanGuarantee[1].Reset();
                        LoanGuarantee[1].SetRange("Loan No", GuarantorLines."Loan No.");
                        LoanGuarantee[1].SetRange("Member No.", GuarantorLines."Security Code");
                        if LoanGuarantee[1].FindSet() then begin
                            LoanGuarantee[1].Substituted := true;
                            LoanGuarantee[1]."Substituted By" := UserId;
                            LoanGuarantee[1]."Document No." := DocumentNo;
                            LoanGuarantee[1].Modify();
                        end;
                    end
                    else begin
                        if GuarantorLines.Substitution then begin
                            LoanGuarantee[2].Reset();
                            LoanGuarantee[2].SetRange("Loan No", GuarantorLines."Loan No.");
                            LoanGuarantee[2].SetRange("Member No.", GuarantorLines."Security Code");
                            if LoanGuarantee[2].FindSet() then begin
                                LoanGuarantee[2].Substituted := true;
                                LoanGuarantee[2]."Substituted By" := UserId;
                                LoanGuarantee[2]."Document No." := DocumentNo;
                                LoanGuarantee[2].Modify();
                            end;
                            GuarantorDetLines.Reset();
                            GuarantorDetLines.SetRange("No.", DocumentNo);
                            GuarantorDetLines.SetRange("Line No", GuarantorLines."Line No");
                            GuarantorLines.SetFilter("Guaranteed Amount", '>0');
                            if GuarantorDetLines.FindSet() then begin
                                repeat
                                    LoanGuarantee[3].Reset();
                                    LoanGuarantee[3].SetRange("Loan No", GuarantorLines."Loan No.");
                                    LoanGuarantee[3].SetRange("Member No.", GuarantorDetLines."Security Code");
                                    if not LoanGuarantee[3].FindSet() then begin
                                        LoanGuarantee[4].Init();
                                        LoanGuarantee[4]."Loan No" := GuarantorLines."Loan No.";
                                        LoanGuarantee[4]."Member No." := GuarantorDetLines."Security Code";
                                        LoanGuarantee[4]."Member Name" := GuarantorDetLines."Security Name";
                                        LoanGuarantee[4]."Member Deposits" := GetMemberDeposits((GuarantorDetLines."Security Code"));
                                        LoanGuarantee[4]."Available Guarantee" := GuarantorDetLines."Qualified Guarantee";
                                        LoanGuarantee[4]."Guaranteed Amount" := GuarantorDetLines."Original Amount";
                                        LoanGuarantee[4]."Intial Substitution" := GuarantorDetLines."Guarantee Amount";
                                        LoanGuarantee[4].Insert();
                                    end
                                    else begin
                                        LoanGuarantee[3]."Guaranteed Amount" += GuarantorDetLines."Original Amount";
                                        LoanGuarantee[3]."Intial Substitution" += GuarantorDetLines."Guarantee Amount";
                                        LoanGuarantee[3].Modify(true);
                                    end;
                                until GuarantorDetLines.Next() = 0;
                            end;
                        end;
                    end;
                end else begin
                    if GuarantorLines.Release then begin
                        LoanSecurities[1].Reset();
                        LoanSecurities[1].SetRange("Loan No", GuarantorLines."Loan No.");
                        LoanSecurities[1].SetRange("Member No.", GuarantorLines."Security Code");
                        if LoanSecurities[1].FindSet() then begin
                            LoanSecurities[1].Substituted := true;
                            LoanSecurities[1]."Substituted By" := UserId;
                            LoanSecurities[1]."Document No." := DocumentNo;
                            LoanSecurities[1].Modify();
                        end;
                    end
                    else begin
                        if GuarantorLines.Substitution then begin
                            LoanSecurities[2].Reset();
                            LoanSecurities[2].SetRange("Loan No", GuarantorLines."Loan No.");
                            LoanSecurities[2].SetRange("Member No.", GuarantorLines."Security Code");
                            if LoanSecurities[2].FindSet() then begin
                                LoanSecurities[2].Substituted := true;
                                LoanSecurities[2]."Substituted By" := UserId;
                                LoanSecurities[2]."Document No." := DocumentNo;
                                LoanSecurities[2].Modify();
                            end;

                            GuarantorDetLines.Reset();
                            GuarantorDetLines.SetRange("No.", DocumentNo);
                            GuarantorDetLines.SetRange("Line No", GuarantorLines."Line No");
                            GuarantorLines.SetFilter("Guaranteed Amount", '>0');
                            if GuarantorDetLines.FindSet() then begin
                                repeat
                                    LoanSecurities[3].Reset();
                                    LoanSecurities[3].SetRange("Loan No", GuarantorLines."Loan No.");
                                    LoanSecurities[3].SetRange("Member No.", GuarantorDetLines."Security Code");
                                    if not LoanSecurities[3].FindSet() then begin
                                        LoanSecurities[4].Init();
                                        LoanSecurities[4]."Loan No" := GuarantorLines."Loan No.";
                                        LoanSecurities[4]."Member No." := GuarantorDetLines."Security Code";
                                        LoanSecurities[4]."Security Code" := GuarantorDetLines."Security Code";
                                        LoanSecurities[4].Description := GuarantorDetLines."Security Name";
                                        LoanSecurities[4].Guarantee := GuarantorDetLines."Guarantee Amount";
                                        LoanSecurities[4].Insert();
                                    end
                                    else begin
                                        LoanSecurities[3].Guarantee += GuarantorDetLines."Guarantee Amount";
                                        LoanSecurities[3].Modify();
                                    end;
                                until GuarantorDetLines.Next() = 0;
                            end;
                        end;
                    end;
                end;
            until GuarantorLines.Next() = 0;
        end;
        GuarantorHeader.Processed := true;
        GuarantorHeader.Modify();
        Message('Guarantor Substituted Successfully!');
    end;

    procedure GetAccruedInterest(LoanNo: Code[20]; AsAtDate: Date) AccruedInterest: Decimal
    var
        DetailedVendorLedger: Record "Detailed Vendor Ledg. Entry";
        Loans: Record Loans;
        DateFilter: Text;
        Days: Integer;
    begin
        DateFilter := '..' + Format(AsAtDate);
        Loans.Reset();
        Loans.SetRange("No.", LoanNo);
        Loans.SetFilter("Date Filter", DateFilter);
        if Loans.findset then begin
            DetailedVendorLedger.Reset();
            DetailedVendorLedger.SetRange("Reason Code", CopyStr(LoanNo, 1, 10));
            DetailedVendorLedger.SetRange("Loan No.", LoanNo);
            DetailedVendorLedger.SetFilter("Posting Date", DateFilter);
            DetailedVendorLedger.SetRange("Vendor No.", Loans."Loan Account");
            DetailedVendorLedger.SetRange("Sacco Transaction Type", DetailedVendorLedger."Sacco Transaction Type"::"Interest Due");
            if DetailedVendorLedger.FindLast() then
                Days := AsAtDate - DetailedVendorLedger."Posting Date"
            else begin
                DetailedVendorLedger.Reset();
                DetailedVendorLedger.SetRange("Loan No.", LoanNo);
                DetailedVendorLedger.SetFilter("Posting Date", DateFilter);
                DetailedVendorLedger.SetRange("Vendor No.", Loans."Loan Account");
                DetailedVendorLedger.SetRange("Sacco Transaction Type", DetailedVendorLedger."Sacco Transaction Type"::"Loan Disbursal");
                if DetailedVendorLedger.FindLast() then Days := AsAtDate - DetailedVendorLedger."Posting Date"
            end;
            if Days <= 0 then Days := 0;
            Loans.CalcFields("Loan Balance");
            AccruedInterest := (Days / 365) * Loans."Loan Balance" * Loans."Interest Rate" * 0.01;
            exit(AccruedInterest);
        end;
    end;

    procedure GetAccruedDailyInterest(LoanNo: Code[20]; AsAtDate: Date) AccruedInterest: Decimal
    var
        DetailedVendorLedger: Record "Detailed Vendor Ledg. Entry";
        Loans: Record Loans;
        DateFilter: Text;
        Days: Integer;
    begin
        DateFilter := '..' + Format(AsAtDate);
        Loans.Reset();
        Loans.SetRange("No.", LoanNo);
        Loans.SetFilter("Date Filter", DateFilter);
        if Loans.findset then begin
            DetailedVendorLedger.Reset();
            DetailedVendorLedger.SetRange("Loan No.", LoanNo);
            DetailedVendorLedger.SetFilter("Posting Date", DateFilter);
            DetailedVendorLedger.SetRange("Vendor No.", Loans."Loan Account");
            DetailedVendorLedger.SetRange("Sacco Transaction Type", DetailedVendorLedger."Sacco Transaction Type"::"Interest Due");
            if DetailedVendorLedger.FindLast() then
                Days := AsAtDate - DetailedVendorLedger."Posting Date"
            else begin
                DetailedVendorLedger.Reset();
                DetailedVendorLedger.SetRange("Loan No.", LoanNo);
                DetailedVendorLedger.SetFilter("Posting Date", DateFilter);
                DetailedVendorLedger.SetRange("Vendor No.", Loans."Loan Account");
                DetailedVendorLedger.SetRange("Sacco Transaction Type", DetailedVendorLedger."Sacco Transaction Type"::"Loan Disbursal");
                if DetailedVendorLedger.FindLast() then Days := AsAtDate - DetailedVendorLedger."Posting Date"
            end;
            if Days <= 0 then Days := 0;
            Loans.CalcFields("Loan Balance");
            AccruedInterest := (Days / 365) * Loans."Loan Balance" * Loans."Interest Rate" * 0.01;
            exit(AccruedInterest);
        end;
    end;

    procedure GetMonthsDifference(StartDate: Date; EndDate: Date): Integer
    var
        StartYear: Integer;
        StartMonth: Integer;
        EndYear: Integer;
        EndMonth: Integer;
    begin
        if EndDate < StartDate then
            exit(-GetMonthsDifference(EndDate, StartDate));

        StartYear := Date2DMY(StartDate, 3);
        StartMonth := Date2DMY(StartDate, 2);

        EndYear := Date2DMY(EndDate, 3);
        EndMonth := Date2DMY(EndDate, 2);

        exit((EndYear - StartYear) * 12 + (EndMonth - StartMonth));
    end;

    procedure PostLoanPenalty(LoansNo: Code[20]; PenaltyDate: Date)
    begin
        DocumentNo := '';
        ReasonCode := '';
        SourceCode := '';
        ExternalDocumentNo := '';
        MemberNo := '';
        PostingAmount := 0;

        if Loans.Get(LoansNo) then begin
            Loans.CalcFields("Principal Balance");
            SaccoProducts.Get(Loans."Product Code");
            if SaccoProducts."Penalty Rate" <> 0 then begin
                JournalBatch := 'PEN-BILL';
                JournalTemplate := 'PAYMENT';
                LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);

                PostingDate := PenaltyDate;
                DocumentNo := Format(PostingDate);
                ReasonCode := Loans."No.";
                SourceCode := Loans."Product Code";
                ExternalDocumentNo := Loans."Member No.";
                MemberNo := Loans."Member No.";

                ArrearsAmount := Loans."Principal Balance";
                PostingAmount := Abs(ArrearsAmount * SaccoProducts."Penalty Rate" * 0.01);

                PostingDescription := (COPYSTR('Penalty Charged On ' + Loans."No.", 1, 50));
                AccountNo := SaccoProducts."Penalty Due Account";
                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", AccountNo, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Penalty Due", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                AccountNo := Loans."Loan Account";
                LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, AccountNo, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Penalty Due", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);

                DetailedVendorLedgEntry.RESET;
                DetailedVendorLedgEntry.SETRANGE("Document No.", DocumentNo);
                DetailedVendorLedgEntry.SETRANGE("Posting Date", PostingDate);
                DetailedVendorLedgEntry.SETRANGE("Member No.", MemberNo);
                DetailedVendorLedgEntry.SETRANGE("Loan No.", Loans."No.");
                if not DetailedVendorLedgEntry.FindFirst then begin
                    JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
                    OnAfterPostLoanPenalty(Loans, PostingAmount)
                end;
            end;
        end;
    end;

    procedure LoanArchiving(Loans: Record Loans)
    begin
        Loans.CalcFields("Mobile Loan");
        if not Loans."Mobile Loan" then begin
            if Loans.Status <> Loans.Status::Archived then
                Loans.Status := Loans.Status::Archived
            else
                if Loans.Status = Loans.Status::Archived then
                    Loans.Status := Loans.Status::Open;
        end else begin
            if Loans.Status = Loans.Status::Approved then
                Loans.Status := Loans.Status::Archived
            else
                if Loans.Status = Loans.Status::Archived then
                    Loans.Status := Loans.Status::Approved;
        end;
        Loans.Modify(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostLoanRecovery(var RecoveryHeader: Record "Loan Recovery Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeSendLoanForApproval(Loans: Record Loans)
    begin
    end;


    [IntegrationEvent(false, false)]
    procedure OnAfterAcceptCollateral(CollateralApplication: Record "Collateral Application")
    begin
    end;


    [IntegrationEvent(false, false)]
    procedure OnBeforePostLoan(var LoanNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterPostLoan(var LoanNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterPostLoanDisbursement(var LoanDisbursement: Record "Loan Disbursement")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterPostLoanRestructure(var LoanRestructure: Record "Loan Moratorium")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterPostLoanPenalty(var Loans: Record Loans; PostingAmount: Decimal)
    begin
    end;
}
