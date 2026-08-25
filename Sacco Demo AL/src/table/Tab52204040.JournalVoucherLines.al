table 52204040 "Journal Voucher Lines"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Document No."; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Line No"; Integer)
        {
            AutoIncrement = true;
        }
        field(3; "Account Type"; Option)
        {
            OptionMembers = "G/L Account","Bank Account","Customer Account","Vendor Account","Fixed Asset","Member Account","Loan Account";
        }
        field(4; "Member No."; code[20])
        {
            TableRelation = Members;

            trigger OnValidate()
            begin
                if JVHeader.Get("Document No.") then begin
                    "Global Dimension 1 Code" := JVHeader."Global Dimension 1 Code";
                    "Global Dimension 2 Code" := JVHeader."Global Dimension 2 Code";
                    "Posting Description" := JVHeader."Posting Description";
                end;
            end;
        }
        field(5; "Account No."; code[20])
        {
            TableRelation = if ("Account Type" = const("G/L Account")) "G/L Account" where("Direct Posting" = const(true))
            else if ("Account Type" = const("Bank Account")) "Bank Account"
            else if ("Account Type" = const("Customer Account")) Customer
            else if ("Account Type" = const("Fixed Asset")) "Fixed Asset"
            else if ("Account Type" = const("Member Account")) "Sacco Products" where("Product Posting Type" = filter(<> "Loan Account"))
            else if ("Account Type" = const("Loan Account")) Loans where("Member No." = field("Member No."));

            trigger OnValidate()
            var
                ProductFactory: Record "Sacco Products";
                BankAccount: Record "Bank Account";
                GLAccount: Record "G/L Account";
                FixedAsset: Record "Fixed Asset";
                Vendor: Record Vendor;
                Loans: Record Loans;
                Customer: Record Customer;
            begin
                case "Account Type" of
                    "Account Type"::"G/L Account":
                        begin
                            if GLAccount.Get("Account No.") then begin
                                "Account Name" := GLAccount.Name;
                                "Post to Account" := GLAccount."No.";
                            end;
                        end;
                    "Account Type"::"Bank Account":
                        begin
                            if BankAccount.Get("Account No.") then begin
                                "Account Name" := BankAccount.Name;
                                "Post to Account" := BankAccount."No.";
                            end;
                        end;
                    "Account Type"::"Customer Account":
                        begin
                            if Customer.Get("Account No.") then begin
                                "Account Name" := Customer.Name;
                                "Post to Account" := Customer."No.";
                            end;
                        end;
                    "Account Type"::"Vendor Account":
                        begin
                            if Vendor.Get("Account No.") then begin
                                "Account Name" := Vendor.Name;
                                "Post to Account" := Vendor."No.";
                            end;
                        end;
                    "Account Type"::"Fixed Asset":
                        begin
                            if FixedAsset.Get("Account No.") then begin
                                "Account Name" := FixedAsset.Description;
                                "Post to Account" := FixedAsset."No.";
                            end;
                        end;
                    "Account Type"::"Loan Account":
                        begin
                            if Loans.Get("Account No.") then begin
                                "Account Name" := Loans."Product Description";
                                "Post to Account" := Loans."Loan Account";
                            end;
                        end;
                    "Account Type"::"Member Account":
                        begin
                            if ProductFactory.Get("Account No.") then begin
                                if Vendor.Get(ProductFactory.Prefix + "Member No.") then begin
                                    "Account Name" := ProductFactory.Description;
                                    "Post to Account" := Vendor."No.";
                                end
                                else
                                    Error('The Member does not have a %1 Account', ProductFactory.Description);
                            end;
                        end;
                end;
                if JVHeader.Get("Document No.") then begin
                    "Global Dimension 1 Code" := JVHeader."Global Dimension 1 Code";
                    "Global Dimension 2 Code" := JVHeader."Global Dimension 2 Code";
                    "Posting Description" := JVHeader."Posting Description";
                end;
            end;
        }
        field(6; "Account Name"; Text[50])
        {
            Editable = false;
        }
        Field(7; "Posting Description"; Text[50])
        {
        }
        field(8; "Debit Amount"; Decimal)
        {
        }
        field(9; "Credit Amount"; Decimal)
        {
        }
        field(10; Amount; Decimal)
        {
        }
        field(11; "Transaction Type"; Option)
        {
            OptionMembers = "General","Cash Deposit","Cash Withdrawal","Loan Disbursal","Principal Repayment","Interest Due","Interest Paid","Penalty Due","Penalty Paid","Recovery","Fixed Deposit","Loan Charge";
        }
        field(12; "Global Dimension 1 Code"; code[20])
        {
            CaptionClass = '1,1,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(13; "Global Dimension 2 Code"; code[20])
        {
            CaptionClass = '1,1,2';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(14; "Post to Account"; code[20])
        {
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Document No.", "Line No")
        {
            Clustered = true;
        }
    }
    var
        JVHeader: Record "Journal Voucher Header";

    trigger OnInsert()
    begin
        if JVHeader.Get("Document No.") then begin
            "Global Dimension 1 Code" := JVHeader."Global Dimension 1 Code";
            "Global Dimension 2 Code" := JVHeader."Global Dimension 2 Code";
            "Posting Description" := JVHeader."Posting Description";
        end;
    end;
}
