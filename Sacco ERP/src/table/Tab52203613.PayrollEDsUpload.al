table 52203613 "Payroll EDs Upload"
{
    fields
    {
        field(1; "Entry No"; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Payroll No."; Code[20])
        {
        }
        field(3; "Transaction Code"; Code[20])
        {
        }
        field(4; "Transaction Name"; Text[30])
        {
        }
        field(5; Amount; Decimal)
        {
        }
        field(6; Appplied; Boolean)
        {
        }
        field(7; "Period Code"; Date)
        {
            TableRelation = "Payroll Periods"."Start Date";
        }
        field(8; "Employee Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Bosa No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Loan No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Loan Balance"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Loan Type"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Interest Amount"; Decimal)
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
