table 52203731 "Motor Vehicle Asset"
{
    DrillDownPageID = "Motor Vehicle List";
    LookupPageID = "Motor Vehicle List";

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnLookup()
            begin
                FixedAsset.Reset;
                FixedAsset.SetRange("Asset Type", FixedAsset."Asset Type"::"Motor Vehicle");
                if PAGE.RunModal(5601, FixedAsset) = ACTION::LookupOK then begin
                    FixedAsset.TestField("Vehicle Registration No.");
                    "No.":=FixedAsset."Vehicle Registration No.";
                end;
            end;
        }
        field(2; "Vehicle Make"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Vehicle Model"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; Color; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Frame No."; Code[50])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                MotorVehicleAsset.Reset;
                MotorVehicleAsset.SetRange("Frame No.", Rec."Frame No.");
                if MotorVehicleAsset.FindFirst then Error('Frame No. already exists for vehicle %1', MotorVehicleAsset."No.");
            end;
        }
        field(6; "Engine No."; Code[50])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                MotorVehicleAsset.Reset;
                MotorVehicleAsset.SetRange("Engine No.", Rec."Engine No.");
                if MotorVehicleAsset.FindFirst then Error('Engine No. already exists for vehicle %1', MotorVehicleAsset."No.");
            end;
        }
        field(7; "Log Book No."; Code[50])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                MotorVehicleAsset.Reset;
                MotorVehicleAsset.SetRange("Log Book No.", Rec."Log Book No.");
                if MotorVehicleAsset.FindFirst then Error('Log Book No. already exists for vehicle %1', MotorVehicleAsset."No.");
            end;
        }
        field(8; "Year Of Manufacture"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Year Of Manufacture" > Today then Error('A future date cannot be used as the date of manufacture');
            end;
        }
        field(9; "Load Limit (KGS)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Passenger Capacity"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Fuel Capacity"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Purchase Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                TestField("Year Of Manufacture");
                if "Purchase Date" < "Year Of Manufacture" then Error('The purchase date cannot come before the manufacture date');
            end;
        }
        field(13; "Purchase Price"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Buy From Vendor"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Vendor."No.";

            trigger OnValidate()
            begin
                if Vendor.Get("Buy From Vendor")then begin
                    "Buy From Vendor Name":=Vendor.Name;
                end;
            end;
        }
        field(15; "Buy From Vendor Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Document Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Vehicle Insurance"."No." WHERE("Vehicle REG. No."=FIELD("No."), Expired=CONST(false));

            trigger OnValidate()
            begin
                TestField("Purchase Date");
                if VehicleInsurance.Get("Document Code")then begin
                    "Insurance Document No.":=VehicleInsurance."Insurance No.";
                    "Insurance Date":=VehicleInsurance."Insurance Date";
                    "Insurance Expiry Date":=VehicleInsurance."Insurance Expiry Date";
                    "Insurance Cover Type":=VehicleInsurance."Type Of Cover";
                    "Insurance Vendor":=VehicleInsurance."Insurance Company Code";
                    "Insurance Vendor Name":=VehicleInsurance."Insurance Company Name";
                    "Insurance Amount":=VehicleInsurance."Insurance Amount";
                end;
            end;
        }
        field(17; "Insurance Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;

            trigger OnValidate()
            begin
                if "Insurance Date" < "Purchase Date" then Error('Insurance date cannot come before the purchase date');
            end;
        }
        field(18; "Insurance Expiry Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(19; "Insurance Vendor"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = Vendor."No.";
        }
        field(20; "Insurance Vendor Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(21; "Responsible Employee No"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee."No.";

            trigger OnValidate()
            begin
                if Employee.Get("Responsible Employee No")then begin
                    "Responsible Employee Name":=Employee."First Name" + ' ' + Employee."Middle Name" + ' ' + Employee."Last Name";
                end;
            end;
        }
        field(22; "Responsible Employee Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(23; "Last Modified Date-Time"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(24; "Last Modified By User ID"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(25; "Mileage at Service (Kms)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(26; "Insurance Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(27; "Insurance Cover Type"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(28; "Insurance Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(29; "Availability Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Available,Not Available';
            OptionMembers = Available, "Not Available";
        }
        field(30; "Current Mileage (Kms)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(31; "Distance From Service (Kms)"; Decimal)
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
    trigger OnModify()
    begin
        "Last Modified Date-Time":=CreateDateTime(Today, Time);
        "Last Modified By User ID":=UserId;
    end;
    var FixedAsset: Record "Fixed Asset";
    FixedAssetList: Page "Fixed Asset List";
    MotorVehicleAsset: Record "Motor Vehicle Asset";
    Vendor: Record Vendor;
    Employee: Record Employee;
    VehicleInsurance: Record "Vehicle Insurance";
}
