table 52203758 "Property Managers"
{
    Caption = 'Property Managers';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; No; Code[20])
        {
            Caption = 'No';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(2; Name; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(3; Address; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "E-Mail"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Phone No."; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "ID No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Pin No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "No. Series"; Code[20])
        {
            TableRelation = "No. Series";
            DataClassification = ToBeClassified;
        }
        field(9; "D.O.B"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(10; Gender; Option)
        {
            Caption = 'Gender';
            DataClassification = ToBeClassified;
            OptionMembers = "", Male, Female;
        }
        field(11; "Marital Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "", Single, Married, Divorced, Widowed;
        }
        field(12; "Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "", Active, Dormant, Terminated, "On Leave";
        }
        field(13; "Employment Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "", Permanent, Contract;
        }
        field(14; "Created By"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Created On"; Date)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; No)
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        if Rec.No = '' then begin
            AssetMgmtSetup.Get();
            AssetMgmtSetup.TestField("Property Manager Nos");
            NoSeriesMgmt.InitSeries(AssetMgmtSetup."Property Manager Nos", xRec.No, 0D, No, "No. Series");
        end;
    end;
    var AssetMgmtSetup: Record "Asset Management Setup";
    NoSeriesMgmt: Codeunit NoSeriesManagement;
}
