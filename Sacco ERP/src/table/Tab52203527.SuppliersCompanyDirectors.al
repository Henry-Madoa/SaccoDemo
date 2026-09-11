table 52203527 "Suppliers Company Directors"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Vendor No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Line No"; Integer)
        {
            AutoIncrement = true;
        }
        field(3; "Title"; Code[20])
        {
        }
        field(4; "Full Name"; Text[80])
        {
        }
        field(5; "Nationality"; Code[20])
        {
        }
        field(6; Shares; Decimal)
        {
        }
    }
    keys
    {
        key(Key1; "Line No", "Vendor No")
        {
            Clustered = true;
        }
        key(Key2; "Vendor No", "Line No")
        {
        }
    }
}
