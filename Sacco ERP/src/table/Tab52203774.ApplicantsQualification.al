table 52203774 "Applicants Qualification"
{
    fields
    {
        field(1; "Applicant No."; Code[20])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
            TableRelation = Applicant."No.";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = ToBeClassified;
        }
        field(3; "Qualification Code"; Code[20])
        {
            Caption = 'Qualification Code';
            DataClassification = ToBeClassified;
            TableRelation = Qualification.Code WHERE("Qualification Type"=FIELD("Qualification Type"));

            trigger OnValidate()
            begin
                Qualifications.Reset;
                Qualifications.SetRange(Qualifications.Code, "Qualification Code");
                if Qualifications.Find('-')then Qualification:=Qualifications.Description;
            end;
        }
        field(4; "From Date"; Date)
        {
            Caption = 'From Date';
            DataClassification = ToBeClassified;
        }
        field(5; "To Date"; Date)
        {
            Caption = 'To Date';
            DataClassification = ToBeClassified;
        }
        field(6; Type; Option)
        {
            Caption = 'Type';
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Internal,External,Previous Position';
            OptionMembers = " ", Internal, External, "Previous Position";
        }
        field(7; Description; Text[1000])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }
        field(8; "Institution/Company"; Text[150])
        {
            Caption = 'Institution/Company';
            DataClassification = ToBeClassified;
        }
        field(9; Cost; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Cost';
            DataClassification = ToBeClassified;
        }
        field(10; "Course Grade"; Text[30])
        {
            Caption = 'Course Grade';
            DataClassification = ToBeClassified;
        }
        field(11; "Employee Status"; Option)
        {
            Caption = 'Employee Status';
            DataClassification = ToBeClassified;
            Editable = false;
            OptionCaption = 'Active,Inactive,Terminated';
            OptionMembers = Active, Inactive, Terminated;
        }
        field(12; Comment; Boolean)
        {
            CalcFormula = Exist("Human Resource Comment Line" WHERE("Table Name"=CONST("Employee Qualification"), "No."=FIELD("Applicant No."), "Table Line No."=FIELD("Line No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(13; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
            DataClassification = ToBeClassified;
        }
        field(14; "Competency Level";Enum "Competency Levels")
        {
            DataClassification = ToBeClassified;
        }
        field(50000; "Qualification Type";Enum "Qualification Types")
        {
            DataClassification = ToBeClassified;
            NotBlank = false;
        }
        field(50001; Qualification; Text[1000])
        {
            DataClassification = ToBeClassified;
        }
        field(50003; "Score ID"; Decimal)
        {
            DataClassification = ToBeClassified;
            TableRelation = "Score Setup"."Score ID";
        }
        field(50004; Address; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(50005; Email; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(50006; "Mobile Number"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(50007; "Attachment Link"; Text[250])
        {
            DataClassification = ToBeClassified;
            ExtendedDatatype = URL;
        }
    }
    keys
    {
        key(Key1; "Applicant No.", "Qualification Type", "Qualification Code")
        {
            SumIndexFields = "Score ID";
        }
        key(Key2; "Qualification Code")
        {
        }
    }
    fieldgroups
    {
    }
    var Qualifications: Record Qualification;
    Applicant: Record Applicant;
    Position: Code[20];
    JobReq: Record "Job Requirements";
}
