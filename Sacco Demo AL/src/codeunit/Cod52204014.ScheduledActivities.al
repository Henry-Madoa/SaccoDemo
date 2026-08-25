codeunit 52204014 "Scheduled Activities"
{
    var
        EntranceFeeRecovery: Report "Entrance Fee Recovery";
        TransferShares: Report "Share Capital Transfer";
        RecoverMobiLoansRep: Report "Mobi Loans Recovery";
        MobiLoanReminder: Report "Mobi Loans Reminder";
        UpdateMemberStatus: Report "Update Member Status";
        RunStandingOrders: Report "Run Standing Orders";
        MemberManagement: Codeunit "Member Management";
        FixedDepositMgt: Codeunit "Fixed Deposit Mgt.";
        FOSAManagement: Codeunit "FOSA Management";

    trigger OnRun()
    begin
        ExecuteFunctions;
    end;

    procedure RecoverEntranceFee()
    begin
        EntranceFeeRecovery.Run();
    end;

    procedure TransferShareCapital()
    begin
        TransferShares.Run();
    end;

    procedure RecoverMobileLoans()
    begin
        RecoverMobiLoansRep.Run();
    end;

    procedure SendMobileLoanReminders()
    begin
        MobiLoanReminder.Run();
    end;

    procedure UpdateStatus()
    begin
        UpdateMemberStatus.Run;
    end;

    procedure RunStandingOrders_fn()
    begin
        RunStandingOrders.Run;
    end;

    procedure MemberWithdrawalNotifications_fn()
    begin
        MemberManagement.MemberWithdrawalNotifications;
    end;

    procedure FDMaturityNotifications_fn()
    begin
        FixedDepositMgt.UpdateFDMaturity;
        FixedDepositMgt.FDMaturityNotifications;
    end;

    procedure UpdateCheque_fn()
    begin
        FOSAManagement.UpdateCheque;
    end;

    procedure MemberBirthdayNotifications_fn()
    begin
        MemberManagement.MemberBirthdayNotification;
    end;

    procedure ExecuteFunctions() response: Text
    var
        Integrations: Codeunit "Channels Integrations";
        B2BPosting: Codeunit "Coop B2B Integration";
        ATMIntegrations: Codeunit "ATM Integration";
        STime, ETime : Time;
        ObjLoansMgt: Codeunit "Loans Management";
        LoansApps: Record Loans;
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get;
        Evaluate(STime, '00:00:00');
        Evaluate(ETime, '01:00:00');
        if ((Time > STime) and (Time < ETime)) then begin
            if GeneralLedgerSetup."Next Run Time" < CurrentDateTime then begin
                // SendMobileLoanReminders;
                // Commit;
                // RecoverMobileLoans;
                // Commit;
                UpdatePostingDates;
                Commit;
                GenerateDailyLoanAging;
                Commit;
                RecoverEntranceFee;
                Commit;
                // TransferShareCapital;
                // Commit;
                RunStandingOrders_fn;
                Commit;
                MemberWithdrawalNotifications_fn;
                Commit;
                FDMaturityNotifications_fn;
                Commit;
                UpdateStatus;
                Commit;
                UpdateCheque_fn;
                Commit;
                GeneralLedgerSetup."Next Run Time" := CreateDateTime(CalcDate('1D', Today), Time);
                GeneralLedgerSetup.Modify;
            end;
        end;
        Integrations.PostChannelTransactions;
        Commit;
        // Integrations.PostPesalinkTransactions;
        // Commit;
        ATMIntegrations.PostATMTransactions;
        Commit;
        ATMIntegrations.PostATMReversals;
        Commit;
        B2BPosting.PostCoopB2BTransaction;
        Commit;
        B2BPosting.PostIPNTransactions();
        Commit;
        LoanPostingCheckup;
        Commit;
    end;

    procedure MembersEStatements()
    var
        Members: Record Members;
        ChannelIntegration: Codeunit "Channels Integrations";
        StartDate: Date;
        EndDate: Date;
        ResponseCode: Code[20];
        ResponseMessage: BigText;
    begin
        Members.Reset();
        Members.SetRange("E-Statement", true);
        Members.SetFilter("E-Statement Next Date", '<=%1', WorkDate);
        Members.SetFilter("E-Mail", '<>%1', '');
        if Members.FindSet then begin
            repeat
                StartDate := CalcDate('-' + Format(Members."E-Statement Period") + '-CM', WorkDate);
                EndDate := CalcDate('-1M+CM', WorkDate);
                ChannelIntegration.EmailFullStatement(Members."No.", StartDate, EndDate, ResponseCode, ResponseMessage);
                Members."E-Statement Next Date" := CalcDate(Members."E-Statement Period", WorkDate);
                Members.Modify(true);
            until Members.Next = 0;
        end;
    end;

    local procedure LoanPostingCheckup()
    var
        Loans: Record Loans;
        LoanMgmt: Codeunit "Loans Management";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
    begin
        Loans.Reset();
        Loans.SetRange(Posted, true);
        Loans.SetRange("Loan Account", '');
        if Loans.FindSet then begin
            repeat
                DetailedVendorLedgEntry.Reset();
                DetailedVendorLedgEntry.SetRange("Document No.", Loans."No.");
                DetailedVendorLedgEntry.SetRange("Member No.", Loans."Member No.");
                DetailedVendorLedgEntry.SetRange("Loan No.", Loans."No.");
                DetailedVendorLedgEntry.SetRange("Sacco Transaction Type", DetailedVendorLedgEntry."Sacco Transaction Type"::"Loan Disbursal");
                if DetailedVendorLedgEntry.FindFirst() then begin
                    Loans."Posting Date" := DetailedVendorLedgEntry."Posting Date";
                    Loans."Loan Account" := LoanMgmt.CreateLoanAccounts(Loans);
                    Loans."Application Status" := Loans."Application Status"::Disbursed;
                    Loans.Posted := true;
                    Loans."Appraisal Commited" := true;
                    Loans.Modify(true);
                end
            until Loans.Next = 0;
        end;
    end;

    local procedure UpdatePostingDates()
    var
        UserSetup: Record "User Setup";
    begin
        UserSetup.Reset();
        UserSetup.SetRange("Is System Admin", false);
        if UserSetup.FindSet then begin
            repeat
                UserSetup."Allow Posting From" := WorkDate;
                UserSetup."Allow Posting To" := WorkDate;
                UserSetup.Modify(true);
            until UserSetup.Next = 0;
        end;
    end;

    local procedure GenerateDailyLoanAging()
    var
        LoansManagement: Codeunit "Loans Management";
        Loans: Record Loans;
    begin
        Loans.Reset;
        Loans.SetFilter(Category, '<>%1&<>%2', Loans.Category::HR, Loans.Category::DEBT);
        Loans.SetRange("Skip Aging", false);
        if Loans.FindSet then begin
            repeat
                LoansManagement.ClassifyLoan(Loans."No.", WorkDate);
            until Loans.Next = 0;
        end;
    end;
}
