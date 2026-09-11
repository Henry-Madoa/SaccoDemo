table 52203734 "Fuel Requisition"
{
    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Vehicle REG. No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Motor Vehicle Asset"."No.";
        }
        field(3; "Fueling Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Vendor Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Vendor."No.";

            trigger OnValidate()
            begin
                if Vendor.Get("Vendor Code")then begin
                    "Vendor Name":=Vendor.Name;
                end;
            end;
        }
        field(5; "Vendor Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Driver Emp. No"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Motor Vehicle Drivers Data"."Employment No.";

            trigger OnValidate()
            begin
                if MotorVehicleDriversData.Get("Driver Emp. No")then begin
                    "Driver Name":=MotorVehicleDriversData."First Name" + ' ' + MotorVehicleDriversData."Middle Name" + ' ' + MotorVehicleDriversData."Last Name";
                end;
            end;
        }
        field(7; "Driver Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Payment Method"; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Payment Method';
            OptionCaption = ',Cash,Card,MPESA Paybill';
            OptionMembers = , Cash, Card, "MPESA Paybill";
        }
        field(9; "Card No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Fueling Card"."No.";

            trigger OnValidate()
            begin
                if FuelingCard.Get("Card No.")then begin
                    if FuelingCard."Expiry Date" < Today then Error('The card is expired');
                end;
            end;
        }
        field(10; "Paybill No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(12; "Quantity Fueled (ltrs)"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                TestField("Vehicle REG. No.");
                if MotorVehicleAsset.Get("Vehicle REG. No.")then begin
                    if "Quantity Fueled (ltrs)" > MotorVehicleAsset."Fuel Capacity" then Error('The fuel capacity of %1 is %2, you cannot fuel more than %2', "Vehicle REG. No.", MotorVehicleAsset."Fuel Capacity");
                end;
            end;
        }
        field(13; "Total Fuel Cost"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                TestField("Quantity Fueled (ltrs)");
                if "Payment Method" = "Payment Method"::Card then begin
                    TestField("Card No.");
                    if FuelingCard.Get("Card No.")then begin
                        if FuelingCard.Type = FuelingCard.Type::"Debit Card" then begin
                            FuelingCard.CalcFields(Amount, "Amount Usage");
                            FuelingCard."Amount Balance":=FuelingCard.Amount - FuelingCard."Amount Usage";
                            if "Total Fuel Cost" > FuelingCard."Amount Balance" then Error('The amount entered is more than the fuel card balance of %1', FuelingCard."Amount Balance");
                        end;
                    end;
                end;
                "Cost Per Litre":="Total Fuel Cost" / "Quantity Fueled (ltrs)";
            end;
        }
        field(14; "Cost Per Litre"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(15; Posted; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Created On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Created By"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Transaction Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Fuel,Insurance,Maintenance';
            OptionMembers = Fuel, Insurance, Maintenance;
        }
        field(19; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'New,Pending Approval,Approved,Rejected';
            OptionMembers = New, "Pending Approval", Approved, Rejected;
        }
        field(20; "Posting Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Invoice Created"; Boolean)
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
            FleetManagementSetup.TestField("Fuel Log Nos");
            NoSeriesManagement.InitSeries(FleetManagementSetup."Fuel Log Nos", xRec."No.", 0D, "No.", "No. Series");
        end;
        "Created On":=Today;
        "Created By":=UserId;
        "Transaction Type":="Transaction Type"::Fuel;
    end;
    var Vendor: Record Vendor;
    Employee: Record Employee;
    MotorVehicleAsset: Record "Motor Vehicle Asset";
    FleetManagementSetup: Record "Fleet Management Setup";
    NoSeriesManagement: Codeunit NoSeriesManagement;
    FuelingCard: Record "Fueling Card";
    FuelCardTopUp: Record "Fuel Card Top-Up";
    MotorVehicleDriversData: Record "Motor Vehicle Drivers Data";
}
