table 52203742 "Vehicle Booking Request Lines"
{
    fields
    {
        field(1; "Requisition No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Vehicle REG. No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Motor Vehicle Asset"."No.";

            trigger OnValidate()
            begin
                VehicleBookingRequestLines.Reset;
                VehicleBookingRequestLines.SetRange("Requisition No.", "Requisition No.");
                VehicleBookingRequestLines.SetRange("Vehicle REG. No.", "Vehicle REG. No.");
                if VehicleBookingRequestLines.FindFirst then begin
                    Error('The vehicle already exists in this requisition');
                end;
                if MotorVehicleAsset.Get("Vehicle REG. No.")then begin
                    "Vehicle Model":=MotorVehicleAsset."Vehicle Model";
                    "Vehicle Make":=MotorVehicleAsset."Vehicle Make";
                    "Fuel Capacity":=MotorVehicleAsset."Fuel Capacity";
                    "Passenger Capacity":=MotorVehicleAsset."Passenger Capacity";
                    "Last Recorded Mileage (kms)":=MotorVehicleAsset."Mileage at Service (Kms)";
                end;
            end;
        }
        field(3; "Vehicle Model"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(4; "Vehicle Make"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5; "Fuel Capacity"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(6; "Passenger Capacity"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(7; "Last Recorded Mileage (kms)"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(8; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Requisition No.", "Line No.")
        {
        }
    }
    var MotorVehicleAsset: Record "Motor Vehicle Asset";
    VehicleBookingRequestLines: Record "Vehicle Booking Request Lines";
}
