table 52203668 "C.Employee Contract Details"
{
    fields
    {
        field(1; "Employee No"; Code[20])
        {
            trigger OnValidate()
            begin
                if Emp.Get("Employee No")then "Employee Name":=Emp.FullName;
            end;
        }
        field(2; "Employee Name"; Text[100])
        {
            Editable = false;
        }
        field(3; "Contract Code"; Code[50])
        {
            TableRelation = "Employment Contract".Code;
        }
        field(4; "COntract Description"; Text[100])
        {
        }
        field(5; "Contract Period"; DateFormula)
        {
        }
        field(6; "Contract Start Date"; Date)
        {
        }
        field(7; "Contract End Date"; Date)
        {
        }
        field(8; "Job Title"; Text[70])
        {
            CalcFormula = Lookup(Employee."Job Title" WHERE("No."=FIELD("Employee No")));
            FieldClass = FlowField;
        }
        field(9; Grade; Text[30])
        {
            CalcFormula = Lookup(Employee."Job Scale" WHERE("No."=FIELD("Employee No")));
            FieldClass = FlowField;
        }
        field(10; "Line No"; Integer)
        {
        }
        field(11; "Current Contract"; Boolean)
        {
        }
        field(12; "Change No."; Code[20])
        {
        }
    }
    keys
    {
        key(Key1; "Employee No", "Line No", "Change No.")
        {
        }
    }
    var Emp: Record Employee;
}
