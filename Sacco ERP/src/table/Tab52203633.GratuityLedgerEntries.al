table 52203633 "Gratuity Ledger Entries"
{
    fields
    {
        field(1; "Employee No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Payroll Period"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Payroll Year"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(4; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(5; Paid; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Period Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Period End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Date of confirmation"; Date)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Employee No", "Payroll Year")
        {
        }
    }
}
