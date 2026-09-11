table 52203771 "Applicant Hobbies"
{
    DrillDownPageID = "Applicant Hobbies";
    LookupPageID = "Applicant Hobbies";

    fields
    {
        field(1; "Applicant No."; Code[20])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(2; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(3; Hobby; Text[100])
        {
            DataClassification = ToBeClassified;
            NotBlank = false;
        }
    }
    keys
    {
        key(Key1; "Applicant No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Line No.", "Applicant No.")
        {
        }
    }
}
