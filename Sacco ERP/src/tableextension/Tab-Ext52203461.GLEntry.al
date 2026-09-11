tableextension 52203461 "G/L Entry" extends "G/L Entry"
{
    fields
    {
        field(8006; "Budget Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(80010; "Donor Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(80011; "Student Code"; Code[20])
        {
            CalcFormula = Lookup("Dimension Set Entry"."Dimension Value Code" WHERE("Dimension Set ID" = FIELD("Dimension Set ID"), "Dimension Code" = FILTER('STUDENT')));
            FieldClass = FlowField;
            TableRelation = "Dimension Value".Code WHERE("Dimension Code" = CONST('STUDENT'));
        }
        modify(Description)
        {
            Width = 250;
        }
    }
}
