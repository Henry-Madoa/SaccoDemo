table 52204096 "Bulk SMS Lines"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Line No"; Integer)
        {
            AutoIncrement = true;
        }
        field(3; "Full Name"; Text[100])
        {
        }
        field(4; "Phone No"; Text[20])
        {
        }
        field(5; Sent; Boolean)
        {
        }
    }
    keys
    {
        key(Key1; "No.", "Line No")
        {
            Clustered = true;
        }
    }
}
