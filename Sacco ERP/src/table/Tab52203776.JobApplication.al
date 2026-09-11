table 52203776 "Job Application"
{
    DrillDownPageID = "Job Applications";
    LookupPageID = "Job Applications";

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            NotBlank = false;
        }
        field(2; "Applicant No."; Code[20])
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
        field(3; "First Name"; Text[30])
        {
            Caption = 'First Name';
        }
        field(4; "Middle Name"; Text[30])
        {
            Caption = 'Middle Name';
        }
        field(5; "Last Name"; Text[30])
        {
            Caption = 'Last Name';
        }
        field(6; Initials; Text[30])
        {
            Caption = 'Initials';

            trigger OnValidate()
            begin
                if("Search Name" = UpperCase(xRec.Initials)) or ("Search Name" = '')then "Search Name":=Initials;
            end;
        }
        field(7; "Job Title"; Text[250])
        {
            Caption = 'Job Title';
        }
        field(8; "Search Name"; Code[30])
        {
            Caption = 'Search Name';
        }
        field(9; Address; Text[50])
        {
            Caption = 'Address';
        }
        field(10; "Requisition No."; Code[20])
        {
            TableRelation = "Job Requisition";
            Editable = false;

            trigger OnValidate()
            begin
                if JobRequisition.Get("Requisition No.")then begin
                    Rec.Validate("Job ID", JobRequisition."Job ID");
                end;
            end;
        }
        field(11; "Job ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            NotBlank = false;
            TableRelation = "Company Jobs" where(Status=const(Approved));

            trigger OnValidate()
            begin
                if Jobs.Get("Job ID")then "Job Title":=Jobs.Name;
            end;
        }
        field(12; Date; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(13; "Date Approved"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "No. Series"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(15; "Created By"; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(16; Status;Enum "Job Application Status")
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(17; Score; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(18; Remark; Text[250])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "No.")
        {
        }
    }
    trigger OnInsert()
    begin
        if "No." = '' then begin
            HumanResSetup.Get;
            HumanResSetup.TestField(HumanResSetup."Job Application Nos");
            NoSeriesMgt.InitSeries(HumanResSetup."Job Application Nos", xRec."No. Series", 0D, "No.", "No. Series");
        end;
        Date:=Today;
        "Created By":=UserId;
    end;
    var Jobs: Record "Company Jobs";
    JobRequisition: Record "Job Requisition";
    DimMgt: Codeunit DimensionManagement;
    HumanResSetup: Record "Human Resources Setup";
    NoSeriesMgt: Codeunit NoSeriesManagement;
    Applicant: Record Applicant;
}
