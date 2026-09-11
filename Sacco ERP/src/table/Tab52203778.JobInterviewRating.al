table 52203778 "Job Interview Rating"
{
    DrillDownPageID = "Job Interview Rating";
    LookupPageID = "Job Interview Rating";

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Applicant No"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(3; Interviewer; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;

            trigger OnValidate()
            begin
                If EmpRec.Get(Interviewer)then "Interviewer Name":=EmpRec.FullName();
            end;
        }
        field(4; "Interviewer Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5; Description; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(6; Marks; Decimal)
        {
            DataClassification = ToBeClassified;
            MaxValue = 100;
            MinValue = 0;
        }
    }
    keys
    {
        key(Key1; "No.", "Applicant No", Interviewer)
        {
        }
    }
    var EmpRec: Record Employee;
}
