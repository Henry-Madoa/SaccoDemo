table 52203748 "Service Items"
{
    DrillDownPageID = "Service V Items";
    LookupPageID = "Service V Items";

    fields
    {
        field(1; "No."; Code[10])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; Name; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(3; Description; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Unit of Measure"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Unit of Measure".Code;
        }
        field(5; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series".Code;
        }
        field(6; Location; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Location.Code;
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
            FleetManagementSetup.TestField("Service Part Nos");
            NoSeriesManagement.InitSeries(FleetManagementSetup."Service Part Nos", xRec."No.", 0D, "No.", "No. Series");
        end;
    end;
    var NoSeriesManagement: Codeunit NoSeriesManagement;
    FleetManagementSetup: Record "Fleet Management Setup";
}
