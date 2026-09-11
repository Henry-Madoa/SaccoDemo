table 52203575 "Exit Clearance Setup"
{
    LookupPageId = "Exit Clearance Setup";
    DrillDownPageId = "Exit Clearance Setup";

    fields
    {
        field(1; "Employee No"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee."No.";

            trigger OnValidate()
            begin
                if Employee.Get("Employee No")then "Employee Name":=Employee.FullName;
            end;
        }
        field(2; "Employee Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(3; Section; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Clearance Sections";
        }
        field(4; Sequence; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(5; Substitute; Code[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee."No." WHERE(Status=CONST(Active));
        }
    }
    keys
    {
        key(Key1; "Employee No", Section)
        {
        }
    }
    var Employee: Record Employee;
}
