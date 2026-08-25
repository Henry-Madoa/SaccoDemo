table 52204103 "Customer Feedback"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Category Code"; Code[20])
        {
        }
        field(3; Subject; Text[250])
        {
        }
        field(4; Details; Text[250])
        {
        }
        field(5; "Created On"; DateTime)
        {
        }
        field(6; Status; Option)
        {
            OptionMembers = New, Submited, Resolved;
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
