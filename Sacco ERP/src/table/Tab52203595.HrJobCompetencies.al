table 52203595 "Hr Job Competencies"
{
    DrillDownPageID = "Job Competencies";
    LookupPageID = "Job Competencies";

    fields
    {
        field(1; "Job ID"; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Competence Description"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Line No"; Integer)
        {
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Job ID", "Line No")
        {
        }
    }
}
