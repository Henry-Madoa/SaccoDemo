table 52204056 "Member Withdrawal Lines"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            TableRelation = "Member Withdrawal";
        }
        field(2; "Entry No"; Integer)
        {
        }
        field(3; "Entry Type"; Option)
        {
            OptionMembers = Asset, Liability, Guarantee;
        }
        field(4; "Account No"; Code[20])
        {
        }
        field(5; "Account Name"; Text[100])
        {
        }
        field(6; "Balance"; Decimal)
        {
        }
        field(7; "Amount (Base)"; Decimal)
        {
        }
        field(8; "Accrued Interest"; Decimal)
        {
        }
        field(9; "Share Capital"; Boolean)
        {
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "No.", "Entry No")
        {
            Clustered = true;
        }
    }
}
