table 52204110 "Job Execution Entries"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Run Date"; DateTime)
        {
        }
        field(3; "Document No"; Code[20])
        {
        }
        field(4; "Member No"; Code[20])
        {
        }
        field(5; "Task Type"; Option)
        {
            OptionMembers = "Loan SMS", "Share Transfer", "Entrance Fee", "Loan Recovery", "ATM Post", "Mobile Post";
        }
        field(6; "Transactions Count"; Integer)
        {
        }
        field(7; Amount; Decimal)
        {
        }
        field(8; "Credit Account"; Code[20])
        {
        }
        field(9; "SASA Amount"; Decimal)
        {
        }
        field(10; "Investment Amount"; Decimal)
        {
        }
        field(11; "Deposits Amount"; Decimal)
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
