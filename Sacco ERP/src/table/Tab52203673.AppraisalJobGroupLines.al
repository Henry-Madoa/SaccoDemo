table 52203673 "Appraisal Job Group Lines"
{
    fields
    {
        field(1; "Appraisal Code"; Code[20])
        {
        }
        field(2; "Job Grade"; Code[20])
        {
            TableRelation = "Lookup Values".Code WHERE(Type=CONST(Grade));

            trigger OnValidate()
            begin
                LookupValues.Reset;
                LookupValues.SetRange(Type, LookupValues.Type::"Job Group");
                LookupValues.SetRange(Code, "Job Grade");
                if LookupValues.FindFirst then "Grade Description":=LookupValues.Description;
            end;
        }
        field(3; "Grade Description"; Code[100])
        {
        }
    }
    keys
    {
        key(Key1; "Appraisal Code", "Job Grade")
        {
        }
    }
    var LookupValues: Record "Lookup Values";
}
