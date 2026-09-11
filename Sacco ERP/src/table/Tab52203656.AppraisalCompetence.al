table 52203656 "Appraisal Competence"
{
    fields
    {
        field(1; "Line No"; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Appraisal No"; Code[20])
        {
        }
        field(3; "Employee Code"; Code[20])
        {
        }
        field(4; "Competence Category"; Text[100])
        {
        }
        field(5; "Maximum Weigth"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Overall Score"; Decimal)
        {
            CalcFormula = Sum("Appraisal Behaviour Rating".Score WHERE("Competence Line No"=FIELD("Line No"), "Appraisal No"=FIELD("Appraisal No"), "Review Period"=field("Review Period")));
            FieldClass = FlowField;
        }
        field(7; "Total Weigth"; Decimal)
        {
            CalcFormula = Sum("Appraisal Behaviour".Weight WHERE("Competence Line No"=FIELD("Line No"), "Employee No"=FIELD("Employee Code"), "Appraisal No"=FIELD("Appraisal No")));
            FieldClass = FlowField;
        }
        field(8; "Review Period"; Code[20])
        {
            TableRelation = "Appraisal Review Periods".Code;
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Line No", "Appraisal No", "Employee Code")
        {
        }
    }
}
