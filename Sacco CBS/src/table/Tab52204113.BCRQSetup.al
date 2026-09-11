table 52204113 "BCRQ Setup"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "User ID"; Code[100])
        {
        }
        field(2; "Partial Member Update"; Boolean)
        {
            trigger OnValidate()
            begin
                if "Partial Member Update" then begin
                    "MPOA Update" := false;
                    "Can Rejoin Member" := false;
                    "Global Editor" := false;
                end;
            end;
        }
        field(3; "MPOA Update"; Boolean)
        {
            trigger OnValidate()
            begin
                "Partial Member Update" := false;
                "Can Rejoin Member" := false;
                "Global Editor" := false;
            end;
        }
        field(4; "Can Rejoin Member"; Boolean)
        {
            trigger OnValidate()
            begin
                "MPOA Update" := false;
                "Partial Member Update" := false;
                "Global Editor" := false;
            end;
        }
        field(5; "Global Editor"; Boolean)
        {
            trigger OnValidate()
            begin
                "MPOA Update" := false;
                "Can Rejoin Member" := false;
                "Partial Member Update" := false;
            end;
        }
        field(6; "Can Release Uncleared Funds"; Boolean)
        {
        }
    }
    keys
    {
        key(Key1; "User ID")
        {
            Clustered = true;
        }
    }
}
