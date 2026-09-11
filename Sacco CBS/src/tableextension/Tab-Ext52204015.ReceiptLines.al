tableextension 52204015 "Receipt Lines" extends "Receipt Lines"
{
    fields
    {
        modify(Amount)
        {
            trigger OnAfterValidate()
            var
                JournalMgmt: Codeunit "Journal Management";
                GeneralLedgerSetup: Record "General Ledger Setup";
            begin
                GeneralLedgerSetup.Get;
                if "Receipt Type" = "Receipt Type"::Member then begin
                    if GeneralLedgerSetup."Loan Repayment Charge" <> '' then begin
                        "Charge Code" := GeneralLedgerSetup."Loan Repayment Charge";
                        "Charge Amount" := JournalMgmt.GetChargesAmount("Charge Code", Amount);
                    end;
                end;
                if "Product Posting Type" = "Product Posting Type"::"Loan Account" then
                    TestField("Loan No.");
            end;
        }
        modify("Account No")
        {
            TableRelation = if ("Receipt Type" = const(Member)) Vendor where("Account Type" = filter(Sacco | Loan), "Member No." = field("Member No."), "Product Posting Type" = filter(<> "Fixed Deposit Account"))
            else if ("Receipt Type" = const(Vendor)) Vendor where("Account Type" = filter(Supplier))
            else if ("Receipt Type" = const(Customer)) Customer
            else if ("Receipt Type" = const(Bank)) "Bank Account" where(Blocked = const(false))
            else if ("Receipt Type" = const(Employee)) Employee where(Status = const(Active))
            else if ("Receipt Type" = const("G/L Account")) "G/L Account" where("Direct Posting" = const(true));

            trigger OnAfterValidate()
            var
                Receipt: Record "Receipt Header";
            begin
                "Loan Balance" := 0;
                "Principal Balance" := 0;
                "Accrued Interest" := 0;
                "Interest Balance" := 0;
                Amount := 0;
                case "Receipt Type" of
                    "Receipt Type"::Member, "Receipt Type"::Vendor:
                        begin
                            if Vendor.Get("Account No") then begin
                                "Account Name" := Vendor.Name;
                                "Product Posting Type" := Vendor."Product Posting Type";
                            end;
                        end;
                    "Receipt Type"::Bank:
                        begin
                            if Bank.Get("Account No") then "Account Name" := Bank.Name;
                        end;
                    "Receipt Type"::Customer:
                        begin
                            if Customer.Get("Account No") then "Account Name" := Customer.Name;
                        end;
                    "Receipt Type"::Employee:
                        begin
                            if Employee.Get("Account No") then "Account Name" := Employee.FullName;
                        end;
                    "Receipt Type"::"G/L Account":
                        begin
                            if GLAccount.Get("Account No") then "Account Name" := GLAccount.Name;
                        end;
                end;
                if Receipt.Get(Rec."No.") then begin
                    Receipt.TestField(Description);
                    if Receipt."Receipt Type" = Receipt."Receipt Type"::Member then
                        Description := 'Member Receipt'
                    else
                        Description := Receipt.Description;
                end;
            end;
        }
        field(52204000; "Member No."; Code[20])
        {
            TableRelation = Members where(Status = filter(Active | Dormant | "Not Paid Up"));
        }
        field(52204001; "Transaction Type"; Enum "Sacco Transaction Type")
        {
        }
        field(52204002; "Loan No."; Code[20])
        {
            TableRelation = Loans."No." where("Member No." = field("Member No."), "Loan Balance" = filter('>0'), "Loan Account" = field("Account No"));

            trigger OnValidate()
            var
                Loan: Record Loans;
                ReceiptHeader: Record "Receipt Header";
                LoansManagement: Codeunit "Loans Management";
            begin
                ReceiptHeader.Get("No.");
                if Loan.Get("Loan No.") then begin
                    Validate("Account No", Loan."Loan Account");
                    Loan.CalcFields("Loan Balance", "Penalty Balance", "Interest Balance", "Principal Balance");
                    "Penalty Balance" := Loan."Penalty Balance";
                    "Accrued Interest" := LoansManagement.GetProratedInterest(Loan."No.", ReceiptHeader."Posting Date");
                    "Interest Balance" := Loan."Interest Balance";
                    "Principal Balance" := Loan."Principal Balance";
                    "Loan Balance" := Loan."Loan Balance";
                end;
            end;
        }
        field(52204003; "Penalty Balance"; Decimal)
        {
            Editable = false;
        }
        field(52204004; "Accrued Interest"; Decimal)
        {
            Editable = false;
        }
        field(52204005; "Interest Balance"; Decimal)
        {
            Editable = false;
        }
        field(52204006; "Principal Balance"; Decimal)
        {
            Editable = false;
        }
        field(52204007; "Charge Code"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(52204008; "Charge Amount"; Decimal)
        {
            Editable = false;
        }
        field(52204009; "Product Posting Type"; Enum "Product Posting Type")
        {
            Editable = false;
        }
    }
    var
        Vendor: Record Vendor;
        Customer: Record Customer;
        Bank: Record "Bank Account";
        GLAccount: Record "G/L Account";
        Employee: Record Employee;
}
