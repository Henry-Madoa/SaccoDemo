table 52203760 "Counties"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = Counties;
    LookupPageId = Counties;

    fields
    {
        field(1; "County Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Name; Text[50])
        {
        }
        field(3; "Sub Counties"; Integer)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = count("Sub Counties" WHERE("County Code"=field("County Code")));
        }
    }
    keys
    {
        key(PK; "County Code")
        {
            Clustered = true;
        }
    }
}
