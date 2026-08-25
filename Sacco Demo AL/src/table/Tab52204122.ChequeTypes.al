table 52204122 "Cheque Types"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Type; Enum "Cheque Type")
        {
            DataClassification = ToBeClassified;
        }
        field(3; Description; Text[50])
        {
        }
        field(4; "Maximum Amount"; Decimal)
        {
        }
        field(5; "Transaction Nos."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(6; "Clearing Account Type"; Enum "Gen. Journal Account Type")
        {
        }
        field(7; "Clearing Account"; Code[20])
        {
            TableRelation = IF ("Clearing Account Type" = CONST("G/L Account")) "G/L Account" WHERE("Account Type" = CONST(Posting), Blocked = CONST(false))
            ELSE IF ("Clearing Account Type" = CONST(Customer)) Customer
            ELSE IF ("Clearing Account Type" = CONST(Vendor)) Vendor
            ELSE IF ("Clearing Account Type" = CONST("Bank Account")) "Bank Account"
            ELSE IF ("Clearing Account Type" = CONST("Fixed Asset")) "Fixed Asset"
            ELSE IF ("Clearing Account Type" = CONST("IC Partner")) "IC Partner"
            ELSE IF ("Clearing Account Type" = CONST(Employee)) Employee;
        }
        field(8; "Clearing Charge"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(9; "Express Clearing Charge Code"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(10; "Bouncing Charge Code"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(11; "In-House"; Boolean)
        {
        }
        field(12; "Maturity Period"; DateFormula)
        {
        }
    }
    keys
    {
        key(Key1; Code, Type)
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; Code, Description)
        {
        }
        fieldgroup(Brick; Code, Description)
        {
        }
    }
}
