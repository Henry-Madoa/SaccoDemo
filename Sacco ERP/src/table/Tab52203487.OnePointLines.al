table 52203487 "One Point Lines"
{
    fields
    {
        field(1; "No."; Code[20])
        {
        }
        field(4; "Employee No."; Code[20])
        {
            TableRelation = Employee;

            trigger OnValidate()
            begin
                if Employee.Get("Employee No.")then "Employee Name":=Employee.FullName;
            end;
        }
        field(6; "Processed Date"; Date)
        {
        }
        field(7; "Employee Name"; Text[30])
        {
            Editable = false;
        }
        field(8; "Current Garde"; Code[8])
        {
        }
        field(9; "Expected New Grade"; Code[8])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "New Grade"; Code[8])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "New Pointer"; Code[8])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "No.", "Employee No.")
        {
        }
    }
    var Employee: Record Employee;
    LeaveAdjustmentsHeader: Record "Leave Adjustment Header";
    LeaveAdjustmentsDetails: Record "Leave Adjustment Details";
}
