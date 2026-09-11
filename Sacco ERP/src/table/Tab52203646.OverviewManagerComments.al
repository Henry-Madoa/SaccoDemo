table 52203646 "Overview Manager Comments"
{
    fields
    {
        field(1; "Line No"; Integer)
        {
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
        field(2; "Employee No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Appraisal No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(4; Comments; Text[250])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Line No", "Employee No", "Appraisal No")
        {
        }
    }
}
