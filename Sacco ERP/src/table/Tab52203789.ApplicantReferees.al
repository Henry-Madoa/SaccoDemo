table 52203789 "Applicant Referees"
{
    DrillDownPageID = "Applicant Referees";
    LookupPageID = "Applicant Referees";

    fields
    {
        field(1; "Applicant No."; Code[20])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(2; Referee; Text[100])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(3; Occupation; Text[100])
        {
            DataClassification = ToBeClassified;
            NotBlank = false;
        }
        field(4; "Mobile Phone"; Code[20])
        {
            DataClassification = ToBeClassified;
            ExtendedDatatype = PhoneNo;
        }
        field(5; Email; Text[50])
        {
            DataClassification = ToBeClassified;
            ExtendedDatatype = EMail;
        }
        field(6; Address; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(7; Insititution; Text[100])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Applicant No.", Referee)
        {
            Clustered = true;
        }
        key(Key2; Referee, "Applicant No.")
        {
        }
    }
}
