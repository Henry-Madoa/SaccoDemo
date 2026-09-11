table 52203429 "Payroll CBS"
{
    fields
    {
        field(1; "Entry No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Fosa Account"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(4; Currency; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Employee No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Employee Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Loan No"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Deposit Type"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Transaction Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Loan,Deposit,Share Capital,Net Pay,Loan Interest';
            OptionMembers = " ", Loan, Deposit, "Share Capital", "Net Pay", "Loan Interest";
        }
        field(10; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Pending,Completed,Failed';
            OptionMembers = Pending, Completed, Failed;
        }
        field(11; Received; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Date Sent"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(13; Comments; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Global Dimension 1 Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Global Dimesnion 2 Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Bosa Number"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Gl Account"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Payroll Period"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Transaction Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Employee No", "Transaction Code", "Payroll Period")
        {
        }
    }
}
