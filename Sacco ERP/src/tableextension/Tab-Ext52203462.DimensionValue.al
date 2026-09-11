tableextension 52203462 "Dimension Value" extends "Dimension Value"
{
    fields
    {
        // Add changes to table fields here
        field(70000; "Max No. of Employees"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(70001; "Minimum No. of Employees"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(70002; "Dimension 1 Code Link"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1), Blocked = const(false));
        }
        field(70003; "IT Dose ID"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }
}
