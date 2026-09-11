table 52203623 "Payroll Salary Card"
{
    fields
    {
        field(1; "Employee Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee."No.";
        }
        field(2; "Basic Pay"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                Text0000: Label 'Do you want to change the Basic Pay for this Employee %1 and Update his/her Employee Card?';
                Text0001: Label 'Aborted. Press F5 to discard the changes';
                Text0002: Label 'Employee %1 does not exist in HR Employees list. Please liase with HR Officer to Create this Employee';
            begin
            end;
        }
        field(3; "Payment Mode"; Option)
        {
            DataClassification = ToBeClassified;
            Description = 'Bank Transfer,Cheque,Cash,FOSA';
            OptionMembers = "Bank Transfer", Cheque, Cash, FOSA;
        }
        field(4; Currency; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = Currency.Code;
        }
        field(5; "Pays NSSF"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Pays SHIF"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Pays PAYE"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Payslip Message"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Cumm BasicPay"; Decimal)
        {
            CalcFormula = Sum("Payroll Employee P9 Tax Info"."Basic Pay" WHERE("Employee Code"=FIELD("Employee Code")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(10; "Cumm GrossPay"; Decimal)
        {
            CalcFormula = Sum("Payroll Employee P9 Tax Info"."Gross Pay" WHERE("Employee Code"=FIELD("Employee Code")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; "Cumm NetPay"; Decimal)
        {
            CalcFormula = Sum("Payroll Employee P9 Tax Info"."Net Pay" WHERE("Employee Code"=FIELD("Employee Code")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(12; "Cumm Allowances"; Decimal)
        {
            CalcFormula = Sum("Payroll Period Transaction".Amount WHERE("Employee Code"=FIELD("Employee Code"), "Group Order"=CONST(3)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(13; "Cumm Deductions"; Decimal)
        {
            CalcFormula = Sum("Payroll Period Transaction".Amount WHERE("Employee Code"=FIELD("Employee Code"), "Group Order"=CONST(8), "Sub Group Order"=FILTER(1|8), "Transaction Code"=FILTER(<>'Total deduction')));
            Editable = false;
            FieldClass = FlowField;
        }
        field(14; "Suspend Pay"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Suspension Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Suspension Reasons"; Text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Stop Relief"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Period Filter"; Date)
        {
            FieldClass = FlowFilter;
            TableRelation = "Payroll Periods"."Start Date";
        }
        field(19; "Insurance Certificate?"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Employee Code")
        {
        }
    }
}
