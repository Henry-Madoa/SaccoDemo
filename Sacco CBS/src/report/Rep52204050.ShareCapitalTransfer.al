report 52204050 "Share Capital Transfer"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Members; Members)
        {
            DataItemTableView = where("Date of Registration" = filter(<> ''), Status = filter(Active | Dormant));

            trigger OnAfterGetRecord()
            begin
                SharesAccount := '';
                SharesBalance := 0;
                AvailableBalance := 0;
                WithdrawableDepositAccount := '';
                MemberNo := Members."No.";
                DocumentNo := MemberNo + 'SCAP';
                ReasonCode := MemberNo;
                SourceCode := 'SHARES';
                SMSSource := 'SHARE_CAP_TRANSFER';
                GeneralLedgerSetup.Get;
                GeneralLedgerSetup.TestField("Share Capital Grace Period");
                If CalcDate(StrSubstNo('+%1', GeneralLedgerSetup."Share Capital Grace Period"), Members."Date of Registration") < WorkDate then CurrReport.Skip;
                ProductFactory.Reset();
                ProductFactory.SetRange("Product Posting Type", ProductFactory."Product Posting Type"::"Share Capital Account");
                if ProductFactory.FindFirst() then MinimumShares := ProductFactory."Minimum Balance";
                WithdrawableDepositAccount := MemberMgt.GetMemberAccount(Members."No.", ProductPostingType::"Withdrawable Deposit");
                SharesAccount := MemberMgt.GetMemberAccount(MemberNo, ProductPostingType::"Share Capital Account");
                if SharesAccount = '' then CurrReport.Skip();
                Members.CalcFields("Total Shares", "Total Withdrawable Deposits", "Uncleared Funds");
                SharesBalance := Members."Total Shares";
                AvailableBalance := Members."Total Withdrawable Deposits" - Members."Uncleared Funds" - ChannelsIntegration.GetPendingChannelsTransactions(Members."No.");
                if AvailableBalance < 0 then AvailableBalance := 0;
                if AvailableBalance = 0 then CurrReport.Skip();
                if SharesBalance >= MinimumShares then CurrReport.Skip();
                if ((SharesBalance < MinimumShares) and (SharesAccount <> '') and (AvailableBalance <> 0) and (WithdrawableDepositAccount <> '')) then begin
                    PostingAmount := MinimumShares - SharesBalance;
                    if PostingAmount > AvailableBalance then PostingAmount := AvailableBalance;
                    PostingDate := WorkDate;
                    JournalBatch := 'S-TRANS';
                    JournalTemplate := 'GENERAL';
                    LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
                    PostingDescription := 'Share Capital Transfer ' + MemberNo;
                    if PostingAmount > 0 then begin
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, WithdrawableDepositAccount, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::General, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                        LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, SharesAccount, PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::General, LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                    end;
                    JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
                    GLEntry.Reset();
                    GLEntry.SetRange("Document No.", DocumentNo);
                    GLEntry.SetRange("Document Date", PostingDate);
                    if GLEntry.FindFirst() then begin
                        SMSNo := Members."Mobile Phone No.";
                        SMSText := 'Dear ' + Members."First Name" + ' Kes. ' + Format(PostingAmount) + ' has been recovered from your deposits to share capital';
                        NotificationsManagement.SendSms(SMSNo, SMSText, SMSSource);
                    end;
                end;
            end;
        }
    }
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        MinimumShares, AvailableBalance, PostingAmount, SharesBalance : decimal;
        MemberMgt: Codeunit "Member Management";
        LoansMgt: Codeunit "Loans Management";
        WithdrawableDepositAccount: Code[20];
        PostingDate: Date;
        SMSSource, SharesAccount, JournalBatch, JournalTemplate, DocumentNo, MemberNo, Dim1, Dim2, SourceCode, ReasonCode, ExternalDocumentNo : Code[20];
        LineNo: Integer;
        JournalManagement: Codeunit "Journal Management";
        ProductFactory: Record "Sacco Products";
        SMSText, SMSNo, PostingDescription : Text[250];
        GlobalTransactionType: Enum "Sacco Transaction Type";
        GlobalAccountType: Enum "Gen. Journal Account Type";
        NotificationsManagement: Codeunit "Notifications Management";
        ProductPostingType: Enum "Product Posting Type";
        GLEntry: Record "G/L Entry";
        ChannelsIntegration: Codeunit "Channels Integrations";
}
