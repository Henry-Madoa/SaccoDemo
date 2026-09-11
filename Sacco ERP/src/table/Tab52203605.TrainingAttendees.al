table 52203605 "Training Attendees"
{
    DrillDownPageID = "Training Attendees";
    LookupPageID = "Training Attendees";

    fields
    {
        field(1; "Line No"; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; "Plan Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Plan No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Employee No"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee where("Nature Of Employment"=filter(<>Board), "Employee Status"=filter(Active|OnLeave));

            trigger OnValidate()
            begin
                if Employee.Get("Employee No")then begin
                    "Employee Name":=Employee.FullName;
                end;
                TrainingAttendees.Reset();
                TrainingAttendees.SetRange("Plan No.", "Plan No.");
                TrainingAttendees.SetRange("Plan Line No.", "Plan Line No.");
                TrainingAttendees.SetRange("Employee No", "Employee No");
                If TrainingAttendees.Find then Error('%1 have alread been added to attend the training', "Employee Name");
            end;
        }
        field(5; "Employee Name"; Text[100])
        {
            Editable = false;
        }
        field(6; "Training Cost"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Training Employee Costs".Cost where("Attendees Line No."=field("Line No"), "Plan Line No."=field("Plan Line No."), "Plan No."=field("Plan No.")));
            Editable = false;
        }
        field(7; "Training Created"; Boolean)
        {
        }
    }
    keys
    {
        key(Key1; "Line No", "Plan Line No.", "Plan No.")
        {
            Clustered = true;
        }
    }
    var Employee: Record Employee;
    TrainingAttendees: Record "Training Attendees";
}
