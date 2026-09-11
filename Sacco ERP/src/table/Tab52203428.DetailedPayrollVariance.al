table 52203428 "Detailed Payroll Variance"
{
    fields
    {
        field(1; "Entry No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Transaction Code"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Transaction Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Employee No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Employee Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Current Period"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Previous Period"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Previous Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Current Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(10; VarCe; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(11; Percentage; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Entry No")
        {
        }
    }
}
