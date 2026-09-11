report 52204000 "Post Payroll"
{
    ProcessingOnly = true;

    requestpage
    {
        layout
        {
            area(content)
            {
                field("Payroll Period"; SelectedPeriod)
                {
                    //TableRelation = "Payroll Periods"."Start Date" where(Closed = const(true));
                    TableRelation = "Payroll Periods"."Start Date";
                    ApplicationArea = Basic, Suite;
                }
                field("Posting Date"; PostingDate)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        if PostingDate = 0D then
            Error('You must specify the posting date');

        GeneralLedgerSetup.Get;
        PayrollVitalSetup.Get;
        JournalTemplate := GeneralLedgerSetup."Payroll Template";
        JournalBatch := GeneralLedgerSetup."Payroll Batch";
        HumanResourceMgmt.DeleteGeneralJournalLines(JournalTemplate, JournalBatch);
        HumanResourceMgmt.CreateGeneralJournalBatch(JournalTemplate, JournalBatch, true);
        CurrentBudget := GeneralLedgerSetup."Current Budget";
        LineNo := 1;

        //Generate None SACCO Transactions
        PayrollPeriodTransaction[1].Reset;
        PayrollPeriodTransaction[1].SetRange("Payroll Period", SelectedPeriod);
        PayrollPeriodTransaction[1].SetRange("Post To Journal", true);
        PayrollPeriodTransaction[1].SetFilter("Coop Parameters", '%1|%2', PayrollPeriodTransaction[1]."Coop Parameters"::none, PayrollPeriodTransaction[1]."Coop Parameters"::NSSF);
        if PayrollPeriodTransaction[1].FindFirst then begin
            repeat
                DebitAccount := '';
                AccountToCredit := '';
                Employee.Get(PayrollPeriodTransaction[1]."Employee Code");
                Employee.TestField("Employee Posting Group");
                Dim1 := Employee."Global Dimension 1 Code";
                Dim2 := Employee."Global Dimension 2 Code";
                LineNo += 1;
                PostingAmount := PayrollPeriodTransaction[1].Amount;

                if EmployeePostingGroup.Get(Employee."Employee Posting Group") then begin
                    EmployeePostingGroup.TestField("Salary Expense Account");
                    EmployeePostingGroup.TestField("Net Payable Account");
                    EmployeePostingGroup.TestField("SHIF Account");
                    EmployeePostingGroup.TestField("NSSF Employee");
                    if PayrollPeriodTransaction[1]."Transaction Code" = 'BPAY' then begin
                        DebitAccount := EmployeePostingGroup."Salary Expense Account";
                    end;

                    if PayrollPeriodTransaction[1]."Transaction Code" = 'PAYE' then begin
                        AccountToCredit := EmployeePostingGroup."PAYE Payable Account";
                    end;
                    if PayrollPeriodTransaction[1]."Transaction Code" = 'SHIF' then begin
                        AccountToCredit := EmployeePostingGroup."SHIF Account";
                    end;
                    if PayrollPeriodTransaction[1]."Transaction Code" = 'NSSF' then begin
                        AccountToCredit := EmployeePostingGroup."NSSF Employee";
                    end;
                end;
                if ((PayrollPeriodTransaction[1]."Transaction Type" = PayrollPeriodTransaction[1]."Transaction Type"::Income) and ((PayrollPeriodTransaction[1]."Transaction Code" <> 'BPAY') and (PayrollPeriodTransaction[1]."Transaction Code" <> 'NPAY') and (PayrollPeriodTransaction[1]."Transaction Code" <> 'PAYE') and (PayrollPeriodTransaction[1]."Transaction Code" <> 'SHIF') and (PayrollPeriodTransaction[1]."Transaction Code" <> 'NSSF') and (PayrollPeriodTransaction[1]."Transaction Code" <> 'NHF'))) then begin
                    DebitAccount := PayrollPeriodTransaction[1]."Journal Account Code";
                end;
                if PayrollPeriodTransaction[1]."Transaction Type" in [PayrollPeriodTransaction[1]."Transaction Type"::Deduction] or (PayrollPeriodTransaction[1]."Transaction Code" = 'NHF') then begin
                    AccountToCredit := PayrollPeriodTransaction[1]."Journal Account Code";
                end;
                if PayrollPeriodTransaction[1]."Transaction Code" = 'NPAY' then begin
                    AccountToCredit := Employee."FOSA Account";
                    OnCreateGnlJournalLineBalanced(JournalTemplate, JournalBatch, Format(SelectedPeriod, 0, '<Month text>-<Year4>'), LineNo, PayrollPeriodTransaction[1].Subledger, DebitAccount, PostingDate, Format(PayrollPeriodTransaction[1]."Transaction Name") + '-' + Format(SelectedPeriod, 0, '<Month text>-<Year4>'), GenJournalLine."Account Type"::Vendor, AccountToCredit, PostingAmount, Dim1, Dim2, '', GenJournalLine."Applies-to Doc. Type"::" ", '', '', 0, '', '', '', GenJournalLine."Transaction Type"::General);
                    LineNo += 1;
                    LineNo := JournalManagement.AddCharges(PayrollVitalSetup."Salary Charge", AccountToCredit, PostingAmount, LineNo, Format(SelectedPeriod, 0, '<Month text>-<Year4>'), Employee."Member No.", '', '', '', JournalBatch, JournalTemplate, Dim1, Dim2, PostingDate, true);
                end else
                    OnCreateGnlJournalLineBalanced(JournalTemplate, JournalBatch, Format(SelectedPeriod, 0, '<Month text>-<Year4>'), LineNo, PayrollPeriodTransaction[1].Subledger, DebitAccount, PostingDate, Format(PayrollPeriodTransaction[1]."Transaction Name") + ' - ' + Format(SelectedPeriod, 0, '<Month text>-<Year4>'), GenJournalLine."Account Type"::"G/L Account", AccountToCredit, PostingAmount, Dim1, Dim2, '', GenJournalLine."Applies-to Doc. Type"::" ", '', '', 0, '', '', '', GenJournalLine."Transaction Type"::General);

            until PayrollPeriodTransaction[1].Next = 0;
        end;
        //Generate SACCO Transactions
        PayrollPeriodTransaction[2].Reset;
        PayrollPeriodTransaction[2].SetRange("Payroll Period", SelectedPeriod);
        PayrollPeriodTransaction[2].SetRange("Post To Journal", true);
        PayrollPeriodTransaction[2].Setfilter("Coop Parameters", '%1|%2|%3', PayrollPeriodTransaction[2]."Coop Parameters"::loan, PayrollPeriodTransaction[2]."Coop Parameters"::"loan Interest", PayrollPeriodTransaction[2]."Coop Parameters"::shares);
        if PayrollPeriodTransaction[2].FindSet then begin
            repeat
                DebitAccount := '';
                AccountToCredit := '';
                ShareCreditAccount := '';
                LoanCreditAccount := '';
                LineNo += 1;
                Employee.Get(PayrollPeriodTransaction[2]."Employee Code");
                Employee.TestField("Employee Posting Group");
                Dim1 := Employee."Global Dimension 1 Code";
                Dim2 := Employee."Global Dimension 2 Code";
                if PayrollPeriodTransaction[2]."Coop Parameters" = PayrollPeriodTransaction[2]."Coop Parameters"::loan then begin
                    if Loans.Get(PayrollPeriodTransaction[2]."Loan Number") then begin
                        Loans.CalcFields("Principal Balance", "Interest Balance", "Loan Balance");
                        LoanCreditAccount := Loans."Loan Account";
                        AccountToCredit := LoanCreditAccount;
                        BaseAmount := 0;
                        InterestPaid := 0;
                        PrincipalPaid := 0;
                        InterestBalance := 0;
                        UnAllocatedAmount := 0;

                        BaseAmount := Round(PayrollPeriodTransaction[2].Amount);
                        InterestBalance := Round(Loans."Interest Balance");
                        PrincipalBalance := Round(Loans."Principal Balance");

                        if InterestBalance < 0 then
                            InterestBalance := 0;
                        if PrincipalBalance < 0 then
                            PrincipalBalance := 0;
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
                        if BaseAmount <> 0 then
                            UnAllocatedAmount := BaseAmount;
                        OnCreateGnlJournalLineBalanced(JournalTemplate, JournalBatch, Format(SelectedPeriod, 0, '<Month text>-<Year4>'), LineNo, GenJournalLine."Account Type"::"G/L Account", DebitAccount, PostingDate, Format(PayrollPeriodTransaction[2]."Transaction Name") + ' - ' + Format(SelectedPeriod, 0, '<Month text>-<Year4>') + '- Principal Paid', GenJournalLine."Account Type"::Vendor, AccountToCredit, PrincipalPaid, Employee."Global Dimension 1 Code", Employee."Global Dimension 2 Code", '', GenJournalLine."Applies-to Doc. Type"::" ", '', '', 0, '', PayrollPeriodTransaction[2]."Loan Number", Employee."Member No.", GenJournalLine."Transaction Type"::"Principal Paid");
                        LineNo := LineNo + 1;
                        OnCreateGnlJournalLineBalanced(JournalTemplate, JournalBatch, Format(SelectedPeriod, 0, '<Month text>-<Year4>'), LineNo, GenJournalLine."Account Type"::"G/L Account", DebitAccount, PostingDate, Format(PayrollPeriodTransaction[2]."Transaction Name") + ' - ' + Format(SelectedPeriod, 0, '<Month text>-<Year4>') + '- Interest Paid', GenJournalLine."Account Type"::Vendor, AccountToCredit, InterestPaid, Employee."Global Dimension 1 Code", Employee."Global Dimension 2 Code", '', GenJournalLine."Applies-to Doc. Type"::" ", '', '', 0, '', PayrollPeriodTransaction[2]."Loan Number", Employee."Member No.", GenJournalLine."Transaction Type"::"Interest Paid");
                        LineNo := LineNo + 1;
                        AccountToCredit := MemberManagement.GetMemberAccount(Loans."Member No.", ProductPostingType::"Withdrawable Deposit");
                        OnCreateGnlJournalLineBalanced(JournalTemplate, JournalBatch, Format(SelectedPeriod, 0, '<Month text>-<Year4>'), LineNo, GenJournalLine."Account Type"::"G/L Account", DebitAccount, PostingDate, Format(PayrollPeriodTransaction[2]."Transaction Name") + ' - ' + Format(SelectedPeriod, 0, '<Month text>-<Year4>') + '- Unallocated', GenJournalLine."Account Type"::Vendor, AccountToCredit, UnallocatedAmount, Employee."Global Dimension 1 Code", Employee."Global Dimension 2 Code", '', GenJournalLine."Applies-to Doc. Type"::" ", '', '', 0, '', PayrollPeriodTransaction[2]."Loan Number", Employee."Member No.", GenJournalLine."Transaction Type"::"Acc. Transfer");
                    end;
                end;
                if PayrollPeriodTransaction[2]."Coop Parameters" = PayrollPeriodTransaction[2]."Coop Parameters"::"loan Interest" then begin
                    AccountToCredit := LoanCreditAccount;
                    OnCreateGnlJournalLineBalanced(JournalTemplate, JournalBatch, Format(SelectedPeriod, 0, '<Month text>-<Year4>'), LineNo, GenJournalLine."Account Type"::"G/L Account", DebitAccount, PostingDate, Format(PayrollPeriodTransaction[2]."Transaction Name") + ' - ' + Format(SelectedPeriod, 0, '<Month text>-<Year4>'), GenJournalLine."Account Type"::Vendor, AccountToCredit, PayrollPeriodTransaction[2].Amount, Employee."Global Dimension 1 Code", Employee."Global Dimension 2 Code", '', GenJournalLine."Applies-to Doc. Type"::" ", '', '', 0, '', PayrollPeriodTransaction[2]."Loan Number", Employee."Member No.", GenJournalLine."Transaction Type"::"Interest Paid");
                end;
                if PayrollPeriodTransaction[2]."Coop Parameters" = PayrollPeriodTransaction[2]."Coop Parameters"::shares then begin
                    PayrollTransactionCode.Get(PayrollPeriodTransaction[2]."Transaction Code");
                    PayrollTransactionCode.TestField("Vendor Posting Group");
                    PayrollTransactionCode.TestField("Posting Type");
                    Vendor[1].Reset();
                    Vendor[1].SetRange("Vendor Posting Group", PayrollTransactionCode."Vendor Posting Group");
                    Vendor[1].SetRange("Member No.", Employee."Member No.");
                    if Vendor[1].FindFirst then ShareCreditAccount := Vendor[1]."No.";
                    AccountToCredit := ShareCreditAccount;
                    OnCreateGnlJournalLineBalanced(JournalTemplate, JournalBatch, Format(SelectedPeriod, 0, '<Month text>-<Year4>'), LineNo, GenJournalLine."Account Type"::"G/L Account", DebitAccount, PostingDate, Format(PayrollPeriodTransaction[2]."Transaction Name") + ' - ' + Format(SelectedPeriod, 0, '<Month text>-<Year4>'), GenJournalLine."Account Type"::Vendor, AccountToCredit, PayrollPeriodTransaction[2].Amount, Employee."Global Dimension 1 Code", Employee."Global Dimension 2 Code", '', GenJournalLine."Applies-to Doc. Type"::" ", '', '', 0, '', '', Employee."Member No.", GenJournalLine."Transaction Type"::"End Month Salary");
                end;
            until PayrollPeriodTransaction[2].Next = 0;
        end;
        //Generate EmployerTransactions
        PayrollEmployerTransaction.Reset;
        PayrollEmployerTransaction.SetRange("Payroll Period", SelectedPeriod);
        if PayrollEmployerTransaction.FindFirst then begin
            repeat
                DebitAccount := '';
                AccountToCredit := '';
                Employee.Get(PayrollEmployerTransaction."Employee Code");
                Employee.TestField("Employee Posting Group");
                Dim1 := Employee."Global Dimension 1 Code";
                Dim2 := Employee."Global Dimension 2 Code";
                LineNo := LineNo + 1;
                DebitAccount := PayrollEmployerTransaction."Account To Debit";
                AccountToCredit := PayrollEmployerTransaction."Account To Credit";
                OnCreateGnlJournalLineBalanced(JournalTemplate, JournalBatch, Format(SelectedPeriod, 0, '<Month text>-<Year4>'), LineNo, GenJournalLine."Account Type"::"G/L Account", DebitAccount, PostingDate, Format(PayrollEmployerTransaction."Transaction Name") + ' - ' + Format(SelectedPeriod, 0, '<Month text>-<Year4>'), GenJournalLine."Account Type"::"G/L Account", '', PayrollEmployerTransaction.Amount, Employee."Global Dimension 1 Code", Employee."Global Dimension 2 Code", '', GenJournalLine."Applies-to Doc. Type"::" ", '', '', 0, '', '', '', GenJournalLine."Transaction Type"::General);
                LineNo := LineNo + 1;
                OnCreateGnlJournalLineBalanced(JournalTemplate, JournalBatch, Format(SelectedPeriod, 0, '<Month text>-<Year4>'), LineNo, GenJournalLine."Account Type"::"G/L Account", '', PostingDate, Format(PayrollEmployerTransaction."Transaction Name") + ' - ' + Format(SelectedPeriod, 0, '<Month text>-<Year4>'), GenJournalLine."Account Type"::"G/L Account", AccountToCredit, PayrollEmployerTransaction.Amount, Employee."Global Dimension 1 Code", Employee."Global Dimension 2 Code", '', GenJournalLine."Applies-to Doc. Type"::" ", '', '', 0, '', '', '', GenJournalLine."Transaction Type"::General);
            until PayrollEmployerTransaction.Next = 0
        end;
        if LineNo > 1 then begin
            Message('%1 Records have been transfered to the journal', LineNo);
        end;
        if LineNo = 0 then Message('No records were transfered');
    end;

    local procedure GetInterestAmount(LoanNo: Code[20]; EmployeeNo: Code[20]; PayrollPeriodVar: Date): Decimal
    var
        PayrollPeriodTransaction: Record "Payroll Period Transaction";
    begin
        PayrollPeriodTransaction.Reset;
        PayrollPeriodTransaction.SetRange("Employee Code", EmployeeNo);
        PayrollPeriodTransaction.SetRange("Payroll Period", PayrollPeriodVar);
        PayrollPeriodTransaction.SetRange("Loan Number", LoanNo);
        PayrollPeriodTransaction.SetRange("Coop Parameters", PayrollPeriodTransaction."Coop Parameters"::"loan Interest");
        if PayrollPeriodTransaction.FindFirst then
            exit(PayrollPeriodTransaction.Amount)
        else
            exit(0);
    end;

    [IntegrationEvent(false, false)]
    procedure OnCreateGnlJournalLineBalanced(TemplateName: Text; BatchName: Text; DocumentNo: Code[30]; LineNo: Integer; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[50]; TransactionDate: Date; TransactionDescription: Text; BalancingAccountType: Enum "Gen. Journal Account Type"; BalancingAccountNo: Code[50]; TransactionAmount: Decimal; Dimension1: Code[40]; Dimension2: Code[40]; ExtDocNo: Code[20]; AppliesToDocType: Enum "Gen. Journal Document Type"; AppliesToDocNo: Code[50]; CurrencyCode: Code[20]; CurrencyFactor: Decimal; SourceNo: Code[100]; LoanNo: Code[20]; MemberNo: Code[20]; SaccoTransactionType: Enum "Sacco Transaction Type")
    begin
    end;

    var
        PayrollPeriodTransaction: array[3] of Record "Payroll Period Transaction";
        GenJournalLine: Record "Gen. Journal Line";
        HumanResourceMgmt: Codeunit "Human Resource Management";
        MemberManagement: Codeunit "Member Management";
        ProductPostingType: Enum "Product Posting Type";
        JournalManagement: Codeunit "Journal Management";
        SelectedPeriod: Date;
        JournalTemplate, JournalBatch, DebitAccount, AccountToCredit, ShareCreditAccount, LoanCreditAccount, CurrentBudget, Dim1, Dim2 : Code[50];
        LineNo: Integer;
        PostingDate: Date;
        GeneralLedgerSetup: Record "General Ledger Setup";
        EmployeePostingGroup: Record "Employee Posting Group";
        PayrollVitalSetup: Record "Payroll Vital Setup";
        Employee: Record Employee;
        Vendor: array[3] of Record Vendor;
        Loans: Record Loans;
        PayrollEmployerTransaction: Record "Payroll Employer Transaction";
        PayrollTransactionCode: Record "Payroll Transaction Code";
        PostingAmount, InterestPaid, PrincipalBalance, PrincipalPaid, BaseAmount, InterestBalance, ChargeAmount, UnallocatedAmount : Decimal;

}
