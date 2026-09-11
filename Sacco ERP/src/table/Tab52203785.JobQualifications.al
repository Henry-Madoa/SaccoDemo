table 52203785 "Job Qualifications"
{
    fields
    {
        field(1; "Job Id"; Code[20])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(2; "Qualification Type";Enum "Qualification Types")
        {
            DataClassification = ToBeClassified;
            NotBlank = false;
            Editable = false;
        }
        field(3; "Qualification Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            Editable = true;
            NotBlank = true;
            TableRelation = Qualification.Code WHERE("Qualification Type"=FIELD("Qualification Type"));

            trigger OnValidate()
            begin
                if QualificationSetUp.Get("Qualification Code")then Qualification:=QualificationSetUp.Description;
            end;
        }
        field(4; Qualification; Text[1000])
        {
            DataClassification = ToBeClassified;
            NotBlank = false;
        }
        field(5; Description; Text[1000])
        {
            DataClassification = ToBeClassified;
        }
        field(6; Priority;Enum "Criticality Status")
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Score ID"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Competency Level";Enum "Competency Levels")
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Job Id", "Qualification Type", "Qualification Code")
        {
            Clustered = true;
            SumIndexFields = "Score ID";
        }
    }
    var QualificationSetUp: Record Qualification;
}
