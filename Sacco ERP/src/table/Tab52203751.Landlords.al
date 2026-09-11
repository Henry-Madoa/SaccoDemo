table 52203751 "Landlords"
{
    fields
    {
        field(1; "No."; Code[20])
        {
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
        field(4; "Phone No."; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Email Address"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "PIN No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(8; "Created Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Created By"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(10; Blocked; Boolean)
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
        if Rec."No." = '' then begin
            AssetManagementSetup.Get();
            AssetManagementSetup.TestField("LandLord Nos");
            NoSeriesManagement.InitSeries(AssetManagementSetup."LandLord Nos", xRec."No.", 0D, "No.", "No. Series");
        end;
        "Created By":=UserId;
        "Created Date":=Today;
    end;
    var AssetManagementSetup: Record "Asset Management Setup";
    NoSeriesManagement: Codeunit NoSeriesManagement;
}
