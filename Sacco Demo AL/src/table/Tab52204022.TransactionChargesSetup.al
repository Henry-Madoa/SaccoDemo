table 52204022 "Transaction Charges Setup"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "Transaction Charges Setup";
    LookupPageId = "Transaction Charges Setup";

    fields
    {
        field(1; "Transaction Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Code; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Charges;

            trigger OnValidate()
            var
                Charges: Record Charges;
            begin
                Charges.Get(Code);
                Description := Charges.Description;
            end;
        }
        field(3; Description; text[50])
        {
            Editable = false;
        }
        field(4; "Post to Account Type"; Enum "Gen. Journal Account Type")
        {
        }
        field(5; "Post-to Account No."; Code[20])
        {
            TableRelation = if ("Post to Account Type" = const("G/L Account")) "G/L Account" where("Direct Posting" = const(true), "Account Type" = const(Posting))
            else if ("Post to Account Type" = const("Bank Account")) "Bank Account"
            else
            Vendor where("Account Type" = filter(<> sacco & <> Loan));
        }
        field(6; "Calculation Type"; Option)
        {
            OptionMembers = "Calculation Scheme","Percentage of Charge";
        }
        field(7; "Source Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = IF ("Calculation Type" = CONST("Percentage of Charge")) "Transaction Charges Setup".Code WHERE("Transaction Code" = FIELD("Transaction Code"));
        }
        field(8; Priority; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Coop Charge"; Decimal)
        {
        }
    }
    keys
    {
        key(PK; "Transaction Code", Code)
        {
            Clustered = true;
        }
        key(PK2; Priority)
        {
        }
    }
}
