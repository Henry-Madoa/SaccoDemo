table 52203574 "Exit Clearance Form"
{
    fields
    {
        field(1; "Form No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Exit No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Employee No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Employee Name"; Text[70])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Global Dimension 1 Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Global Dimension 2 Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Global Dimension 3 Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Global Dimension 4 Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Created On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Created By"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Responsible Employee"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(13; Dues; Decimal)
        {
            Editable = false;
            CalcFormula = Sum("Exit Clearance Form Lines".Amount WHERE("Employee No"=FIELD("Employee No")));
            FieldClass = FlowField;
        }
        field(14; Cleared; Boolean)
        {
            trigger OnValidate()
            begin
                if Cleared then begin
                    if EmployeeExit.Get("Exit No")then begin
                        EmployeeExit.Status:=EmployeeExit.Status::Cleared;
                        EmployeeExit.Modify(true);
                    end;
                end;
            end;
        }
        field(20; "Clearing Employee"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(22; "HOD Comments"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(23; "Supervisor Comments"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(24; "HR Comments"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Form No")
        {
        }
    }
    var EmployeeExit: Record "Employee Exit";
}
