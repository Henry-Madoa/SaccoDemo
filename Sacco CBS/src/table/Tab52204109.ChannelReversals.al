table 52204109 "Channel Reversals"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Document No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Created On"; DateTime)
        {
        }
        field(3; "Created By"; Code[100])
        {
        }
        field(4; "Processed On"; DateTime)
        {
        }
        field(5; Processed; Boolean)
        {
        }
    }
    keys
    {
        key(Key1; "Document No")
        {
            Clustered = true;
        }
    }
}
