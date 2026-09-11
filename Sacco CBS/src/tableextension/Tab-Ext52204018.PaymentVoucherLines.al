tableextension 52204018 "Payment Voucher Lines" extends "Payment Voucher Lines"
{
    fields
    {
        modify("No.")
        {
            trigger OnAfterValidate()
            var
                PaymentVoucher: Record "Payment Voucher";
            begin
                if PaymentVoucher.Get("No.") then begin
                    if (PaymentVoucher."Payment Type" in [PaymentVoucher."Payment Type"::"Member Payment", PaymentVoucher."Payment Type"::"RTGS/SWIFT", PaymentVoucher."Payment Type"::"Loan Payment"]) then begin
                        "Member No." := PaymentVoucher."Member No";
                    end;
                end;
            end;
        }
        modify("Payment Type")
        {
            trigger OnAfterValidate()
            begin
                if Rec."Payment Type" in [Rec."Payment Type"::"Member Payment", Rec."Payment Type"::"RTGS/SWIFT", Rec."Payment Type"::"EFT Loan Payment"] then Validate("Account Type", "Account Type"::Vendor);
            end;
        }
        modify("Account No")
        {
            TableRelation = if ("Payment Type" = filter("Member Payment")) Vendor where("Account Type" = const(Sacco), "Member No." = field("Member No."), "Product Posting Type" = filter("Withdrawable Deposit" | "Non Withdrawable Deposit" | "Junior Account"))
            else if ("Payment Type" = filter("RTGS/SWIFT")) Vendor where("Account Type" = const(Sacco), "Member No." = field("Member No."), "Product Posting Type" = filter("Withdrawable Deposit" | "Holiday Account" | "Junior Account"))
            else if ("Payment Type" = const("EFT Loan Payment")) Vendor where("Account Type" = const(Loan), "Member No." = field("Member No."), "Product Posting Type" = filter("Loan Account"))
            else if ("Payment Type" = const("Supplier Payment")) Vendor where("Account Type" = filter(Supplier))
            else if ("Payment Type" = const("Customer Refund")) Customer
            else if ("Payment Type" = const("Bank Transfer")) "Bank Account" where(Blocked = const(false))
            else if ("Payment Type" = const("Employee Payment")) Employee where(Status = const(Active))
            else if ("Payment Type" = filter("Direct Expensing" | "Board Allowances" | "Staff Bulk Payment")) "G/L Account" where("Account Type" = const(Posting), "Direct Posting" = const(true))
            else if ("Payment Type" = filter("Payroll Settlement" | Remittance | "Loan Payment" | "Member Exit")) "G/L Account" where("Account Type" = const(Posting), "Direct Posting" = const(true), "Account Category" = const(Liabilities));

            trigger OnAfterValidate()
            begin
                case "Payment Type" of
                    "Payment Type"::"Member Payment", "Payment Type"::"RTGS/SWIFT":
                        begin
                            PaymentVoucher.Get("No.");
                            if Members.Get(PaymentVoucher."Member No") then Validate("Account Name", Members."Full Name");
                            if Vendor.Get("Account No") then begin
                                SaccoProducts.Get(Vendor."Product Code");
                                Vendor.CalcFields(Balance, "Uncleared Funds");
                                "Available Balance" := Vendor.Balance - Vendor."Uncleared Funds" - SaccoProducts."Minimum Balance" - ChannelsIntegrations.GetPendingChannelsTransactions(Vendor."Member No.");
                                if "Available Balance" < 0 then "Available Balance" := 0;
                            end;
                        end;
                    "Payment Type"::"EFT Loan Payment":
                        begin
                            MemberAccounts.Get("Account No");
                            Validate("Account Name", MemberAccounts.Name);
                        end;
                    "Payment Type"::"Loan Payment", "Payment Type"::"Member Exit":
                        begin
                            GLAccount.Get("Account No");
                            Validate("Account Name", GLAccount.Name);
                            if "Payment Type" = "Payment Type"::"Member Exit" then begin
                                GLEntry.Reset();
                                GLEntry.SetRange("G/L Account No.", "Account No");
                                GLEntry.SetRange("Member No.", "Member No.");
                                if GLEntry.FindSet then begin
                                    GLEntry.CalcSums(Amount);
                                    if GLEntry.Amount = 0 then
                                        Error('The Exit has already been paid!')
                                    else
                                        Amount := Abs(GLEntry.Amount);
                                end;
                            end;
                        end;
                end;
            end;
        }
        modify(Amount)
        {
            trigger OnAfterValidate()
            begin
                if "Payment Type" in ["Payment Type"::"Member Payment", "Payment Type"::"RTGS/SWIFT"] then begin
                    if Amount <> 0 then begin
                        if Amount > ("Available Balance" - JournalManagement.GetChargesAmount(PaymentVoucher."Charge Code", Amount)) then
                            Error(StrSubstNo('You cannot overdraw the Account, Available Balance %1', Format("Available Balance" - JournalManagement.GetChargesAmount(PaymentVoucher."Charge Code", Amount))));
                    end;
                end;
            end;
        }
        field(52204000; "Member No."; Code[20])
        {
            TableRelation = Members;
        }
        field(52204001; "Uncleared Funds Entry No."; Integer)
        {
        }
        field(52204002; "Available Balance"; Decimal)
        {
            Editable = false;
        }
        field(52204003; "Loan No."; Code[20])
        {
            TableRelation = Loans where("Member No." = field("Member No."), Posted = const(true), "Mode of Disbursement" = const(BOSA), "Loan Balance" = filter(<> 0));

            trigger OnValidate()
            begin
                if Loans.Get("Loan No.") then begin
                    Validate("Account Type", "Account Type"::"G/L Account");
                    Validate("Account No", Loans."Disbursement Account");
                    GLEntry.Reset();
                    GLEntry.SetRange("G/L Account No.", Loans."Disbursement Account");
                    GLEntry.SetRange("Loan No.", "Loan No.");
                    GLEntry.SetRange("Member No.", "Member No.");
                    if GLEntry.FindSet then begin
                        GLEntry.CalcSums(Amount);
                        if GLEntry.Amount = 0 then
                            Error('The Loan has already been paid!')
                        else
                            Amount := Abs(GLEntry.Amount);
                    end;
                end;
            end;
        }
    }
    var
        Loans: Record Loans;
        GLEntry: Record "G/L Entry";
        PaymentVoucher: Record "Payment Voucher";
        Members: Record Members;
        Vendor: Record Vendor;
        SaccoProducts: Record "Sacco Products";
        PayeeBankDetails: Record "Payee Bank Details";
        Customer: Record Customer;
        BankAccount: Record "Bank Account";
        Employee: Record Employee;
        MemberAccounts: Record Vendor;
        GLAccount: Record "G/L Account";
        CashMgmt: Codeunit "CBS Cash Management";
        ChannelsIntegrations: Codeunit "Channels Integrations";
        JournalManagement: Codeunit "Journal Management";
}
