report 52204052 "Mobi Loans Recovery"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    ProcessingOnly = true;
    UseRequestPage = true;

    dataset
    {
        dataitem(Members; Members)
        {
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            var
                SMSSource: Code[20];
                DueDate, DueDateMinus7 : Date;
                Loans: Record Loans;
                MemberNo: Code[20];
                SMSMessage, SMSNo : text;
                SMSSend: Codeunit "Notifications Management";
                NonWithdrawableDeposits, PrincipalPaid, InterestPaid : Decimal;
                LoansMgt: Codeunit "Loans Management";
                PostingDate: Date;
                NonWithdrawableDepositAccount, WithdrawableDepositsAccount, JournalBatch, JournalTemplate, DocumentNo, Dim1, Dim2, SourceCode, ReasonCode, ExternalDocumentNo : Code[20];
                LineNo: Integer;
                JournalManagement: Codeunit "Journal Management";
                MemberMgt: Codeunit "Member Management";
                MobiloanBlock: Record "Channel Loan Blocking";
                PostingDescription: Text[100];
                GlobalTransactionType: Enum "Sacco Transaction Type";
                GlobalAccountType: Enum "Gen. Journal Account Type";
                ProductPostingType: Enum "Product Posting Type";
                GlobalTaskType: Option "Loan SMS","Share Transfer","Entrance Fee","Loan Recovery";
                NotificationsMGT: Codeunit "Notifications Management";
                Vendor: Record Vendor;
                LoanBalance, WithdrawableDeposits, PrincipalBalance, InterestBalance : Decimal;
                InterestRecovered: array[10] of Decimal;
                PrincipalRecovered: array[10] of Decimal;
                AmountRecovered: Decimal;
                SaccoProducts: Record "Sacco Products";
                GLEntry: Record "G/L Entry";
            begin
                SMSSource := 'LOAN_RECOVERY';
                Loans.Reset();
                Loans.SetFilter("Loan Balance", '>0');
                Loans.SetRange("Mobile Loan", true);
                Loans.SetFilter("Repayment End Date", '<%1', Today);
                Loans.SetRange("Member No.", Members."No.");
                if Loans.FindSet() then begin
                    repeat
                        MemberNo := '';
                        MemberNo := Loans."Member No.";
                        PrincipalBalance := 0;
                        InterestBalance := 0;
                        LoanBalance := 0;
                        AmountRecovered := 0;
                        WithdrawableDeposits := 0;
                        NonWithdrawableDeposits := 0;
                        Clear(InterestRecovered);
                        Clear(PrincipalRecovered);
                        Loans.CalcFields("Principal Balance", "Loan Balance", "Interest Balance");
                        LoanBalance := Loans."Loan Balance";
                        InterestBalance := Loans."Interest Balance";
                        PrincipalBalance := Loans."Principal Balance";
                        WithdrawableDepositsAccount := MemberMgt.GetMemberAccount(MemberNo, ProductPostingType::"Withdrawable Deposit");
                        WithdrawableDeposits := LoansMgt.GetMemberAvailableBalance(MemberNo);
                        NonWithdrawableDepositAccount := MemberMgt.GetMemberAccount(MemberNo, ProductPostingType::"Non Withdrawable Deposit");
                        NonWithdrawableDeposits := LoansMgt.GetMemberDeposits(MemberNo);
                        //Recover From Withdrawable Deposits
                        if WithdrawableDeposits > 0 then begin
                            if InterestBalance <= WithdrawableDeposits then begin
                                InterestRecovered[1] := InterestBalance;
                                WithdrawableDeposits -= InterestBalance;
                                InterestBalance := 0;
                                if PrincipalBalance <= WithdrawableDeposits then begin
                                    PrincipalRecovered[1] := PrincipalBalance;
                                    WithdrawableDeposits -= PrincipalBalance;
                                    PrincipalBalance := 0;
                                end
                                else begin
                                    PrincipalRecovered[1] := WithdrawableDeposits;
                                    PrincipalBalance -= WithdrawableDeposits;
                                end;
                            end
                            else begin
                                InterestRecovered[1] := WithdrawableDeposits;
                                NonWithdrawableDeposits -= WithdrawableDeposits;
                            end;
                        end;
                        //Recover From Deposits
                        if NonWithdrawableDeposits > 0 then begin
                            if InterestBalance <= NonWithdrawableDeposits then begin
                                InterestRecovered[2] := InterestBalance;
                                NonWithdrawableDeposits -= InterestBalance;
                                InterestBalance := 0;
                                if PrincipalBalance <= NonWithdrawableDeposits then begin
                                    PrincipalRecovered[2] := PrincipalBalance;
                                    NonWithdrawableDeposits -= PrincipalBalance;
                                    PrincipalBalance := 0;
                                end
                                else begin
                                    PrincipalRecovered[2] := NonWithdrawableDeposits;
                                    PrincipalBalance -= NonWithdrawableDeposits;
                                end;
                            end
                            else begin
                                InterestRecovered[2] := NonWithdrawableDeposits;
                            end;
                        end;
                        MemberNo := '';
                        MemberNo := Loans."Member No.";
                        SMSNo := Members."Mobile Phone No.";
                        DocumentNo := Format(Today);
                        JournalBatch := 'M-REC';
                        JournalTemplate := 'GENERAL';
                        LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
                        PostingDate := WorkDate;
                        ReasonCode := Loans."No.";
                        SourceCode := Loans."Product Code";
                        //Post Interest
                        PostingDescription := 'Interest Paid';
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, Loans."Loan Account", PostingDate, PostingDescription, -1 * InterestRecovered[1], Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, Loans."Loan Account", PostingDate, PostingDescription, -1 * InterestRecovered[2], Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Interest Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                        PostingDescription := 'Principal Paid';
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, Loans."Loan Account", PostingDate, PostingDescription, -1 * PrincipalRecovered[1], Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Principal Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, Loans."Loan Account", PostingDate, PostingDescription, -1 * PrincipalRecovered[2], Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Principal Paid", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                        PostingDescription := 'Mobile Loan Recovered';
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, WithdrawableDepositsAccount, PostingDate, PostingDescription, InterestRecovered[1] + PrincipalRecovered[1], Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::General, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, NonWithdrawableDepositAccount, PostingDate, PostingDescription, InterestRecovered[2] + PrincipalRecovered[2], Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::General, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                        JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
                        GLEntry.Reset();
                        GLEntry.SetRange("Document No.", DocumentNo);
                        GLEntry.SetRange("Document Date", PostingDate);
                        if GLEntry.FindFirst() then begin
                            AmountRecovered := 0;
                            AmountRecovered := InterestRecovered[1] + InterestRecovered[2];
                            AmountRecovered += PrincipalRecovered[1] + PrincipalRecovered[2];
                            MobiloanBlock.Reset();
                            MobiloanBlock.SetRange("Member No", MemberNo);
                            MobiloanBlock.SetRange("Product Code", Loans."Product Code");
                            if MobiloanBlock.IsEmpty then begin
                                MobiloanBlock.Init();
                                MobiloanBlock."Member No" := MemberNo;
                                MobiloanBlock.Validate("Product Code", Loans."Product Code");
                                MobiloanBlock.Insert();
                            end;
                            SMSSource := 'LOAN_REC_AUTO';
                            SMSMessage := '';
                            SMSMessage := 'Dear ' + Members."First Name" + ' your ' + Loans."Product Description" + ' of KSh. ' + Format(AmountRecovered) + ' due on ' + Format(Loans."Repayment End Date") + ' has been recovered from your Savings';
                            if Abs(AmountRecovered) <> 0 then SMSSend.SendSms(SMSNo, SMSMessage, SMSSource);
                        end;
                    until Loans.Next() = 0;
                end;
            end;
        }
    }
}
