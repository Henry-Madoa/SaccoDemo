table 52203635 "Payroll Import Bonus Buffer"
{
    Caption = 'Payroll Import Buffer';
    ReplicateData = false;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(10; "Payroll Period"; Date)
        {
            Caption = 'Transaction date';
            DataClassification = SystemMetadata;
        }
        field(11; "Transaction Code"; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = SystemMetadata;
        }
        field(12; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = SystemMetadata;
        }
        field(13; "Employee No"; Code[20])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }
}
