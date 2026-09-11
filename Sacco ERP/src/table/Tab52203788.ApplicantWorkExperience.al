table 52203788 "Applicant Work Experience"
{
    LookupPageId = "Applicant Work Experience";
    DrillDownPageId = "Applicant Work Experience";

    fields
    {
        field(1; "Applicant No."; Code[20])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(2; "From Date"; Date)
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(3; "To Date"; Date)
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(4; "Company Name"; Text[150])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(5; "Postal Address"; Text[40])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Address 2"; Text[40])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Job Title"; Text[150])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Key Experience"; Text[150])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Salary On Leaving"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Reason For Leaving"; Text[150])
        {
            DataClassification = ToBeClassified;
        }
        field(16; Comment; Text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Currently Working Here"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Applicant No.", "Company Name")
        {
        }
    }
}
