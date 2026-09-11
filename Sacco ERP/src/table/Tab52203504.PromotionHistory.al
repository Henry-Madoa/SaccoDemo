table 52203504 "Promotion History"
{
    fields
    {
        field(1; "Employee No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Salary Scale"; Code[10])
        {
        }
        field(3; "Salary Pointer"; Code[10])
        {
        }
        field(4; "Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Pointer Closed"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Last Modified"; Date)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Employee No", "Salary Scale", "Salary Pointer", "Start Date")
        {
        }
    }
}
