codeunit 52204006 "Product Management"
{
    var
        SaccoProducts: Record "Sacco Products";
        LoanProductLinking: array[3] of Record "Loan Product Linking";
        ProductInterestBands: array[3] of Record "Product Interest Bands";
        ProductChargeSetup: array[3] of Record "Product Charge Setup";
        TransactionCalcScheme: array[3] of Record "Transaction Calc. Scheme";

    procedure ProcessProductApplication(ProductMgmt: Record "Products Management")
    begin
        if not Confirm(StrSubstNo('You are about to create %1, Do you wish to continue?', ProductMgmt.Description)) then exit;
        SaccoProducts.Init();
        SaccoProducts.Validate(Code, ProductMgmt."Product Code");
        SaccoProducts.Validate(Category, ProductMgmt.Category);
        SaccoProducts.Validate(Description, ProductMgmt.Description);
        SaccoProducts.Validate("Product Posting Type", ProductMgmt."Product Posting Type");
        SaccoProducts.Validate("Posting Group", ProductMgmt."Posting Group");
        SaccoProducts.Validate(Prefix, ProductMgmt.Prefix);
        SaccoProducts.Validate(Suffix, ProductMgmt.Suffix);
        SaccoProducts.Validate("Print Sequence", ProductMgmt."Print Sequence");
        SaccoProducts.Validate("Hide on Statement", ProductMgmt."Hide on Statement");
        SaccoProducts.Validate("Loan Recovery Priority", ProductMgmt."Loan Recovery Priority");
        SaccoProducts.Validate("Blocked", ProductMgmt.Blocked);
        if SaccoProducts."Product Posting Type" <> ProductMgmt."Product Posting Type"::"Loan Account" then begin
            SaccoProducts.Validate("Business Account", ProductMgmt."Business Account");
            SaccoProducts.Validate("Cash Deposit Allowed", ProductMgmt."Cash Deposit Allowed");
            SaccoProducts.Validate("Cash Withdraw Allowed", ProductMgmt."Cash Withdraw Allowed");
            SaccoProducts.Validate("Cash Transfer Allowed", ProductMgmt."Cash Transfer Allowed");
            SaccoProducts.Validate("ATM Use Allowed", ProductMgmt."ATM Use Allowed");
            SaccoProducts.Validate("Cheque Book Allowed", ProductMgmt."Cheque Book Allowed");
            SaccoProducts.Validate("Checkoff Product", ProductMgmt."Checkoff Product");
            SaccoProducts.Validate("Minimum Balance", ProductMgmt."Minimum Balance");
            SaccoProducts.Validate("Maximum Balance", ProductMgmt."Maximum Balance");
            SaccoProducts.Validate("Minimum Contribution", ProductMgmt."Minimum Contribution");
        end
        else begin
            SaccoProducts.Validate("Rate Type", ProductMgmt."Rate Type");
            SaccoProducts.Validate("Interest Rate", ProductMgmt."Interest Rate");
            SaccoProducts.Validate("Interest Due Account", ProductMgmt."Interest Due Account");
            SaccoProducts.Validate("Interest Paid Account", ProductMgmt."Interest Paid Account");
            SaccoProducts.Validate("Interest Repayment Method", ProductMgmt."Interest Repayment Method");
            SaccoProducts.Validate("Penalty Due Account", ProductMgmt."Penalty Due Account");
            SaccoProducts.Validate("Penalty Paid Account", ProductMgmt."Penalty Paid Account");
            SaccoProducts.Validate("Penalty Rate", ProductMgmt."Penalty Rate");
            SaccoProducts.Validate("Loan Multiplier", ProductMgmt."Loan Multiplier");
            SaccoProducts.Validate("Maximum Loan Multiplier", ProductMgmt."Maximum Loan Multiplier");
            SaccoProducts.Validate("Ordinary Default Intallments", ProductMgmt."Ordinary Default Intallments");
            SaccoProducts.Validate("Max. Running Loans", ProductMgmt."Max. Running Loans");
            SaccoProducts.Validate("Minimum Loan Amount", ProductMgmt."Minimum Loan Amount");
            SaccoProducts.Validate("Maximum Loan Amount", ProductMgmt."Maximum Loan Amount");
            SaccoProducts.Validate("Minimum Deposit Balance", ProductMgmt."Minimum Deposit Balance");
            SaccoProducts.Validate("Minimum Deposit Contribution", ProductMgmt."Minimum Deposit Contribution");
            SaccoProducts.Validate("Minimum Installments", ProductMgmt."Minimum Installments");
            SaccoProducts.Validate("Maximum Installments", ProductMgmt."Maximum Installments");
            SaccoProducts.Validate("Max. NWD Boost", ProductMgmt."Max. NWD Boost");
            SaccoProducts.Validate("Max. NWD Boost %", ProductMgmt."Max. NWD Boost %");
            SaccoProducts.Validate("Charge UpFront Interest", ProductMgmt."Charge UpFront Interest");
            SaccoProducts.Validate("View Online", ProductMgmt."View Online");
            SaccoProducts.Validate("Mobile Loan", ProductMgmt."Mobile Loan");
            SaccoProducts.Validate("Exclude Billing & Interest", ProductMgmt."Exclude Billing & Interest");
            SaccoProducts.Validate("Boosting Commission %", ProductMgmt."Boosting Commission %");
            SaccoProducts.Validate("Max. Bridging Commission", ProductMgmt."Max. Bridging Commission");
            SaccoProducts.Validate("Commission Account", ProductMgmt."Commission Account");
            SaccoProducts.Validate("Insurance Rate", ProductMgmt."Insurance Rate");
            SaccoProducts.Validate("Insurance Factor", ProductMgmt."Insurance Factor");
            SaccoProducts.Validate("Insurance Account", ProductMgmt."Insurance Account");
            SaccoProducts.Validate("Insurance Income %", ProductMgmt."Insurance Income %");
            SaccoProducts.Validate("Insurance Income Account", ProductMgmt."Insurance Income Account");
            SaccoProducts.Validate("Boost Deposits", ProductMgmt."Boost Deposits");
            SaccoProducts.Validate("Appraise with 0 Deposits", ProductMgmt."Appraise with 0 Deposits");
            SaccoProducts.Validate("Mobile Appraisal Type", ProductMgmt."Mobile Appraisal Type");
            SaccoProducts.Validate("Salary Based", ProductMgmt."Salary Based");
            SaccoProducts.Validate("Dividend Based", ProductMgmt."Dividend Based");
            SaccoProducts.Validate("Min. Salary Count", ProductMgmt."Min. Salary Count");
            SaccoProducts.Validate("Salary %", ProductMgmt."Salary %");
            SaccoProducts.Validate("Salary Appraisal Type", ProductMgmt."Salary Appraisal Type");
            SaccoProducts.Validate("Special Loan Multiplier", ProductMgmt."Special Loan Multiplier");
            SaccoProducts.Validate("Unsecured Product", ProductMgmt."Unsecured Product");
            SaccoProducts.Validate("Repayment Cutoff Date", ProductMgmt."Repayment Cutoff Date");
            SaccoProducts.Validate("Mode of Disbursement", ProductMgmt."Mode of Disbursement");
            SaccoProducts.Validate("Disbursement Account", ProductMgmt."Disbursement Account");
        end;
        SaccoProducts.Insert(true);
        if ProductMgmt."Product Posting Type" = ProductMgmt."Product Posting Type"::"Loan Account" then begin
            LoanProductLinking[1].Reset();
            LoanProductLinking[1].SetRange("Source Code", ProductMgmt."No.");
            if LoanProductLinking[1].FindSet() then begin
                repeat
                    LoanProductLinking[2].Init();
                    LoanProductLinking[2].TransferFields(LoanProductLinking[1]);
                    LoanProductLinking[2]."Source Code" := SaccoProducts.Code;
                    LoanProductLinking[2].Insert();
                until LoanProductLinking[1].Next() = 0;
            end;
            ProductInterestBands[1].Reset();
            ProductInterestBands[1].SetRange("Source Code", ProductMgmt."No.");
            if ProductInterestBands[1].FindSet() then begin
                repeat
                    ProductInterestBands[2].Init();
                    ProductInterestBands[2].TransferFields(ProductInterestBands[1], false);
                    ProductInterestBands[2]."Source Code" := SaccoProducts.Code;
                    ProductInterestBands[2].Insert(true);
                until ProductInterestBands[1].Next() = 0;
            end;
            ProductChargeSetup[1].Reset();
            ProductChargeSetup[1].SetRange("Source Code", ProductMgmt."No.");
            if ProductChargeSetup[1].FindSet() then begin
                repeat
                    ProductChargeSetup[2].Init();
                    ProductChargeSetup[2].TransferFields(ProductChargeSetup[1]);
                    ProductChargeSetup[2]."Source Code" := SaccoProducts.Code;
                    ProductChargeSetup[2].Insert(true);
                until ProductChargeSetup[1].Next() = 0;
            end;
            TransactionCalcScheme[1].Reset();
            TransactionCalcScheme[1].SetRange("Source Code", ProductMgmt."No.");
            if TransactionCalcScheme[1].FindSet() then begin
                repeat
                    TransactionCalcScheme[2].Init();
                    TransactionCalcScheme[2].TransferFields(TransactionCalcScheme[1]);
                    TransactionCalcScheme[2]."Source Code" := SaccoProducts.Code;
                    TransactionCalcScheme[2].Insert(true);
                until TransactionCalcScheme[1].Next() = 0;
            end;
        end;
        OnAfterProcessProductManagement(ProductMgmt);
    end;

    procedure ProcessProductEditing(ProductMgmt: Record "Products Management")
    begin
        if not Confirm(StrSubstNo('You are about to Update %1, Do you wish to continue?', ProductMgmt."Product Code")) then exit;
        if ProductMgmt."Product Posting Type" = ProductMgmt."Product Posting Type"::"Loan Account" then begin
            LoanProductLinking[1].Reset();
            LoanProductLinking[1].SetRange("Source Code", ProductMgmt."Product Code");
            LoanProductLinking[1].DeleteAll();
            ProductInterestBands[1].Reset();
            ProductInterestBands[1].SetRange("Source Code", ProductMgmt."Product Code");
            ProductInterestBands[1].DeleteAll();
            ProductChargeSetup[1].Reset();
            ProductChargeSetup[1].SetRange("Source Code", ProductMgmt."Product Code");
            ProductChargeSetup[1].DeleteAll();
            TransactionCalcScheme[1].Reset();
            TransactionCalcScheme[1].SetRange("Source Code", ProductMgmt."Product Code");
            TransactionCalcScheme[1].DeleteAll();
        end;
        if SaccoProducts.Get(ProductMgmt."Product Code") then begin
            SaccoProducts.Validate(Category, ProductMgmt.Category);
            SaccoProducts.Validate(Description, ProductMgmt.Description);
            SaccoProducts.Validate("Product Posting Type", ProductMgmt."Product Posting Type");
            SaccoProducts.Validate("Posting Group", ProductMgmt."Posting Group");
            SaccoProducts.Validate(Prefix, ProductMgmt.Prefix);
            SaccoProducts.Validate(Suffix, ProductMgmt.Suffix);
            SaccoProducts.Validate("Print Sequence", ProductMgmt."Print Sequence");
            SaccoProducts.Validate("Hide on Statement", ProductMgmt."Hide on Statement");
            SaccoProducts.Validate("Loan Recovery Priority", ProductMgmt."Loan Recovery Priority");
            SaccoProducts.Validate("Blocked", ProductMgmt.Blocked);
            if SaccoProducts."Product Posting Type" <> ProductMgmt."Product Posting Type"::"Loan Account" then begin
                SaccoProducts.Validate("Business Account", ProductMgmt."Business Account");
                SaccoProducts.Validate("Cash Deposit Allowed", ProductMgmt."Cash Deposit Allowed");
                SaccoProducts.Validate("Cash Withdraw Allowed", ProductMgmt."Cash Withdraw Allowed");
                SaccoProducts.Validate("Cash Transfer Allowed", ProductMgmt."Cash Transfer Allowed");
                SaccoProducts.Validate("ATM Use Allowed", ProductMgmt."ATM Use Allowed");
                SaccoProducts.Validate("Cheque Book Allowed", ProductMgmt."Cheque Book Allowed");
                SaccoProducts.Validate("Checkoff Product", ProductMgmt."Checkoff Product");
                SaccoProducts.Validate("Minimum Balance", ProductMgmt."Minimum Balance");
                SaccoProducts.Validate("Maximum Balance", ProductMgmt."Maximum Balance");
                SaccoProducts.Validate("Minimum Contribution", ProductMgmt."Minimum Contribution");
            end
            else begin
                SaccoProducts.Validate("Rate Type", ProductMgmt."Rate Type");
                SaccoProducts.Validate("Interest Rate", ProductMgmt."Interest Rate");
                SaccoProducts.Validate("Interest Due Account", ProductMgmt."Interest Due Account");
                SaccoProducts.Validate("Interest Paid Account", ProductMgmt."Interest Paid Account");
                SaccoProducts.Validate("Interest Repayment Method", ProductMgmt."Interest Repayment Method");
                SaccoProducts.Validate("Penalty Due Account", ProductMgmt."Penalty Due Account");
                SaccoProducts.Validate("Penalty Paid Account", ProductMgmt."Penalty Paid Account");
                SaccoProducts.Validate("Penalty Rate", ProductMgmt."Penalty Rate");
                SaccoProducts.Validate("Loan Multiplier", ProductMgmt."Loan Multiplier");
                SaccoProducts.Validate("Maximum Loan Multiplier", ProductMgmt."Maximum Loan Multiplier");
                SaccoProducts.Validate("Ordinary Default Intallments", ProductMgmt."Ordinary Default Intallments");
                SaccoProducts.Validate("Max. Running Loans", ProductMgmt."Max. Running Loans");
                SaccoProducts.Validate("Minimum Loan Amount", ProductMgmt."Minimum Loan Amount");
                SaccoProducts.Validate("Maximum Loan Amount", ProductMgmt."Maximum Loan Amount");
                SaccoProducts.Validate("Minimum Deposit Balance", ProductMgmt."Minimum Deposit Balance");
                SaccoProducts.Validate("Minimum Deposit Contribution", ProductMgmt."Minimum Deposit Contribution");
                SaccoProducts.Validate("Minimum Installments", ProductMgmt."Minimum Installments");
                SaccoProducts.Validate("Maximum Installments", ProductMgmt."Maximum Installments");
                SaccoProducts.Validate("Max. NWD Boost", ProductMgmt."Max. NWD Boost");
                SaccoProducts.Validate("Max. NWD Boost %", ProductMgmt."Max. NWD Boost %");
                SaccoProducts.Validate("Bridging Commision %", ProductMgmt."Bridging Commision %");
                SaccoProducts.Validate("Charge UpFront Interest", ProductMgmt."Charge UpFront Interest");
                SaccoProducts.Validate("View Online", ProductMgmt."View Online");
                SaccoProducts.Validate("Mobile Loan", ProductMgmt."Mobile Loan");
                SaccoProducts.Validate("Exclude Billing & Interest", ProductMgmt."Exclude Billing & Interest");
                SaccoProducts.Validate("Boosting Commission %", ProductMgmt."Boosting Commission %");
                SaccoProducts.Validate("Max. Bridging Commission", ProductMgmt."Max. Bridging Commission");
                SaccoProducts.Validate("Commission Account", ProductMgmt."Commission Account");
                SaccoProducts.Validate("Insurance Rate", ProductMgmt."Insurance Rate");
                SaccoProducts.Validate("Insurance Factor", ProductMgmt."Insurance Factor");
                SaccoProducts.Validate("Insurance Account", ProductMgmt."Insurance Account");
                SaccoProducts.Validate("Insurance Income %", ProductMgmt."Insurance Income %");
                SaccoProducts.Validate("Insurance Income Account", ProductMgmt."Insurance Income Account");
                SaccoProducts.Validate("Boost Deposits", ProductMgmt."Boost Deposits");
                SaccoProducts.Validate("Appraise with 0 Deposits", ProductMgmt."Appraise with 0 Deposits");
                SaccoProducts.Validate("Mobile Appraisal Type", ProductMgmt."Mobile Appraisal Type");
                SaccoProducts.Validate("Salary Based", ProductMgmt."Salary Based");
                SaccoProducts.Validate("Dividend Based", ProductMgmt."Dividend Based");
                SaccoProducts.Validate("Min. Salary Count", ProductMgmt."Min. Salary Count");
                SaccoProducts.Validate("Salary %", ProductMgmt."Salary %");
                SaccoProducts.Validate("Salary Appraisal Type", ProductMgmt."Salary Appraisal Type");
                SaccoProducts.Validate("Special Loan Multiplier", ProductMgmt."Special Loan Multiplier");
                SaccoProducts.Validate("Unsecured Product", ProductMgmt."Unsecured Product");
                SaccoProducts.Validate("Repayment Cutoff Date", ProductMgmt."Repayment Cutoff Date");
                SaccoProducts.Validate("Mode of Disbursement", ProductMgmt."Mode of Disbursement");
                SaccoProducts.Validate("Disbursement Account", ProductMgmt."Disbursement Account");

            end;
            SaccoProducts.Modify(true);
            if ProductMgmt."Product Posting Type" = ProductMgmt."Product Posting Type"::"Loan Account" then begin
                LoanProductLinking[2].Reset();
                LoanProductLinking[2].SetRange("Source Code", ProductMgmt."No.");
                if LoanProductLinking[2].FindSet() then begin
                    repeat
                        LoanProductLinking[3].Init();
                        LoanProductLinking[3].TransferFields(LoanProductLinking[2]);
                        LoanProductLinking[3]."Source Code" := SaccoProducts.Code;
                        LoanProductLinking[3].Insert();
                    until LoanProductLinking[2].Next() = 0;
                end;
                ProductInterestBands[2].Reset();
                ProductInterestBands[2].SetRange("Source Code", ProductMgmt."No.");
                if ProductInterestBands[2].FindSet() then begin
                    repeat
                        ProductInterestBands[3].Init();
                        ProductInterestBands[3].TransferFields(ProductInterestBands[2], false);
                        ProductInterestBands[3]."Source Code" := SaccoProducts.Code;
                        ProductInterestBands[3]."Entry No." := ProductInterestBands[2]."Entry No.";
                        ProductInterestBands[3].Insert(true);
                    until ProductInterestBands[2].Next() = 0;
                end;
                ProductChargeSetup[2].Reset();
                ProductChargeSetup[2].SetRange("Source Code", ProductMgmt."No.");
                if ProductChargeSetup[2].FindSet() then begin
                    repeat
                        ProductChargeSetup[3].Init();
                        ProductChargeSetup[3].TransferFields(ProductChargeSetup[2]);
                        ProductChargeSetup[3]."Source Code" := SaccoProducts.Code;
                        ProductChargeSetup[3].Insert(true);
                    until ProductChargeSetup[2].Next() = 0;
                end;
                TransactionCalcScheme[2].Reset();
                TransactionCalcScheme[2].SetRange("Source Code", ProductMgmt."No.");
                if TransactionCalcScheme[2].FindSet() then begin
                    repeat
                        TransactionCalcScheme[3].Init();
                        TransactionCalcScheme[3].TransferFields(TransactionCalcScheme[2]);
                        TransactionCalcScheme[3]."Source Code" := SaccoProducts.Code;
                        TransactionCalcScheme[3].Insert(true);
                    until TransactionCalcScheme[2].Next() = 0;
                end;
            end;
            OnAfterProcessProductManagement(ProductMgmt);
        end;
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterProcessProductManagement(ProductMgmt: Record "Products Management")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Product Management", 'OnAfterProcessProductManagement', '', false, false)]
    local procedure OnAfterProcessing(ProductMgmt: Record "Products Management")
    begin
        ProductMgmt.Processed := true;
        ProductMgmt."Processed By" := UserId;
        ProductMgmt."Processed On" := WorkDate;
        ProductMgmt.Modify(true);
    end;
}
