table 52203616 "Payroll Employer Transaction"
{
    fields
    {
        field(1; "Employee Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Transaction Code"; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if PayrollTransactionCode.Get(Rec."Transaction Code") then
                    "Transaction Name" := PayrollTransactionCode.Name;
            end;
        }
        field(3; "Transaction Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Transaction Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Earning,Deduction';
            OptionMembers = Earning,Deduction;
        }
        field(5; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(6; Balance; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Payroll Period"; Date)
        {
            DataClassification = ToBeClassified;
            TableRelation = "Payroll Periods"."Start Date";
        }
        field(8; "Account To Credit"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Account To Debit"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Employee Code", "Transaction Code", "Payroll Period")
        {
        }
    }
    var
        PayrollTransactionCode: Record "Payroll Transaction Code";
}
