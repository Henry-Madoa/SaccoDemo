table 52203782 "Job Professional Bodies"
{
    DrillDownPageID = "Job Professional Bodies";
    LookupPageID = "Job Professional Bodies";

    fields
    {
        field(1; "Job Id"; Code[20])
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
        field(7; "Line No"; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
    }
    keys
    {
        key(Key1; "Job Id", "Line No")
        {
            Clustered = true;
            SumIndexFields = "Score ID";
        }
        key(Key2; "Line No", "Job Id")
        {
        }
    }
    fieldgroups
    {
        fieldgroup(Dropdowm; "Job Id", Code, Name)
        {
        }
        fieldgroup(Brick; "Job Id", Code, Name)
        {
        }
    }
    var ProfessionalBody: Record "Professional Bodies";
}
