table 52203747 "Motor Vehicle Drivers Data"
{
    DrillDownPageID = "Vehicle Drivers List";
    LookupPageID = "Vehicle Drivers List";

    fields
    {
        field(1; "Employment No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee."No." WHERE("Job Title"=CONST('DRIVER'));

            trigger OnValidate()
            begin
                if Employee.Get("Employment No.")then begin
                    "First Name":=Employee."First Name";
                    "Middle Name":=Employee."Middle Name";
                    "Last Name":=Employee."Last Name";
                end;
            end;
        }
        field(2; "First Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Middle Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Last Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "ID No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "D.O.B"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Driving License No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Driving License Issue Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Driving License Expiry Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Driving License Type"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Date of Employment"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "License Use Duration"; Duration)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Employment No.")
        {
        }
    }
    var Employee: Record Employee;
}
