table 52203617 "Payroll Periods"
{
    LookupPageId = "Payroll Periods";
    DrillDownPageId = "Payroll Periods";
    fields
    {
        field(1; "Period Name"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Start Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                IF "Start Date" = 0D THEN EXIT;
                // IF CALCDATE('CM', "Start Date") <> "Start Date" THEN
                //     ERROR('Start date must be the begining of the month');
            end;
        }
        field(3; "End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Created By"; Code[100])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Created On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Closed By"; Code[100])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Closed On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(8; Closed; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Period Month"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Period Year"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Opened By"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(12; Status; Enum "Document Status")
        {
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(13; "Approval Opened"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Start Date")
        {
        }
    }
}
