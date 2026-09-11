table 52203679 "Investment Group No"
{
    fields
    {
        field(1; "Roll Over No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Investment Posting Group"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Investment Posting Group".Group;
        }
    }
    keys
    {
        key(Key1; "Roll Over No.")
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Roll Over No.", "Investment Posting Group")
        {
        }
    }
}
