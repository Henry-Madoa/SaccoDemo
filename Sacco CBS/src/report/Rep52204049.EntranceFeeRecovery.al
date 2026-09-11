report 52204049 "Entrance Fee Recovery"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Members; Members)
        {
            DataItemTableView = where(Status = const("Not Paid Up"));

            trigger OnAfterGetRecord()
            begin
                If MemberCategory.Get(Category) then begin
                    MemberCategory.TestField("Registration Fee Account");
                    if (MemberCategory."Registration Fee" > 0) then begin
                        EntranceFee := MemberCategory."Registration Fee";
                        MemberNo := '';
                        DepositAccount := '';
                        DepositBalance := 0;
                        MemberNo := Members."No.";
                        DepositAccount := MemberMgt.GetMemberAccount(MemberNo, ProductPostingType::"Non Withdrawable Deposit");
                        Vendor.Get(DepositAccount);
                        SaccoProducts.Get(Vendor."Product Code");
                        Members.CalcFields("Paid Registration");
                        Vendor.CalcFields(Balance, "Uncleared Funds");
                        AvailableBalance := Vendor.Balance - Vendor."Uncleared Funds" - SaccoProducts."Minimum Balance";
                        if AvailableBalance < 0 then
                            AvailableBalance := 0;
                        if ((DepositAccount <> '') and (EntranceFee > 0) and (AvailableBalance > 0)) then begin
                            PostingAmount := EntranceFee - Members."Paid Registration";

                            if PostingAmount > AvailableBalance then
                                PostingAmount := AvailableBalance;

                            SMSNo := Members."Mobile Phone No.";
                            SMSText := 'Dear ' + Members."First Name" + ', KES ' + Format(PostingAmount) + ' has been recovered from your deposits as Registraion Fees';
                            PostingDate := WorkDate;
                            JournalBatch := 'E-FEE';
                            JournalTemplate := 'GENERAL';
                            DocumentNo := MemberNo + 'E-FEE';
                            LineNo := JournalManagement.PrepareJournal(JournalTemplate, JournalBatch);
                            PostingDescription := 'Entrance Fee Recovery ' + MemberNo;
                            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::Vendor, DepositAccount, PostingDate, PostingDescription, PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Registration Fee", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                            LineNo := JournalManagement.CreateJournalLine(GlobalAccountType::"G/L Account", MemberCategory."Registration Fee Account", PostingDate, PostingDescription, -1 * PostingAmount, Dim1, Dim2, MemberNo, DocumentNo, GlobalTransactionType::"Registration Fee", LineNo, SourceCode, ReasonCode, ExternalDocumentNo, '', 0, '', JournalTemplate, JournalBatch);
                            JournalManagement.CompletePosting(JournalTemplate, JournalBatch);
                            GLEntry.Reset();
                            GLEntry.SetRange("Document No.", DocumentNo);
                            GLEntry.SetRange("Document Date", PostingDate);
                            if GLEntry.FindFirst() then begin
                                Members.CalcFields("Paid Registration");
                                If Members."Paid Registration" = MemberCategory."Registration Fee" then begin
                                    Members."Reg. Fee Paid" := true;
                                    Members.Status := Members.Status::Active;
                                    Members.Modify();
                                end;
                                SMSSource := 'ENT_FEE_RECOVERY';
                                NotificationsMGT.SendSms(SMSNo, SMSText, SMSSource);
                            end;
                        end;
                    end;
                end;
            end;
        }
    }
    var
        SMSNo, SMSText, PostingDescription : Text[250];
        GlobalTransactionType: Enum "Sacco Transaction Type";
        GlobalAccountType: Enum "Gen. Journal Account Type";
        ProductPostingType: Enum "Product Posting Type";
        NotificationsMGT: Codeunit "Notifications Management";
        EntranceFee, DepositBalance, PostingAmount, AvailableBalance, Bookvalue : Decimal;
        MemberMgt: Codeunit "Member Management";
        LoansMgt: Codeunit "Loans Management";
        PostingDate: Date;
        DepositAccount, SMSSource, JournalBatch, JournalTemplate, DocumentNo, MemberNo, Dim1, Dim2, SourceCode, ReasonCode, ExternalDocumentNo : Code[20];
        LineNo: Integer;
        JournalManagement: Codeunit "Journal Management";
        GLEntry: Record "G/L Entry";
        MemberCategory: Record "Member Categories";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        SaccoProducts: Record "Sacco Products";
        Vendor: Record Vendor;
        ChannelsIntegrations: Codeunit "Channels Integrations";
}
