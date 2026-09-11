table 52203783 "Applicant Professional Bodies"
{
    DrillDownPageID = "Applicant Professional Bodies";
    LookupPageID = "Applicant Professional Bodies";

    fields
    {
        field(1; "Applicant No."; Code[20])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(2; Code; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = true;
            NotBlank = true;
            TableRelation = "Professional Bodies";

            trigger OnValidate()
            begin
                ProfessionalBody.Reset;
                ProfessionalBody.SetRange(Code, Code);
                if ProfessionalBody.Find('-')then Name:=ProfessionalBody.Name;
            end;
        }
        field(3; Name; Text[100])
        {
            DataClassification = ToBeClassified;
            NotBlank = false;
        }
        field(4; Description; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(5; Priority;Enum "Criticality Status")
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Score ID"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Membership No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Membership Status";Enum "Employee Status")
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Applicant No.", Code, Name)
        {
            Clustered = true;
            SumIndexFields = "Score ID";
        }
        key(Key2; Code, "Applicant No.")
        {
        }
    }
    fieldgroups
    {
        fieldgroup(Dropdowm; "Applicant No.", Code, Name)
        {
        }
        fieldgroup(Brick; "Applicant No.", Code, Name)
        {
        }
    }
    var ProfessionalBody: Record "Professional Bodies";
}
