table 52203786 "Job Shortlisted Applicants"
{
    DrillDownPageID = "Job Shortlisted Applicants";
    LookupPageID = "Job Shortlisted Applicants";
    Caption = 'Shortlisted Applicants';

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            NotBlank = false;
        }
        field(2; "Application No."; Code[20])
        {
            DataClassification = ToBeClassified;
            NotBlank = false;
        }
        field(3; "Requisition No."; Code[20])
        {
            Editable = false;

            trigger OnValidate()
            begin
                if JobRequisition.Get("Requisition No.")then begin
                    Rec.Validate("Job ID", JobRequisition."Job ID");
                end;
            end;
        }
        field(4; "Applicant No."; Code[20])
        {
            Editable = false;

            trigger OnValidate()
            begin
                If Applicant.Get("Applicant No.")then begin
                    Rec."First Name":=Applicant."First Name";
                    Rec."Middle Name":=Applicant."Middle Name";
                    Rec.Initials:=Applicant.Initials;
                    Rec.Address:=Applicant."Postal Address";
                end;
            end;
        }
        field(5; "First Name"; Text[30])
        {
            Caption = 'First Name';
        }
        field(6; "Middle Name"; Text[30])
        {
            Caption = 'Middle Name';
        }
        field(7; "Last Name"; Text[30])
        {
            Caption = 'Last Name';
        }
        field(8; Initials; Text[30])
        {
            Caption = 'Initials';

            trigger OnValidate()
            begin
                if("Search Name" = UpperCase(xRec.Initials)) or ("Search Name" = '')then "Search Name":=Initials;
            end;
        }
        field(9; "Job Title"; Text[250])
        {
            Caption = 'Job Title';
        }
        field(10; "Search Name"; Code[30])
        {
            Caption = 'Search Name';
        }
        field(11; Address; Text[50])
        {
            Caption = 'Address';
        }
        field(12; "Job ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            NotBlank = false;
            TableRelation = "Company Jobs" where(Status=const(Approved));

            trigger OnValidate()
            begin
                if Jobs.Get("Job ID")then "Job Title":=Jobs.Name;
            end;
        }
        field(13; Score; Decimal)
        {
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "No.", "Applicant No.")
        {
        }
    }
    var Jobs: Record "Company Jobs";
    JobRequisition: Record "Job Requisition";
    Applicant: Record Applicant;
}
