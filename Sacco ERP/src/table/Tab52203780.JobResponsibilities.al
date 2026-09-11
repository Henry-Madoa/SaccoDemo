table 52203780 "Job Responsibilities"
{
    DrillDownPageID = "&Job Responsibilities";
    LookupPageID = "&Job Responsibilities";
    Caption = 'Responsibilities';

    fields
    {
        field(1; "Job Id"; Code[20])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
            TableRelation = "Company Jobs";
        }
        field(2; "Line No"; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(3; "Responsibility Description"; Text[1000])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
    }
    keys
    {
        key(Key1; "Job Id", "Line No")
        {
            Clustered = true;
        }
        key(Key2; "Line No", "Job Id")
        {
        }
    }
}
