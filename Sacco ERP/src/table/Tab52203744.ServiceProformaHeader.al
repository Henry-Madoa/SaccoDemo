table 52203744 "Service Proforma Header"
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
                if MotorVehicleAsset.Get("Vehicle REG. No.")then begin
                    Model:=MotorVehicleAsset."Vehicle Make" + ' ' + MotorVehicleAsset."Vehicle Model";
                    "Chassis No.":=MotorVehicleAsset."Frame No.";
                    "Engine No.":=MotorVehicleAsset."Engine No.";
                    "Mileage (Kms)":=MotorVehicleAsset."Current Mileage (Kms)";
                end;
            end;
        }
        field(3; Model; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Chassis No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Engine No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Mileage (Kms)"; Decimal)
        {
        }
        field(7; "Dealer No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Vendor."No.";

            trigger OnValidate()
            begin
                if Vendor.Get("Dealer No.")then begin
                    "Dealer Name":=Vendor.Name;
                end;
            end;
        }
        field(8; "Dealer Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Proforma Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Last Service Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Created Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Created By"; Code[80])
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Contact Person"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee."No.";

            trigger OnValidate()
            begin
                if HREmployees.Get("Contact Person")then begin
                    "Contact Person Name":=HREmployees."First Name" + ' ' + HREmployees."Middle Name" + ' ' + HREmployees."Last Name";
                end;
            end;
        }
        field(14; "Contact Person Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(15; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(16; "Total Amount + Sundries"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Total Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Total Sundries"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Repair Executed"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(20; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'New,Pending Approval,Approved,Rejected';
            OptionMembers = New, "Pending Approval", Approved, Rejected;
        }
        field(21; "Employee No."; Code[50])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if HREmployees.Get("Employee No.")then begin
                    "Employee Name":=HREmployees.FullName;
                    "Created Date":=Today;
                    "Created By":=UserId;
                end;
            end;
        }
        field(22; "Employee Name"; Text[100])
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
            FleetManagementSetup.TestField("Service Proforma Nos");
            NoSeriesManagement.InitSeries(FleetManagementSetup."Service Proforma Nos", xRec."No.", 0D, "No.", "No. Series");
        end;
        // IF CURRENTCLIENTTYPE=CLIENTTYPE::SOAP THEN
        //  EXIT;
        // IF NOT IansoftFactory.FnIsWebServiceUser(USERID) THEN BEGIN
        if UserSetup.Get(UserId)then begin
            UserSetup.CalcFields("Employee No.");
            UserSetup.TestField("Employee No.");
            "Employee No.":=UserSetup."Employee No.";
            Validate("Employee No.");
        end;
    //  END;
    end;
    var FleetManagementSetup: Record "Fleet Management Setup";
    NoSeriesManagement: Codeunit NoSeriesManagement;
    MotorVehicleAsset: Record "Motor Vehicle Asset";
    Vendor: Record Vendor;
    HREmployees: Record Employee;
    //IansoftFactory: Codeunit IansoftFactory;
    UserSetup: Record "User Setup";
}
