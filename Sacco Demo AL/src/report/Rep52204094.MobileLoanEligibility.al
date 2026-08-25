report 52204094 "Mobile Loan Eligibility"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    PreviewMode = PrintLayout;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Mobile Loan Eligibility.rdl';
    dataset
    {
        dataitem(Members; Members)
        {
            RequestFilterFields = "Date Filter";
            column("CompanyAddress1"; CompanyInformation.Address)
            {
            }
            column("CompanyAddress2"; CompanyInformation."Address 2")
            {
            }
            column("CompanyEmail"; CompanyInformation."E-Mail")
            {
            }
            column(CompanyWebsite; CompanyInformation."Home Page")
            {
            }
            column("CompanyLogo"; CompanyInformation.Picture)
            {
            }
            column("CompanyName"; CompanyInformation.Name)
            {
            }
            column("CompanyPhone"; CompanyInformation."Phone No.")
            {
            }
            column(Member_No_; "No.")
            {
            }
            column(Full_Name; "Full Name")
            {
            }
            column(Salaried; Salaried)
            {
            }
            column(Total_Deposits; "Total Deposits")
            {
            }
            column(Status; Status)
            {
            }
            column(MLoanBalance; MLoanBalance)
            {
            }
            column(MemberContribution; MemberContribution)
            {
            }
            column(EligibleAmount_1; EligibleAmount_1)
            {
            }
            column(EligibleAmount_3; EligibleAmount_3)
            {
            }
            column(EligibleAmount_6; EligibleAmount_6)
            {
            }
            column(Comment; Comment)
            {
            }

            trigger OnAfterGetRecord()
            begin
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);
                CalcFields("Total Deposits", "Total Shares");

                SaccoProduct.Reset();
                SaccoProduct.SetRange("Product Posting Type", SaccoProduct."Product Posting Type"::"Loan Account");
                SaccoProduct.SetRange("Mobile Loan", true);
                SaccoProduct.SetRange("Dividend Based", false);
                if SaccoProduct.FindFirst then;


                MemberContribution := 0;
                MonthlyContribution := 0;
                NetPay := 0;
                MLoanBalance := 0;
                Eligibility := 0;
                EligibleAmount_1 := 0;
                EligibleAmount_3 := 0;
                EligibleAmount_6 := 0;
                Limit := 0;
                DepositEligibility := 0;
                MaxAmount := 0;
                Comment := '';
                Datefilter := '';

                Evaluate(FilterDate, DelChr(Members.GetFilter("Date Filter"), '=', '..'));
                If FilterDate = 0D then
                    FilterDate := WorkDate;

                Datefilter := StrSubstNo('%1..%2', CalcDate('-CM', FilterDate), CalcDate('CM', FilterDate));

                Loans.Reset();
                Loans.SetRange("Member No.", "No.");
                Loans.SetRange("Mobile Loan", true);
                Loans.SetRange(Posted, true);
                Loans.Setfilter("Loan Balance", '>0');
                if Loans.FindSet then begin
                    repeat
                        Loans.CalcFields("Loan Balance");
                        MLoanBalance += Loans."Loan Balance";
                    until Loans.Next = 0;
                    if MLoanBalance < 0 then
                        MLoanBalance := 0;
                end;


                EndDate := FilterDate;
                SDate := CalcDate('-2M', CALCDATE('<-CM>', EndDate));
                DateFilter := Format(SDate) + '..' + Format(EndDate);

                DetailedVendorLedgEntry.Reset();
                DetailedVendorLedgEntry.SetRange("Product Posting Type", DetailedVendorLedgEntry."Product Posting Type"::"Non Withdrawable Deposit");
                DetailedVendorLedgEntry.SetRange("Member No.", "No.");
                DetailedVendorLedgEntry.Setfilter("Posting Date", Datefilter);
                DetailedVendorLedgEntry.Setfilter("Document No.", '<>OPENBAL');
                DetailedVendorLedgEntry.SetCurrentKey("Entry No.");
                DetailedVendorLedgEntry.SetAscending("Entry No.", false);
                if DetailedVendorLedgEntry.FindSet then begin
                    DetailedVendorLedgEntry.CalcSums("Credit Amount");
                    MemberContribution := DetailedVendorLedgEntry."Credit Amount";
                    MemberContribution := Round(MemberContribution / 3);
                end;

                Loans.Reset();
                Loans.SetRange("Member No.", "No.");
                Loans.SetFilter("Loan Classification", '<>%1', Loans."Loan Classification"::Performing);
                if Loans.FindFirst() then
                    Comment := 'Member have a Non Performing Loan'
                else begin
                    if ChannelsIntegrations.MobileLoanBlocked("No.", SaccoProduct.Code) then
                        Comment := 'Member is blocked to Access Mobile Loans'
                    else begin
                        if "Total Shares" < 2000 then
                            Comment := 'Member must have at least 2,000 Shares Balance'
                        else begin
                            if Members.Category = 'STAFF' then begin
                                PayrollPeriodTransaction.Reset;
                                PayrollPeriodTransaction.SetRange("Employee Code", MemberMgmt.GetEmployeeNo(Members."No."));
                                PayrollPeriodTransaction.SetFilter("Payroll Period", DateFilter);
                                PayrollPeriodTransaction.SetRange("Transaction Code", 'NPAY');
                                if PayrollPeriodTransaction.FindSet() then begin
                                    repeat
                                        NetPay += PayrollPeriodTransaction.Amount;
                                    until PayrollPeriodTransaction.Next = 0;
                                    Eligibility := Round((NetPay / 3) * 0.5);
                                end;
                            end
                            else
                                if not Salaried then begin
                                    DetailedVendorLedgEntry.Reset();
                                    DetailedVendorLedgEntry.SetRange("Product Posting Type", DetailedVendorLedgEntry."Product Posting Type"::"Non Withdrawable Deposit");
                                    DetailedVendorLedgEntry.Setfilter("Sacco Transaction Type", '<>%1', DetailedVendorLedgEntry."Sacco Transaction Type"::"End Month Salary");
                                    DetailedVendorLedgEntry.SetRange("Member No.", "No.");
                                    DetailedVendorLedgEntry.Setfilter("Posting Date", Datefilter);
                                    DetailedVendorLedgEntry.Setfilter("Document No.", '<>OPENBAL');
                                    DetailedVendorLedgEntry.SetCurrentKey("Entry No.");
                                    DetailedVendorLedgEntry.SetAscending("Entry No.", false);
                                    if DetailedVendorLedgEntry.FindSet then begin
                                        DetailedVendorLedgEntry.CalcSums("Credit Amount");
                                        MonthlyContribution := DetailedVendorLedgEntry."Credit Amount";
                                        Eligibility := (MonthlyContribution / 3) * 2;
                                    end;
                                end
                                else begin
                                    CheckOffLines.Reset();
                                    CheckOffLines.SetRange("Member No", "No.");
                                    CheckOffLines.SetFilter("Posting Date", DateFilter);
                                    CheckOffLines.SetRange("Upload Type", CheckOffLines."Upload Type"::Salary);
                                    CheckOffLines.SetRange("Income Type", CheckOffLines."Income Type"::Salary);
                                    CheckOffLines.SetRange(Posted, true);
                                    if CheckOffLines.FindSet() then begin
                                        repeat
                                            CheckOffLines.CalcFields("Net Amount");
                                            MonthlyContribution += CheckOffLines."Net Amount";
                                        until CheckOffLines.Next = 0;
                                        Eligibility := Round((MonthlyContribution / 3) * 0.5);
                                    end;
                                end;

                            If "Mobi Loan Limit" <> 0 then
                                Eligibility := "Mobi Loan Limit";

                            if Eligibility < 0 then
                                Eligibility := 0;

                            Deposits := "Total Deposits";
                            DepositEligibility := (Deposits * SaccoProduct."Loan Multiplier");
                            if DepositEligibility < 0 then
                                DepositEligibility := 0;

                            MaxAmount := SaccoProduct."Maximum Loan Amount";
                            Limit := MaxAmount;

                            if Eligibility > DepositEligibility then
                                Eligibility := DepositEligibility;

                            if Eligibility > Limit then
                                Eligibility := limit;

                            EligibleAmount_1 := Eligibility;


                            EligibleAmount_3 := Eligibility * 3;

                            if EligibleAmount_3 > Limit then
                                EligibleAmount_3 := limit;
                            if EligibleAmount_3 > DepositEligibility then
                                EligibleAmount_3 := DepositEligibility;

                            EligibleAmount_6 := Eligibility * 6;

                            if EligibleAmount_6 > Limit then
                                EligibleAmount_6 := Limit;
                            if EligibleAmount_6 > DepositEligibility then
                                EligibleAmount_6 := DepositEligibility;

                            if not Members.Salaried then
                                EligibleAmount_6 := 0;
                        end;
                    end;
                end;
            end;
        }
    }

    var
        CompanyInformation: Record "Company Information";
        NetPay, MonthlyContribution, MemberContribution, MLoanBalance, Eligibility, EligibleAmount_1, EligibleAmount_3, EligibleAmount_6, Limit, MaxAmount, DepositEligibility, Deposits : Decimal;
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        SaccoProduct: Record "Sacco Products";
        CheckOffLines: Record "Checkoff Lines";
        ChannelsIntegrations: Codeunit "Channels Integrations";
        PayrollPeriodTransaction: Record "Payroll Period Transaction";
        MemberMgmt: Codeunit "Member Management";
        Loans: Record Loans;
        Datefilter, Comment : Text;
        EndDate, SDate, FilterDate : Date;
}
