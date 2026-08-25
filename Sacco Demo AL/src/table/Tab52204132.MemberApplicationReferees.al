table 52204132 "Member Application Referees"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Application No."; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(3; "Full Names"; Text[150])
        {
        }
        field(4; "Phone No."; code[20])
        {
        }
        field(5; "Relationship"; code[20])
        {
        }
    }
    keys
    {
        key(PK; "Application No.", "Entry No.")
        {
            Clustered = true;
        }
    }
}
