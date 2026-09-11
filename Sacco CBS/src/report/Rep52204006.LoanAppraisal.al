report 52204006 "Loan Appraisal"
{
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    PreviewMode = PrintLayout;
    RDLCLayout = './ssrs/Loan Appraisal.rdl';

    dataset
    {
        dataitem("Loan Application"; Loans)
        {
            column(Application_No; "No.")
            {
            }
            column(Application_Date; "Application Date")
            {
            }
            column(Member_No_; "Member No.")
            {
            }
            column(IDNumber; IDNumber)
            {
            }
            column(BridgingLoan; BridgingLoan)
            {
            }
            column(ProratedInterest; ProratedInterest)
            {
            }
            column(ExternalEffect; ExternalEffect)
            {
            }
            column(Member_Name; "Member Name")
            {
            }
            column(Member_Age; Age)
            {
            }
            column(Product_Code; "Product Code")
            {
            }
            column(Insurance_Amount; "Insurance Amount")
            {
            }
            column(GuarantorWarning; GuarantorWarning)
            {
            }
            column(LoanToDepositRatioWarning; LoanToDepositRatioWarning)
            {
            }
            column(AmountToDeposit; AmountToDeposit)
            {
            }
            column(BridgingCommision; BridgingCommision)
            {
            }
            column(ThirdRuleWarning; ThirdRuleWarning)
            {
            }
            column(Product_Description; "Product Description")
            {
            }
            column(Requested_Amount; "Requested Amount")
            {
            }
            column(Applied_Amount; "Loan Amount")
            {
            }
            column(PayrollNo; PayrollNo)
            {
            }
            column(Approved_Amount; "Approved Amount")
            {
            }
            column(Total_Recoveries; "Total Recoveries")
            {
            }
            column(Recoveries_Commissions; "Recoveries Commissions")
            {
            }
            column(Charges_Amount; "Charges Amount")
            {
            }
            column(Take_Home; "Approved Amount" - ("Total Recoveries" + "Charges Amount" + "Recoveries Commissions"))
            {
            }
            column(TagLine; TagLine)
            {
            }
            column(Repayment_Start_Date; "Repayment Start Date")
            {
            }
            column(Repayment_End_Date; "Repayment End Date")
            {
            }
            column(Installments; Installments)
            {
            }
            column(Share_Capital; "Share Capital")
            {
            }
            column(Deposits; Deposits)
            {
            }
            column(Total_Loans; "Total Loans")
            {
            }
            column("CompanyLogo"; CompanyInformation.Picture)
            {
            }
            column("CompanyName"; CompanyInformation.Name)
            {
            }
            column("CompanyAddress1"; CompanyInformation.Address)
            {
            }
            column("CompanyAddress2"; CompanyInformation."Address 2")
            {
            }
            column("CompanyPhone"; CompanyInformation."Phone No.")
            {
            }
            column("CompanyEmail"; CompanyInformation."E-Mail")
            {
            }
            column(AmountInWords; AmountInWords[1])
            {
            }
            column(BasicPay; BasicPay)
            {
            }
            column(HouseAllowance; HouseAllowance)
            {
            }
            column(OtherEarnings; OtherEarnings)
            {
            }
            column(OtherDeductions; OtherDeductions)
            {
            }
            column(OneThird; OneThird)
            {
            }
            column(NetIncome; NetIncome)
            {
            }
            column(MInstallment; MInstallment)
            {
            }
            column(NewNet; NewNet)
            {
            }
            column(QualifiedAmount; QualifiedAmount)
            {
            }
            column(QualifiedDepositWise; QualifiedDepositWise)
            {
            }
            column(QualifiedSalaryWise; QualifiedSalaryWise)
            {
            }
            column(AvailableRecovery; AvailableRecovery)
            {
            }
            column(ClearedEffect; ClearedEffect)
            {
            }
            column(FirstApprover; Approvers[1])
            {
            }
            column(SecondApprover; Approvers[2])
            {
            }
            column(ThirdApprover; Approvers[3])
            {
            }
            column(FourthApprover; Approvers[4])
            {
            }
            column(FirstApproverDate; ApproverDate[1])
            {
            }
            column(SecondApproverDate; ApproverDate[2])
            {
            }
            column(ThirdApproverDate; ApproverDate[3])
            {
            }
            column(FourthApproverDate; ApproverDate[4])
            {
            }
            column(FirstApproverSignature; UserSetup[1].Signature)
            {
            }
            column(SecondApproverSignature; UserSetup[2].Signature)
            {
            }
            column(ThirdApproverSignature; UserSetup[3].Signature)
            {
            }
            column(FourthApproverSignature; UserSetup[4].Signature)
            {
            }
            dataitem("Loan Charges"; "Product Charge Setup")
            {
                DataItemLink = "Source Code" = field("No.");

                column(Loan_No_; "Source Code")
                {
                }
                column(Charge_Code; "Charge Code")
                {
                }
                column(Charge_Description; "Charge Description")
                {
                }
                column(Amount; Amount)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    Amount := 0;
                    Amount := LoanMgmt.GetLoanProductChargesAmount("Loan Application"."Product Code", "Loan Application"."Approved Amount");
                    net -= Amount;
                end;
            }
            dataitem(LoanCharges; "Loan Charges")
            {
                DataItemLink = "No." = field("No.");

                column(Charge_Code_LoanCharges; "Charge Code")
                {
                }
                column(Charge_Description_LoanCharges; "Charge Description")
                {
                }
                column(Amount_LoanCharges; Amount)
                {
                }
            }
            dataitem("Loan Securities"; "Loan Securities")
            {
                DataItemLink = "Loan No" = field("No.");

                column(Security_Type; "Security Type")
                {
                }
                column(Security_Code; "Security Code")
                {
                }
                column(Description; Description)
                {
                }
                column(Security_Value; "Security Value")
                {
                }
                column(Guarantee; Guarantee)
                {
                }
            }
            dataitem("Loan Guarantees"; "Loan Guarantees")
            {
                DataItemLink = "Loan No" = field("No.");

                column(Member_No; "Member No.")
                {
                }
                column(GMember_Name; "Member Name")
                {
                }
                column(Total_Deposits; "Member Deposits")
                {
                }
                column(Guarantor_Value; "Multiplied Deposits")
                {
                }
                column(Guaranteed_Amount; "Guaranteed Amount")
                {
                }
                column(PFNumber; GuarantorPFNo)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    GuarantorPFNo := '';
                    if Member.Get("Loan Guarantees"."Member No.") then begin
                        GuarantorPFNo := Member."Payroll No.";
                        if GuarantorPFNo = '' then GuarantorPFNo := Member."Payroll No.";
                    end;
                end;
            }
            dataitem(ExistingLoans; Loans)
            {
                DataItemLink = "Member No." = field("Member No.");
                DataItemTableView = where(Posted = const(true), "Loan Balance" = filter(<> 0));
                CalcFields = "Loan Balance";
                column(No_ExistingLoans; "No.")
                {
                }
                column(Product_Description_ExistingLoans; "Product Description")
                {
                }
                column(Posting_Date_ExistingLoans; "Posting Date")
                {
                }
                column(Monthly_Installment; "Monthly Installment")
                {
                }
                column(Approved_Amount_ExistingLoans; "Approved Amount")
                {
                }
                column(Loan_Balance_ExistingLoans; "Loan Balance")
                {
                }
                column(Total_Arrears_ExistingLoans; "Total Arrears")
                {
                }
                column(Loan_Classification_ExistingLoans; "Loan Classification")
                {
                }
                trigger OnAfterGetRecord()
                begin
                    CalcFields("Loan Balance");
                end;
            }
            trigger OnPreDataItem()
            begin
                BasicPay := 0;
                HouseAllowance := 0;
                OtherEarnings := 0;
                OtherDeductions := 0;
                OneThird := 0;
                NetIncome := 0;
                MInstallment := 0;
                NewNet := 0;
                Net := 0;
                ClearedEffect := 0;
                GuarantorWarning := '';
                ThirdRuleWarning := '';
                ExternalEffect := 0;
                BridgingLoan := 0;
                ProratedInterest := 0;
                TagLine := '';
            end;

            trigger OnAfterGetRecord()
            var
                LCharge: Record "Product Charge Setup";
                AppraisalParameters: Record "Loanees Payroll Transactions";
                LoansManagement: Codeunit "Loans Management";
                LoanRecoveries: Record "Loan Recoveries";
            begin
                LoanProduct.Get("Loan Application"."Product Code");
                GuarantorPFNo := '';
                "Loan Application".Validate("Insurance Amount");
                //LoansManagement.GetDepositBoostAmount("Loan Application"."No.");
                if "Loan Application"."Requested Amount" = 0 then begin
                    "Loan Application"."Requested Amount" := "Loan Application"."Loan Amount";
                    "Loan Application".Modify;
                end;
                PayrollNo := '';
                if Member.Get("Loan Application"."Member No.") then begin
                    PayrollNo := Member."Payroll No.";
                    IDNumber := Member."Identification No.";
                    if Member."Date of Birth" <> 0D then Age := Format(Date2DMY(WorkDate, 3) - Date2DMY(Member."Date of Birth", 3)) + ' YEARS';
                end;
                BridgingCommision := 0;
                BridgingLoan := 0;
                ProratedInterest := 0;
                LoanRecoveries.Reset();
                LoanRecoveries.SetRange("Loan No", "Loan Application"."No.");
                LoanRecoveries.SetRange("Recovery Type", LoanRecoveries."Recovery Type"::Loan);
                if LoanRecoveries.FindSet() then begin
                    repeat
                        BridgingLoan += LoanRecoveries.Amount;
                        ProratedInterest += LoanRecoveries."Prorated Interest";
                        BridgingCommision += LoanRecoveries."Commission Amount";
                    until LoanRecoveries.next = 0;
                end;
                LoanRecoveries.Reset();
                LoanRecoveries.SetRange("Loan No", "Loan Application"."No.");
                LoanRecoveries.SetRange("Recovery Type", LoanRecoveries."Recovery Type"::External);
                if LoanRecoveries.FindSet() then begin
                    LoanRecoveries.CalcSums(Amount, "Commission Amount");
                    ExternalEffect := LoanRecoveries.Amount;
                end;
                LoanRecoveries.Reset();
                LoanRecoveries.SetRange("Loan No", "Loan Application"."No.");
                LoanRecoveries.SetRange("Recovery Type", LoanRecoveries."Recovery Type"::Account);
                if LoanRecoveries.FindSet() then begin
                    LoanRecoveries.CalcSums(Amount, "Commission Amount");
                    AmountToDeposit := LoanRecoveries.Amount;
                end;
                "Loan Application".Deposits := LoansManagement.GetMemberDeposits("Loan Application"."Member No.");
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);
                Net := "Loan Application"."Approved Amount";
                GuarantorWarning := '';
                "Loan Application".CalcFields("Total Guarantees", "Total Securities");
                if (("Loan Application"."Total Guarantees" + "Loan Application"."Total Securities" < "Loan Application"."Loan Amount") and (not LoanProduct."Unsecured Product")) then GuarantorWarning := 'The Loan is unsecured by Ksh. ' + Format(("Loan Application"."Total Guarantees" + "Loan Application"."Total Securities" - "Loan Application"."Loan Amount"));
                "Loan Application".CalcFields("Monthly Installment");
                MInstallment := "Loan Application"."Monthly Installment";
                AppraisalParameters.Reset();
                AppraisalParameters.SetRange("Source No.", "Loan Application"."No.");
                AppraisalParameters.SetFilter("Transaction Type", '<>%1', AppraisalParameters."Transaction Type"::"1/3 Basic Salary");
                if AppraisalParameters.FindSet() then begin
                    repeat // if AppraisalParameters.Type = AppraisalParameters.Type::Income then
                           //     NetIncome += AppraisalParameters.Amount
                           // else
                        NetIncome += AppraisalParameters.Amount;
                        ParameterSetup.Get(AppraisalParameters."Source No.", AppraisalParameters.Type, AppraisalParameters.Code);
                        if ParameterSetup."Cleared Effect" then ClearedEffect += AppraisalParameters.Amount;
                        if AppraisalParameters.Type = AppraisalParameters.Type::Deduction then
                            OtherDeductions += AppraisalParameters.Amount
                        else begin
                            if AppraisalParameters."Transaction Type" = AppraisalParameters."Transaction Type"::"Basic Salary" then
                                BasicPay += AppraisalParameters.Amount
                            else if AppraisalParameters."Transaction Type" = AppraisalParameters."Transaction Type"::"House Allownace" then
                                HouseAllowance += AppraisalParameters.Amount
                            else begin
                                if ParameterSetup."Cleared Effect" = false then OtherEarnings += AppraisalParameters.Amount;
                            end;
                        end;
                    until AppraisalParameters.Next() = 0;
                end;
                SpecialLoan := 0;
                SpecialLoans2 := 0;
                LoansManagement.GetMemberSpecialLoanAmount("Loan Application"."Member No.", "Loan Application"."No.", SpecialLoans2, SpecialLoan);
                "Total Loans" := LoansManagement.GetMemberLoans("Loan Application"."Member No.") - LoansManagement.GetRefinancedLoans("No.") - SpecialLoans2;
                LoanProduct.Get("Loan Application"."Product Code");
                if LoanProduct."Special Loan Multiplier" then
                    QualifiedDepositWise := ((LoansManagement.GetMemberDeposits("Loan Application"."Member No.") - SpecialLoan + LoansManagement.GetBoostedDeposits("Loan Application"."No.")) * LoanProduct."Loan Multiplier")
                else
                    QualifiedDepositWise := ((LoansManagement.GetMemberDeposits("Loan Application"."Member No.") + LoansManagement.GetBoostedDeposits("Loan Application"."No.")) * LoanProduct."Loan Multiplier");
                OneThird := (1 / 3) * BasicPay;
                NewNet := NetIncome - MInstallment;
                if LoanProduct."Salary Based" then
                    AvailableRecovery := NetIncome
                else
                    AvailableRecovery := NetIncome - OneThird;
                QualifiedAmount := QualifiedDepositWise;
                MaxCredit := QualifiedDepositWise - "Total Loans";
                if ((OneThird <> 0) and (AvailableRecovery < MInstallment)) then ThirdRuleWarning := 'One third rule not met';
                if ((not LoanProduct."Mobile Loan") and (not LoanProduct."Dividend Based") and (not LoanProduct."Appraise with 0 Deposits")) then begin
                    if QualifiedAmount < "Loan Application"."Loan Amount" then LoanToDepositRatioWarning := 'Loan-to-Deposit ratio not met';
                end;
                if (("Loan Application"."Loan Amount" <= MaxCredit) OR (AvailableRecovery > MInstallment) or LoanProduct."Unsecured Product") then
                    TagLine := 'This member qualifies for ' + Format("Loan Application"."Loan Amount") + ' recoverable ' + format(Round("Loan Application"."Monthly Installment", 0.10, '=')) + ' for ' + Format("Loan Application".Installments) + ' months'
                else
                    TagLine := 'This member does not qualify for ' + Format("Loan Application"."Loan Amount");
                "Loan Application".CalcFields("Total Recoveries");

                if "Loan Application"."Total Recoveries" > "Loan Application"."Loan Amount" then ThirdRuleWarning := 'You cannot refinance more than the applied amount';
                Clear(AmountInWords);
                AmountToWords.FormatNoText(AmountInWords, Net, '');
                if QualifiedAmount > "Loan Application"."Loan Amount" then QualifiedAmount := "Loan Application"."Loan Amount";
                "Total Loans" := LoansManagement.GetOutstandingLoans("No.") - LoansManagement.GetExcludedLoans("No.");
                if "Loan Application"."Appraisal Commited" = false then begin
                    LoanProduct.Get("Loan Application"."Product Code");
                    if ((LoanProduct."Appraise with 0 Deposits") AND (AvailableRecovery > MInstallment)) then
                        "Loan Application"."Approved Amount" := "Loan Application"."Loan Amount"
                    else
                        "Loan Application"."Approved Amount" := QualifiedAmount;
                    If LoanProduct."Dividend Based" then begin
                        PreviousDividends := 0;
                        PreviousDividends := LoansManagement.GetPriorDividendAmount("Member No.");
                        If ("Loan Application"."Loan Amount" + PreviousDividends) > Member."Prior Year Dividend" then
                            "Loan Application"."Approved Amount" := Member."Prior Year Dividend" - PreviousDividends
                        else
                            "Loan Application"."Approved Amount" := "Loan Application"."Loan Amount";
                    end;
                    "New Monthly Installment" := MInstallment;
                    "Loan Application".Modify();
                end;
                ApprovalEntries.RESET;
                ApprovalEntries.SetCurrentKey("Sequence No.");
                ApprovalEntries.SETRANGE(ApprovalEntries."Table ID", Database::Loans);
                ApprovalEntries.SETRANGE(ApprovalEntries."Document No.", "Loan Application"."No.");
                ApprovalEntries.SETRANGE(ApprovalEntries.Status, ApprovalEntries.Status::Approved);
                IF ApprovalEntries.FIND('-') THEN BEGIN
                    i := 0;
                    REPEAT
                        i := i + 1;
                        IF i = 1 THEN BEGIN
                            Users.RESET;
                            Users.SETRANGE("User Name", ApprovalEntries."Sender ID");
                            IF Users.FINDFIRST THEN BEGIN
                                Approvers[1] := Users."Full Name";
                            end;
                            Users.RESET;
                            Users.SETRANGE("User Name", ApprovalEntries."Approver ID");
                            IF Users.FINDFIRST THEN BEGIN
                                Approvers[2] := Users."Full Name";
                                Approvers[3] := Users."Full Name";
                                Approvers[4] := Users."Full Name";
                            end;
                            ApproverDate[1] := ApprovalEntries."Date-Time Sent for Approval";
                            ApproverDate[2] := ApprovalEntries."Last Date-Time Modified";
                            ApproverDate[3] := ApprovalEntries."Last Date-Time Modified";
                            ApproverDate[4] := ApprovalEntries."Last Date-Time Modified";
                            IF UserSetup[1].GET(ApprovalEntries."Sender ID") THEN UserSetup[1].CALCFIELDS(UserSetup[1].Signature);
                            IF UserSetup[2].GET(ApprovalEntries."Approver ID") THEN UserSetup[2].CALCFIELDS(UserSetup[2].Signature);
                            IF UserSetup[3].GET(ApprovalEntries."Approver ID") THEN UserSetup[3].CALCFIELDS(UserSetup[3].Signature);
                            IF UserSetup[4].GET(ApprovalEntries."Approver ID") THEN UserSetup[4].CALCFIELDS(UserSetup[4].Signature);
                        end;
                        IF i = 2 THEN BEGIN
                            Users.RESET;
                            Users.SETRANGE("User Name", ApprovalEntries."Approver ID");
                            IF Users.FINDFIRST THEN BEGIN
                                Approvers[3] := Users."Full Name";
                                Approvers[4] := Users."Full Name";
                            end;
                            ApproverDate[3] := ApprovalEntries."Last Date-Time Modified";
                            ApproverDate[4] := ApprovalEntries."Last Date-Time Modified";
                            IF UserSetup[3].GET(ApprovalEntries."Approver ID") THEN UserSetup[3].CALCFIELDS(UserSetup[3].Signature);
                            IF UserSetup[4].GET(ApprovalEntries."Approver ID") THEN UserSetup[4].CALCFIELDS(UserSetup[4].Signature);
                        end;
                        IF i = 3 THEN BEGIN
                            Users.RESET;
                            Users.SETRANGE("User Name", ApprovalEntries."Approver ID");
                            IF Users.FINDFIRST THEN BEGIN
                                Approvers[4] := Users."Full Name";
                            end;
                            ApproverDate[4] := ApprovalEntries."Last Date-Time Modified";
                            IF UserSetup[4].GET(ApprovalEntries."Approver ID") THEN UserSetup[4].CALCFIELDS(UserSetup[4].Signature);
                        end;
                    UNTIL ApprovalEntries.NEXT = 0;
                end;
            end;
        }
    }
    var
        PayrollNo, GuarantorPFNo : Code[20];
        Check: Codeunit "Journal Management";
        AmountToWords: Codeunit "Amount To Words";
        Amount: Decimal;
        MaxCredit, AvailableRecovery, QualifiedSalaryWise, QualifiedDepositWise, QualifiedAmount, BridgingLoan, ProratedInterest, ExternalEffect, AmountToDeposit, BridgingCommision : decimal;
        ClearedEffect, BasicPay, HouseAllowance, OtherEarnings, OtherDeductions, OneThird, NetIncome, MInstallment, NewNet : decimal;
        CompanyInformation: Record "Company Information";
        AmountInWords: array[2] of Text[250];
        LoanProduct: Record "Sacco Products";
        AppraisalAccounts: Record "Appraisal Accounts";
        Net: Decimal;
        Member: Record Members;
        IDNumber: Code[20];
        ParameterSetup: Record "Loanees Payroll Transactions";
        TagLine, GuarantorWarning, ThirdRuleWarning, LoanToDepositRatioWarning, RetirementWarning, Age : Text[100];
        SpecialLoan, SpecialLoans2, PreviousDividends : Decimal;
        LoanMgmt: Codeunit "Loans Management";
        ApprovalEntries: Record "Approval Entry";
        Users: Record User;
        i: Integer;
        Approvers: array[4] of Text[100];
        ApproverDate: array[4] of DateTime;
        UserSetup: array[4] of Record "User Setup";
}
