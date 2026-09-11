table 52203649 "Appraisal Activities"
{
    fields
    {
        field(1; "Line No"; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Kra Line No"; Integer)
        {
        }
        field(3; "Appraisal No"; Code[20])
        {
        }
        field(4; "Employee No"; Code[20])
        {
        }
        field(5; Activity; Text[250])
        {
        }
        field(6; "Due Date"; Date)
        {
        }
        field(7; "Review Period"; Code[20])
        {
            TableRelation = "Appraisal Review Periods".Code;
            Editable = false;
        }
        field(8; "Kra/Objective"; Text[250])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Appraisal Objectives/KRAs"."KRA/Objective" where("Line No"=field("Kra Line No"), "Appraisal No"=field("Appraisal No"), "Employee No"=field("Employee No")));
            Editable = false;
        }
        field(17; Weight; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(27; "Target/KPI"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(28; "Target Justification"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Target/KPI Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ", Achieved, "Not Achieved";
        }
    }
    keys
    {
        key(Key1; "Line No", "Appraisal No", "Employee No", "Kra Line No")
        {
        }
    }
}
