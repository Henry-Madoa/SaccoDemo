table 52204017 "Member Fixed Deposit Types"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Description; Text[50])
        {
        }
        field(3; "Min. Interest Rate"; Decimal)
        {
        }
        field(4; "Max. Interest Rate"; Decimal)
        {
        }
        field(5; "Interest Calculation Type"; Option)
        {
            OptionMembers = "Flat Rate", "Reducing Balance";
        }
        field(6; "Interest Provision Account"; code[20])
        {
            TableRelation = "G/L Account";
        }
        field(7; "Interest Payable Account"; code[20])
        {
            TableRelation = "G/L Account";
        }
        field(8; "Linking Account Type"; Code[20])
        {
            TableRelation = "Sacco Products" where(Indentation=const(1), Blocked=const(false), "Product Posting Type"=const("Fixed Deposit Account"));
        }
        field(9; "Charge Code"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(10; "Withholding Tax Rate"; Decimal)
        {
        }
        field(11; "Withholding Tax Account"; Code[20])
        {
            TableRelation = "G/L Account" where("Direct Posting"=const(true), Blocked=const(false), "Account Type"=const(Posting), "Account Category"=const(Liabilities));
        }
    }
    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
}
