table 52203739 "Vehicle Booking Request"
{
    DrillDownPageID = "Vehicle Booking List";
    LookupPageID = "Vehicle Booking List";

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Requisition Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Requisition Date" < Today then Error('You cannot enter a past date');
            end;
        }
        field(3; "Employee No."; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee."No.";

            trigger OnValidate()
            begin
                if Employee.Get("Employee No.")then begin
                    "Employee Name":=Employee."First Name" + ' ' + Employee."Middle Name" + ' ' + Employee."Last Name";
                    Department:=Employee."Global Dimension 1 Code";
                end;
            end;
        }
        field(4; "Employee Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(5; Destination; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Reason For Request"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Number Of Travellers"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(8; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'New,Pending Approval,Approved,Rejected';
            OptionMembers = New, "Pending Approval", Approved, Rejected;
        }
        field(9; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(10; Department; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Created On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Created By"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(13; Submitted; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Capacity of Assigned Vehicles"; Integer)
        {
            CalcFormula = Sum("Vehicle Booking Request Lines"."Passenger Capacity" WHERE("Requisition No."=FIELD("No.")));
            FieldClass = FlowField;
        }
        field(15; "Expected Return Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "No.")
        {
        }
    }
    trigger OnInsert()
    begin
        if "No." = '' then begin
            FleetManagementSetup.Get;
            FleetManagementSetup.TestField("Vehicle Booking Nos");
            NoSeriesManagement.InitSeries(FleetManagementSetup."Vehicle Booking Nos", xRec."No.", 0D, "No.", "No. Series");
        end;
        "Created On":=Today;
        "Created By":=UserId;
    end;
    var FleetManagementSetup: Record "Fleet Management Setup";
    NoSeriesManagement: Codeunit NoSeriesManagement;
    Employee: Record Employee;
}
