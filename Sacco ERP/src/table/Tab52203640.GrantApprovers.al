table 52203640 "Grant Approvers"
{
    fields
    {
        field(1; "Emp No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Level; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Grant Approver,OverView,Line Manager';
            OptionMembers = " ", "Grant Approver", OverView, "Line Manager";
        }
    }
    keys
    {
        key(Key1; "Emp No", Level)
        {
        }
    }
}
