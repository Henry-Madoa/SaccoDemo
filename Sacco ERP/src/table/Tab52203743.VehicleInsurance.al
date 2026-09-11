table 52203743 "Vehicle Insurance"
{
    DrillDownPageID = "Vehicle Insurance List";
    LookupPageID = "Vehicle Insurance List";

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Insurance No."; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Insurance Company Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Vendor."No.";

            trigger OnValidate()
            begin
                if Vendor.Get("Insurance Company Code")then begin
                    "Insurance Company Name":=Vendor.Name;
                end;
            end;
        }
        field(4; "Insurance Company Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5; "Type Of Cover"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Insurance Cover Type".Code;
        }
        field(6; "Insurance Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Insurance Period"; DateFormula)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                TestField("Insurance Date");
                "Insurance Expiry Date":=CalcDate("Insurance Period", "Insurance Date");
            end;
        }
        field(8; "Insurance Expiry Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(9; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(10; Expired; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Vehicle REG. No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Motor Vehicle Asset"."No.";
        }
        field(12; "Insurance Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Transaction Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Fuel,Insurance,Maintenance';
            OptionMembers = Fuel, Insurance, Maintenance;
        }
        field(14; Posted; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Posting Date"; Date)
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
            FleetManagementSetup.TestField("Insurance Nos");
            NoSeriesManagement.InitSeries(FleetManagementSetup."Insurance Nos", xRec."No.", 0D, "No.", "No. Series");
        end;
        "Transaction Type":="Transaction Type"::Insurance;
    end;
    var FleetManagementSetup: Record "Fleet Management Setup";
    NoSeriesManagement: Codeunit NoSeriesManagement;
    Vendor: Record Vendor;
}
