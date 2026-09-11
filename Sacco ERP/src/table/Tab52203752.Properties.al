table 52203752 "Properties"
{
    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Property Code"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Property Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Landlord Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Landlords."No.";

            trigger OnValidate()
            begin
                if Landlords.Get("Landlord Code")then begin
                    "Landlord Name":=Landlords.Name;
                end;
            end;
        }
        field(5; "Landlord Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(6; Blocked; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(8; "Bill Water"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Bill Electricity"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Bill Other Amenities"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Property Manager"; code[20])
        {
            TableRelation = "Property Managers".No;
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if PropertyManager.Get("Property Manager")then begin
                    "Manager Name":=PropertyManager.Name;
                end;
            end;
        }
        field(12; "Manager Name"; Text[100])
        {
            Editable = false;
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; "Property Code")
        {
        }
    }
    trigger OnInsert()
    begin
        if "No." = '' then begin
            AssetManagementSetup.Get;
            AssetManagementSetup.TestField("Property Nos");
            NoSeriesManagement.InitSeries(AssetManagementSetup."Property Nos", xRec."No.", 0D, "No.", "No. Series");
        end;
    end;
    var Landlords: Record Landlords;
    AssetManagementSetup: Record "Asset Management Setup";
    NoSeriesManagement: Codeunit NoSeriesManagement;
    PropertyManager: Record "Property Managers";
}
