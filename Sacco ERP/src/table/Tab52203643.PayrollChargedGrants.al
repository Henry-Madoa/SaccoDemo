table 52203643 "Payroll Charged Grants"
{
    fields
    {
        field(1; "Emp Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee."No.";
        }
        field(2; "Payroll Period"; Date)
        {
            DataClassification = ToBeClassified;
            TableRelation = "Payroll Periods"."Start Date";
        }
        field(3; "Period Month"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Period Year"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Grant Code"; Code[100])
        {
            DataClassification = ToBeClassified;
        }
        field(6; Percentage; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Emp Code", "Payroll Period", "Grant Code")
        {
        }
    }
}
