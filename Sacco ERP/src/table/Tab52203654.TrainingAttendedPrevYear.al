table 52203654 "Training Attended Prev. Year"
{
    fields
    {
        field(1; "Appraisal Code"; Code[20])
        {
        }
        field(2; "Employee Code"; Code[30])
        {
        }
        field(3; "Employee Name"; Text[100])
        {
        }
        field(4; "Training Code"; Code[50])
        {
        }
        field(5; "Training Description"; Text[100])
        {
        }
        field(6; Helpful; Boolean)
        {
        }
        field(7; "Lesson Learnt"; Text[250])
        {
        }
        field(8; "Why was it not Helpfull"; Text[250])
        {
        }
        field(9; "Another Atempt"; Boolean)
        {
        }
        field(10; "Line No"; Integer)
        {
            AutoIncrement = true;
        }
        field(11; "Supervisor Comments"; Text[250])
        {
        }
    }
    keys
    {
        key(Key1; "Appraisal Code", "Employee Code", "Line No")
        {
        }
    }
    trigger OnInsert()
    begin
        if EmployeesHR.Get("Employee Code")then begin
            "Employee Name":=EmployeesHR.FullName;
        end;
    end;
    var EmployeesHR: Record Employee;
}
