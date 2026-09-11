table 52203592 "Employee Hobbies"
{
    fields
    {
        field(1; "Employee No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Hobby Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Hobby Description"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Employee No", "Hobby Code")
        {
        }
    }
}
