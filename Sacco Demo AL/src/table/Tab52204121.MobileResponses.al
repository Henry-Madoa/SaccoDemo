table 52204121 "Mobile Responses"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Response Code"; Code[20])
        {
        }
        field(3; "Response Message"; Text[400])
        {
        }
        field(4; "Transaction Code"; Code[20])
        {
        }
        field(5; "Request ID"; Code[20])
        {
        }
        field(6; "Created At"; DateTime)
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
