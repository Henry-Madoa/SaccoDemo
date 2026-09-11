table 52203454 "Leave Adjustment Line"
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
        field(7; "Employee Name"; Text[100])
        {
            Editable = false;
        }
        field(8; "Adjustment Days"; Integer)
        {
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
