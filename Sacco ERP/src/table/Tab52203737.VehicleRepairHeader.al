table 52203737 "Vehicle Repair Header"
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

            trigger OnValidate()
            begin
                VehicleRepairLine.Reset;
                VehicleRepairLine.SetRange("Requisition No.", Rec."No.");
                if VehicleRepairLine.FindSet then begin
                    VehicleRepairLine.DeleteAll;
                end;
            end;
        }
        field(3; "Created On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Created By"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(5; Status; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Status';
            OptionCaption = 'New,Pending Approval,Approved,Rejected';
            OptionMembers = New, "Pending Approval", Approved, Rejected;
        }
        field(6; "Mileage at Service (kms)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(8; "Reason Code"; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Reason Code';
            OptionCaption = 'Repair,Replacement,Accident,Service';
            OptionMembers = Repair, Replacement, Accident, Service;

            trigger OnValidate()
            begin
                VehicleRepairLine.Reset;
                VehicleRepairLine.SetRange("Requisition No.", Rec."No.");
                if VehicleRepairLine.FindSet then begin
                    repeat VehicleRepairLine.Type:=Rec."Reason Code";
                        VehicleRepairLine.Modify(true);
                    until VehicleRepairLine.Next = 0;
                end;
            end;
        }
        field(9; "Service Proforma No"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Service Proforma Header"."No." WHERE("Vehicle REG. No."=FIELD("Vehicle REG. No."), "Repair Executed"=CONST(false));

            trigger OnValidate()
            begin
                if ServiceProformaHeader.Get("Service Proforma No")then begin
                    "Mileage at Service (kms)":=ServiceProformaHeader."Mileage (Kms)";
                    VehicleRepairLine.Reset;
                    VehicleRepairLine.SetRange("Requisition No.", Rec."No.");
                    if VehicleRepairLine.FindSet then begin
                        VehicleRepairLine.DeleteAll;
                    end;
                    ServiceProformaHeader.Reset;
                    ServiceProformaHeader.SetRange("No.", Rec."Service Proforma No");
                    if ServiceProformaHeader.FindFirst then begin
                        ServiceProformaLine.Reset;
                        ServiceProformaLine.SetRange("Document No.", ServiceProformaHeader."No.");
                        if ServiceProformaLine.FindFirst then begin
                            repeat VehicleRepairLine.Init;
                                VehicleRepairLine."Requisition No.":=Rec."No.";
                                VehicleRepairLine."No.":=Rec."Vehicle REG. No.";
                                VehicleRepairLine.Validate("No.");
                                VehicleRepairLine."Line No."+=10;
                                VehicleRepairLine.Type:=Rec."Reason Code";
                                VehicleRepairLine.Narration:=ServiceProformaLine.Description;
                                VehicleRepairLine.Quantity:=ServiceProformaLine.Quantity;
                                VehicleRepairLine.Validate(Quantity);
                                VehicleRepairLine."Estimated Unit Cost":=ServiceProformaLine."Unit Price";
                                VehicleRepairLine.Validate("Estimated Unit Cost");
                                VehicleRepairLine."Total + Sundries":=ServiceProformaLine."Total Amount" + ServiceProformaLine.Sundries;
                                VehicleRepairLine.Insert;
                            until ServiceProformaLine.Next = 0;
                        end;
                    end;
                end
                else if "Service Proforma No" = '' then begin
                        VehicleRepairLine.Reset;
                        VehicleRepairLine.SetRange("Requisition No.", Rec."No.");
                        if VehicleRepairLine.FindSet then begin
                            VehicleRepairLine.DeleteAll;
                        end;
                    end;
            end;
        }
        field(10; "Transaction Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Fuel,Insurance,Maintenance';
            OptionMembers = Fuel, Insurance, Maintenance;
        }
        field(11; "Posting Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(12; Posted; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Invoice Created"; Boolean)
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
            FleetManagementSetup.TestField("Vehicle Repair Nos");
            NoSeriesManagement.InitSeries(FleetManagementSetup."Vehicle Repair Nos", xRec."No.", 0D, "No.", "No. Series");
        end;
        "Created On":=Today;
        "Created By":=UserId;
        "Transaction Type":="Transaction Type"::Maintenance;
    end;
    var FleetManagementSetup: Record "Fleet Management Setup";
    NoSeriesManagement: Codeunit NoSeriesManagement;
    VehicleRepairLine: Record "Vehicle Repair Line";
    ServiceProformaLine: Record "Service Proforma Line";
    ServiceProformaHeader: Record "Service Proforma Header";
}
