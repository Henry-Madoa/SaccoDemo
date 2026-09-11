codeunit 52204018 "Debtor Collection Integrations"
{
    procedure GetLoanListing(AccountNo: Code[20]; CustomerNo: Code[20]; var ResponseMessage: BigText)
    var
        Loans: Record Loans;
        Member: array[2] of Record Members;
        LoanGuarantees: Record "Loan Guarantees";
        LoanSecurities: Record "Loan Securities";
        CollateralRegister: Record "Collateral Register";
        GeneralLedgerSetup: Record "General Ledger Setup";
        DimensionValue: Record "Dimension Value";
        CurrentPaymentDate, NextPaymentDate : Date;
        LoanObject: JsonObject;
        GuarantorObject: JsonObject;
        CollateralObject: JsonObject;
        GuarantorsArray: JsonArray;
        CollateralArray: JsonArray;
        LoansArray: JsonArray;
        RootObject: JsonObject;
        ResponseText: Text;
    begin
        GeneralLedgerSetup.Get;
        Clear(ResponseMessage);

        Loans.Reset(); 
        Loans.SetFilter("Loan Balance", '>0');
        Loans.SetRange(Posted, true);
        if CustomerNo <> '' then
            Loans.SetRange("Member No.", CustomerNo);
        if AccountNo <> '' then
            Loans.SetRange("No.", AccountNo);
        if not Loans.FindSet() then begin
            ResponseMessage.AddText('{"ResponseCode":"01","ResponseMessage":"No loans found for the given criteria."}');
            exit;
        end;

        repeat
            Clear(LoanObject);
            Clear(GuarantorsArray);
            Clear(CollateralArray);
            Loans.CalcFields("Penalty Balance", "Loan Balance");
            if Member[1].Get(Loans."Member No.") then;
            if DimensionValue.Get(GeneralLedgerSetup."Global Dimension 1 Code", Loans."Global Dimension 1 Code") then;

            if Loans."Payment Date" <> 0D then
                GetPaymentDates(Loans."Payment Date", CurrentPaymentDate, NextPaymentDate);
            // stg_loan_arrears fields
            LoanObject.Add('account_number', Loans."No.");
            LoanObject.Add('customer_number', Loans."Member No.");
            LoanObject.Add('fullname', Member[1].FullName);
            LoanObject.Add('gender', Format(Member[1].Gender));
            LoanObject.Add('product_code', Loans."Product Code");
            LoanObject.Add('product_name', Loans."Product Description");
            LoanObject.Add('relationship_officer', Loans."Sales Representative Name");
            LoanObject.Add('branch_code', Loans."Global Dimension 1 Code");
            LoanObject.Add('branch_name', DimensionValue."Name");
            LoanObject.Add('currency', GeneralLedgerSetup."LCY Code");
            LoanObject.Add('origination_date', Format(Loans."Application Date"));
            LoanObject.Add('loan_amount', Format(Loans."Approved Amount"));
            LoanObject.Add('maturity_date', Format(Loans."Repayment End Date"));
            LoanObject.Add('tenure_months', Loans.Installments);
            LoanObject.Add('settlement_account', Loans."Loan Account");
            LoanObject.Add('settlement_account_balance', Format(Loans."Loan Balance"));
            LoanObject.Add('next_repayment_date', Format(NextPaymentDate));
            LoanObject.Add('due_date', Format(CurrentPaymentDate));
            LoanObject.Add('overdue_principal', Format(Round(Loans."Principal Arrears", 0.01)));
            LoanObject.Add('overdue_interest', Format(Round(Loans."Interest Arrears", 0.01)));
            LoanObject.Add('outstanding_balance', Format(Round(Loans."Total Arrears", 0.01)));
            LoanObject.Add('penalty_amount', Format(Loans."Penalty Balance"));
            LoanObject.Add('days_past_due', Format(Loans."Defaulted Days"));
            LoanObject.Add('address_line_1', Member[1].Address);
            LoanObject.Add('address_line_2', Member[1].Address);
            LoanObject.Add('address_line_3', Member[1].Address);
            LoanObject.Add('telephone_1', Member[1]."Mobile Transacting No");
            LoanObject.Add('telephone_2', Member[1]."Mobile Phone No.");
            LoanObject.Add('telephone_3', Member[1]."Alt. Phone No");
            LoanObject.Add('dob', Format(Member[1]."Date of Birth"));
            LoanObject.Add('email_address', Member[1]."E-Mail");
            LoanObject.Add('national_id', Member[1]."Identification No.");

            // stg_guarantors fields
            LoanGuarantees.Reset();
            LoanGuarantees.SetRange("Loan No", Loans."No.");
            if LoanGuarantees.FindSet() then
                repeat
                    if Member[2].Get(LoanGuarantees."Member No.") then;
                    Clear(GuarantorObject);
                    GuarantorObject.Add('guarantor_id', LoanGuarantees."Member No.");
                    GuarantorObject.Add('loan_id', LoanGuarantees."Loan No");
                    GuarantorObject.Add('customer_number', Loans."Member No.");
                    GuarantorObject.Add('guarantor_name', LoanGuarantees."Member Name");
                    GuarantorObject.Add('national_id', Member[2]."Identification No.");
                    GuarantorObject.Add('address', Member[2].Address);
                    GuarantorObject.Add('phone_number', Member[2]."Mobile Transacting No");
                    GuarantorObject.Add('email_address', Member[2]."E-Mail");
                    GuarantorObject.Add('guaranteed_amount', Format(LoanGuarantees."Guaranteed Amount"));
                    GuarantorObject.Add('active_status', Format(not LoanGuarantees.Substituted));
                    GuarantorObject.Add('created_at', Format(LoanGuarantees.SystemCreatedAt));
                    GuarantorObject.Add('updated_at', Format(LoanGuarantees.SystemModifiedAt));
                    GuarantorsArray.Add(GuarantorObject);
                until LoanGuarantees.Next() = 0;
            LoanObject.Add('Guarantors', GuarantorsArray);

            // stg_collateral fields
            LoanSecurities.Reset();
            LoanSecurities.SetRange("Loan No", Loans."No.");
            if LoanSecurities.FindSet() then
                repeat
                    Clear(CollateralObject);
                    if CollateralRegister.Get(LoanSecurities."Security Code") then;
                    CollateralObject.Add('collateral_id', CollateralRegister."No.");
                    CollateralObject.Add('loan_id', LoanSecurities."Loan No");
                    CollateralObject.Add('customer_number', Loans."Member No.");
                    CollateralObject.Add('collateral_type', Format(LoanSecurities."Security Type"));
                    CollateralObject.Add('description', LoanSecurities.Description);
                    CollateralObject.Add('owner_name', CollateralRegister."Owner Name");
                    CollateralObject.Add('estimated_value', Format(LoanSecurities."Security Value"));
                    CollateralObject.Add('registration_doc', CollateralRegister."Serial/Reg No.");
                    CollateralObject.Add('registration_date', Format(CollateralRegister."Posting Date"));
                    CollateralObject.Add('valuation_amount', Format(CollateralRegister."Collateral Value"));
                    CollateralObject.Add('collateral_status', Format(CollateralRegister.Status));
                    CollateralArray.Add(CollateralObject);
                until LoanSecurities.Next() = 0;
            LoanObject.Add('Collaterals', CollateralArray);
            LoansArray.Add(LoanObject);
        until Loans.Next() = 0;

        // Build root response object
        RootObject.Add('ResponseCode', '00');
        RootObject.Add('ResponseMessage', 'Success');
        RootObject.Add('Loans', LoansArray);
        RootObject.WriteTo(ResponseText);
        ResponseMessage.AddText(ResponseText);
    end;

    procedure GetPaymentDates(InputDate: Date; var CurrentMonthDate: Date; var NextMonthDate: Date)
    var
        CurrentYear, CurrentMonth, InputDay, NextMonth, NextYear, LastDayCurrentMonth : Integer;
    begin
        CurrentYear := Date2DMY(WorkDate, 3);
        CurrentMonth := Date2DMY(WorkDate, 2);
        InputDay := Date2DMY(InputDate, 1);

        LastDayCurrentMonth := Date2DMY(CalcDate('<CM>', DMY2Date(1, CurrentMonth, CurrentYear)), 1);
        CurrentMonthDate := DMY2Date(MinInteger(InputDay, LastDayCurrentMonth), CurrentMonth, CurrentYear);


        if CurrentMonth = 12 then begin
            NextMonth := 1;
            NextYear := CurrentYear + 1;
        end else begin
            NextMonth := CurrentMonth + 1;
            NextYear := CurrentYear;
        end;

        NextMonthDate := DMY2Date(1, NextMonth, NextYear);
        NextMonthDate := CalcDate('<CM>', NextMonthDate);
        if InputDay < Date2DMY(NextMonthDate, 1) then
            NextMonthDate := DMY2Date(InputDay, NextMonth, NextYear)
        else
            NextMonthDate := DMY2Date(Date2DMY(NextMonthDate, 1), NextMonth, NextYear);
    end;

    local procedure MinInteger(A: Integer; B: Integer): Integer
    begin
        if A < B then
            exit(A);
        exit(B);
    end;
}

