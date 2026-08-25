report 52204060 "Dividend Slipt"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/DividendSlipt.rdlc';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("Dividend Header"; "Dividend Header")
        {
            RequestFilterFields = "Dividend Year";

            column(Logo; CompanyInformation.Picture)
            {
            }
            column(City; CompanyInformation.City)
            {
            }
            column(Address2; CompanyInformation."Address 2")
            {
            }
            column(Address; CompanyInformation.Address)
            {
            }
            column(Name; CompanyInformation.Name)
            {
            }
            column(DividendCode_DividendHeader; "Dividend Header"."No.")
            {
            }
            column(Description_DividendHeader; "Dividend Header".Description)
            {
            }
            column(StartDate_DividendHeader; "Dividend Header"."Start Date")
            {
            }
            column(EndDate_DividendHeader; "Dividend Header"."End Date")
            {
            }
            column(CreatedBy_DividendHeader; "Dividend Header"."Created By")
            {
            }
            column(CreatedOn_DividendHeader; "Dividend Header"."Created On")
            {
            }
            column(LastUpdatedBy_DividendHeader; "Dividend Header"."Last Updated By")
            {
            }
            column(LastUpdatedOn_DividendHeader; "Dividend Header"."Last Updated On")
            {
            }
            column(CurrentStatus_DividendHeader; "Dividend Header"."Current Status")
            {
            }
            column(TransactionCode_DividendHeader; "Dividend Header"."Transaction Code")
            {
            }
            column(DebitAccount_DividendHeader; "Dividend Header"."Expense Account No.")
            {
            }
            column(CreditAccount_DividendHeader; "Dividend Header"."Payable Account No.")
            {
            }
            column(BoostShares_DividendHeader; "Dividend Header"."Boost Shares")
            {
            }
            column(RecoverLoans_DividendHeader; "Dividend Header"."Recover Loans")
            {
            }
            column(PostingType_DividendHeader; "Dividend Header"."Posting Type")
            {
            }
            column(PostingDescription_DividendHeader; "Dividend Header"."Posting Description")
            {
            }
            column(Posted_DividendHeader; "Dividend Header".Posted)
            {
            }
            column(PostedOn_DividendHeader; "Dividend Header"."Posted On")
            {
            }
            column(PostedBy_DividendHeader; "Dividend Header"."Posted By")
            {
            }
            column(TotalAmount_DividendHeader; "Dividend Header"."Total Net Amount")
            {
            }
            column(PostingDate_DividendHeader; "Dividend Header"."Posting Date")
            {
            }
            column(Scheduled_DividendHeader; "Dividend Header".Scheduled)
            {
            }
            column(NextRunDate_DividendHeader; "Dividend Header"."Next Run Date")
            {
            }
            column(MemberBalances_DividendHeader; "Dividend Header"."Member Balances")
            {
            }
            dataitem("Dividend Lines."; "Dividend Lines")
            {
                DataItemLink = "Dividend Code" = FIELD("No.");
                RequestFilterFields = "Member No.";

                column(DividendCode_DividendLines; "Dividend Lines."."Dividend Code")
                {
                }
                column(MemberNo_DividendLines; "Dividend Lines."."Member No.")
                {
                }
                column(MemberName_DividendLines; "Dividend Lines."."Member Name")
                {
                }
                column(AmountEarned_DividendLines; "Dividend Lines."."Automatic Amount Earned")
                {
                }
                column(Posted_DividendLines; "Dividend Lines.".Posted)
                {
                }
                column(AccountType_DividendLines; "Dividend Lines."."Account Type")
                {
                }
                column(AccountNo_DividendLines; "Dividend Lines."."Account No")
                {
                }
                column(Recoveries_DividendLines; "Dividend Lines."."Total Recoveries")
                {
                }
                column(NetAmount_DividendLines; "Dividend Lines."."Net Amount")
                {
                }
                column(SavingsAccount_DividendLines; "Dividend Lines."."Savings Account")
                {
                }
                column(HasAdvance_DividendLines; "Dividend Lines."."Has Advance")
                {
                }
                dataitem("Dividend Recoveries"; "Dividend Recoveries")
                {
                    DataItemLink = "Dividend Code" = FIELD("Dividend Code"), "Member No" = FIELD("Member No."), "Account No." = FIELD("Account No");
                    DataItemTableView = SORTING("Dividend Code", "Entry Type", "Recovery Code", "Member No", "Account No.") ORDER(Ascending);

                    column(DividendCode_DividendRecoveries; "Dividend Recoveries"."Dividend Code")
                    {
                    }
                    column(EntryType_DividendRecoveries; "Dividend Recoveries"."Entry Type")
                    {
                    }
                    column(Code_DividendRecoveries; "Dividend Recoveries"."Recovery Code")
                    {
                    }
                    column(MemberNo_DividendRecoveries; "Dividend Recoveries"."Member No")
                    {
                    }
                    column(Description_DividendRecoveries; "Dividend Recoveries".Description)
                    {
                    }
                    column(MemberName_DividendRecoveries; "Dividend Recoveries"."Member Name")
                    {
                    }
                    column(Amount_DividendRecoveries; "Dividend Recoveries".Amount)
                    {
                    }
                    column(AccountNo_DividendRecoveries; "Dividend Recoveries"."Account No.")
                    {
                    }
                    column(LoanType_DividendRecoveries; '')
                    {
                    }
                }
                dataitem("Dividend Det. Entries"; "Dividend Det. Entries")
                {
                    DataItemLink = "Dividend Code" = FIELD("Dividend Code"), "Member No." = FIELD("Member No."), "Account Type" = FIELD("Account Type");

                    column(DividendCode_DividendDetEntries; "Dividend Det. Entries"."Dividend Code")
                    {
                    }
                    column(MemberNo_DividendDetEntries; "Dividend Det. Entries"."Member No.")
                    {
                    }
                    column(EntryType_DividendDetEntries; "Dividend Det. Entries"."Entry Type")
                    {
                    }
                    column(Code_DividendDetEntries; "Dividend Det. Entries".Code)
                    {
                    }
                    column(Description_DividendDetEntries; "Dividend Det. Entries".Description)
                    {
                    }
                    column(Amount_DividendDetEntries; "Dividend Det. Entries".Amount)
                    {
                    }
                    column(AccountType_DividendDetEntries; "Dividend Det. Entries"."Account Type")
                    {
                    }
                    column(AccountBalance_DividendDetEntries; "Dividend Det. Entries"."Account Balance")
                    {
                    }
                    column(MonthCode_DividendDetEntries; "Dividend Det. Entries"."Month Code")
                    {
                    }
                    column(MonthNo_DividendDetEntries; "Dividend Det. Entries"."Month No.")
                    {
                    }
                    column(DestinationAccount_DividendDetEntries; "Dividend Det. Entries"."Destination Account")
                    {
                    }
                    column(BoostingAmount_DividendDetEntries; "Dividend Det. Entries"."Boosting Amount")
                    {
                    }
                    column(NetAmount_DividendDetEntries; "Dividend Det. Entries"."Net Amount")
                    {
                    }
                    column(SystemEntry_DividendDetEntries; "Dividend Det. Entries"."System Entry")
                    {
                    }
                    column(EntryNo_DividendDetEntries; "Dividend Det. Entries"."Entry No")
                    {
                    }
                    column(PreCalculated_DividendDetEntries; "Dividend Det. Entries"."Pre Calculated")
                    {
                    }
                    column(PostingType_DividendDetEntries; "Dividend Det. Entries"."Posting Type")
                    {
                    }
                    column(Rate_DividendDetEntries; "Dividend Det. Entries".Rate)
                    {
                    }
                    column(PreviousMonth_DividendDetEntries; "Dividend Det. Entries"."Previous Month")
                    {
                    }
                    column(PreviousMonthBalance_DividendDetEntries; "Dividend Det. Entries"."Previous Month Balance")
                    {
                    }
                    column(CurrentMonth_DividendDetEntries; "Dividend Det. Entries"."Current Month")
                    {
                    }
                    column(CurrentMonthBalance_DividendDetEntries; "Dividend Det. Entries"."Current Month Balance")
                    {
                    }
                    column(NetChange_DividendDetEntries; "Dividend Det. Entries"."Net Change")
                    {
                    }
                    column(Year_DividendDetEntries; "Dividend Det. Entries".Year)
                    {
                    }
                    column(Ratio_DividendDetEntries; "Dividend Det. Entries".Ratio)
                    {
                    }
                }
            }
            trigger OnPreDataItem()
            begin
                CompanyInformation.GET;
                CompanyInformation.CALCFIELDS(Picture);
            end;
        }
    }
    var
        Customer: Record Customer;
        CustomerName: Text[200];
        CompanyInformation: Record "Company Information";
}
