codeunit 52203433 "Payroll Processing"
{
    var
        PayrollPeriods: Record "Payroll Periods";
        PayrollPeriodTrans: Record "Payroll Period Transaction";
        PayrollEmployeeP9TaxInfo: Record "Payroll Employee P9 Tax Info";
        PRSalaryCard: Record "Payroll Salary Card";
        IsSecondary: Boolean;
        SelectedPeriod: Date;
        ProgressWindow: Dialog;
        IansTotalDeduction: Decimal;
        PayrollSetup: Record "Payroll Vital Setup";
        curReliefPersonal: Decimal;
        curReliefInsurance: Decimal;
        curReliefMorgage: Decimal;
        curMaximumRelief: Decimal;
        currMinRelief: Decimal;
        curNssf_Employer_Factor: Decimal;
        curNHFAmount: Decimal;
        intSHIF_BasedOn: Option Gross,Basic,"Taxable Pay";
        intNHF_BasedOn: Option Gross,Basic,"Taxable Pay";
        NHF_Enabled: Boolean;
        NHFPercentage: Decimal;
        NHF_BaseAmount: Decimal;
        curHousingLevyRelief: Decimal;
        intNSSF_BasedOn: Option Gross,Basic;
        curDisabledLimit: Decimal;
        curMaxPensionContrib: Decimal;
        curRateTaxExPension: Decimal;
        curOOIMaxMonthlyContrb: Decimal;
        curOOIDecemberDedc: Decimal;
        curLoanMarketRate: Decimal;
        curLoanCorpRate: Decimal;
        curReliefPension: Decimal;
        curFringeBenefit: Decimal;
        TaxAccount: Code[20];
        salariesAcc: Code[20];
        PayablesAcc: Code[20];
        NSSFEMPyer: Code[20];
        PensionEMPyer: Code[20];
        NSSFEMPyee: Code[20];
        SHIFEMPyer: Code[20];
        SHIFEMPyee: Code[20];
        HREmployee: Record Employee;
        CoopParameters: Option "none",shares,loan,"loan Interest","Emergency loan","Emergency loan Interest","School Fees loan","School Fees loan Interest",Welfare,Pension,NSSF;
        PostingGroup: Record "Employee Posting Group";
        AccSchedMgt: Codeunit AccSchedManagement;
        HREmp2: Record Employee;
        PRTransCode: Record "Payroll Transaction Code";
        HREmployes: Record Employee;
        Cust2: Record Customer;
        curTransSubledger: Option " ",Customer,Vendor;
        curTransSubledgerAccount: Code[20];
        PRSalCard: Record "Payroll Salary Card";
        PRSalCard_2: Record "Payroll Salary Card";
        EmployeeInterestRate: Decimal;
        curMorgageRelief: Decimal;
        PRTransCode_2: Record "Payroll Transaction Code";
        PREmpTrans_2: Record "Payroll Employee Transaction";
        BenifitAmount: Decimal;
        Prsalary: Record "Payroll Salary Card";
        ThirdSalary: Decimal;
        CurSalaryRecoveryAmount: Decimal;
        GratuityCalculation: Codeunit "Gratuity Calculation";
        GratuityAccount: Code[20];
        NHFAccount, EmployerNHFAccount : Code[20];
        PostInGlobal: Option " ",ERP,CBS;
        ImprestManagement: Codeunit "Imprest Management";
        SecondaryTaxPercentage: Decimal;
        TaxablePension: Decimal;
        EmployeePayrollScales: Record "Employee Payroll Scales";
        PayrollTransactionJobs: Record "Payroll Transaction Jobs";
        EmployeeDonors: Record "Employee Donors";
        PayrollChargedGrants: Record "Payroll Charged Grants";
        EmployeeContractDetails: Record "Employee Contract Details";
        TaxableGratuity: Decimal;
        TaxFromGratuity: Decimal;
        LeaveApplications: Record "Leave Applications";
        PayrollTransactionCode: Record "Payroll Transaction Code";
        "SHIF%": Decimal;
        SHIFReliefEnabled: Boolean;
        "SHIFRelief%": Decimal;
        CurSHIFRelief: Decimal;

    procedure fnInitialize()
    var
        strTableName: Text[50];
        curTransAmount: Decimal;
        curTransBalance: Decimal;
        strTransDescription: Text[50];
        TGroup: Text[30];
        TGroupOrder: Integer;
        TSubGroupOrder: Integer;
        curSalaryArrears: Decimal;
        curPayeArrears: Decimal;
        curGrossPay: Decimal;
        curTotAllowances: Decimal;
        curExcessPension: Decimal;
        curNSSF: Decimal;
        curDefinedContrib: Decimal;
        curPensionStaff: Decimal;
        curNonTaxable: Decimal;
        curGrossTaxable: Decimal;
        curBenefits: Decimal;
        curValueOfQuarters: Decimal;
        curUnusedRelief: Decimal;
        curInsuranceReliefAmount: Decimal;
        curMorgageReliefAmount: Decimal;
        curTaxablePay: Decimal;
        curTaxCharged: Decimal;
        curPAYE: Decimal;
        prPeriodTransactions: Record "Payroll Period Transaction";
        intYear: Integer;
        intMonth: Integer;
        LeapYear: Boolean;
        CountDaysofMonth: Integer;
        DaysWorked: Integer;
        prSalaryArrears: Record "Payroll Salary Card";
        prEmployeeTransactions: Record "Payroll Employee Transaction";
        prTransactionCodes: Record "Payroll Transaction Code";
        strExtractedFrml: Text[250];
        SpecialTransType: Option Ignore,"Defined Contribution","Home Ownership Savings Plan","Life Insurance","Owner Occupier Interest","Prescribed Benefit","Salary Arrears","Staff Loan","Value of Quarters",Morgage;
        TransactionType: Option Income,Deduction;
        curPensionCompany: Decimal;
        curTaxOnExcessPension: Decimal;
        curSHIF_Base_Amount: Decimal;
        curSHIF: Decimal;
        curTotalDeductions: Decimal;
        curNetRnd_Effect: Decimal;
        curNetPay: Decimal;
        curTotCompanyDed: Decimal;
        curOOI: Decimal;
        curHOSP: Decimal;
        curLoanInt: Decimal;
        strTransCode: Text[250];
        fnCalcFringeBenefit: Decimal;
        prEmployerDeductions: Record "Payroll Employer Transaction";
        JournalPostingType: Option " ","G/L Account",Customer,Vendor;
        JournalAcc: Code[20];
        Customer: Record Customer;
        JournalPostAs: Option " ",Debit,Credit;
        "`": Integer;
    begin
        OnPayrollLoanManagement;
        PayrollSetup.FindFirst;
        with PayrollSetup do begin
            curReliefPersonal := "Tax Relief";
            curReliefInsurance := "Insurance Relief %";
            curReliefMorgage := "Mortgage Relief";
            curMaximumRelief := "Max Relief";
            curNssf_Employer_Factor := "NSSF Employer Factor";
            intSHIF_BasedOn := "SHIF Based on";
            intNHF_BasedOn := "NHF Based On";
            NHF_Enabled := "Activate NHF";
            SecondaryTaxPercentage := "Secondary Employee Tax %";
            if NHF_Enabled then TestField("NHF %");
            NHFPercentage := "NHF %";
            curMaxPensionContrib := "Max Pension Contribution";
            curRateTaxExPension := "Tax On Excess Pension";
            curOOIMaxMonthlyContrb := "OOI Deduction";
            curOOIDecemberDedc := "OOI December";
            curLoanMarketRate := "Loan Market Rate";
            curLoanCorpRate := "Loan Corporate Rate";
            currMinRelief := "Minimum Relief Amount";
            curDisabledLimit := "Disbled Tax Limit";
            "SHIF%" := "SHIF %";
            SHIFReliefEnabled := "Enable SHIF Relief";
            "SHIFRelief%" := "SHIF Relief %";
        end;
        CurSalaryRecoveryAmount := 0;
    end;

    procedure ProcessIndividualPayroll(Emp: Record Employee)
    var
        count: Integer;
    begin
        PayrollPeriods.Reset;
        PayrollPeriods.SetRange(PayrollPeriods.Closed, false);
        if PayrollPeriods.Find('-') then begin
            SelectedPeriod := PayrollPeriods."Start Date";
        end
        else begin
            Error('No Payroll period found');
        end;
        PayrollPeriodTrans.Reset;
        PayrollPeriodTrans.SetRange("Payroll Period", SelectedPeriod);
        PayrollPeriodTrans.SetRange("Employee Code", Emp."No.");
        if PayrollPeriodTrans.FindSet then PayrollPeriodTrans.DeleteAll;
        PayrollEmployeeP9TaxInfo.Reset;
        PayrollEmployeeP9TaxInfo.SetRange("Payroll Period", SelectedPeriod);
        PayrollEmployeeP9TaxInfo.SetRange("Employee Code", Emp."No.");
        if PayrollEmployeeP9TaxInfo.FindSet then PayrollEmployeeP9TaxInfo.DeleteAll;
        if PRSalaryCard.Get(Emp."No.") then begin
            ProgressWindow.Open('Processing Salary #1#################################################################');
            ProgressWindow.Update(1, Emp."No." + ':' + Emp.FullName);
            if Emp."Type of Employee" in [Emp."Type of Employee"::seconded] then
                IsSecondary := true
            else
                IsSecondary := false;
            if PRSalaryCard.Get(Emp."No.") then begin
                Processpayroll(Emp."No.", Emp."Employment Date", PRSalaryCard."Basic Pay", PRSalaryCard."Pays PAYE", PRSalaryCard."Pays NSSF", PRSalaryCard."Pays SHIF", SelectedPeriod, SelectedPeriod, '', '', Emp."Date of Leaving", true, Emp."Global Dimension 1 Code", PRSalaryCard."Insurance Certificate?", IsSecondary);
                ProgressWindow.Close;
            end;
            Commit;
        end;
    end;

    procedure Processpayroll(strEmpCode: Code[20]; dtDOE: Date; curBasicPay: Decimal; blnPaysPaye: Boolean; blnPaysNssf: Boolean; blnPaysSHIF: Boolean; SelectedPeriod: Date; dtOpenPeriod: Date; Membership: Text[30]; ReferenceNo: Text[30]; dtTermination: Date; blnGetsPAYERelief: Boolean; Dept: Code[20]; blnInsuranceCertificate: Boolean; blnsIsSecondaryEmployee: Boolean)
    var
        strTableName: Text[50];
        curTransAmount: Decimal;
        curTransBalance: Decimal;
        strTransDescription: Text[50];
        TGroup: Text[30];
        TGroupOrder: Integer;
        TSubGroupOrder: Integer;
        curSalaryArrears: Decimal;
        curPayeArrears: Decimal;
        curGrossPay: Decimal;
        curTotAllowances: Decimal;
        curExcessPension: Decimal;
        curNSSF: Decimal;
        curDefinedContrib: Decimal;
        curPensionStaff: Decimal;
        curNonTaxable: Decimal;
        curGrossTaxable: Decimal;
        curBenefits: Decimal;
        curValueOfQuarters: Decimal;
        curUnusedRelief: Decimal;
        curInsuranceReliefAmount: Decimal;
        curMorgageReliefAmount: Decimal;
        curTaxablePay: Decimal;
        curTaxCharged: Decimal;
        curPAYE: Decimal;
        intYear: Integer;
        intMonth: Integer;
        LeapYear: Boolean;
        CountDaysofMonth: Integer;
        DaysWorked: Integer;
        prSalaryArrears: Record "Payroll Salary Card";
        prEmployeeTransactions: Record "Payroll Employee Transaction";
        prTransactionCodes: Record "Payroll Transaction Code";
        strExtractedFrml: Text[250];
        SpecialTransType: Option Ignore,"Defined Contribution","Home Ownership Savings Plan","Life Insurance","Owner Occupier Interest","Prescribed Benefit","Salary Arrears","Staff Loan","Value of Quarters",Mortgage,Pension,"Mortgage Relief";
        TransactionType: Option Income,Deduction;
        curPensionCompany: Decimal;
        curTaxOnExcessPension: Decimal;
        curSHIF_Base_Amount: Decimal;
        curSHIF: Decimal;
        curTotalDeductions: Decimal;
        curNetRnd_Effect: Decimal;
        curNetPay: Decimal;
        curTotCompanyDed: Decimal;
        curOOI: Decimal;
        curHOSP: Decimal;
        curLoanInt: Decimal;
        strTransCode: Text[250];
        fnCalcFringeBenefit: Decimal;
        prEmployerDeductions: Record "Payroll Employer Transaction";
        salCard: Record "Payroll Salary Card";
        curBPAYBal: Decimal;
        curPensionReliefAmount: Decimal;
        curIncludeinNet: Decimal;
        JournalPostAs: Option ,Debit,Credit;
        JournalPostingType: Option " ","G/L Account",Customer,Vendor,Credit,Savings;
        JournalAc: Code[20];
        Customer: Record Customer;
        curIncludeGross: Decimal;
        IsCashbenefit: Decimal;
        curNssf_Base_Amount: Decimal;
        PRPeriodTrans: Record "Payroll Period Transaction";
        CurGratuityAMount: Decimal;
        InsuranceCert: Boolean;
        IsContractRenewed: Boolean;
    begin
        if HREmp2.Get(strEmpCode) then HREmp2.TestField("Employee Posting Group");
        dtOpenPeriod := fnGetOpenPeriod();
        fnInitialize;
        fnGetJournalDet(strEmpCode);
        if SelectedPeriod <> dtOpenPeriod then exit;
        intMonth := Date2DMY(SelectedPeriod, 2);
        intYear := Date2DMY(SelectedPeriod, 3);
        begin
            //IsContractRenewed:=GratuityCalculation.IanIsContractExpiredAndNotRenewed(strEmpCode,dtOpenPeriod);
            if (Date2DMY(dtDOE, 2) = Date2DMY(dtOpenPeriod, 2)) and (Date2DMY(dtDOE, 3) = Date2DMY(dtOpenPeriod, 3)) and (Date2DMY(dtDOE, 1) <> 1) then begin
                CountDaysofMonth := fnDaysInMonth(dtDOE);
                DaysWorked := fnDaysWorked(dtDOE, false);
                curBasicPay := fnBasicPayProrated(strEmpCode, intMonth, intYear, curBasicPay, DaysWorked, CountDaysofMonth)
            end;
            //IF NOT IsContractRenewed THEN BEGIN
            if dtTermination <> 0D then begin
                if (Date2DMY(dtTermination, 2) = Date2DMY(dtOpenPeriod, 2)) and (Date2DMY(dtTermination, 3) = Date2DMY(dtOpenPeriod, 3)) then begin
                    CountDaysofMonth := fnDaysInMonth(dtTermination);
                    DaysWorked := fnDaysWorked(dtTermination, true);
                    curBasicPay := fnBasicPayProrated(strEmpCode, intMonth, intYear, curBasicPay, DaysWorked, CountDaysofMonth)
                end;
            end;
            //END;
            curBPAYBal := 0;
            salCard.Reset;
            salCard.SetRange(salCard."Employee Code", strEmpCode);
            if salCard.Find('-') then begin
                curBPAYBal := curBasicPay;
            end;
            EmployeeContractDetails.Reset;
            EmployeeContractDetails.SetRange("Employee No", strEmpCode);
            //EmployeeContractDetails.SETRANGE("Contract Status",EmployeeContractDetails."Contract Status"::Active);
            if EmployeeContractDetails.FindFirst then begin
                EmployeeDonors.Reset;
                EmployeeDonors.SetRange("Employee No", strEmpCode);
                EmployeeDonors.SetRange("Grant Status", EmployeeDonors."Grant Status"::Active);
                EmployeeDonors.SetRange("Contract Line No", EmployeeContractDetails."Line No");
                if EmployeeDonors.FindSet then begin
                    repeat
                        PayrollChargedGrants.Init;
                        PayrollChargedGrants."Emp Code" := strEmpCode;
                        PayrollChargedGrants."Payroll Period" := dtOpenPeriod;
                        PayrollChargedGrants."Period Month" := intMonth;
                        PayrollChargedGrants."Period Year" := intYear;
                        PayrollChargedGrants.Percentage := EmployeeDonors.Percentage;
                        PayrollChargedGrants."Grant Code" := EmployeeDonors."Donor Code";
                        PayrollChargedGrants.Insert;
                    until EmployeeDonors.Next = 0;
                end;
                //      END ELSE
                //        ERROR('No active grant for employee no %1',strEmpCode);
            end;
            CurGratuityAMount := 0;
            salCard.Get(strEmpCode);
            // CurGratuityAMount := GratuityCalculation.CalculateGratuityAmount(strEmpCode, SelectedPeriod, salCard."Basic Pay");
            if CurGratuityAMount > 0 then begin
                prTransactionCodes.Reset;
                prTransactionCodes.SetRange("Special Transactions", prTransactionCodes."Special Transactions"::Gratuity);
                if prTransactionCodes.FindFirst then begin
                    prEmployeeTransactions.Init;
                    prEmployeeTransactions.Validate("Employee Code", strEmpCode);
                    prEmployeeTransactions.Validate("Transaction Code", prTransactionCodes.Code);
                    prEmployeeTransactions.Validate(Amount, CurGratuityAMount);
                    prEmployeeTransactions."Temporary Transaction" := true;
                    if not prEmployeeTransactions.Get(strEmpCode, prTransactionCodes.Code, dtOpenPeriod, intMonth, intYear) then
                        prEmployeeTransactions.Insert
                    else begin
                        if prEmployeeTransactions.Get(strEmpCode, prTransactionCodes.Code, dtOpenPeriod, intMonth, intYear) then begin
                            prEmployeeTransactions.Amount := CurGratuityAMount;
                            prEmployeeTransactions.Modify(true);
                        end;
                    end;
                end;
            end;
            /*curTransAmount := CurGratuityAMount;
            strTransDescription := 'Gratuity';
            TGroup := 'ALLOWANCE'; TGroupOrder := 3; TSubGroupOrder := 0;
            fnUpdatePeriodTrans(strEmpCode, 'GRAT', TGroup, TGroupOrder,
                               TSubGroupOrder, strTransDescription, curTransAmount, CurGratuityAMount,
                               intMonth, intYear,Membership,ReferenceNo,SelectedPeriod,Dept,
                               GratuityAccount,JournalPostAs::Debit,JournalPostingType::"G/L Account",''
                               ,CoopParameters::none,TRUE,PostInGlobal::ERP,'');*/
            curTransAmount := curBasicPay;
            strTransDescription := 'Basic Pay';
            TGroup := 'BASIC SALARY';
            TGroupOrder := 1;
            TSubGroupOrder := 1;
            fnUpdatePeriodTrans(strEmpCode, 'BPAY', TGroup, TGroupOrder, TSubGroupOrder, strTransDescription, curTransAmount, curBPAYBal, intMonth, intYear, Membership, ReferenceNo, SelectedPeriod, Dept, salariesAcc, JournalPostAs::Debit, JournalPostingType::"G/L Account", '', CoopParameters::none, true, PostInGlobal::ERP, '');
            HREmp2.Get(strEmpCode);
            prTransactionCodes.Reset;
            prTransactionCodes.SetRange("For Every Employee", true);
            prTransactionCodes.SetFilter("Specific Month", '=%1', 0);
            if prTransactionCodes.FindSet then begin
                repeat
                    prEmployeeTransactions.Init;
                    prEmployeeTransactions.Validate("Employee Code", strEmpCode);
                    prEmployeeTransactions.Validate("Transaction Code", prTransactionCodes.Code);
                    prEmployeeTransactions.Validate("Payroll Period", SelectedPeriod);
                    prTransactionCodes.Get(prEmployeeTransactions."Transaction Code");
                    if prTransactionCodes."P10 Allowance Type" in [prTransactionCodes."P10 Allowance Type"::Leave] then begin
                        if EmployeePayrollScales.Get(HREmp2."Job Scale") then begin
                            prEmployeeTransactions.Amount := EmployeePayrollScales."Leave Allowance Amount";
                            prEmployeeTransactions."Temporary Transaction" := true;
                        end;
                    end
                    else
                        prEmployeeTransactions.Validate(Amount, prTransactionCodes.Amount);
                    if not prEmployeeTransactions.Get(strEmpCode, prTransactionCodes.Code, SelectedPeriod, intMonth, intYear) then begin
                        if prTransactionCodes."Employee Category" in [prTransactionCodes."Employee Category"::"Long Term"] then if HREmp2."Long Term" then prEmployeeTransactions.Insert;
                        if prTransactionCodes."Employee Category" in [prTransactionCodes."Employee Category"::"Short Term"] then if not HREmp2."Long Term" then prEmployeeTransactions.Insert;
                        if prTransactionCodes."Employee Category" in [prTransactionCodes."Employee Category"::Both] then prEmployeeTransactions.Insert;
                    end
                    else begin
                        if prTransactionCodes."P10 Allowance Type" in [prTransactionCodes."P10 Allowance Type"::Leave] then begin
                            if EmployeePayrollScales.Get(HREmp2."Job Scale") then begin
                                prEmployeeTransactions.Amount := EmployeePayrollScales."Leave Allowance Amount";
                            end
                        end
                        else
                            prEmployeeTransactions.Amount := prTransactionCodes.Amount;
                        if prTransactionCodes."Employee Category" in [prTransactionCodes."Employee Category"::"Long Term"] then if HREmp2."Long Term" then prEmployeeTransactions.Modify(true);
                        if prTransactionCodes."Employee Category" in [prTransactionCodes."Employee Category"::"Short Term"] then if not HREmp2."Long Term" then prEmployeeTransactions.Modify(true);
                        if prTransactionCodes."Employee Category" in [prTransactionCodes."Employee Category"::Both] then prEmployeeTransactions.Modify(true);
                    end;
                until prTransactionCodes.Next = 0;
            end;
            prTransactionCodes.Reset;
            prTransactionCodes.SetRange("For Every Employee", true);
            prTransactionCodes.SetFilter("Specific Month", '>%1', 0);
            if prTransactionCodes.FindSet then begin
                repeat
                    if prTransactionCodes."Specific Month" = intMonth then begin
                        prEmployeeTransactions.Init;
                        prEmployeeTransactions.Validate("Employee Code", strEmpCode);
                        prEmployeeTransactions.Validate("Transaction Code", prTransactionCodes.Code);
                        prEmployeeTransactions.Validate("Payroll Period", SelectedPeriod);
                        prTransactionCodes.Get(prEmployeeTransactions."Transaction Code");
                        prEmployeeTransactions."Temporary Transaction" := true;
                        if prTransactionCodes."P10 Allowance Type" in [prTransactionCodes."P10 Allowance Type"::Leave] then begin
                            if EmployeePayrollScales.Get(HREmp2."Job Scale") then begin
                                prEmployeeTransactions.Amount := EmployeePayrollScales."Leave Allowance Amount";
                                prEmployeeTransactions."Temporary Transaction" := true;
                            end;
                        end
                        else
                            prEmployeeTransactions.Validate(Amount, prTransactionCodes.Amount);
                        if not prEmployeeTransactions.Get(strEmpCode, prTransactionCodes.Code, SelectedPeriod, intMonth, intYear) then begin
                            if prTransactionCodes."Employee Category" in [prTransactionCodes."Employee Category"::"Long Term"] then if HREmp2."Long Term" then prEmployeeTransactions.Insert;
                            if prTransactionCodes."Employee Category" in [prTransactionCodes."Employee Category"::"Short Term"] then if not HREmp2."Long Term" then prEmployeeTransactions.Insert;
                            if prTransactionCodes."Employee Category" in [prTransactionCodes."Employee Category"::Both] then prEmployeeTransactions.Insert;
                        end
                        else begin
                            if prTransactionCodes."P10 Allowance Type" in [prTransactionCodes."P10 Allowance Type"::Leave] then begin
                                if EmployeePayrollScales.Get(HREmp2."Job Scale") then begin
                                    prEmployeeTransactions.Amount := EmployeePayrollScales."Leave Allowance Amount";
                                end
                            end
                            else
                                prEmployeeTransactions.Amount := prTransactionCodes.Amount;
                            if prTransactionCodes."Employee Category" in [prTransactionCodes."Employee Category"::"Long Term"] then if HREmp2."Long Term" then prEmployeeTransactions.Modify(true);
                            if prTransactionCodes."Employee Category" in [prTransactionCodes."Employee Category"::"Short Term"] then if not HREmp2."Long Term" then prEmployeeTransactions.Modify(true);
                            if prTransactionCodes."Employee Category" in [prTransactionCodes."Employee Category"::Both] then prEmployeeTransactions.Modify(true);
                        end;
                    end;
                until prTransactionCodes.Next = 0;
            end;
            if HREmp2."Job Title" <> '' then begin
                PayrollTransactionJobs.Reset;
                PayrollTransactionJobs.SetRange("Job Id", HREmp2."Job Code");
                if PayrollTransactionJobs.FindFirst then begin
                    repeat
                        prEmployeeTransactions.Init;
                        prEmployeeTransactions.Validate("Transaction Code", PayrollTransactionJobs."Transaction Code");
                        prEmployeeTransactions.Validate("Employee Code", strEmpCode);
                        prEmployeeTransactions.Validate(Amount, PayrollTransactionJobs.Amount);
                        if not prEmployeeTransactions.Get(strEmpCode, PayrollTransactionJobs."Transaction Code", dtOpenPeriod, intMonth, intYear) then
                            prEmployeeTransactions.Insert
                        else begin
                            if prEmployeeTransactions.Get(strEmpCode, PayrollTransactionJobs."Transaction Code", dtOpenPeriod, intMonth, intYear) then begin
                                prEmployeeTransactions.Amount := PayrollTransactionJobs.Amount;
                                prEmployeeTransactions.Modify(true);
                            end;
                        end;
                    until PayrollTransactionJobs.Next = 0;
                end;
            end;
            //Get Earnings
            prEmployeeTransactions.Reset;
            prEmployeeTransactions.SetRange(prEmployeeTransactions."Employee Code", strEmpCode);
            prEmployeeTransactions.SetRange(prEmployeeTransactions."Period Month", intMonth);
            prEmployeeTransactions.SetRange(prEmployeeTransactions."Period Year", intYear);
            prEmployeeTransactions.SetRange("Payroll Period", SelectedPeriod);
            prEmployeeTransactions.SetRange(prEmployeeTransactions.Stopped, false);
            if prEmployeeTransactions.Find('-') then begin
                curTotAllowances := 0;
                repeat
                    prTransactionCodes.Reset;
                    prTransactionCodes.SetRange(prTransactionCodes.Code, prEmployeeTransactions."Transaction Code");
                    prTransactionCodes.SetRange(Type, prTransactionCodes.Type::Income);
                    if prTransactionCodes.Find('-') then begin
                        curTransAmount := 0;
                        curTransBalance := 0;
                        strTransDescription := '';
                        strExtractedFrml := '';
                        curIncludeinNet := 0;
                        if prTransactionCodes."Is Formula" then begin
                            if prTransactionCodes."Special Transactions" in [prTransactionCodes."Special Transactions"::"Acting Allowance"] then
                                strExtractedFrml := fnPureFormula(strEmpCode, intMonth, intYear, prTransactionCodes.Formula, true, prEmployeeTransactions."Transaction Code")
                            else
                                strExtractedFrml := fnPureFormula(strEmpCode, intMonth, intYear, prTransactionCodes.Formula, false, prEmployeeTransactions."Transaction Code");
                            curTransAmount := Round(fnFormulaResult(strExtractedFrml), 1);
                            if prTransactionCodes."Has Upper Limit" then begin
                                prTransactionCodes.TestField("Upper Limit");
                                if curTransAmount >= prTransactionCodes."Upper Limit" then
                                    curTransAmount := curTransAmount
                                else
                                    curTransAmount := prTransactionCodes."Upper Limit";
                            end;
                            prEmployeeTransactions.Amount := curTransAmount;
                            prEmployeeTransactions.Modify(true);
                        end
                        else begin
                            curTransAmount := prEmployeeTransactions.Amount;
                        end;
                        /*IF prTransactionCodes."P10 Allowance Type" IN [prTransactionCodes."P10 Allowance Type"::Leave] THEN
                          IF IanCheckLeaveAllowanceEntries(strEmpCode,SelectedPeriod,intYear) THEN
                            ERROR('Employee No. [%1] Has already been paid leave allowance',strEmpCode)
                          ELSE BEGIN
                            IanCreateLeaveAllowanceEntries(strEmpCode,SelectedPeriod,intYear,prEmployeeTransactions.Amount);
                            END;*/
                        if prTransactionCodes."Balance Type" = prTransactionCodes."Balance Type"::None then curTransBalance := 0;
                        if prTransactionCodes."Balance Type" = prTransactionCodes."Balance Type"::Increasing then curTransBalance := prEmployeeTransactions.Balance + curTransAmount;
                        if prTransactionCodes."Balance Type" = prTransactionCodes."Balance Type"::Reducing then curTransBalance := prEmployeeTransactions.Balance - curTransAmount;
                        if prTransactionCodes."Include in Net" = true then begin
                            curIncludeinNet := curTransAmount;
                        end;
                        if not (prTransactionCodes."Special Transactions" in [prTransactionCodes."Special Transactions"::Gratuity]) then begin
                            if (Date2DMY(dtDOE, 2) = Date2DMY(dtOpenPeriod, 2)) and (Date2DMY(dtDOE, 3) = Date2DMY(dtOpenPeriod, 3)) and (Date2DMY(dtDOE, 1) <> 1) then begin
                                CountDaysofMonth := fnDaysInMonth(dtDOE);
                                DaysWorked := fnDaysWorked(dtDOE, false);
                                curTransAmount := fnBasicPayProrated(strEmpCode, intMonth, intYear, curTransAmount, DaysWorked, CountDaysofMonth)
                            end;
                            //Prorate Basic Pay on    {What if someone leaves within the same month they are employed}
                            //IF NOT IsContractRenewed THEN BEGIN
                            if dtTermination <> 0D then begin
                                if (Date2DMY(dtTermination, 2) = Date2DMY(dtOpenPeriod, 2)) and (Date2DMY(dtTermination, 3) = Date2DMY(dtOpenPeriod, 3)) then begin
                                    CountDaysofMonth := fnDaysInMonth(dtTermination);
                                    DaysWorked := fnDaysWorked(dtTermination, true);
                                    curTransAmount := fnBasicPayProrated(strEmpCode, intMonth, intYear, curTransAmount, DaysWorked, CountDaysofMonth)
                                end;
                            end;
                        end;
                        //END;
                        // Prorate Allowances Here
                        //Add Non Taxable Here
                        if (not prTransactionCodes.Taxable) and (prTransactionCodes."Special Transactions" = prTransactionCodes."Special Transactions"::None) then curNonTaxable := curNonTaxable + curTransAmount;
                        //Added to ensure special transaction that are not taxable are not inlcuded in list of Allowances
                        if (not prTransactionCodes.Taxable) and (prTransactionCodes."Special Transactions" <> prTransactionCodes."Special Transactions"::None) then curTransAmount := 0;
                        curTotAllowances := curTotAllowances + curTransAmount;
                        curTransAmount := curTransAmount;
                        curTransBalance := curTransBalance;
                        strTransDescription := prTransactionCodes.Name;
                        TGroup := 'ALLOWANCE';
                        TGroupOrder := 3;
                        TSubGroupOrder := 0;
                        JournalPostingType := JournalPostingType::" ";
                        JournalAc := '';
                        if prTransactionCodes."Sub Ledger Type" <> prTransactionCodes."Sub Ledger Type"::" " then begin
                            if prTransactionCodes."Sub Ledger Type" = prTransactionCodes."Sub Ledger Type"::Customer then begin
                                Customer.Reset;
                                Customer.SetRange(Customer."No.", strEmpCode);
                                if Customer.Find('-') then begin
                                    JournalAc := strEmpCode;
                                    JournalPostingType := JournalPostingType::Customer;
                                end;
                            end;
                            if prTransactionCodes."Sub Ledger Type" = prTransactionCodes."Sub Ledger Type"::Vendor then begin
                                HREmployes.Reset;
                                HREmployes.SetRange(HREmployes."No.", strEmpCode);
                                if HREmployes.Find('-') then begin
                                    JournalAc := prEmployeeTransactions."Subledger Account";
                                    JournalPostingType := JournalPostingType::Vendor;
                                end;
                            end;
                        end
                        else begin
                            JournalPostingType := JournalPostingType::"G/L Account";
                            JournalAc := prTransactionCodes."GL Account No.";
                        end;
                        fnUpdatePeriodTrans(strEmpCode, prTransactionCodes.Code, TGroup, TGroupOrder, TSubGroupOrder, strTransDescription, curTransAmount, curTransBalance, intMonth, intYear, prEmployeeTransactions.Membership, prEmployeeTransactions."Reference No", SelectedPeriod, Dept, JournalAc, JournalPostAs::Debit, JournalPostingType, '', prTransactionCodes."Coop Parameter", true, PostInGlobal::ERP, '');
                    end;
                until prEmployeeTransactions.Next = 0;
            end;

            curGrossPay := (curBasicPay + curTotAllowances + curSalaryArrears + curIncludeGross) - CurSalaryRecoveryAmount;
            curTransAmount := Round(curGrossPay, 1);
            strTransDescription := 'Gross Pay';
            TGroup := 'GROSS PAY';
            TGroupOrder := 4;
            TSubGroupOrder := 0;
            fnUpdatePeriodTrans(strEmpCode, 'GPAY', TGroup, TGroupOrder, TSubGroupOrder, strTransDescription, curTransAmount, 0, intMonth, intYear, '', '', SelectedPeriod, Dept, '', JournalPostAs::Debit, JournalPostingType::" ", '', CoopParameters::none, false, PostInGlobal::" ", '');

            curNSSF := 0;

            if blnPaysNssf then
                curNSSF := Round(IanGetNSSFAmount(curGrossPay - StatutoriesExclusion(strEmpCode, SelectedPeriod)), 1);

            curTransAmount := curNSSF;
            strTransDescription := 'N.S.S.F';
            TGroup := 'STATUTORIES';
            TGroupOrder := 7;
            TSubGroupOrder := 1;
            fnUpdatePeriodTrans(strEmpCode, 'NSSF', TGroup, TGroupOrder, TSubGroupOrder, strTransDescription, curTransAmount, 0, intMonth, intYear, '', '', SelectedPeriod, Dept, NSSFEMPyee, JournalPostAs::Credit, JournalPostingType::"G/L Account", '', CoopParameters::NSSF, true, PostInGlobal::ERP, '');
            //Update Employer
            if blnPaysNssf then
                curTransAmount := curNSSF * curNssf_Employer_Factor;
            fnUpdateEmployerDeductions(strEmpCode, 'NSSF', 'EMP', TGroupOrder, TSubGroupOrder, strTransDescription, curTransAmount, 0, intMonth, intYear, '', '', SelectedPeriod, NSSFEMPyer, NSSFEMPyee);

            //Get the Defined contribution to post based on the Max Def contrb allowed   ****************All Defined Contributions not included
            curDefinedContrib := curNSSF;
            //(curNSSF + curPensionStaff + curNonTaxable) - curMorgageReliefAmount
            curTransAmount := curDefinedContrib;

            strTransDescription := 'Defined Contributions';
            TGroup := 'TAX CALCULATIONS';
            TGroupOrder := 6;
            TSubGroupOrder := 1;
            fnUpdatePeriodTrans(strEmpCode, 'DEFCON', TGroup, TGroupOrder, TSubGroupOrder, strTransDescription, curTransAmount, 0, intMonth, intYear, '', '', SelectedPeriod, Dept, '', JournalPostAs::Credit, JournalPostingType::" ", '', CoopParameters::none, false, PostInGlobal::" ", '');
            curGrossTaxable := (curGrossPay + curBenefits + curValueOfQuarters + TaxableGratuity) - CurGratuityAMount;
            if curGrossTaxable = 0 then curDefinedContrib := 0;
            //Added for auto relief calculation
            HREmp2.Get(strEmpCode);
            if ((curGrossPay - curNSSF) <= currMinRelief) then begin
                blnGetsPAYERelief := false;
            end
            else begin
                blnGetsPAYERelief := true;
                //If employee is marked on salary card as not entitle to personal relief
                PRSalCard_2.Reset;
                if PRSalCard_2.Get(strEmpCode) then begin
                    if PRSalCard_2."Stop Relief" or HREmp2.Disabled then blnGetsPAYERelief := false;
                end;
            end;
            Prsalary.Get(strEmpCode);
            blnGetsPAYERelief := Prsalary."Pays PAYE";
            HREmp2.Get(strEmpCode);
            if (HREmp2.Disabled) then begin
                if curGrossPay > curDisabledLimit then
                    blnGetsPAYERelief := true
                else
                    blnGetsPAYERelief := false;
            end;
            blnsIsSecondaryEmployee := false;
            if HREmployee.Get(strEmpCode) then if HREmployee."Nature Of Employment" in [HREmployee."Nature Of Employment"::Seconded] then blnsIsSecondaryEmployee := true;
            if blnsIsSecondaryEmployee then blnGetsPAYERelief := false;
            Prsalary.Get(strEmpCode);
            if blnGetsPAYERelief then begin
                curReliefPersonal := curReliefPersonal + curUnusedRelief;
                //*****Get curUnusedRelief
                curTransAmount := curReliefPersonal;
                strTransDescription := 'Personal Relief';
                TGroup := 'TAX CALCULATIONS';
                TGroupOrder := 6;
                TSubGroupOrder := 9;
                fnUpdatePeriodTrans(strEmpCode, 'PSNR', TGroup, TGroupOrder, TSubGroupOrder, strTransDescription, curTransAmount, 0, intMonth, intYear, '', '', SelectedPeriod, Dept, '', JournalPostAs::Credit, JournalPostingType::" ", '', CoopParameters::none, false, PostInGlobal::" ", '');
            end
            else
                curReliefPersonal := 0;
            //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            //>Pension Contribution [self] relief
            TaxablePension := 0;
            curPensionStaff := fnGetSpecialTransAmount(strEmpCode, intMonth, intYear, SpecialTransType::"Defined Contribution", false);
            //Self contrib Pension is 1 on [Special Transaction]
            if curPensionStaff > 0 then begin
                if curPensionStaff >= curMaxPensionContrib then begin
                    curTransAmount := Round(curMaxPensionContrib, 1);
                    TaxablePension := (curPensionStaff + (curNssf_Employer_Factor * curNSSF)) - curMaxPensionContrib;
                end
                else
                    curTransAmount := Round(curPensionStaff, 1);
                strTransDescription := 'Pension Relief';
                TGroup := 'TAX CALCULATIONS';
                TGroupOrder := 6;
                TSubGroupOrder := 2;
                fnUpdatePeriodTrans(strEmpCode, 'PNSR', TGroup, TGroupOrder, TSubGroupOrder, strTransDescription, curTransAmount, 0, intMonth, intYear, '', '', SelectedPeriod, Dept, '', JournalPostAs::Credit, JournalPostingType::" ", '', CoopParameters::none, false, PostInGlobal::" ", '');
                strTransDescription := 'Taxable Pension';
                TGroup := 'TAX CALCULATIONS';
                TGroupOrder := 6;
                TSubGroupOrder := 2;
                fnUpdatePeriodTrans(strEmpCode, 'TPNSR', TGroup, TGroupOrder, TSubGroupOrder, strTransDescription, TaxablePension, 0, intMonth, intYear, '', '', SelectedPeriod, Dept, '', JournalPostAs::Credit, JournalPostingType::" ", '', CoopParameters::none, false, PostInGlobal::" ", '')
            end;
            //if he PAYS paye only*******************I
            InsuranceCert := false;
            if salCard.Get(strEmpCode) then InsuranceCert := salCard."Insurance Certificate?";
            if blnPaysPaye and blnGetsPAYERelief and InsuranceCert then begin
                //Get Insurance Relief
                curInsuranceReliefAmount := fnGetSpecialTransAmount(strEmpCode, intMonth, intYear, SpecialTransType::"Life Insurance", false); //Insurance is 3 on [Special Transaction]
                //********************************************************************************************************************************************************
                //Added DW - for employees who have brought the Insurance certificate, they are entitled to Insurance relief, Otherwise NO
                //Place a check mark on the Salary Card to YES
                if (curInsuranceReliefAmount > 0) and (InsuranceCert) then begin //AND (blnInsuranceCertificate)THEN BEGIN
                    curTransAmount := Round(curInsuranceReliefAmount, 1);
                    strTransDescription := 'Insurance Relief';
                    TGroup := 'TAX CALCULATIONS';
                    TGroupOrder := 6;
                    TSubGroupOrder := 8;
                    fnUpdatePeriodTrans(strEmpCode, 'INSR', TGroup, TGroupOrder, TSubGroupOrder, strTransDescription, curTransAmount, 0, intMonth, intYear, '', '', SelectedPeriod, Dept, '', JournalPostAs::Credit, JournalPostingType::" ", '', CoopParameters::none, false, PostInGlobal::" ", '');
                end;
                //********************************************************************************************************************************************************
                //Get Pension Relief
                curPensionReliefAmount := fnGetSpecialTransAmount(strEmpCode, intMonth, intYear, SpecialTransType::Pension, false); //Insurance is 3 on [Special Transaction]
                if curPensionReliefAmount > 0 then begin
                    curTransAmount := curPensionReliefAmount;
                    strTransDescription := 'Insurance Pension Relief';
                    TGroup := 'TAX CALCULATIONS';
                    TGroupOrder := 6;
                    TSubGroupOrder := 8;
                    fnUpdatePeriodTrans(strEmpCode, 'IPR', TGroup, TGroupOrder, TSubGroupOrder, strTransDescription, curTransAmount, 0, intMonth, intYear, '', '', SelectedPeriod, Dept, '', JournalPostAs::Credit, JournalPostingType::" ", '', CoopParameters::none, false, PostInGlobal::" ", '');
                end;
                //HOSP
                curHOSP := fnGetSpecialTransAmount(strEmpCode, intMonth, intYear, SpecialTransType::"Home Ownership Savings Plan", false); //Home Ownership Savings Plan
                if curHOSP > 0 then begin
                    if curHOSP <= curReliefMorgage then
                        curTransAmount := curHOSP
                    else
                        curTransAmount := curReliefMorgage;
                    strTransDescription := 'Home Ownership Savings Plan';
                    TGroup := 'TAX CALCULATIONS';
                    TGroupOrder := 6;
                    TSubGroupOrder := 4;
                    fnUpdatePeriodTrans(strEmpCode, 'HOSP', TGroup, TGroupOrder, TSubGroupOrder, strTransDescription, curTransAmount, 0, intMonth, intYear, '', '', SelectedPeriod, Dept, '', JournalPostAs::Credit, JournalPostingType::" ", '', CoopParameters::none, false, PostInGlobal::ERP, '');
                end;
                //Dann
                //Mortage Relief
                curMorgageRelief := fnGetSpecialTransAmount(strEmpCode, intMonth, intYear, SpecialTransType::"Mortgage Relief", false);
                if curMorgageRelief > 0 then begin
                    curTransAmount := curMorgageRelief;
                    strTransDescription := 'Mortgage Relief';
                    TGroup := 'TAX CALCULATIONS';
                    TGroupOrder := 6;
                    TSubGroupOrder := 9;
                    fnUpdatePeriodTrans(strEmpCode, 'MORG-RL', TGroup, TGroupOrder, TSubGroupOrder, strTransDescription, curTransAmount, 0, intMonth, intYear, '', '', SelectedPeriod, Dept, '', JournalPostAs::Credit, JournalPostingType::" ", '', CoopParameters::none, false, PostInGlobal::" ", '');
                end;
                //Fringe Benefits and Low interest Benefits
                curFringeBenefit := 0;
                fnCalcFringeBenefit := 0;
                prEmployeeTransactions.Reset;
                prEmployeeTransactions.SetRange("Employee Code", strEmpCode);
                prEmployeeTransactions.SetRange("Payroll Period", SelectedPeriod);
                if prEmployeeTransactions.FindSet then begin
                    repeat
                        if (prTransactionCodes.Get(prEmployeeTransactions."Transaction Code")) and (prTransactionCodes."Fringe Benefit") then begin
                            if prTransactionCodes."Interest Rate" < curLoanMarketRate then begin
                                fnCalcFringeBenefit := (((curLoanMarketRate - prTransactionCodes."Interest Rate")) / 1200) * prEmployeeTransactions.Balance;
                                curFringeBenefit := curFringeBenefit + fnCalcFringeBenefit;
                            end;
                        end until prEmployeeTransactions.Next = 0;
                end;
                if curFringeBenefit > 0 then begin
                    strTransDescription := 'Loan Benefit Deduction';
                    TGroup := 'TAX CALCULATIONS';
                    TGroupOrder := 6;
                    TSubGroupOrder := 1;
                    fnUpdatePeriodTrans(strEmpCode, 'FRINGE', TGroup, TGroupOrder, TSubGroupOrder, strTransDescription, Round(curFringeBenefit), 0, intMonth, intYear, '', '', SelectedPeriod, Dept, '', JournalPostAs::Credit, JournalPostingType::" ", '', CoopParameters::none, false, PostInGlobal::" ", '');
                end;
                //End Fringe Benefits
                //Enter NonTaxable Amount
                if curNonTaxable > 0 then begin
                    strTransDescription := 'Other Non-Taxable Benefits';
                    TGroup := 'TAX CALCULATIONS';
                    TGroupOrder := 6;
                    TSubGroupOrder := 5;
                    fnUpdatePeriodTrans(strEmpCode, 'NONTAX', TGroup, TGroupOrder, TSubGroupOrder, strTransDescription, curNonTaxable, 0, intMonth, intYear, '', '', SelectedPeriod, Dept, '', JournalPostAs::Credit, JournalPostingType::" ", '', CoopParameters::none, false, PostInGlobal::" ", '');
                end;
            end;
            //>OOI
            curOOI := fnGetSpecialTransAmount(strEmpCode, intMonth, intYear, SpecialTransType::"Owner Occupier Interest", false); //Morgage is LAST on [Special Transaction]
            if curOOI > 0 then begin
                if curOOI <= curOOIMaxMonthlyContrb then
                    curTransAmount := curOOI
                else
                    curTransAmount := curOOIMaxMonthlyContrb;
                strTransDescription := 'Owner Occupier Interest';
                TGroup := 'TAX CALCULATIONS';
                TGroupOrder := 6;
                TSubGroupOrder := 11;
                fnUpdatePeriodTrans(strEmpCode, 'OOI', TGroup, TGroupOrder, TSubGroupOrder, strTransDescription, curTransAmount, 0, intMonth, intYear, '', '', SelectedPeriod, Dept, '', JournalPostAs::Credit, JournalPostingType::" ", '', CoopParameters::none, false, PostInGlobal::" ", '');
            end;
            curSHIF_Base_Amount := 0;
            if intSHIF_BasedOn = intSHIF_BasedOn::Gross then //>SHIF calculation can be based on:
                curSHIF_Base_Amount := curGrossPay - StatutoriesExclusion(strEmpCode, SelectedPeriod);
            if intSHIF_BasedOn = intSHIF_BasedOn::Basic then curSHIF_Base_Amount := curBasicPay;
            if intSHIF_BasedOn = intSHIF_BasedOn::"Taxable Pay" then curSHIF_Base_Amount := curTaxablePay;
            if blnPaysSHIF then begin
                //curSHIF := fnGetEmployeeSHIF(curSHIF_Base_Amount);
                curSHIF := Round(curSHIF_Base_Amount * ("SHIF%" / 100), 1);
                curTransAmount := curSHIF;
                strTransDescription := 'S.H.I.F';
                TGroup := 'STATUTORIES';
                TGroupOrder := 7;
                TSubGroupOrder := 2;
                fnUpdatePeriodTrans(strEmpCode, 'SHIF', TGroup, TGroupOrder, TSubGroupOrder, strTransDescription, curTransAmount, 0, intMonth, intYear, '', '', SelectedPeriod, Dept, SHIFEMPyee, JournalPostAs::Credit, JournalPostingType::"G/L Account", '', CoopParameters::none, true, PostInGlobal::ERP, '');
                CurSHIFRelief := 0;
                CurSHIFRelief := Round(curSHIF * ("SHIFRelief%" / 100), 1);
                if (SHIFReliefEnabled and (CurSHIFRelief > 0)) then begin
                    curTransAmount := CurSHIFRelief;
                    strTransDescription := 'S.H.I.F Relief';
                    TGroup := 'TAX CALCULATIONS';
                    TGroupOrder := 6;
                    TSubGroupOrder := 9;
                    fnUpdatePeriodTrans(strEmpCode, 'SHIFREL', TGroup, TGroupOrder, TSubGroupOrder, strTransDescription, curTransAmount, 0, intMonth, intYear, '', '', SelectedPeriod, Dept, '', JournalPostAs::Credit, JournalPostingType::" ", '', CoopParameters::none, false, PostInGlobal::ERP, '');
                end;
            end;
            NHF_BaseAmount := 0;
            if intNHF_BasedOn = intNHF_BasedOn::Gross then
                NHF_BaseAmount := curGrossPay - StatutoriesExclusion(strEmpCode, SelectedPeriod);
            if intNHF_BasedOn = intNHF_BasedOn::Basic then
                NHF_BaseAmount := curBasicPay;
            if intNHF_BasedOn = intNHF_BasedOn::"Taxable Pay" then
                NHF_BaseAmount := curTaxablePay;

            if NHF_Enabled then begin
                curNHFAmount := Round(NHF_BaseAmount * (NHFPercentage / 100), 1);
                curTransAmount := curNHFAmount;
                strTransDescription := 'National Housing Fund';
                TGroup := 'STATUTORIES';
                TGroupOrder := 7;
                TSubGroupOrder := 2;
                fnUpdatePeriodTrans(strEmpCode, 'NHF', TGroup, TGroupOrder, TSubGroupOrder, strTransDescription, curTransAmount, 0, intMonth, intYear, '', '', SelectedPeriod, Dept, NHFAccount, JournalPostAs::Credit, JournalPostingType::"G/L Account", '', CoopParameters::none, true, PostInGlobal::ERP, '');
                fnUpdateEmployerDeductions(strEmpCode, 'NHF', 'EMP', TGroupOrder, TSubGroupOrder, strTransDescription, curTransAmount, 0, intMonth, intYear, '', '', SelectedPeriod, EmployerNHFAccount, NHFAccount);
                curHousingLevyRelief := 0;
                curHousingLevyRelief := curNHFAmount;
                if curHousingLevyRelief > 0 then begin
                    curTransAmount := curHousingLevyRelief;
                    strTransDescription := 'Housing Levy Relief';
                    TGroup := 'TAX CALCULATIONS';
                    TGroupOrder := 6;
                    TSubGroupOrder := 2;
                    fnUpdatePeriodTrans(strEmpCode, 'HL-RL', TGroup, TGroupOrder, TSubGroupOrder, strTransDescription, curTransAmount, 0, intMonth, intYear, '', '', SelectedPeriod, Dept, '', JournalPostAs::Credit, JournalPostingType::" ", '', CoopParameters::None, false, PostInGlobal::" ", '');
                end;
            end;
            if not blnsIsSecondaryEmployee then
                curTaxablePay := curGrossTaxable - (curSalaryArrears + curDefinedContrib + curOOI + curHOSP + curHousingLevyRelief + CurSHIFRelief + curNonTaxable + curPensionStaff) + BenifitAmount + curFringeBenefit + TaxablePension
            // curTaxablePay := curGrossTaxable - (curSalaryArrears + curOOI + curHOSP + curHousingLevyRelief + CurSHIFRelief + curSHIF + curNonTaxable + curPensionReliefAmount) + BenifitAmount + curFringeBenefit - TaxablePension
            else
                curTaxablePay := curGrossPay;
            curTaxablePay := Round(curTaxablePay, 1);
            //Gr
            HREmp2.Reset;
            if HREmp2.Get(strEmpCode) then begin
                if HREmp2.Disabled = true then curTransAmount -= 150000;
            end;
            curTransAmount := curTaxablePay;
            strTransDescription := 'Taxable Pay';
            TGroup := 'TAX CALCULATIONS';
            TGroupOrder := 6;
            TSubGroupOrder := 15;
            fnUpdatePeriodTrans(strEmpCode, 'TXBP', TGroup, TGroupOrder, TSubGroupOrder, strTransDescription, curTransAmount, 0, intMonth, intYear, '', '', SelectedPeriod, Dept, '', JournalPostAs::Credit, JournalPostingType::" ", '', CoopParameters::None, false, PostInGlobal::" ", '');
            //Get the Tax charged for the month
            //Added for auto relief calculation
            if ((curGrossPay - curNSSF) <= currMinRelief) and not (blnsIsSecondaryEmployee) then begin
                blnPaysPaye := false;
            end
            else begin
                blnPaysPaye := true;
            end;
            if blnPaysPaye then begin
                //Added:: Dann.... Special tax for disabled employee
                HREmp2.Reset;
                if HREmp2.Get(strEmpCode) then begin
                    if HREmp2.Disabled = true then begin
                        //  blnPaysPaye:=FALSE;
                        //gr
                        if blnsIsSecondaryEmployee then
                            curTaxCharged := fnGetEmployeePaye(curTaxablePay - curDisabledLimit, true)
                        else
                            curTaxCharged := fnGetEmployeePaye(curTaxablePay - curDisabledLimit, false);
                        if curTaxCharged < 0 then curTaxCharged := 0;
                        curTransAmount := curTaxCharged;
                        strTransDescription := 'Tax Charged';
                        TGroup := 'TAX CALCULATIONS';
                        TGroupOrder := 6;
                        TSubGroupOrder := 20;
                        fnUpdatePeriodTrans(strEmpCode, 'TXCHRG', TGroup, TGroupOrder, TSubGroupOrder, strTransDescription, curTransAmount, 0, intMonth, intYear, '', '', SelectedPeriod, Dept, '', JournalPostAs::Credit, JournalPostingType::" ", '', CoopParameters::None, false, PostInGlobal::" ", '');
                        //-end Gr
                    end
                    else begin
                        if blnsIsSecondaryEmployee then
                            curTaxCharged := fnGetEmployeePaye(curTaxablePay, true)
                        else
                            curTaxCharged := fnGetEmployeePaye(curTaxablePay, false);
                        curTransAmount := curTaxCharged;
                        strTransDescription := 'Tax Charged';
                        TGroup := 'TAX CALCULATIONS';
                        TGroupOrder := 6;
                        TSubGroupOrder := 7;
                        fnUpdatePeriodTrans(strEmpCode, 'TXCHRG', TGroup, TGroupOrder, TSubGroupOrder, strTransDescription, curTransAmount, 0, intMonth, intYear, '', '', SelectedPeriod, Dept, '', JournalPostAs::Credit, JournalPostingType::" ", '', CoopParameters::None, false, PostInGlobal::" ", '');
                        //MESSAGE(FORMAT('herere'));
                    end;
                end;
            end;
            if blnsIsSecondaryEmployee then blnGetsPAYERelief := false;
            if blnGetsPAYERelief and (curTaxCharged > 0) then begin
                curReliefPersonal := curReliefPersonal + curUnusedRelief; //*****Get curUnusedRelief
                curTransAmount := curReliefPersonal;
                strTransDescription := 'Personal Relief';
                TGroup := 'TAX CALCULATIONS';
                TGroupOrder := 6;
                TSubGroupOrder := 9;
                fnUpdatePeriodTrans(strEmpCode, 'PSNR', TGroup, TGroupOrder, TSubGroupOrder, strTransDescription, curTransAmount, 0, intMonth, intYear, '', '', SelectedPeriod, Dept, '', JournalPostAs::Credit, JournalPostingType::" ", '', CoopParameters::None, false, PostInGlobal::" ", '');
            end
            else
                curReliefPersonal := 0;
            //Get Insurance Relief
            if (curTaxCharged - curReliefPersonal <> 0) then begin
                curInsuranceReliefAmount := fnGetSpecialTransAmount(strEmpCode, intMonth, intYear, SpecialTransType::"Life Insurance", false);
                if curTaxCharged - curReliefPersonal < curInsuranceReliefAmount then curInsuranceReliefAmount := curTaxCharged - curReliefPersonal;
                if (curInsuranceReliefAmount > 0) then begin //AND (blnInsuranceCertificate)THEN BEGIN
                    curTransAmount := Round(curInsuranceReliefAmount, 1);
                    strTransDescription := 'Insurance Relief';
                    TGroup := 'TAX CALCULATIONS';
                    TGroupOrder := 6;
                    TSubGroupOrder := 8;
                    fnUpdatePeriodTrans(strEmpCode, 'INSR', TGroup, TGroupOrder, TSubGroupOrder, strTransDescription, curTransAmount, 0, intMonth, intYear, '', '', SelectedPeriod, Dept, '', JournalPostAs::Credit, JournalPostingType::" ", '', CoopParameters::None, false, PostInGlobal::" ", '');
                end;
            end;
            //Get the Net PAYE amount to post for the month
            if blnsIsSecondaryEmployee then
                curPAYE := curTaxCharged
            else begin
                if (curReliefPersonal + curInsuranceReliefAmount) > curMaximumRelief then begin
                    curPAYE := curTaxCharged - curMaximumRelief; //hosea
                end
                else begin
                    //******************************************************************************************************************************************
                    //Added DW: Only for Employees who have brought their insurance Certificate are entitled to Insurance Relief Otherwise NO
                    //Place a check mark on the Salary Card to YES
                    if (curInsuranceReliefAmount > 0) then begin
                        curPAYE := curTaxCharged - (curReliefPersonal + curInsuranceReliefAmount);
                    end
                    else begin
                        curPAYE := curTaxCharged - curReliefPersonal;
                    end;
                    //******************************************************************************************************************************************
                end;
            end;
            //Added for auto PAYE calculation
            if (curGrossPay - curNSSF) <= currMinRelief then begin
                blnPaysPaye := false;
            end
            else begin
                blnPaysPaye := true;
            end;
            //P.A.Y.for Board members
            HREmployee.Reset;
            HREmployee.SetRange(HREmployee."No.", strEmpCode);
            HREmployee.SetRange(HREmployee."Nature Of Employment", HREmployee."Nature Of Employment"::Board);
            if HREmployee.Find('-') then
                curPAYE := curBasicPay * 0.3
            else // MESSAGE(FORMAT(curBasicPay));
                if not blnPaysPaye then curPAYE := 0; //Get statutory Exemption for the staff. If exempted from tax, set PAYE=0
            curTransAmount := curPAYE;
            if curPAYE < 0 then curTransAmount := 0;
            strTransDescription := 'P.A.Y.E';
            TGroup := 'STATUTORIES';
            TGroupOrder := 7;
            TSubGroupOrder := 3;
            fnUpdatePeriodTrans(strEmpCode, 'PAYE', TGroup, TGroupOrder, TSubGroupOrder, strTransDescription, curTransAmount, 0, intMonth, intYear, '', '', SelectedPeriod, Dept, TaxAccount, JournalPostAs::Credit, JournalPostingType::"G/L Account", '', CoopParameters::None, true, PostInGlobal::ERP, '');
        end;
        //Calculate company deductions
        prEmployeeTransactions.Reset;
        prEmployeeTransactions.SetRange(prEmployeeTransactions."Employee Code", strEmpCode);
        prEmployeeTransactions.SetRange(prEmployeeTransactions."Period Month", intMonth);
        prEmployeeTransactions.SetRange(prEmployeeTransactions."Period Year", intYear);
        prEmployeeTransactions.SetRange(prEmployeeTransactions.Stopped, false);
        if prEmployeeTransactions.Find('-') then begin
            curTotalDeductions := 0;
            repeat
                prTransactionCodes.Reset;
                prTransactionCodes.SetRange(prTransactionCodes.Code, prEmployeeTransactions."Transaction Code");
                prTransactionCodes.SetRange(prTransactionCodes.Type, prTransactionCodes.Type::"Company Deduction");
                if prTransactionCodes.Find('-') then begin
                    curTransAmount := 0;
                    curTransBalance := 0;
                    strTransDescription := '';
                    strExtractedFrml := '';
                    strTransDescription := prTransactionCodes.Name;
                    JournalAc := prTransactionCodes."GL Account No.";
                    if prTransactionCodes."Is Formula" then begin
                        strExtractedFrml := fnPureFormula(strEmpCode, intMonth, intYear, prTransactionCodes.Formula, false, prEmployeeTransactions."Transaction Code");
                        curTransAmount := fnFormulaResult(strExtractedFrml); //Get the calculated amount
                        prEmployeeTransactions.Amount := Round(curTransAmount, 1);
                        prEmployeeTransactions.Modify(true);
                    end
                    else begin
                        curTransAmount := prEmployeeTransactions.Amount;
                    end;
                    if prTransactionCodes."Has Upper Limit" then begin
                        prTransactionCodes.TestField("Upper Limit");
                        if curTransAmount >= prTransactionCodes."Upper Limit" then
                            curTransAmount := curTransAmount
                        else
                            curTransAmount := prTransactionCodes."Upper Limit";
                    end;
                    prEmployeeTransactions.Amount := curTransAmount;
                    prEmployeeTransactions.Modify(true);
                    if prTransactionCodes."Balance Type" = prTransactionCodes."Balance Type"::None then curTransBalance := 0;
                    if prTransactionCodes."Balance Type" = prTransactionCodes."Balance Type"::Increasing then curTransBalance := prEmployeeTransactions.Balance + curTransAmount;
                    if prTransactionCodes."Balance Type" = prTransactionCodes."Balance Type"::Reducing then curTransBalance := prEmployeeTransactions.Balance - curTransAmount;
                    TGroup := 'EMPLOYER';
                    TGroupOrder := 8;
                    TSubGroupOrder := 0;
                    fnUpdatePeriodTrans(strEmpCode, prEmployeeTransactions."Transaction Code", TGroup, TGroupOrder, TSubGroupOrder, strTransDescription, curTransAmount, curTransBalance, intMonth, intYear, prEmployeeTransactions.Membership, prEmployeeTransactions."Reference No", SelectedPeriod, Dept, JournalAc, JournalPostAs::Credit, JournalPostingType, prEmployeeTransactions."Loan Number", prTransactionCodes."Coop Parameter", true, PostInGlobal::ERP, '');
                end;
            until prEmployeeTransactions.Next = 0;
        end;
        //Calculate Company Deductions Korir
        prEmployeeTransactions.Reset;
        prEmployeeTransactions.SetRange(prEmployeeTransactions."Employee Code", strEmpCode);
        prEmployeeTransactions.SetRange(prEmployeeTransactions."Period Month", intMonth);
        prEmployeeTransactions.SetRange(prEmployeeTransactions."Period Year", intYear);
        prEmployeeTransactions.SetRange("Payroll Period", SelectedPeriod);
        prEmployeeTransactions.SetRange(prEmployeeTransactions.Stopped, false);
        if prEmployeeTransactions.Find('-') then begin
            curTotalDeductions := 0;
            repeat
                prTransactionCodes.Reset;
                prTransactionCodes.SetRange(prTransactionCodes.Code, prEmployeeTransactions."Transaction Code");
                prTransactionCodes.SetRange(prTransactionCodes.Type, prTransactionCodes.Type::Deduction);
                if prTransactionCodes.Find('-') then begin
                    curTransAmount := 0;
                    curTransBalance := 0;
                    strTransDescription := '';
                    strExtractedFrml := '';
                    if prTransactionCodes."Is Formula" then begin
                        strExtractedFrml := fnPureFormula(strEmpCode, intMonth, intYear, prTransactionCodes.Formula, false, prEmployeeTransactions."Transaction Code");
                        curTransAmount := fnFormulaResult(strExtractedFrml); //Get the calculated amount
                        prEmployeeTransactions.Amount := Round(curTransAmount, 1);
                        prEmployeeTransactions.Modify(true);
                    end
                    else begin
                        curTransAmount := prEmployeeTransactions.Amount;
                    end;
                    //Commented By Henry
                    // if prTransactionCodes."Coop Parameter" in [prTransactionCodes."Coop Parameter"::"loan Interest"] then begin
                    //     curTransAmount := fnCalcLoanInterest(strEmpCode, PRTransCode.Code, prTransactionCodes."Interest Rate",
                    //                     prTransactionCodes."Repayment Method", IanGetLoanAmount(prTransactionCodes.Code, strEmpCode),
                    //                     IanGetLoanAmount(prTransactionCodes.Code, strEmpCode), dtOpenPeriod);
                    //     prEmployeeTransactions.Amount := curTransAmount;
                    //     prEmployeeTransactions.Modify(true);
                    // end;
                    if prTransactionCodes."Special Transactions" in [prTransactionCodes."Special Transactions"::"Imprest Recovery"] then prEmployeeTransactions.TestField("Imprest No");
                    //**************************If "deduct Premium" is not ticked and the type is insurance- Dennis*****
                    if (prTransactionCodes."Special Transactions" = prTransactionCodes."Special Transactions"::"Life Insurance") and (prTransactionCodes."Deduct Premium" = false) then begin
                        curTransAmount := 0;
                    end;
                    //**************************If "deduct Premium" is not ticked and the type is mortgage- Dennis*****
                    if (prTransactionCodes."Special Transactions" = prTransactionCodes."Special Transactions"::Mortgage) and (prTransactionCodes."Deduct Mortgage" = false) then begin
                        curTransAmount := 0;
                    end;
                    //**************************If "deduct Premium" is not ticked and the type is mortgage- Dennis*****
                    if (prTransactionCodes."Special Transactions" = prTransactionCodes."Special Transactions"::Pension) and (prTransactionCodes.Welfare = false) then begin
                        curTransAmount := 0;
                    end;
                    //Get the posting Details
                    JournalPostingType := JournalPostingType::" ";
                    JournalAc := '';
                    if prTransactionCodes."Sub Ledger Type" <> prTransactionCodes."Sub Ledger Type"::" " then begin
                        //IF prTransactionCodes.Subledger=prTransactionCodes.Subledger::Customer THEN BEGIN
                        ////Customer.RESET;
                        // HrEmployee.GET(strEmpCode);
                        //   {
                        //Customer
                        if prTransactionCodes."Sub Ledger Type" = prTransactionCodes."Sub Ledger Type"::Customer then begin
                            //HrEmployee.GET(strEmpCode);
                            Customer.Reset;
                            Customer.SetRange(Customer."No.", strEmpCode);
                            if Customer.Find('-') then begin
                                JournalAc := strEmpCode;
                                JournalPostingType := JournalPostingType::Customer;
                            end;
                        end;
                        //FOR VENDOR
                        //***********************************
                        if prTransactionCodes."Sub Ledger Type" = prTransactionCodes."Sub Ledger Type"::Vendor then begin
                            HREmployes.Reset;
                            HREmployes.SetRange(HREmployes."No.", strEmpCode);
                            if HREmployes.Find('-') then begin
                                JournalAc := prEmployeeTransactions."Subledger Account";
                                JournalPostingType := JournalPostingType::Vendor;
                            end;
                        end;
                        //Credit
                        /*IF prTransactionCodes.Subledger=prTransactionCodes.Subledger::"3" THEN
                                        BEGIN
                                             CreditAcc.RESET;
                                             CreditAcc.SETRANGE(CreditAcc."Payroll/Staff No.",strEmpCode);
                                             CreditAcc.SETRANGE("Product Type",prTransactionCodes."Loan Product Type");
                                             IF CreditAcc.FIND('-') THEN
                                             BEGIN


                                                JournalAc:=CreditAcc."No.";
                                                JournalPostingType:=JournalPostingType::Credit;
                                             END;
                                         END;*/
                        //Savings
                        /* IF prTransactionCodes.Subledger=prTransactionCodes.Subledger::"4" THEN
                                         BEGIN
                                              SavingAcc.RESET;
                                              SavingAcc.SETRANGE(SavingAcc."Payroll/Staff No.",strEmpCode);
                                              SavingAcc.SETRANGE("Product Type",prTransactionCodes."Loan Product Type");
                                              IF SavingAcc.FIND('-') THEN
                                              BEGIN
                                                 JournalAc:=SavingAcc."No.";
                                                 JournalPostingType:=JournalPostingType::Savings;
                                              END;
                                          END;*/
                    end
                    else begin
                        JournalAc := prTransactionCodes."GL Account No.";
                        JournalPostingType := JournalPostingType::"G/L Account";
                    end;
                    //End posting Details
                    //Loan Calculation is Amortized do Calculations here -Monthly Principal and Interest Keeps on Changing
                    /*IF (prTransactionCodes."Special Transactions"=prTransactionCodes."Special Transactions"::"Staff Loan (Interest Varies)") AND
                       (prTransactionCodes."Repayment Method" = prTransactionCodes."Repayment Method"::Amortized) THEN BEGIN
                       curTransAmount:=0; curLoanInt:=0;

                      // IF NOT prEmployeeTransactions."Exempt from Interest" THEN prEmployeeTransactions.TESTFIELD(prEmployeeTransactions."Loan Interest Rate");

                       curLoanInt:=fnCalcLoanInterest (strEmpCode, prEmployeeTransactions."Transaction Code",
                       prEmployeeTransactions."Loan Interest Rate",prTransactionCodes."Repayment Method",
                          prEmployeeTransactions."Original Amount",prEmployeeTransactions.Balance,SelectedPeriod);
                       //Post the Interest
                       IF (curLoanInt<>0) THEN BEGIN
                              curTransAmount := curLoanInt;
                              curTotalDeductions := curTotalDeductions + curTransAmount; //Sum-up all the deductions
                              curTransBalance:=0;
                              strTransCode := prEmployeeTransactions."Transaction Code"+'-INT';
                              strTransDescription := prEmployeeTransactions."Transaction Name"+ ' Interest';
                              TGroup := 'DEDUCTIONS'; TGroupOrder := 8; TSubGroupOrder := 1;

                              fnUpdatePeriodTrans(strEmpCode, strTransCode, TGroup, TGroupOrder, TSubGroupOrder,
                                strTransDescription, curTransAmount, curTransBalance, intMonth, intYear,
                                prEmployeeTransactions.Membership, prEmployeeTransactions."Reference No",SelectedPeriod,Dept,
                                JournalAc,JournalPostAs::Credit,JournalPostingType,prEmployeeTransactions."Loan Number",
                                CoopParameters::"loan Interest",TRUE,PostInGlobal::ERP,prEmployeeTransactions."Imprest No")
                        END;
                       //Get the Principal Amt
                       curTransAmount:=prEmployeeTransactions."Amortized Loan Total Repay Amt"-curLoanInt;
                        //Modify PREmployeeTransaction Table
                        prEmployeeTransactions.Amount:=curTransAmount;
                        prEmployeeTransactions.MODIFY;
                    END;
                    //Loan Calculation Amortized
                    */
                    case prTransactionCodes."Balance Type" of //[0=None, 1=Increasing, 2=Reducing]
                        prTransactionCodes."Balance Type"::None:
                            curTransBalance := 0;
                        prTransactionCodes."Balance Type"::Increasing:
                            begin
                                //Added Dann
                                if prTransactionCodes."Special Transactions" <> prTransactionCodes."Special Transactions"::"Defined Contribution" then begin
                                    curTransAmount := prEmployeeTransactions.Amount;
                                end;
                                //Added Dann
                                curTransBalance := prEmployeeTransactions.Balance + curTransAmount;
                            end;
                        prTransactionCodes."Balance Type"::Reducing:
                            begin
                                curTransBalance := prEmployeeTransactions.Balance - curTransAmount;
                            end
                    end;
                    curTotalDeductions := curTotalDeductions + curTransAmount;
                    //Sum-up all the deductions
                    curTransAmount := curTransAmount;
                    curTransBalance := curTransBalance;
                    strTransDescription := prTransactionCodes.Name;
                    TGroup := 'DEDUCTIONS';
                    TGroupOrder := 8;
                    TSubGroupOrder := 0;
                    fnUpdatePeriodTrans(strEmpCode, prEmployeeTransactions."Transaction Code", TGroup, TGroupOrder, TSubGroupOrder, strTransDescription, curTransAmount, curTransBalance, intMonth, intYear, prEmployeeTransactions.Membership, prEmployeeTransactions."Reference No", SelectedPeriod, Dept, JournalAc, JournalPostAs::Credit, JournalPostingType, prEmployeeTransactions."Loan Number", prTransactionCodes."Coop Parameter", true, PostInGlobal::ERP, prEmployeeTransactions."Imprest No");

                    //Create Employer Deduction
                    if (prTransactionCodes."Employer Deduction") or (prTransactionCodes."Include Employer Deduction") then begin
                        if prTransactionCodes."Is Formula for employer" <> '' then begin
                            strExtractedFrml := fnPureFormula(strEmpCode, intMonth, intYear, prTransactionCodes."Is Formula for employer", false, prEmployeeTransactions."Transaction Code");
                            curTransAmount := fnFormulaResult(strExtractedFrml); //Get the calculated amount
                            if prTransactionCodes."GL Employer Account" = ''
                            then
                                Error('You have to specify the Employer Expense account for %1', prTransactionCodes.Code);
                            prEmployeeTransactions."Employer Amount" := Round(curTransAmount, 1);
                            prEmployeeTransactions.Modify(true);
                        end
                        else begin
                            curTransAmount := prEmployeeTransactions."Employer Amount";
                        end;
                        if curTransAmount > 0 then
                            fnUpdateEmployerDeductions(strEmpCode, prEmployeeTransactions."Transaction Code", 'EMP', TGroupOrder, TSubGroupOrder, prTransactionCodes.Name, curTransAmount, 0, intMonth, intYear, prEmployeeTransactions.Membership, prEmployeeTransactions."Reference No", SelectedPeriod, prTransactionCodes."GL Employer Account", prTransactionCodes."GL Account No.");
                        //Added Dann
                        //Update Balance on PR Period Transaction Table with Pension Contributed from Employer
                        /*PRPeriodTrans.RESET;
                                        PRPeriodTrans.SETRANGE(PRPeriodTrans."Employee Code",strEmpCode);
                                        PRPeriodTrans.SETRANGE(PRPeriodTrans."Transaction Code",prEmployeeTransactions."Transaction Code");
                                        PRPeriodTrans.SETRANGE(PRPeriodTrans."Payroll Period",SelectedPeriod);
                                        IF PRPeriodTrans.FIND('-') THEN
                                        BEGIN
                                           IF PRPeriodTrans.Balance <> 0 THEN PRPeriodTrans.Balance += curTransAmount;
                                           PRPeriodTrans.MODIFY;
                                        END;*/
                        //Added Dann
                    end;
                end;
            until prEmployeeTransactions.Next = 0;
            // RONO..Henry
            PRPeriodTrans.Reset;
            PRPeriodTrans.SetRange(PRPeriodTrans."Employee Code", strEmpCode);
            PRPeriodTrans.SetFilter("Group Text", '%1|%2', 'DEDUCTIONS', 'STATUTORIES');
            PRPeriodTrans.SetRange(PRPeriodTrans."Payroll Period", SelectedPeriod);
            if PRPeriodTrans.FindSet then begin
                PRPeriodTrans.CalcSums(Amount);
                IansTotalDeduction := PRPeriodTrans.Amount;
            end;
            //RONO..Henry
            //curTotalDeductions replaced with IansTotalDeduction
            //GET TOTAL DEDUCTIONS
            curTransBalance := 0;
            strTransCode := 'TOT-DED';
            strTransDescription := 'TOTAL DEDUCTION';
            TGroup := 'DEDUCTIONS';
            TGroupOrder := 8;
            TSubGroupOrder := 9;
            fnUpdatePeriodTrans(strEmpCode, strTransCode, TGroup, TGroupOrder, TSubGroupOrder, strTransDescription, IansTotalDeduction, curTransBalance, intMonth, intYear, prEmployeeTransactions.Membership, prEmployeeTransactions."Reference No", SelectedPeriod, Dept, '', JournalPostAs::Credit, JournalPostingType::" ", '', CoopParameters::none, false, PostInGlobal::" ", '');
            //END GET TOTAL DEDUCTIONS
        end;
        //Net Pay: calculate the Net pay for the month in the following manner:
        //>Nett = Gross - (xNssfAmount + curMySHIFAmt + PAYE + PayeArrears + prTotDeductions)
        //...Tot Deductions also include (SumLoan + SumInterest)
        curNetPay := curGrossPay - (curNSSF + curSHIF + curNHFAmount + curPAYE + curPayeArrears + curTotalDeductions); //-curIncludeinNet;
        //curNetPay:=curNetPay+curIncludeinNet;
        //>Nett = Nett - curExcessPension
        //...Excess pension is only used for tax. Staff is not paid the amount hence substract it
        curNetPay := curNetPay; //- curExcessPension
        //>Nett = Nett - cSumEmployerDeductions
        //...Employer Deductions are used for reporting as cost to company BUT dont affect Net pay
        //curNetPay := curNetPay - curTotCompanyDed; 
        //******Get Company Deduction*****
        curNetRnd_Effect := curNetPay - Round(curNetPay);
        curNetPay := Round(curNetPay, 1); //Check here
        curTransAmount := curNetPay;
        strTransDescription := 'Net Pay';
        TGroup := 'NET PAY';
        TGroupOrder := 9;
        TSubGroupOrder := 0;
        HREmp2.Get(strEmpCode);
        PRSalCard.Get(strEmpCode);
        IF (1 / 3 * PRSalCard."Basic Pay" > curNetPay) AND (PRSalCard."Basic Pay" > 0) THEN IF NOT HREmp2."Flout 1/3 Rule" THEN ERROR('Employee No %1 violates 1/3 rule', strEmpCode);
        fnUpdatePeriodTrans(strEmpCode, 'NPAY', TGroup, TGroupOrder, TSubGroupOrder, strTransDescription, curTransAmount, 0, intMonth, intYear, '', '', SelectedPeriod, Dept, PayablesAcc, JournalPostAs::Credit, JournalPostingType::"G/L Account", '', CoopParameters::none, true, PostInGlobal::ERP, '');
        fnUpdateP9Table(strEmpCode, curBasicPay, curTotAllowances, 0, 0, curDefinedContrib, curOOI, curGrossPay, curTaxablePay, curTaxCharged, curInsuranceReliefAmount, curReliefPersonal, curPAYE, curNSSF, curSHIF, curTotalDeductions, curNetPay, SelectedPeriod, curPensionStaff);
    end;

    procedure fnBasicPayProrated(strEmpCode: Code[20]; Month: Integer; Year: Integer; BasicSalary: Decimal; DaysWorked: Integer; DaysInMonth: Integer) ProratedAmt: Decimal
    begin
        ProratedAmt := Round((DaysWorked / 22) * BasicSalary, 1);
    end;

    procedure fnDaysInMonth(dtDate: Date) DaysInMonth: Integer
    var
        Day: Integer;
        SysDate: Record Date;
        Expr1: Text[30];
        FirstDay: Date;
        LastDate: Date;
        TodayDate: Date;
    begin
        TodayDate := dtDate;
        Day := Date2DMY(TodayDate, 1);
        Expr1 := Format(-Day) + 'D+1D';
        FirstDay := CalcDate('-CM', TodayDate);
        LastDate := CalcDate('CM', FirstDay);
        DaysInMonth := Date2DMY(CalcDate('CM', dtDate), 1);
        /*SysDate.RESET;
                        SysDate.SETRANGE(SysDate."Period Type",SysDate."Period Type"::Date);
                        SysDate.SETRANGE(SysDate."Period Start",FirstDay,LastDate);
                        SysDate.SETFILTER(SysDate."Period No.",'1..7');
                        IF SysDate.FIND('-') THEN
                           DaysInMonth:=SysDate.COUNT;*/
    end;

    procedure fnUpdatePeriodTrans(EmpCode: Code[20]; TCode: Code[20]; TGroup: Code[20]; GroupOrder: Integer; SubGroupOrder: Integer; Description: Text[50]; curAmount: Decimal; curBalance: Decimal; Month: Integer; Year: Integer; mMembership: Text[30]; ReferenceNo: Text[30]; dtOpenPeriod: Date; Department: Code[50]; JournalAC: Code[20]; PostAs: Option " ",Debit,Credit; JournalACType: Option " ","G/L Account",Customer,Vendor; LoanNo: Code[50]; CoopParam: Option "none",shares,loan,"loan Interest","Emergency loan","Emergency loan Interest","School Fees loan","School Fees loan Interest",Welfare,Pension; PostToJournal: Boolean; PostIn: Option " ",ERP,CBS; ImprestNo: Code[50])
    var
        PRPeriodTransactions: Record "Payroll Period Transaction";
        PRPeriodTransactionsCheck: Record "Payroll Period Transaction";
        curNetPay_2: Decimal;
        EmployeeLocal: Record Employee;
        PayrollTransactionCodeLocal: Record "Payroll Transaction Code";
        PaymentSuspended: Boolean;
        AmountHeld: Decimal;
        BPayHeld: Decimal;
        ReasonForHold: Text;
    begin
        if curAmount = 0 then
            exit;

        PaymentSuspended := false;
        AmountHeld := 0;
        BPayHeld := 0;

        if EmployeeLocal.Get(EmpCode) then PaymentSuspended := EmployeeLocal."Suspend Pay";
        if PaymentSuspended then begin
            if PayrollTransactionCodeLocal.Get(TCode) then
                if PayrollTransactionCodeLocal."Subject To Suspension" then begin
                    PayrollTransactionCodeLocal.TestField("Percentage To Hold");
                    AmountHeld := (PayrollTransactionCodeLocal."Percentage To Hold" / 100) * curAmount;
                    curAmount := curAmount - AmountHeld;
                end
                else begin
                    curAmount := curAmount;
                end;
            if TCode = 'BPAY' then
                if EmployeeLocal.Get(EmpCode) then begin
                    EmployeeLocal.TestField("Percentage To Hold");
                    EmployeeLocal.TestField("Reason For Pay Suspension");
                    ReasonForHold := EmployeeLocal."Reason For Pay Suspension";
                    AmountHeld := (EmployeeLocal."Percentage To Hold" / 100) * curAmount;
                    curAmount := curAmount - AmountHeld;
                end;
        end;
        if (curAmount = 0) and (AmountHeld = 0) then
            exit;

        //Determine if payment is suspended
        with PRPeriodTransactions do begin
            Init;
            "Employee Code" := EmpCode;
            Validate("Employee Code");
            "Transaction Code" := TCode;
            "Group Text" := TGroup;
            "Transaction Name" := Description;
            Amount := Round(curAmount, 1);
            Balance := Round(curBalance, 1);
            "Original Amount" := Balance;
            "Group Order" := GroupOrder;
            "Sub Group Order" := SubGroupOrder;
            Membership := mMembership;
            "Reference No" := ReferenceNo;
            "Period Month" := Month;
            "Period Year" := Year;
            "Payroll Period" := dtOpenPeriod;
            "Department Code" := Department;
            "Journal Account Type" := JournalACType;
            "Post As" := PostAs;
            "Journal Account Code" := JournalAC;
            "Loan Number" := LoanNo;
            "Coop Parameters" := CoopParam;
            "Amount Held" := Round(AmountHeld, 1);
            "Reason For Hold" := ReasonForHold;
            "Payment Held" := PaymentSuspended;
            "Post To Journal" := PostToJournal;
            "Post In" := PostIn;
            "Imprest No" := ImprestNo;
            if PayrollTransactionCodeLocal.Get("Transaction Code") then if PayrollTransactionCodeLocal."Special Transactions" in [PayrollTransactionCodeLocal."Special Transactions"::"Imprest Recovery"] then Subledger := Subledger::Employee;
            if TGroup = 'EMPLOYER' then "Company Deduction" := true;
            PRTransCode.Reset;
            PRTransCode.SetRange(PRTransCode.Code, TCode);
            if PRTransCode.Find('-') then begin
                "Transaction Type" := PRTransCode.Type;
            end;
            if not PRPeriodTransactionsCheck.Get(EmpCode, TCode, Month, Year, mMembership, ReferenceNo) then
                Insert(true)
            else begin
                PRPeriodTransactionsCheck := PRPeriodTransactions;
                PRPeriodTransactionsCheck.Modify;
            end;
        end;
    end;

    procedure fnGetSpecialTransAmount(strEmpCode: Code[20]; intMonth: Integer; intYear: Integer; intSpecTransID: Option Ignore,"Defined Contribution","Home Ownership Savings Plan","Life Insurance","Owner Occupier Interest","Prescribed Benefit","Salary Arrears","Staff Loan","Value of Quarters",Mortgage,Pension,"Mortgage Relief"; blnCompDedc: Boolean) SpecialTransAmount: Decimal
    var
        prEmployeeTransactions: Record "Payroll Employee Transaction";
        prTransactionCodes: Record "Payroll Transaction Code";
        strExtractedFrml: Text[250];
        MortgageInterest: Decimal;
        MortgageRelief: Decimal;
    begin
        SpecialTransAmount := 0;
        prTransactionCodes.Reset;
        prTransactionCodes.SetRange(prTransactionCodes."Special Transactions", intSpecTransID);
        if prTransactionCodes.Find('-') then begin
            repeat
                prEmployeeTransactions.Reset;
                prEmployeeTransactions.SetRange(prEmployeeTransactions."Employee Code", strEmpCode);
                prEmployeeTransactions.SetRange(prEmployeeTransactions."Transaction Code", prTransactionCodes.Code);
                prEmployeeTransactions.SetRange(prEmployeeTransactions."Period Month", intMonth);
                prEmployeeTransactions.SetRange(prEmployeeTransactions."Period Year", intYear); //Added DW to not process Stopped Transactions
                if prEmployeeTransactions.Find('-') then begin
                    case intSpecTransID of
                        intSpecTransID::"Defined Contribution":
                            if prTransactionCodes."Is Formula" then begin
                                strExtractedFrml := '';
                                strExtractedFrml := fnPureFormula(strEmpCode, intMonth, intYear, prTransactionCodes.Formula, false, prEmployeeTransactions."Transaction Code");
                                SpecialTransAmount += Round(SpecialTransAmount + (fnFormulaResult(strExtractedFrml)), 1); //Get the calculated amount for the Special Transaction
                            end
                            else
                                SpecialTransAmount += prEmployeeTransactions.Amount;
                        intSpecTransID::"Life Insurance":
                            begin
                                SpecialTransAmount += Round(((curReliefInsurance / 100) * prEmployeeTransactions.Amount), 1);
                            end;
                        intSpecTransID::"Owner Occupier Interest":
                            SpecialTransAmount := Round(SpecialTransAmount + prEmployeeTransactions.Amount, 1);
                        intSpecTransID::"Home Ownership Savings Plan":
                            begin
                                SpecialTransAmount := Round(SpecialTransAmount + prEmployeeTransactions.Balance, 1);
                                if SpecialTransAmount > 4000 then
                                    SpecialTransAmount := 4000;
                            end;
                        intSpecTransID::Pension:
                            begin
                                SpecialTransAmount := Round(SpecialTransAmount + ((curReliefPension / 100) * prEmployeeTransactions.Balance), 1);
                                if SpecialTransAmount > curMaxPensionContrib then
                                    SpecialTransAmount := curMaxPensionContrib
                            end;
                        intSpecTransID::Mortgage:
                            begin
                                SpecialTransAmount := Round(SpecialTransAmount + curReliefMorgage, 1);
                                if SpecialTransAmount > curReliefMorgage then begin
                                    SpecialTransAmount := curReliefMorgage
                                end;
                            end;
                        //Dann
                        intSpecTransID::"Mortgage Relief":
                            begin
                                //Intrest = 6%/12 * Curr Balance
                                MortgageInterest := (0.06 / 12) * prEmployeeTransactions."Original Amount";
                                if MortgageInterest < curReliefMorgage then begin
                                    MortgageRelief := 0.3 * MortgageInterest;
                                end;
                                if MortgageInterest > curReliefMorgage then begin
                                    MortgageRelief := 0.3 * curReliefMorgage;
                                end;
                                SpecialTransAmount := Round(MortgageRelief, 1);
                            end;
                    //Dann
                    end;
                end;
            until prTransactionCodes.Next = 0;
        end;
    end;

    procedure fnGetEmployeePaye(curTaxablePay: Decimal; IsSecondaryEmployee: Boolean) PAYE: Decimal
    var
        prPAYE: Record "Payroll PAYE";
        curTempAmount: Decimal;
        KeepCount: Integer;
    begin
        KeepCount := 0;
        if not IsSecondaryEmployee then begin
            prPAYE.Reset;
            if prPAYE.FindFirst then begin
                if curTaxablePay < prPAYE."PAYE Tier" then exit;
                repeat
                    KeepCount += 1;
                    curTempAmount := curTaxablePay;
                    if curTaxablePay = 0 then exit;
                    if KeepCount = prPAYE.Count then //this is the last record or loop
                        curTaxablePay := curTempAmount
                    else if curTempAmount >= prPAYE."PAYE Tier" then
                        curTempAmount := prPAYE."PAYE Tier"
                    else
                        curTempAmount := curTempAmount;
                    PAYE := PAYE + (curTempAmount * (prPAYE.Rate / 100));
                    curTaxablePay := curTaxablePay - curTempAmount;
                until prPAYE.Next = 0;
            end;
        end
        else
            PAYE := curTaxablePay * (SecondaryTaxPercentage / 100);
    end;

    procedure fnGetEmployeeSHIF(curBaseAmount: Decimal) SHIF: Decimal
    var
        prSHIF: Record "Payroll SHIF";
    begin
        prSHIF.Reset;
        prSHIF.SetCurrentKey(prSHIF."Tier Code");
        if prSHIF.FindFirst then begin
            repeat
                if ((curBaseAmount >= prSHIF."Lower Limit") and (curBaseAmount <= prSHIF."Upper Limit")) then SHIF := prSHIF.Amount;
            until prSHIF.Next = 0;
        end;
    end;

    procedure fnPureFormula(strEmpCode: Code[20]; intMonth: Integer; intYear: Integer; strFormula: Text[250]; IsActingAllowance: Boolean; EmpTransCode: Code[30]) Formula: Text[250]
    var
        Where: Text[30];
        Which: Text[30];
        i: Integer;
        TransCode: Code[20];
        Char: Text[1];
        FirstBracket: Integer;
        StartCopy: Boolean;
        FinalFormula: Text[250];
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
                TransCodeAmount := fnGetTransAmount(strEmpCode, TransCode, intMonth, intYear, IsActingAllowance, EmpTransCode);
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

    procedure fnGetTransAmount(strEmpCode: Code[20]; strTransCode: Code[20]; intMonth: Integer; intYear: Integer; IsActingAllowance: Boolean; TransCode: Code[30]): Decimal
    var
        prEmployeeTransactions: Record "Payroll Employee Transaction";
        prPeriodTransactions: Record "Payroll Period Transaction";
    begin
        if not IsActingAllowance then begin
            // prEmployeeTransactions.RESET;
            // prEmployeeTransactions.SETRANGE(prEmployeeTransactions."Employee Code",strEmpCode);
            // prEmployeeTransactions.SETRANGE(prEmployeeTransactions."Transaction Code",strTransCode);
            // prEmployeeTransactions.SETRANGE(prEmployeeTransactions."Period Month",intMonth);
            // prEmployeeTransactions.SETRANGE(prEmployeeTransactions."Period Year",intYear); //Added DW to not process Stopped Transactions
            // IF prEmployeeTransactions.FINDFIRST THEN
            //  TransAmount:=prEmployeeTransactions.Balance;
            prPeriodTransactions.Reset;
            prPeriodTransactions.SetRange(prPeriodTransactions."Employee Code", strEmpCode);
            prPeriodTransactions.SetRange(prPeriodTransactions."Transaction Code", strTransCode);
            prPeriodTransactions.SetRange(prPeriodTransactions."Period Month", intMonth);
            prPeriodTransactions.SetRange(prPeriodTransactions."Period Year", intYear);
            if prPeriodTransactions.FindFirst then exit(prPeriodTransactions.Amount);
        end;
        if IsActingAllowance then begin
            prEmployeeTransactions.Reset;
            prEmployeeTransactions.SetRange(prEmployeeTransactions."Employee Code", strEmpCode);
            prEmployeeTransactions.SetRange(prEmployeeTransactions."Transaction Code", TransCode);
            prEmployeeTransactions.SetRange(prEmployeeTransactions."Period Month", intMonth);
            prEmployeeTransactions.SetRange(prEmployeeTransactions."Period Year", intYear); //Added DW to not process Stopped Transactions
            if prEmployeeTransactions.FindFirst then exit(GetBasicPay(prEmployeeTransactions.Grade, prEmployeeTransactions.Pointer));
        end;
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

    procedure fnClosePayrollPeriod(dtOpenPeriod: Date) Closed: Boolean
    var
        dtNewPeriod: Date;
        intNewMonth: Integer;
        intNewYear: Integer;
        prEmployeeTransactions: Record "Payroll Employee Transaction";
        prPeriodTransactions: Record "Payroll Period Transaction";
        intMonth: Integer;
        intYear: Integer;
        prTransactionCodes: Record "Payroll Transaction Code";
        curTransAmount: Decimal;
        curTransBalance: Decimal;
        prEmployeeTrans: Record "Payroll Employee Transaction";
        prPayrollPeriods: Record "Payroll Periods";
        prNewPayrollPeriods: Record "Payroll Periods";
        CreateTrans: Boolean;
    begin
        //MESSAGE('Also include function to reset No. of days worked');
        dtNewPeriod := CalcDate('1M', dtOpenPeriod);
        intNewMonth := Date2DMY(dtNewPeriod, 2);
        intNewYear := Date2DMY(dtNewPeriod, 3);
        intMonth := Date2DMY(dtOpenPeriod, 2);
        intYear := Date2DMY(dtOpenPeriod, 3);
        prEmployeeTransactions.Reset;
        prEmployeeTransactions.SetRange(prEmployeeTransactions."Period Month", intMonth);
        prEmployeeTransactions.SetRange(prEmployeeTransactions."Period Year", intYear);
        if prEmployeeTransactions.Find('-') then begin
            repeat
                prTransactionCodes.Reset;
                prTransactionCodes.SetRange(prTransactionCodes.Code, prEmployeeTransactions."Transaction Code");
                if prTransactionCodes.Find('-') then begin
                    with prTransactionCodes do begin
                        case prTransactionCodes."Balance Type" of
                            prTransactionCodes."Balance Type"::None:
                                begin
                                    curTransAmount := prEmployeeTransactions.Balance;
                                    curTransBalance := 0;
                                end;
                            prTransactionCodes."Balance Type"::Increasing:
                                begin
                                    curTransAmount := prEmployeeTransactions.Balance;
                                    curTransBalance := prEmployeeTransactions."Original Amount" + prEmployeeTransactions.Balance;
                                    //****
                                end;
                            prTransactionCodes."Balance Type"::Reducing:
                                begin
                                    curTransAmount := prEmployeeTransactions.Balance;
                                    if prEmployeeTransactions."Original Amount" < prEmployeeTransactions.Balance then begin
                                        curTransAmount := prEmployeeTransactions."Original Amount";
                                        curTransBalance := 0;
                                    end
                                    else begin
                                        curTransBalance := prEmployeeTransactions."Original Amount" - prEmployeeTransactions.Balance;
                                    end;
                                    if curTransBalance < 0 then begin
                                        curTransAmount := 0;
                                        curTransBalance := 0;
                                    end;
                                end;
                        end;
                    end;
                end;
            until prEmployeeTransactions.Next = 0;
        end;
        //Update the Period as Closed
        prPayrollPeriods.Reset;
        prPayrollPeriods.SetRange(prPayrollPeriods."Period Month", intMonth);
        prPayrollPeriods.SetRange(prPayrollPeriods."Period Year", intYear);
        prPayrollPeriods.SetRange(prPayrollPeriods.Closed, false);
        if prPayrollPeriods.Find('-') then begin
            prPayrollPeriods.Closed := true;
            prPayrollPeriods."Closed On" := WorkDate;
            prPayrollPeriods."Closed By" := UserId;
            prPayrollPeriods.Modify;
        end;
        //Enter a New Period
        with prNewPayrollPeriods do begin
            Init;
            "Period Month" := intNewMonth;
            "Period Year" := intNewYear;
            "Period Name" := Format(dtNewPeriod, 0, '<Month Text>') + '' + Format(intNewYear);
            "Start Date" := dtNewPeriod;
            "Opened By" := UserId;
            Closed := false;
            Insert;
        end;
        //Effect the transactions for the P9
        fnP9PeriodClosure(intMonth, intYear, dtOpenPeriod);
        //Take all the Negative pay (Net) for the current month & treat it as a deduction in the new period
        fnGetNegativePay(intMonth, intYear, dtOpenPeriod);
        /*
                        //Reset no. of days worked for casuals
                        PRSalCard.RESET;
                        PRSalCard.SETRANGE(PRSalCard."Employee Contract Type",'CASUALS');
                        IF PRSalCard.FIND('-') THEN
                        BEGIN
                            REPEAT
                                PRSalCard."No. of Days Worked":=0;
                                PRSalCard.MODIFY;
                            UNTIL PRSalCard.NEXT = 0;
                        END;
                        */
    end;

    procedure fnGetNegativePay(intMonth: Integer; intYear: Integer; dtOpenPeriod: Date)
    var
        prEmployeeTransactions: Record "Payroll Employee Transaction";
        prPeriodTransactions: Record "Payroll Period Transaction";
        intNewMonth: Integer;
        intNewYear: Integer;
        dtNewPeriod: Date;
    begin
        dtNewPeriod := CalcDate('1M', dtOpenPeriod);
        intNewMonth := Date2DMY(dtNewPeriod, 2);
        intNewYear := Date2DMY(dtNewPeriod, 3);
        prPeriodTransactions.Reset;
        prPeriodTransactions.SetRange(prPeriodTransactions."Period Month", intMonth);
        prPeriodTransactions.SetRange(prPeriodTransactions."Period Year", intYear);
        prPeriodTransactions.SetRange(prPeriodTransactions."Group Order", 9);
        prPeriodTransactions.SetFilter(prPeriodTransactions.Amount, '<0');
        if prPeriodTransactions.Find('-') then begin
            repeat
                with prEmployeeTransactions do begin
                    Init;
                    "Employee Code" := prPeriodTransactions."Employee Code";
                    "Transaction Code" := 'NEGP';
                    "Transaction Name" := 'Negative Pay';
                    Balance := prPeriodTransactions.Amount;
                    "Original Amount" := 0;
                    "Period Month" := intNewMonth;
                    "Period Year" := intNewYear;
                    "Payroll Period" := dtNewPeriod;
                    Insert;
                end;
            until prPeriodTransactions.Next = 0;
        end;
    end;

    procedure fnP9PeriodClosure(intMonth: Integer; intYear: Integer; dtCurPeriod: Date)
    var
        P9EmployeeCode: Code[20];
        P9BasicPay: Decimal;
        P9Allowances: Decimal;
        P9Benefits: Decimal;
        P9ValueOfQuarters: Decimal;
        P9DefinedContribution: Decimal;
        P9OwnerOccupierInterest: Decimal;
        P9GrossPay: Decimal;
        P9TaxablePay: Decimal;
        P9TaxCharged: Decimal;
        P9InsuranceRelief: Decimal;
        P9TaxRelief: Decimal;
        P9Paye: Decimal;
        P9NSSF: Decimal;
        P9SHIF: Decimal;
        P9Deductions: Decimal;
        P9NetPay: Decimal;
        prPeriodTransactions: Record "Payroll Period Transaction";
        prEmployee: Record Employee;
    begin
        P9BasicPay := 0;
        P9Allowances := 0;
        P9Benefits := 0;
        P9ValueOfQuarters := 0;
        P9DefinedContribution := 0;
        P9OwnerOccupierInterest := 0;
        P9GrossPay := 0;
        P9TaxablePay := 0;
        P9TaxCharged := 0;
        P9InsuranceRelief := 0;
        P9TaxRelief := 0;
        P9Paye := 0;
        P9NSSF := 0;
        P9SHIF := 0;
        P9Deductions := 0;
        P9NetPay := 0;
        prEmployee.Reset;
        prEmployee.SetRange(prEmployee.Status, prEmployee.Status::Active);
        //prEmployee.SETFILTER(prEmployee."Employee Contract Type",'<>%1','CASUALS'); //Remove
        if prEmployee.Find('-') then begin
            repeat
                P9BasicPay := 0;
                P9Allowances := 0;
                P9Benefits := 0;
                P9ValueOfQuarters := 0;
                P9DefinedContribution := 0;
                P9OwnerOccupierInterest := 0;
                P9GrossPay := 0;
                P9TaxablePay := 0;
                P9TaxCharged := 0;
                P9InsuranceRelief := 0;
                P9TaxRelief := 0;
                P9Paye := 0;
                P9NSSF := 0;
                P9SHIF := 0;
                P9Deductions := 0;
                P9NetPay := 0;
                prPeriodTransactions.Reset;
                prPeriodTransactions.SetRange(prPeriodTransactions."Employee Code", prEmployee."No.");
                prPeriodTransactions.SetRange(prPeriodTransactions."Payroll Period", dtCurPeriod);
                if prPeriodTransactions.Find('-') then begin
                    repeat
                        with prPeriodTransactions do begin
                            case prPeriodTransactions."Group Order" of
                                1: //Basic pay & Arrears
                                    begin
                                        if "Sub Group Order" = 1 then P9BasicPay := Amount; //Basic Pay
                                        if "Sub Group Order" = 2 then P9BasicPay := P9BasicPay + Amount; //Basic Pay Arrears
                                    end;
                                3: //Allowances
                                    begin
                                        P9Allowances := P9Allowances + Amount
                                    end;
                                4: //Gross Pay
                                    begin
                                        P9GrossPay := Amount
                                    end;
                                6: //Taxation
                                    begin
                                        if "Sub Group Order" = 1 then P9DefinedContribution := Amount; //Defined Contribution
                                        if "Sub Group Order" = 9 then P9TaxRelief := Amount; //Tax Relief
                                        if "Sub Group Order" = 8 then P9InsuranceRelief := Amount; //Insurance Relief
                                        if "Sub Group Order" = 6 then P9TaxablePay := Amount; //Taxable Pay
                                        if "Sub Group Order" = 7 then P9TaxCharged := Amount; //Tax Charged
                                    end;
                                7: //Statutories
                                    begin
                                        if "Sub Group Order" = 1 then P9NSSF := Amount; //Nssf
                                        if "Sub Group Order" = 2 then P9SHIF := Amount; //SHIF
                                        if "Sub Group Order" = 3 then P9Paye := Amount; //paye
                                        if "Sub Group Order" = 4 then P9Paye := P9Paye + Amount; //Paye Arrears
                                    end;
                                8: //Deductions
                                    begin
                                        P9Deductions := P9Deductions + Amount;
                                    end;
                                9: //NetPay
                                    begin
                                        P9NetPay := Amount;
                                    end;
                            end;
                        end;
                    until prPeriodTransactions.Next = 0;
                end;
                //Update the P9 Details
                if P9NetPay <> 0 then fnUpdateP9Table(prEmployee."No.", P9BasicPay, P9Allowances, P9Benefits, P9ValueOfQuarters, P9DefinedContribution, P9OwnerOccupierInterest, P9GrossPay, P9TaxablePay, P9TaxCharged, P9InsuranceRelief, P9TaxRelief, P9Paye, P9NSSF, P9SHIF, P9Deductions, P9NetPay, dtCurPeriod, 0);
            until prEmployee.Next = 0;
        end;
    end;

    procedure fnUpdateP9Table(P9EmployeeCode: Code[20]; P9BasicPay: Decimal; P9Allowances: Decimal; P9Benefits: Decimal; P9ValueOfQuarters: Decimal; P9DefinedContribution: Decimal; P9OwnerOccupierInterest: Decimal; P9GrossPay: Decimal; P9TaxablePay: Decimal; P9TaxCharged: Decimal; P9InsuranceRelief: Decimal; P9TaxRelief: Decimal; P9Paye: Decimal; P9NSSF: Decimal; P9SHIF: Decimal; P9Deductions: Decimal; P9NetPay: Decimal; dtCurrPeriod: Date; P9PensionAmount: Decimal)
    var
        prEmployeeP9Info: Record "Payroll Employee P9 Tax Info";
        intYear: Integer;
        intMonth: Integer;
    begin
        intMonth := Date2DMY(dtCurrPeriod, 2);
        intYear := Date2DMY(dtCurrPeriod, 3);
        prEmployeeP9Info.Reset;
        with prEmployeeP9Info do begin
            Init;
            "Employee Code" := P9EmployeeCode;
            "Basic Pay" := P9BasicPay;
            Allowances := P9Allowances;
            Benefits := P9Benefits;
            "Value Of Quarters" := P9ValueOfQuarters;
            "Defined Contribution" := P9DefinedContribution;
            "Owner Occupier Interest" := P9OwnerOccupierInterest;
            "Gross Pay" := P9GrossPay;
            "Taxable Pay" := P9TaxablePay;
            "Tax Charged" := P9TaxCharged;
            "Insurance Relief" := P9InsuranceRelief;
            "Tax Relief" := P9TaxRelief;
            PAYE := P9Paye;
            NSSF := P9NSSF;
            SHIF := P9SHIF;
            Deductions := P9Deductions;
            "Net Pay" := P9NetPay;
            "Period Month" := intMonth;
            "Period Year" := intYear;
            "Payroll Period" := dtCurrPeriod;
            Pension := P9PensionAmount;
            Insert;
        end;
    end;

    procedure fnDaysWorked(dtDate: Date; IsTermination: Boolean) DaysWorked: Integer
    var
        Day: Integer;
        SysDate: Record Date;
        Expr1: Text[30];
        FirstDay: Date;
        LastDate: Date;
        TodayDate: Date;
    begin
        TodayDate := dtDate;
        Day := Date2DMY(TodayDate, 1);
        Expr1 := Format(-Day) + 'D+1D';
        FirstDay := CalcDate(Expr1, TodayDate);
        LastDate := CalcDate('1M-1D', FirstDay);
        SysDate.Reset;
        SysDate.SetRange(SysDate."Period Type", SysDate."Period Type"::Date);
        if not IsTermination then
            SysDate.SetRange(SysDate."Period Start", dtDate, LastDate)
        else
            SysDate.SetRange(SysDate."Period Start", FirstDay, dtDate);
        SysDate.SetFilter(SysDate."Period No.", '1..5');
        if SysDate.Find('-') then DaysWorked := SysDate.Count;
    end;

    procedure fnDisplayFrmlValues(EmpCode: Code[30]; intMonth: Integer; intYear: Integer; Formula: Text[50]) curTransAmount: Decimal
    var
        pureformula: Text[50];
    begin
        pureformula := fnPureFormula(EmpCode, intMonth, intYear, Formula, false, '');
        curTransAmount := fnFormulaResult(pureformula); //Get the calculated amount
        curTransAmount := Round(curTransAmount, 1);
    end;

    procedure fnGetOpenPeriod() dtOpenPeriod: Date
    var
        "prPayroll Periods": Record "Payroll Periods";
        intMonth: Integer;
        intYear: Integer;
    begin
        "prPayroll Periods".Reset;
        "prPayroll Periods".SetRange("prPayroll Periods".Closed, false);
        if "prPayroll Periods".Find('-') then begin
            dtOpenPeriod := "prPayroll Periods"."Start Date";
            intMonth := Date2DMY(dtOpenPeriod, 2); //GET THE MONTH
            intYear := Date2DMY(dtOpenPeriod, 3); //GET THE YEAR
        end
        else begin
            Error('There is no open payroll period');
        end
    end;

    procedure fnGetJournalDet(strEmpCode: Code[20])
    var
        SalaryCard: Record "Payroll Salary Card";
        HREmp: Record Employee;
    begin
        //Get Payroll Posting Accounts
        //IF SalaryCard.GET(strEmpCode) THEN BEGIN
        if HREmp.Get(strEmpCode) then begin
            if PostingGroup.Get(HREmp."Employee Posting Group") then begin
                //Comment This for the Time Being
                PostingGroup.TestField("Salary Expense Account");
                PostingGroup.TestField("PAYE Payable Account");
                PostingGroup.TestField("Net Payable Account");
                PostingGroup.TestField("Payables Account");
                PostingGroup.TestField("Pension Employer Acc");
                PostingGroup.TestField("Gratuity Account");
                PostingGroup.TestField("NSSF Employee");
                PostingGroup.TestField("SHIF Account");
                if NHF_Enabled then PostingGroup.TestField("National Housing Fund");
                GratuityAccount := PostingGroup."Gratuity Account";
                NHFAccount := PostingGroup."National Housing Fund";
                EmployerNHFAccount := PostingGroup."Employer National Housing Fund";
                TaxAccount := PostingGroup."PAYE Payable Account";
                salariesAcc := PostingGroup."Salary Expense Account";
                PayablesAcc := PostingGroup."Net Payable Account";
                NSSFEMPyer := PostingGroup."NSSF Employer Account";
                PensionEMPyer := PostingGroup."Pension Employer Acc";
                NSSFEMPyee := PostingGroup."NSSF Employee";
                SHIFEMPyee := PostingGroup."SHIF Account";
            end;
        end;
        //End Get Payroll Posting Accounts
    end;

    procedure fnUpdateEmployerDeductions(EmpCode: Code[20]; TCode: Code[20]; TGroup: Code[20]; GroupOrder: Integer; SubGroupOrder: Integer; Description: Text[50]; curAmount: Decimal; curBalance: Decimal; Month: Integer; Year: Integer; mMembership: Text[30]; ReferenceNo: Text[30]; dtOpenPeriod: Date; AccountToDebit: Code[20]; AccountToCredit: Code[20])
    var
        prEmployerDeductions: Record "Payroll Employer Transaction";
        Employee: Record Employee;
    begin
        if prEmployerDeductions.Get(EmpCode, TCode, dtOpenPeriod) then
            prEmployerDeductions.Delete;

        if curAmount < 0 then
            curAmount := 0;

        if curAmount = 0 then
            exit;

        with prEmployerDeductions do begin
            Init;
            "Employee Code" := EmpCode;
            "Transaction Code" := TCode;
            Validate("Transaction Code");
            "Transaction Name" := Description;
            "Transaction Type" := "Transaction Type"::Deduction;
            Amount := curAmount;
            "Payroll Period" := dtOpenPeriod;
            "Account To Credit" := AccountToCredit;
            "Account To Debit" := AccountToDebit;
            Insert;
        end;
    end;

    procedure DeletePayrollPeriodTransactions(PayrollPeriodTransaction: Record "Payroll Period Transaction")
    begin
        if PayrollPeriodTransaction.FindSet(true) then PayrollPeriodTransaction.DeleteAll;
    end;

    procedure DeleteP9Transactions(PayrolP9Transaction: Record "Payroll Employee P9 Tax Info")
    begin
        if PayrolP9Transaction.FindSet(true) then PayrolP9Transaction.DeleteAll;
    end;

    procedure fnCalcLoanInterest(strEmpCode: Code[20]; strTransCode: Code[20]; InterestRate: Decimal; RecoveryMethod: Option Reducing,"Straight line",Amortized; LoanAmount: Decimal; Balance: Decimal; CurrPeriod: Date) LnInterest: Decimal
    var
        curLoanInt: Decimal;
        intMonth: Integer;
        intYear: Integer;
    begin
        intMonth := Date2DMY(CurrPeriod, 2);
        intYear := Date2DMY(CurrPeriod, 3);
        curLoanInt := 0;
        if InterestRate > 0 then begin
            if RecoveryMethod = RecoveryMethod::"Straight line" then //Straight Line Method [1]
                curLoanInt := (InterestRate / 1200) * LoanAmount;
            if RecoveryMethod = RecoveryMethod::Reducing then //Reducing Balance [0]
                curLoanInt := (InterestRate / 1200) * Balance;
            if RecoveryMethod = RecoveryMethod::Amortized then //Amortized [2]
                curLoanInt := (InterestRate / 100) * Balance;
        end
        else
            curLoanInt := 0;
        //Return the Amount
        LnInterest := Round(curLoanInt, 1);
    end;

    procedure CheckForImprestMarkedForPayroll()
    var
        RequestHeader: Record "Request Header";
    begin
        RequestHeader.Reset;
        RequestHeader.SetFilter("Request Type", '=%1|=%2|=%3', RequestHeader."Request Type"::Imprest, RequestHeader."Request Type"::"Salary Advance", RequestHeader."Request Type"::"Staff Claim");
        RequestHeader.SetRange("Transfered To Payroll", false);
        RequestHeader.SetRange(Status, RequestHeader.Status::Approved);
        if RequestHeader.FindFirst then
            if not Confirm('There are imprests/Salary Advance that have been marked to be recovered from payroll, do you wish to recover?') then
                exit
            else
                ImprestManagement.LoopThroughImprestToTransferToPayroll();
    end;

    local procedure CreateLeaveAllowanceEntries(EmpNo: Code[20]; PayPeriod: Date; PayYear: Integer; PayAMount: Decimal)
    var
        LeaveAllowanceLedgerEntries: Record "Leave Allowance Ledger Entries";
    begin
        LeaveAllowanceLedgerEntries.Init;
        LeaveAllowanceLedgerEntries."Employee No" := EmpNo;
        LeaveAllowanceLedgerEntries."Payroll Year" := PayYear;
        LeaveAllowanceLedgerEntries."Payroll Period" := PayPeriod;
        LeaveAllowanceLedgerEntries.Amount := PayAMount;
        if not LeaveAllowanceLedgerEntries.Get(EmpNo, PayYear) then LeaveAllowanceLedgerEntries.Insert;
    end;

    local procedure CheckLeaveAllowanceEntries(EmpNo: Code[20]; PayPeriod: Date; PayYear: Integer): Boolean
    var
        LeaveAllowanceLedgerEntries: Record "Leave Allowance Ledger Entries";
    begin
        LeaveAllowanceLedgerEntries.Reset;
        LeaveAllowanceLedgerEntries.SetRange("Employee No", EmpNo);
        LeaveAllowanceLedgerEntries.SetRange("Payroll Year", PayYear);
        LeaveAllowanceLedgerEntries.SetFilter("Payroll Period", '<>%1', PayPeriod);
        exit(LeaveAllowanceLedgerEntries.FindFirst);
    end;

    local procedure CreateGratuityEntries(EmpNo: Code[20]; PayPeriod: Date; PayYear: Integer; PayAMount: Decimal)
    var
        GratuityLedgerEntries: Record "Gratuity Ledger Entries";
    begin
        GratuityLedgerEntries.Init;
        GratuityLedgerEntries."Employee No" := EmpNo;
        GratuityLedgerEntries."Payroll Year" := PayYear;
        GratuityLedgerEntries."Payroll Period" := PayPeriod;
        GratuityLedgerEntries.Amount := PayAMount;
        if not GratuityLedgerEntries.Get(EmpNo, PayYear) then GratuityLedgerEntries.Insert;
    end;

    local procedure DeleteGratuityEntries(EmpNo: Code[20]; PayPeriod: Date; PayYear: Integer)
    var
        GratuityLedgerEntries: Record "Gratuity Ledger Entries";
    begin
        if GratuityLedgerEntries.Get(EmpNo, PayYear) then GratuityLedgerEntries.Delete;
    end;

    local procedure GetBasicPay(Grade: Code[5]; Ponter: Code[5]): Decimal
    var
        SalaryScalePointers: Record "Salary Scale Pointers";
    begin
        if SalaryScalePointers.Get(Grade, Ponter) then exit(SalaryScalePointers."Basic Pay")
    end;

    local procedure StatutoriesExclusion(EmpNo: Code[20]; PayrollPeriod: Date): Decimal
    var
        prEmployeeTransactions: Record "Payroll Employee Transaction";
    begin
        PayrollSetup.Get;
        if PayrollSetup."Statutories Exclusion" <> '' then begin
            prEmployeeTransactions.Reset();
            prEmployeeTransactions.SetRange("Payroll Period", PayrollPeriod);
            prEmployeeTransactions.SetRange("Employee Code", EmpNo);
            prEmployeeTransactions.SetFilter("Transaction Code", PayrollSetup."Statutories Exclusion");
            if prEmployeeTransactions.FindSet then begin
                prEmployeeTransactions.CalcSums(Amount);
                exit(prEmployeeTransactions.Amount);
            end;
        end;
    end;

    local procedure GetLoanAmount(TransCode: Code[20]; EmpNo: Code[20]): Decimal
    var
        PayrollEmployeeTransaction: Record "Payroll Employee Transaction";
    begin
        PayrollEmployeeTransaction.Reset;
        PayrollEmployeeTransaction.SetRange("Employee Code", EmpNo);
        PayrollEmployeeTransaction.SetRange("Transaction Code", TransCode);
        if PayrollEmployeeTransaction.FindFirst then exit(PayrollEmployeeTransaction.Balance);
    end;

    local procedure GetRentAmount(EmpCode: Code[20]): Decimal
    begin
        PRTransCode.Reset;
        PRTransCode.SetRange("Special Transactions", PRTransCode."Special Transactions"::Rent);
        PRTransCode.FindFirst;
        PREmpTrans_2.Reset;
        PREmpTrans_2.SetRange("Employee Code", EmpCode);
        PREmpTrans_2.SetRange("Transaction Code", PRTransCode.Code);
        if PREmpTrans_2.FindFirst then exit(PREmpTrans_2.Amount);
    end;

    procedure LeaveAllowancesToBePaid()
    var
        PostingDay: Integer;
        CutOffDay: Integer;
    begin
        PayrollSetup.Get;
        LeaveApplications.Reset;
        LeaveApplications.SetRange(Status, LeaveApplications.Status::Approved);
        LeaveApplications.SetRange("Leave Allowance Payable", LeaveApplications."Leave Allowance Payable"::Yes);
        LeaveApplications.SetRange("Allowance Paid", false);
        if LeaveApplications.FindSet() then begin
            repeat
                PostingDay := Date2DMY(LeaveApplications."Start Date", 1);
                CutOffDay := Date2DMY(PayrollSetup."Payroll Cut off Date", 1);
                if PostingDay <= CutOffDay then CreateLeavePayrollTransaction(LeaveApplications);
            until LeaveApplications.Next = 0;
            LeaveApplications."Allowance Paid" := true;
            LeaveApplications.Modify(true);
        end;
    end;

    local procedure CreateLeavePayrollTransaction(LeaveApp: Record "Leave Applications")
    var
        PayrollEmpTransaction: Record "Payroll Employee Transaction";
        PayrollPeriod: Record "Payroll Periods";
        HumanResSetup: Record "Human Resources Setup";
    begin
        PayrollPeriod.Reset;
        PayrollPeriod.SetRange(Closed, false);
        if PayrollPeriod.FindFirst then begin
            HREmployee.Get(LeaveApp."Employee No");
            HREmployee.TestField("Job Scale");
            EmployeePayrollScales.Reset;
            EmployeePayrollScales.SetRange(Scale, HREmployee."Job Scale");
            if EmployeePayrollScales.FindFirst then begin
                PayrollTransactionCode.Reset;
                PayrollTransactionCode.SetRange("Special Transactions", PayrollTransactionCode."Special Transactions"::"Leave Allowance");
                if not PayrollTransactionCode.FindFirst then
                    Error('There is no Payroll Transaction Code define as Leave Allowance in Special Transaction')
                else begin
                    EmployeePayrollScales.TestField("Leave Allowance Amount");
                    PayrollEmpTransaction.Init;
                    PayrollEmpTransaction."Employee Code" := LeaveApp."Employee No";
                    PayrollEmpTransaction.Validate("Transaction Code", PayrollTransactionCode.Code);
                    PayrollEmpTransaction.Validate(Amount, EmployeePayrollScales."Leave Allowance Amount");
                    PayrollEmpTransaction.Validate("Payroll Period", PayrollPeriod."Start Date");
                    PayrollEmpTransaction."Period Month" := PayrollPeriod."Period Month";
                    PayrollEmpTransaction."Period Year" := PayrollPeriod."Period Year";
                    PayrollEmpTransaction.Insert(true);
                end;
            end;
        end;
    end;

    local procedure IanGetNSSFAmount(GrossPayToUse: Decimal): Decimal
    var
        PayrollNSSFTiers: Record "Payroll NSSF Matrix";
    begin
        PayrollNSSFTiers.Reset;
        PayrollNSSFTiers.FindFirst;
        if PayrollNSSFTiers."Upper Limit" * (PayrollNSSFTiers.Percentage / 100) > (PayrollNSSFTiers.Percentage / 100) * GrossPayToUse then
            exit((PayrollNSSFTiers.Percentage / 100) * GrossPayToUse)
        else
            exit(PayrollNSSFTiers."Upper Limit" * (PayrollNSSFTiers.Percentage / 100));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPayrollLoanManagement()
    begin
    end;
}
