table 52203620 "Payroll Employee P9 Tax Info"
{
    fields
    {
        field(1; "Employee Code"; Code[20])
        {
            TableRelation = Employee;
        }
        field(2; "Basic Pay"; Decimal)
        {
        }
        field(3; Allowances; Decimal)
        {
        }
        field(4; Benefits; Decimal)
        {
        }
        field(5; "Value Of Quarters"; Decimal)
        {
        }
        field(6; "Defined Contribution"; Decimal)
        {
        }
        field(7; "Owner Occupier Interest"; Decimal)
        {
        }
        field(8; "Gross Pay"; Decimal)
        {
        }
        field(9; "Taxable Pay"; Decimal)
        {
        }
        field(10; "Tax Charged"; Decimal)
        {
        }
        field(11; "Insurance Relief"; Decimal)
        {
        }
        field(12; "Tax Relief"; Decimal)
        {
        }
        field(13; PAYE; Decimal)
        {
        }
        field(14; NSSF; Decimal)
        {
        }
        field(15; SHIF; Decimal)
        {
        }
        field(16; Deductions; Decimal)
        {
        }
        field(17; "Net Pay"; Decimal)
        {
        }
        field(18; "Period Month"; Integer)
        {
        }
        field(19; "Period Year"; Integer)
        {
        }
        field(20; "Payroll Period"; Date)
        {
            TableRelation = "Payroll Periods";
        }
        field(21; "Period Filter"; Date)
        {
            FieldClass = FlowFilter;
            TableRelation = "Payroll Periods";
        }
        field(22; Pension; Decimal)
        {
        }
        field(23; HELB; Decimal)
        {
        }
        field(24; "Payroll Code"; Code[20])
        {
            TableRelation = "Payroll Periods";
        }
        field(25; Source; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Payroll,Per Diem';
            OptionMembers = Payroll, "Per Diem";
        }
        field(26; "Entry No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(27; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
    }
    keys
    {
        key(Key1; "Employee Code", "Payroll Period", "Line No.")
        {
            SumIndexFields = "Basic Pay", "Gross Pay", "Net Pay", Allowances, Deductions, PAYE, NSSF, SHIF;
        }
    }
    trigger OnInsert()
    begin
        PayrollEmployeeP9TaxInfo.Reset;
        PayrollEmployeeP9TaxInfo.SetFilter("Line No.", '<>%1', 0);
        if not PayrollEmployeeP9TaxInfo.FindLast then begin
            PayrollEmployeeP9TaxInfo."Line No.":=1;
        end
        else
        begin
            PayrollEmployeeP9TaxInfo."Line No.":=PayrollEmployeeP9TaxInfo."Line No." + 1;
        end;
    end;
    var PayrollEmployeeP9TaxInfo: Record "Payroll Employee P9 Tax Info";
}
