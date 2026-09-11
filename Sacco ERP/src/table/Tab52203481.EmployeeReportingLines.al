table 52203481 "Employee Reporting Lines"
{
    fields
    {
        field(1; No; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Employee No"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Employee Name"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(4; Level; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Line Manager,Overview Manager';
            OptionMembers = " ", "Line Manager", "Overview Manager";
        }
    }
    keys
    {
        key(Key1; No)
        {
        }
    }
}
