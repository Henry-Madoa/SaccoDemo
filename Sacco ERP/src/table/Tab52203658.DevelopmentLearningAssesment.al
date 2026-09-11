table 52203658 "Development Learning Assesment"
{
    fields
    {
        field(1; "Line No"; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Employee No"; Code[20])
        {
        }
        field(3; "Appraisal No"; Code[20])
        {
        }
        field(4; "Training Action"; Text[100])
        {
        }
        field(5; "Due Date"; Date)
        {
        }
        field(6; "Learning Hours"; Integer)
        {
        }
        field(7; "Status(Mid Year)"; Text[100])
        {
        }
        field(8; "Status(End Year)"; Text[100])
        {
        }
        field(9; Comments; Text[100])
        {
        }
    }
    keys
    {
        key(Key1; "Line No", "Employee No", "Appraisal No")
        {
        }
    }
}
