table 52203588 "Contract Conditions"
{
    fields
    {
        field(1; "Employee No"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Contract Line No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(3; Condition; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Line No"; Integer)
        {
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Employee No", "Contract Line No", "Line No")
        {
        }
    }
}
