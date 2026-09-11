table 52203770 "Job Requirement"
{
    fields
    {
        field(1; "Job Id"; Code[20])
        {
            NotBlank = true;
            TableRelation = "Company Jobs";
        }
        field(2; "Qualification Type"; Option)
        {
            NotBlank = false;
            OptionCaption = ' ,Academic,Professional,Technical,Personal Attributes,Certification';
            OptionMembers = " ", Academic, Professional, Technical, "Personal Attributes", Certification;
        }
        field(3; "Qualification Code"; Code[10])
        {
            Editable = true;
            NotBlank = true;
            TableRelation = Qualification.Code WHERE("Qualification Type"=FIELD("Qualification Type"));

            trigger OnValidate()
            begin
                //TBL JD 1.0 BT 18/08/2016 BEGIN
                gRecQualification.Reset;
                gRecQualification.SetRange(Code, "Qualification Code");
                if gRecQualification.Find('-')then Qualification:=gRecQualification.Description;
            //TBL JD 1.0 BT 18/08/2016 END
            end;
        }
        field(4; Qualification; Text[200])
        {
            NotBlank = false;
        }
        field(5; "Job Requirements"; Text[250])
        {
            NotBlank = true;
        }
        field(6; Priority; Option)
        {
            OptionMembers = " ", High, Medium, Low;
        }
        field(7; "Job Specification"; Option)
        {
            OptionMembers = " ", Academic, Professional, Technical, Experience;
        }
        field(8; Mandatory; Boolean)
        {
        }
        field(9; Minimum; Decimal)
        {
        }
        field(10; Actual; Decimal)
        {
        }
    }
    keys
    {
        key(Key1; "Job Id", "Qualification Type", "Qualification Code")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
    }
    var gRecQualification: Record Qualification;
}
