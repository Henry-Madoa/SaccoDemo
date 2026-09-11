table 52203663 "Areas of Further Development"
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
        field(4; Weakness; Text[250])
        {
        }
        field(5; "Training Needed"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Support Needed"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Status Comment"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Line No.", "Appraisal No.", "Employee No.")
        {
        }
    }
}
