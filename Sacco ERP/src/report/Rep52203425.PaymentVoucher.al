report 52203425 "Payment Voucher"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Payment Voucher.rdl';

    dataset
    {
        dataitem(PVHeader; "Payment Voucher")
        {
            column(USER; UserId)
            {
            }
            column(DT; CurrentDateTime)
            {
            }
            column(Created_By; PVHeader."Prepared By")
            {
            }
            column(Logo; CompInfo.Picture)
            {
            }
            column(Logo2; CompInfo.Picture2)
            {
            }
            column(CompName; CompInfo.Name)
            {
            }
            column(CompAddress; CompInfo.Address)
            {
            }
            column(CompAddress2; CompInfo."Address 2")
            {
            }
            column(CompCity; CompInfo.City)
            {
            }
            column(CompPhone; CompInfo."Phone No.")
            {
            }
            column(CompCountry; CompInfo."Country/Region Code")
            {
            }
            column(PaymentVoucherLabel; PaymentVoucherLabel)
            {
            }
            column(ChequeReceivedBy; PVHeader."Cheque Received By")
            {
            }
            column(Date; PVHeader.Date)
            {
            }
            column(No; PVHeader."No.")
            {
            }
            column(Department; Department)
            {
            }
            column(Branch; Branch)
            {
            }
            column(AmountInWords; NumberText[1] + ' ' + NumberText[2])
            {
            }
            column(Bank; BankName)
            {
            }
            column(ChequeNo; PVHeader."Cheque Number")
            {
            }
            column(Description; PVHeader.Description)
            {
            }
            column(FirstApprover; "1stapprover")
            {
            }
            column(SecondApprover; "2ndapprover")
            {
            }
            column(ThirdApprover; "3rdapprover")
            {
            }
            column(FourthApprover; "4thapprover")
            {
            }
            column(FirstApproverDate; "1stapproverdate")
            {
            }
            column(SecondApproverDate; "2ndapproverdate")
            {
            }
            column(ThirdApproverDate; "3rdapproverdate")
            {
            }
            column(FourthApproverDate; "4thapproverdate")
            {
            }
            column(FirstApproverSignature; UserRecApp1."Signature Card")
            {
            }
            column(SecondApproverSignature; UserRecApp2."Signature Card")
            {
            }
            column(ThirdApproverSignature; UserRecApp3."Signature Card")
            {
            }
            column(FourthApproverSignature; UserRecApp4."Signature Card")
            {
            }
            column(PayMode; PVHeader."Pay Mode")
            {
            }
            column(Payee; PayeeDtls)
            {
            }
            column(PayeeKRAPin; PayeeKRAPin)
            {
            }
            column(PayeeAddress; PayeeAddress)
            {
            }
            column(PayingBankGLName; PayingBankGLName)
            {
            }
            column(PayingBankGLCode; PayingBankGLCode)
            {
            }
            column(PayingAmount; PVHeader."Total Amount")
            {
            }
            dataitem("PV Lines"; "Payment Voucher Lines")
            {
                DataItemLink = "No." = FIELD("No.");

                column(Description_PVLines; "PV Lines".Description)
                {
                }
                column(GrossAmount; "PV Lines".Amount)
                {
                }
                column(VAT; "PV Lines"."VAT Amount")
                {
                }
                column(W_Tax_Code; "PV Lines"."WHT Code One")
                {
                }
                column(WHT; "PV Lines"."WHT Amount One")
                {
                }
                column(NetAmount; "PV Lines"."Net Amount")
                {
                }
                column(Account; "PV Lines"."Account No")
                {
                }
                column(Account_Name; "PV Lines".Description)
                {
                }
                column(Project; "PV Lines"."Global Dimension 1 Code")
                {
                }
                column(Donor; "PV Lines"."Global Dimension 2 Code")
                {
                }
                column(Dr; Debit)
                {
                }
                column(Cr; Credit)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    Debit := 0;
                    Credit := 0;
                    if "PV Lines"."Net Amount" > 0 then begin
                        Credit := "PV Lines"."Net Amount";
                        Debit := 0;
                    end
                    else begin
                        Credit := 0;
                        Debit := Abs("PV Lines"."Net Amount");
                    end;
                    if "PV Lines"."Account Type" = "PV Lines"."Account Type"::Vendor then begin
                        if Vend.Get("Account No") then begin
                            PayeeAddress := Vend.Address;
                            PayeeDtls := Vend.Name;
                            PayeeKRAPin := Vend."KRA PIN No.";
                            /*PayeeDetails.Reset();
                                PayeeDetails.SetRange("Vendor No", "PV Lines"."Account No");
                                PayeeDetails.SetRange(Active, true);
                                if PayeeDetails.FindFirst() then begin
                                    PayeeDtls := PayeeDetails."Beneficiary Name";
                                end;*/
                        end;
                    end;
                end;
            }
            dataitem(PaymentSchedule; "Payment Schedule")
            {
                DataItemLink = "PV No." = field("No.");

                column(PaymentSchedule_PV_Line_No_; PaymentSchedule."PV Line No.")
                {
                }
                column(PaymentSchedule_Payment_Type; PaymentSchedule."Payment Type")
                {
                }
                column(PaymentSchedule_Employee_No; PaymentSchedule."Employee No")
                {
                }
                column(PaymentSchedule_FOSA_Account; PaymentSchedule."FOSA Account")
                {
                }
                column(PaymentSchedule_Employee_Name; PaymentSchedule."Employee Name")
                {
                }
                column(PaymentSchedule_Allowance_Code; 'N/A')
                {
                }
                column(PaymentSchedule_Amount; PaymentSchedule.Amount)
                {
                }
                column(PaymentSchedule_Net_Allowance_Amount; PaymentSchedule."Net Allowance Amount")
                {
                }
                column(PaymentSchedule_Tax_Code; 'N/A')
                {
                }
                column(PaymentSchedule_Tax_Amount; PaymentSchedule."Tax Amount")
                {
                }
            }
            trigger OnAfterGetRecord()
            begin
                //Payment Label
                if PVHeader."Payment Type" = PVHeader."Payment Type"::"Bank Transfer" then
                    PaymentVoucherLabel := 'BANK TRANSFER VOUCHER'
                else if PVHeader."Payment Type" = PVHeader."Payment Type"::"Customer Refund" then
                    PaymentVoucherLabel := 'CUSTOMER REFUND VOUCHER'
                else if PVHeader."Payment Type" = PVHeader."Payment Type"::"Direct Expensing" then
                    PaymentVoucherLabel := 'DIRECT EXPENSING VOUCHER'
                else if PVHeader."Payment Type" = PVHeader."Payment Type"::"Petty Cash Topup" then
                    PaymentVoucherLabel := 'PETTY CASH REIMBURSEMENT VOUCHER'
                else if PVHeader."Payment Type" = PVHeader."Payment Type"::"Supplier Payment" then
                    PaymentVoucherLabel := 'SUPPLIER PAYMENT VOUCHER'
                else if PVHeader."Payment Type" = PVHeader."Payment Type"::Remittance then
                    PaymentVoucherLabel := 'REMITTANCE VOUCHER'
                else if PVHeader."Payment Type" = PVHeader."Payment Type"::"Staff Bulk Payment" then
                    PaymentVoucherLabel := 'STAFF PAYMENT VOUCHER'
                else if PVHeader."Payment Type" = PVHeader."Payment Type"::"Member Payment" then
                    PaymentVoucherLabel := 'MEMBER PAYMENT VOUCHER'
                else if PVHeader."Payment Type" = PVHeader."Payment Type"::"EFT Loan Payment" then
                    PaymentVoucherLabel := 'EFT LOAN PAYMENT VOUCHER'
                else if PVHeader."Payment Type" = PVHeader."Payment Type"::"RTGS/SWIFT" then
                    PaymentVoucherLabel := 'RTGS/SWIFT PAYMENT VOUCHER';
                //Get Dimensions
                if DimValue.Get('DEPARTMENT', PVHeader."Global Dimension 1 Code") then Department := DimValue.Name;
                if DimValue.Get('BRANCH', PVHeader."Global Dimension 2 Code") then Branch := DimValue.Name;
                //Paying Details;
                If BankAccount.Get("Paying Bank Account") then begin
                    if BankAccountPostingGroup.Get(BankAccount."Bank Acc. Posting Group") then begin
                        if GLAccount.Get(BankAccountPostingGroup."G/L Account No.") then begin
                            PayingBankGLName := StrSubstNo('%1 (%2)', GLAccount.Name, "Paying Bank Account");
                            PayingBankGLCode := GLAccount."No.";
                        end;
                    end;
                end;
                PVHeader.CalcFields("Total Amount");
                GLsetup.GET;
                IF PVHeader.Currency <> '' THEN
                    CurrencyCodeText := PVHeader.Currency
                ELSE
                    CurrencyCodeText := GLsetup."LCY Code";
                Banks.RESET;
                Banks.SETRANGE(Banks."No.", PVHeader."Paying Bank Account");
                IF Banks.FIND('-') THEN BEGIN
                    BankName := Banks.Name;
                END
                ELSE BEGIN
                    BankName := '';
                end;
                PVHeader.CALCFIELDS("Total Amount");
                AmountToWords.FormatNoText(NumberText, "Total Amount", CurrencyCodeText);
                
                //Approvers
                ApprovalEntries.RESET;
                ApprovalEntries.SETRANGE(ApprovalEntries."Table ID", Database::"Payment Voucher");
                ApprovalEntries.SETRANGE(ApprovalEntries."Document No.", PVHeader."No.");
                ApprovalEntries.SETRANGE(ApprovalEntries.Status, ApprovalEntries.Status::Approved);
                IF ApprovalEntries.FIND('-') THEN BEGIN
                    i := 0;
                    REPEAT
                        i := i + 1;
                        IF i = 1 THEN BEGIN
                            Users.RESET;
                            Users.SETRANGE("User Name", ApprovalEntries."Sender ID");
                            IF Users.FINDFIRST THEN BEGIN
                                "1stapprover" := Users."Full Name";
                            end;
                            Users.RESET;
                            Users.SETRANGE("User Name", ApprovalEntries."Approver ID");
                            IF Users.FINDFIRST THEN BEGIN
                                "2ndapprover" := Users."Full Name";
                                "3rdapprover" := Users."Full Name";
                                "4thapprover" := Users."Full Name";
                            end;
                            "1stapproverdate" := ApprovalEntries."Date-Time Sent for Approval";
                            "2ndapproverdate" := ApprovalEntries."Last Date-Time Modified";
                            "3rdapproverdate" := ApprovalEntries."Last Date-Time Modified";
                            "4thapproverdate" := ApprovalEntries."Last Date-Time Modified";
                            IF UserRecApp1.GET(ApprovalEntries."Sender ID") THEN UserRecApp1.CALCFIELDS(UserRecApp1."Signature Card");
                            IF UserRecApp2.GET(ApprovalEntries."Approver ID") THEN UserRecApp2.CALCFIELDS(UserRecApp2."Signature Card");
                            IF UserRecApp3.GET(ApprovalEntries."Approver ID") THEN UserRecApp3.CALCFIELDS(UserRecApp3."Signature Card");
                            IF UserRecApp4.GET(ApprovalEntries."Approver ID") THEN UserRecApp4.CALCFIELDS(UserRecApp4."Signature Card");
                        end;
                        IF i = 2 THEN BEGIN
                            Users.RESET;
                            Users.SETRANGE("User Name", ApprovalEntries."Approver ID");
                            IF Users.FINDFIRST THEN BEGIN
                                "3rdapprover" := Users."Full Name";
                                "4thapprover" := Users."Full Name";
                            end;
                            "3rdapproverdate" := ApprovalEntries."Last Date-Time Modified";
                            "4thapproverdate" := ApprovalEntries."Last Date-Time Modified";
                            IF UserRecApp3.GET(ApprovalEntries."Approver ID") THEN UserRecApp3.CALCFIELDS(UserRecApp3."Signature Card");
                            IF UserRecApp4.GET(ApprovalEntries."Approver ID") THEN UserRecApp4.CALCFIELDS(UserRecApp4."Signature Card");
                        end;
                        IF i = 3 THEN BEGIN
                            Users.RESET;
                            Users.SETRANGE("User Name", ApprovalEntries."Approver ID");
                            IF Users.FINDFIRST THEN BEGIN
                                "4thapprover" := Users."Full Name";
                            end;
                            "4thapproverdate" := ApprovalEntries."Last Date-Time Modified";
                            IF UserRecApp4.GET(ApprovalEntries."Approver ID") THEN UserRecApp4.CALCFIELDS(UserRecApp4."Signature Card");
                        end;
                    UNTIL ApprovalEntries.NEXT = 0;
                end;
            end;
        }
    }
    trigger OnPreReport()
    begin
        CompInfo.GET;
        CompInfo.CALCFIELDS(CompInfo.Picture);
        CompInfo.CALCFIELDS(CompInfo.Picture2);
    end;

    var
        CompInfo: Record "Company Information";
        BankName: Text[100];
        Vend: Record Vendor;
        Banks: Record "Bank Account";
        GLAccount: Record "G/L Account";
        GLsetup: Record "General Ledger Setup";
        NumberText: array[2] of Text[80];
        CurrencyCodeText: Code[10];
        ApprovalEntries: Record "Approval Entry";
        "1stapprover": Text[100];
        "2ndapprover": Text[100];
        "3rdapprover": Text[100];
        "4thapprover": Text[100];
        i: Integer;
        "1stapproverdate": DateTime;
        "2ndapproverdate": DateTime;
        "3rdapproverdate": DateTime;
        "4thapproverdate": DateTime;
        UserRecApp1: Record "User Setup";
        UserRecApp2: Record "User Setup";
        UserRecApp3: Record "User Setup";
        UserRecApp4: Record "User Setup";
        Users: Record User;
        Branch: Text;
        Department: Text;
        DimValue: Record "Dimension Value";
        PayeeDtls: Text;
        PayeeKRAPin: Code[20];
        PayeeAddress: Text;
        Debit: Decimal;
        Credit: Decimal;
        PayeeDetails: Record "Payee Bank Details";
        BankAccount: Record "Bank Account";
        BankAccountPostingGroup: Record "Bank Account Posting Group";
        PayingBankGLName: Text[100];
        PayingBankGLCode: Code[20];
        PayingAmount: Decimal;
        AmountToWords: Codeunit "Amount To Words";
        PaymentVoucherLabel: Text[100];
}
