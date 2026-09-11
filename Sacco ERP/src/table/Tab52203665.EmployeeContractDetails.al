table 52203665 "Employee Contract Details"
{
    fields
    {
        field(1; "Employee No"; Code[20])
        {
        }
        field(2; "Employee Name"; Text[100])
        {
            FieldClass = Normal;
        }
        field(3; "Contract Code"; Code[50])
        {
            TableRelation = "Employment Contract".Code;

            trigger OnValidate()
            begin
                if EmploymentContract.Get("Contract Code")then begin
                    "Contract Description":=EmploymentContract.Description;
                    "Notice Period":=EmploymentContract."Notice Period";
                end;
            end;
        }
        field(4; "Contract Description"; Text[100])
        {
        }
        field(5; "Contract Period"; DateFormula)
        {
            trigger OnValidate()
            begin
                if Format("Contract Period") <> '' then begin
                    Rec.Testfield("Contract Start Date");
                    "Contract End Date":=CalcDate("Contract Period", "Contract Start Date");
                end;
            end;
        }
        field(6; "Contract Start Date"; Date)
        {
        }
        field(7; "Contract End Date"; Date)
        {
        }
        field(8; "Job Title"; Text[70])
        {
            FieldClass = Normal;
        }
        field(9; Grade; Text[30])
        {
            FieldClass = Normal;
        }
        field(10; "Line No"; Integer)
        {
            AutoIncrement = true;
        }
        field(11; "Current Contract"; Boolean)
        {
        }
        field(12; "Notice Period"; DateFormula)
        {
        }
        field(13; Salary; Decimal)
        {
            FieldClass = Normal;
        }
        field(14; "Line Manager"; Code[50])
        {
            trigger OnValidate()
            begin
                if EmployeesHR.Get()then begin
                    "Manager Name":=EmployeesHR.FullName;
                end;
            end;
        }
        field(15; "Manager Name"; Text[70])
        {
            FieldClass = Normal;
        }
        field(16; Department; Code[50])
        {
            FieldClass = Normal;
        }
        field(17; "Contract Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Active,Inactive';
            OptionMembers = Active, Inactive;
        }
        field(18; Pointer; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Employee Title"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Probation Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Employee No", "Line No")
        {
        }
    }
    var EmploymentContract: Record "Employment Contract";
    EmployeesHR: Record Employee;
}
