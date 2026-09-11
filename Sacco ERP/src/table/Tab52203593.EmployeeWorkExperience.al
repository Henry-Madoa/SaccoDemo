table 52203593 "Employee Work Experience"
{
    fields
    {
        field(1; "Employee No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Position; Code[100])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Job Description"; Text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(4; Institution; Code[100])
        {
            DataClassification = ToBeClassified;
        }
        field(5; Period; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Job Responsibility"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Current Job"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Employee No", Position, "Job Description", Institution)
        {
        }
    }
}
