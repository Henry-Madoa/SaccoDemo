table 52203591 "Employee Languages"
{
    fields
    {
        field(1; "Employee No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Language; Text[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Hr Languages";
        }
        field(4; Read; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(5; Write; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(6; Speak; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Employee No", Language)
        {
        }
    }
}
