table 52203626 "Employee Payroll Scales"
{
    DrillDownPageID = "Employee Payroll Scales";
    LookupPageID = "Employee Payroll Scales";

    fields
    {
        field(1; Scale; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "No. of Employees"; Integer)
        {
            CalcFormula = Count(Employee WHERE("Job Scale"=FIELD(Scale)));
            FieldClass = FlowField;
        }
        field(3; "Leave Allowance Amount"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if xRec."Leave Allowance Amount" = Rec."Leave Allowance Amount" then exit;
                Employee.Reset;
                Employee.SetRange("Job Scale", Rec.Scale);
                if Employee.FindSet then begin
                    repeat if PayrollSalaryCard.Get(Employee."No.")then begin
                            PayrollSalaryCard."Basic Pay":=Rec."Leave Allowance Amount";
                            PayrollSalaryCard.Modify(true);
                        end;
                    until Employee.Next = 0;
                end;
            end;
        }
        field(4; Sequence; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Notice Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Probation Notice Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Inpatient Ward Entitlement"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,General,Semi Private,Private';
            OptionMembers = " ", General, "Semi Private", Private;
        }
        field(8; "Training Allowance Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Overtime Allowance Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; Scale)
        {
        }
        key(Key2; Sequence)
        {
        }
    }
    var Employee: Record Employee;
    PayrollSalaryCard: Record "Payroll Salary Card";
    PayrollEmployeeTransaction: Record "Payroll Employee Transaction";
}
