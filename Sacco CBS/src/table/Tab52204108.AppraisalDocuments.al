table 52204108 "Appraisal Documents"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Employer Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Line No"; Integer)
        {
            autoincrement = true;
        }
        field(3; "Document Description"; Text[250])
        {
        }
    }
    keys
    {
        key(Key1; "Employer Code", "Line No")
        {
            Clustered = true;
        }
    }
}
