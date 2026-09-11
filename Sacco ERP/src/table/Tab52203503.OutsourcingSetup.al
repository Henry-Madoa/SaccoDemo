table 52203503 "Outsourcing Setup"
{
    fields
    {
        field(1; "Primary Key"; Integer)
        {
        }
        field(2; "Employee Import Nos."; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(3; "Employee Leave Nos."; Code[20])
        {
            TableRelation = "No. Series";
        }
    }
    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }
}
