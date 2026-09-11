table 52203610 "Payroll Approval Header"
{
    fields
    {
        field(1; "Period Name"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Start Date"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Created By"; Code[100])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Created On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Period Month"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Period Year"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Opened By"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Start Date")
        {
        }
    }
}
