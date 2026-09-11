table 52204023 "Transaction Calc. Scheme"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Source Code"; Code[20])
        {
        }
        field(2; "Charge Code"; Code[20])
        {
            TableRelation = Charges;
        }
        field(3; "Entry No"; Integer)
        {
            AutoIncrement = true;
        }
        field(4; "Lower Limit"; Decimal)
        {
        }
        field(5; "Upper Limit"; Decimal)
        {
        }
        field(6; "Rate Type"; Option)
        {
            OptionMembers = "Flat Rate", "Percentage";
        }
        field(7; Rate; Decimal)
        {
        }
        field(8; "Upper Charge Limit"; Decimal)
        {
        }
        field(9; "Lower Charge Limit"; Decimal)
        {
        }
    }
    keys
    {
        key(Key1; "Source Code", "Charge Code", "Entry No")
        {
            Clustered = true;
        }
    }
}
