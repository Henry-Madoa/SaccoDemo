table 52203662 "Key Strengths Career Goals"
{
    fields
    {
        field(1; "Line No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Appraisal No."; Code[20])
        {
        }
        field(3; "Employee No."; Code[20])
        {
        }
        field(4; Strength; Text[250])
        {
        }
        field(5; "Goal Line No."; Integer)
        {
        }
    }
    keys
    {
        key(Key1; "Line No.", "Appraisal No.", "Employee No.", "Goal Line No.")
        {
        }
        key(Key2; "Goal Line No.")
        {
        }
    }
}
