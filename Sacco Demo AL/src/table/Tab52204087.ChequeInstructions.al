table 52204087 "Cheque Instructions"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Document No"; Code[20])
        {
        }
        field(2; "Line No"; Integer)
        {
            AutoIncrement = true;
        }
        field(3; "Account Type"; Option)
        {
            Editable = false;
            OptionMembers = Account,Loan;
            InitValue = Account;
        }
        field(4; "Account No"; Code[20])
        {
            trigger OnValidate()
            begin
                if "Account Type" = "Account Type"::Account then begin
                    if Vendor.Get("Account No") then begin
                        Vendor.CalcFields(Balance);
                        "Account Name" := Vendor.Name;
                    end;
                end
                else begin
                    if Loan.Get("Account No") then begin
                        Loan.CalcFields("Loan Balance");
                        "Loan Balance" := Loan."Loan Balance";
                        "Account Name" := Loan."Product Description";
                    end;
                end;
            end;

            trigger OnLookup()
            var
                ChequeDeposit: Record "Cheque Deposits";
            begin
                ChequeDeposit.Get("Document No", ChequeDeposit."Document Type"::Deposit);
                if "Account Type" = "Account Type"::Account then begin
                    Vendor.Reset();
                    Vendor.SetRange("Member No.", ChequeDeposit."Member No");
                    Vendor.SetFilter("Account Type", '<>%1', Vendor."Account Type"::Loan);
                    //Vendor.SetFilter("Product Posting Type", '<>%1', Vendor."Product Posting Type"::"Withdrawable Deposit");
                    if Page.RunModal(0, Vendor) = Action::LookupOK then begin
                        Validate("Account No", Vendor."No.");
                    end;
                end
                else begin
                    Loan.Reset();
                    Loan.SetRange("Member No.", ChequeDeposit."Member No");
                    Loan.SetFilter("Loan Balance", '>0');
                    if Page.RunModal(0, Loan) = Action::LookupOK then begin
                        Validate("Account No", Loan."No.");
                    end;
                end;
            end;
        }
        field(5; "Account Name"; Text[100])
        {
            Editable = false;
        }
        field(6; Amount; decimal)
        {
        }
        field(7; "Loan Balance"; Decimal)
        {
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Document No", "Line No")
        {
            Clustered = true;
        }
    }
    var
        Vendor: Record Vendor;
        Loan: Record Loans;
}
