table 52204016 "Repayment Schedule"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Expected Date"; Date)
        {
        }
        field(4; Description; Text[50])
        {
        }
        field(5; "Principal Repayment"; Decimal)
        {
        }
        field(6; "Interest Repayment"; Decimal)
        {
        }
        field(7; "Monthly Repayment"; Decimal)
        {
        }
        field(8; "Running Balance"; Decimal)
        {
        }
        field(9; "Loan No."; Code[20])
        {
        }
    }
    keys
    {
        key(PK; "Entry No")
        {
            Clustered = true;
        }
    }
}
