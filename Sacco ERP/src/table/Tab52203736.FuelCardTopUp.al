table 52203736 "Fuel Card Top-Up"
{
    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Card No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Fueling Card"."No.";

            trigger OnValidate()
            begin
                if FuelingCard.Get("Card No.")then begin
                    "Card Description":=FuelingCard.Description;
                    "Card Type":=FuelingCard.Type;
                end;
            end;
        }
        field(3; "Card Description"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Card Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ',Credit Card,Debit Card';
            OptionMembers = , "Credit Card", "Debit Card";
        }
        field(5; "Top-Up Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Top-Up Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(7; Submitted; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(9; "Created On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Created By"; Code[50])
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
            FleetManagementSetup.TestField("Fuel Top-Up Nos");
            NoSeriesManagement.InitSeries(FleetManagementSetup."Fuel Top-Up Nos", xRec."No.", 0D, "No.", "No. Series");
        end;
        "Created On":=Today;
        "Created By":=UserId;
    end;
    var FleetManagementSetup: Record "Fleet Management Setup";
    NoSeriesManagement: Codeunit NoSeriesManagement;
    FuelingCard: Record "Fueling Card";
}
