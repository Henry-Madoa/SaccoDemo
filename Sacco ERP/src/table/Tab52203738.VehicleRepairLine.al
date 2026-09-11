table 52203738 "Vehicle Repair Line"
{
    fields
    {
        field(1; "Requisition No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Type; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Type';
            OptionCaption = 'Repair,Replacement,Accident,Service';
            OptionMembers = Repair, Replacement, Accident, Service;
        }
        field(3; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "Motor Vehicle Asset"."No.";

            trigger OnValidate()
            begin
                if MotorVehicleAsset.Get("No.")then begin
                    Description:=MotorVehicleAsset."Vehicle Make" + ' ' + MotorVehicleAsset."Vehicle Model";
                end;
            end;
        }
        field(4; Description; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(5; Narration; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(6; Quantity; Integer)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                "Total Cost":="Estimated Unit Cost" * Quantity;
            end;
        }
        field(7; "Estimated Unit Cost"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                "Total Cost":="Estimated Unit Cost" * Quantity;
            end;
        }
        field(8; "Total Cost"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Total + Sundries"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Requisition No.", "No.", "Line No.")
        {
        }
    }
    var VehicleRepairHeader: Record "Vehicle Repair Header";
    MotorVehicleAsset: Record "Motor Vehicle Asset";
}
