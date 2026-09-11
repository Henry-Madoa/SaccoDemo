table 52203641 "Scale COLA Tracker"
{
    fields
    {
        field(1; "Entry No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; Grade; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(3; Pointer; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(4; Percentage; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(5; Date; Date)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Entry No")
        {
        }
    }
}
