table 52203611 "Payroll Approval Line Entries"
{
    fields
    {
        field(1; "Payroll Period"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Employee No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Employee Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Payroll Period", "Employee No.")
        {
        }
    }
}
