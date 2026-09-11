table 52204037 "Loan Calculator Lines"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Calculator No"; Code[20])
        {
        }
        field(3; Month; Code[20])
        {
        }
        field(4; "Expected Date"; Date)
        {
        }
        field(5; "Principal Amount"; Decimal)
        {
        }
        field(6; "Interest Amount"; Decimal)
        {
        }
        field(7; "Installment Amount"; Decimal)
        {
        }
        field(8; "Running Balance"; Decimal)
        {
        }
    }
    keys
    {
        key(Key1; "Entry No")
        {
            Clustered = true;
        }
    }
}
