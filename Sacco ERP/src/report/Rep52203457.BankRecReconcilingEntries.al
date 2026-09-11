report 52203457 "Bank Rec-Reconciling Entries"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Bank Rec-Reconciling Entries.rdlc';

    dataset
    {
        dataitem("Bank Acc. Reconciliation"; "Bank Acc. Reconciliation")
        {
            RequestFilterFields = "Bank Account No.", "Statement No.";

            column(CashBookBalance; CashBookBalance)
            {
            }
            column(Bank_Name; Namex)
            {
            }
            column(Account_No; "A/C")
            {
            }
            column(EndTotal; EndTotal)
            {
            }
            column(BankAccountNo_BankAccReconciliation; "Bank Acc. Reconciliation"."Bank Account No.")
            {
            }
            column(StatementNo_BankAccReconciliation; "Bank Acc. Reconciliation"."Statement No.")
            {
            }
            column(StatementEndingBalance_BankAccReconciliation; "Bank Acc. Reconciliation"."Statement Ending Balance")
            {
            }
            column(StatementDate_BankAccReconciliation; "Bank Acc. Reconciliation"."Statement Date")
            {
            }
            column(BalanceLastStatement_BankAccReconciliation; "Bank Acc. Reconciliation"."Balance Last Statement")
            {
            }
            column(BankStatement_BankAccReconciliation; "Bank Acc. Reconciliation"."Bank Statement")
            {
            }
            column(TotalBalanceonBankAccount_BankAccReconciliation; "Bank Acc. Reconciliation"."Total Balance on Bank Account")
            {
            }
            column(TotalAppliedAmount_BankAccReconciliation; "Bank Acc. Reconciliation"."Total Applied Amount")
            {
            }
            column(TotalTransactionAmount_BankAccReconciliation; "Bank Acc. Reconciliation"."Total Transaction Amount")
            {
            }
            column(TotalUnpostedAppliedAmount_BankAccReconciliation; "Bank Acc. Reconciliation"."Total Unposted Applied Amount")
            {
            }
            column(TotalDifference_BankAccReconciliation; "Bank Acc. Reconciliation"."Total Difference")
            {
            }
            column(StatementType_BankAccReconciliation; "Bank Acc. Reconciliation"."Statement Type")
            {
            }
            column(ShortcutDimension1Code_BankAccReconciliation; "Bank Acc. Reconciliation"."Shortcut Dimension 1 Code")
            {
            }
            column(ShortcutDimension2Code_BankAccReconciliation; "Bank Acc. Reconciliation"."Shortcut Dimension 2 Code")
            {
            }
            column(PostPaymentsOnly_BankAccReconciliation; "Bank Acc. Reconciliation"."Post Payments Only")
            {
            }
            column(ImportPostedTransactions_BankAccReconciliation; "Bank Acc. Reconciliation"."Import Posted Transactions")
            {
            }
            column(TotalOutstdBankTransactions_BankAccReconciliation; "Bank Acc. Reconciliation"."Total Outstd Bank Transactions")
            {
            }
            column(TotalOutstdPayments_BankAccReconciliation; "Bank Acc. Reconciliation"."Total Outstd Payments")
            {
            }
            column(TotalAppliedAmountPayments_BankAccReconciliation;'"Bank Acc. Reconciliation"."Total Applied Amount Payments"')
            {
            }
            column(BankAccountBalanceLCY_BankAccReconciliation; "Bank Acc. Reconciliation"."Bank Account Balance (LCY)")
            {
            }
            column(TotalPositiveAdjustments_BankAccReconciliation; "Bank Acc. Reconciliation"."Total Positive Adjustments")
            {
            }
            column(TotalNegativeAdjustments_BankAccReconciliation; "Bank Acc. Reconciliation"."Total Negative Adjustments")
            {
            }
            column(TotalPositiveDifference_BankAccReconciliation;'"Bank Acc. Reconciliation"."Total Positive Difference"')
            {
            }
            column(TotalNegativeDifference_BankAccReconciliation;'"Bank Acc. Reconciliation"."Total Negative Difference"')
            {
            }
            column(DimensionSetID_BankAccReconciliation; "Bank Acc. Reconciliation"."Dimension Set ID")
            {
            }
            column(CreatedOn_BankAccReconciliation; "Bank Acc. Reconciliation"."Created On")
            {
            }
            column(CreatedBy_BankAccReconciliation; "Bank Acc. Reconciliation"."Created By")
            {
            }
            dataitem("Bank Acc. Reconciliation Line"; "Bank Acc. Reconciliation Line")
            {
                DataItemLink = "Bank Account No."=FIELD("Bank Account No."), "Statement No."=FIELD("Statement No.");

                column(StatementTotal; StatementTotal)
                {
                }
                column(BankAccountNo_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Bank Account No.")
                {
                }
                column(StatementNo_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Statement No.")
                {
                }
                column(StatementLineNo_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Statement Line No.")
                {
                }
                column(DocumentNo_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Document No.")
                {
                }
                column(TransactionDate_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Transaction Date")
                {
                }
                column(Description_BankAccReconciliationLine; "Bank Acc. Reconciliation Line".Description)
                {
                }
                column(StatementAmount_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Statement Amount")
                {
                }
                column(StmntAmnt; StmntAmnt)
                {
                }
                column(Difference_BankAccReconciliationLine; "Bank Acc. Reconciliation Line".Difference)
                {
                }
                column(AppliedAmount_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Applied Amount")
                {
                }
                column(Type_BankAccReconciliationLine;'"Bank Acc. Reconciliation Line".Type')
                {
                }
                column(AppliedEntries_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Applied Entries")
                {
                }
                column(ValueDate_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Value Date")
                {
                }
                column(ReadyforApplication_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Ready for Application")
                {
                }
                column(CheckNo_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Check No.")
                {
                }
                column(RelatedPartyName_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Related-Party Name")
                {
                }
                column(AdditionalTransactionInfo_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Additional Transaction Info")
                {
                }
                column(DataExchEntryNo_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Data Exch. Entry No.")
                {
                }
                column(DataExchLineNo_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Data Exch. Line No.")
                {
                }
                column(StatementType_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Statement Type")
                {
                }
                column(AccountType_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Account Type")
                {
                }
                column(AccountNo_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Account No.")
                {
                }
                column(TransactionText_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Transaction Text")
                {
                }
                column(RelatedPartyBankAccNo_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Related-Party Bank Acc. No.")
                {
                }
                column(RelatedPartyAddress_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Related-Party Address")
                {
                }
                column(RelatedPartyCity_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Related-Party City")
                {
                }
                column(ShortcutDimension1Code_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Shortcut Dimension 1 Code")
                {
                }
                column(ShortcutDimension2Code_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Shortcut Dimension 2 Code")
                {
                }
                column(MatchConfidence_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Match Confidence")
                {
                }
                column(MatchQuality_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Match Quality")
                {
                }
                column(SortingOrder_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Sorting Order")
                {
                }
                column(ParentLineNo_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Parent Line No.")
                {
                }
                column(TransactionID_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Transaction ID")
                {
                }
                column(DimensionSetID_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."Dimension Set ID")
                {
                }
                column(Reconciled_BankAccReconciliationLine; "Bank Acc. Reconciliation Line".Reconciled)
                {
                }
                column(ExternalDocumentNo_BankAccReconciliationLine; "Bank Acc. Reconciliation Line"."External Document No")
                {
                }
                column(Type; EntType)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if "Bank Account Ledger Entry".Reversed then CurrReport.Skip;
                    EntType:='';
                    if "Bank Acc. Reconciliation Line"."Statement Amount" > 0 then EntType:=UpperCase('Receipts')
                    else
                        EntType:=UpperCase('payments');
                    EndTotal-=Abs("Bank Acc. Reconciliation Line"."Statement Amount");
                    StatementTotal:=StatementTotal + Abs("Bank Acc. Reconciliation Line"."Statement Amount");
                    StmntAmnt:=Abs("Bank Acc. Reconciliation Line"."Statement Amount");
                    if "Bank Acc. Reconciliation Line"."Statement Amount" <> "Bank Acc. Reconciliation Line"."Applied Amount" then CurrReport.Skip;
                end;
            }
            dataitem("Bank Account Ledger Entry"; "Bank Account Ledger Entry")
            {
                DataItemLink = "Bank Account No."=FIELD("Bank Account No.");
                DataItemTableView = WHERE(Open=CONST(true), "Statement Status"=FILTER(Open|"Bank Acc. Entry Applied"|"Check Entry Applied"));

                column(CashBookTotal; CashBookTotal)
                {
                }
                column(EntryNo_BankAccountLedgerEntry; "Bank Account Ledger Entry"."Entry No.")
                {
                }
                column(BankAccountNo_BankAccountLedgerEntry; "Bank Account Ledger Entry"."Bank Account No.")
                {
                }
                column(PostingDate_BankAccountLedgerEntry; "Bank Account Ledger Entry"."Posting Date")
                {
                }
                column(DocumentType_BankAccountLedgerEntry; "Bank Account Ledger Entry"."Document Type")
                {
                }
                column(DocumentNo_BankAccountLedgerEntry; "Bank Account Ledger Entry"."Document No.")
                {
                }
                column(Description_BankAccountLedgerEntry; "Bank Account Ledger Entry".Description)
                {
                }
                column(CurrencyCode_BankAccountLedgerEntry; "Bank Account Ledger Entry"."Currency Code")
                {
                }
                column(Amount_BankAccountLedgerEntry; "Bank Account Ledger Entry".Amount)
                {
                }
                column(RemainingAmount_BankAccountLedgerEntry; "Bank Account Ledger Entry"."Remaining Amount")
                {
                }
                column(Type1; EntType1)
                {
                }
                column(LegerAmnt; LegerAmnt)
                {
                }
                column(ExternalDocumentNo_BankAccountLedgerEntry; "Bank Account Ledger Entry"."External Document No.")
                {
                }
                column(AppliedAmount; AppliedAmount)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    EntType1:='';
                    if "Bank Account Ledger Entry".Amount > 0 then EntType1:=UpperCase('Uncredited Cheques')
                    else
                        EntType1:=UpperCase('Unpresented Cheques');
                    EndTotal+=Abs("Bank Account Ledger Entry".Amount);
                    CashBookTotal:=CashBookTotal + Abs("Bank Account Ledger Entry".Amount);
                    LegerAmnt:=Abs("Bank Account Ledger Entry".Amount);
                    AppliedAmount:=0;
                    if BankAccReconciliationLine.Get(BankAccReconciliationLine."Statement Type"::"Bank Reconciliation", "Bank Account Ledger Entry"."Bank Account No.", "Bank Account Ledger Entry"."Statement No.", "Bank Account Ledger Entry"."Statement Line No.")then AppliedAmount:=BankAccReconciliationLine."Applied Amount";
                    if AppliedAmount <> "Bank Account Ledger Entry".Amount then CurrReport.Skip;
                end;
                trigger OnPreDataItem()
                begin
                    "Bank Account Ledger Entry".SetFilter("Posting Date", '..%1', "Bank Acc. Reconciliation"."Statement Date");
                end;
            }
            trigger OnAfterGetRecord()
            begin
                Namex:='';
                "A/C":='';
                if BankAccount.Get("Bank Acc. Reconciliation"."Bank Account No.")then begin
                    Namex:=BankAccount.Name;
                    "A/C":=BankAccount."Bank Account No.";
                end;
                CashBookBalance:=0;
                EndTotal:=0;
                StatementTotal:=0;
                CashBookTotal:=0;
                EndTotal:="Bank Acc. Reconciliation"."Statement Ending Balance";
                BankAccountLedgerEntry.Reset;
                BankAccountLedgerEntry.SetFilter("Posting Date", '..%1', "Bank Acc. Reconciliation"."Statement Date");
                BankAccountLedgerEntry.SetRange("Bank Account No.", "Bank Acc. Reconciliation"."Bank Account No.");
                if BankAccountLedgerEntry.FindSet then begin
                    BankAccountLedgerEntry.CalcSums(Amount);
                    CashBookBalance:=BankAccountLedgerEntry.Amount;
                end;
            end;
        }
    }
    var EntType: Text[20];
    EntType1: Text[20];
    BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
    CashBookBalance: Decimal;
    EndTotal: Decimal;
    StatementTotal: Decimal;
    CashBookTotal: Decimal;
    StmntAmnt: Decimal;
    LegerAmnt: Decimal;
    AppliedAmount: Decimal;
    BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
    Namex: Text[50];
    BankAccount: Record "Bank Account";
    "A/C": Text;
}
