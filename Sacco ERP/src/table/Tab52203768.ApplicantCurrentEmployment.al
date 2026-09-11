table 52203768 "Applicant Current Employment"
{
    LookupPageId = "Applicant Current Employment";
    DrillDownPageId = "Applicant Current Employment";

    fields
    {
        field(1; "Applicant No."; Code[20])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(2; "From Date"; Date)
        {
            Caption = 'Effective Day of Employment';
            DataClassification = ToBeClassified;
            NotBlank = true;

            trigger OnValidate()
            begin
                If(("From Date" <> 0D) and ("To Date" <> 0D))then "Employment Period":=Dates.DetermineDatesDiffrence("From Date", "To Date");
                If(("From Date" <> 0D) and "Currently Employment")then "Employment Period":=Dates.DetermineDatesDiffrence("From Date", WorkDate);
            end;
        }
        field(3; "To Date"; Date)
        {
            DataClassification = ToBeClassified;
            NotBlank = true;

            trigger OnValidate()
            begin
                Validate("From Date");
            end;
        }
        field(4; "Employer/Institution Name"; Text[150])
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
        field(7; "Substantive Post"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Key Experience"; Text[150])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Gross Salary (KSH)"; Decimal)
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
            Editable = false;
        }
        field(17; "Currently Employment"; Boolean)
        {
            DataClassification = ToBeClassified;
        // trigger OnValidate()
        // var
        //     WorkExperience: Record "Applicant Work Experience";
        // begin
        //     if "Currently Employment" then begin
        //         WorkExperience.Reset();
        //         WorkExperience.SetRange("Applicant No.", "Applicant No.");
        //         WorkExperience.SetRange("Currently Employment", true);
        //         if WorkExperience.FindFirst() then begin
        //             WorkExperience."Currently Employment" := false;
        //             WorkExperience.Modify(true);
        //         end;
        //     end;
        // end;
        }
        field(18; Sector; Option)
        {
            OptionMembers = Public, Private, Academia, Corporate, Others;

            trigger OnValidate()
            begin
                If Sector <> Sector::Others then "Sector Specification":='';
            end;
        }
        field(19; "Sector Specification"; Text[50])
        {
        }
        field(20; "Employment No."; Code[20])
        {
        }
        field(21; "Job Grade"; Code[20])
        {
        //TableRelation = "Salary Scales";
        }
        field(22; "Terms of Service"; Option)
        {
            OptionMembers = Pensionable, Contract, Others;

            trigger OnValidate()
            begin
                If "Terms of Service" <> "Terms of Service"::Others then "Terms of Service Specfication":='';
            end;
        }
        field(23; "Terms of Service Specfication"; Text[50])
        {
        }
        field(24; "Expected Salary (KSH)"; Decimal)
        {
        }
        field(25; "Employment Period"; Text[50])
        {
        }
    }
    keys
    {
        key(Key1; "Applicant No.", "Employer/Institution Name", "Currently Employment")
        {
        }
    }
    var Dates: Codeunit "HR Dates";
    LoginMgmt: Codeunit "User Management Ext";
}
