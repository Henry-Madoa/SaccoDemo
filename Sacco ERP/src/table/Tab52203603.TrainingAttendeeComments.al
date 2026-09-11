table 52203603 "Training Attendee Comments"
{
    fields
    {
        field(1; "Application No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Comment date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Created By"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(4; Comments; Text[250])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Application No", Comments)
        {
        }
    }
}
