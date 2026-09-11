table 52203753 "Property Units"
{
    fields
    {
        field(1; "Unit No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Name; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Property Code"; Code[20])
        {
            DataClassification = ToBeClassified;

            //TableRelation = Properties."Property Code";
            trigger OnValidate()
            begin
                if Properties.Get("Property Code")then begin
                    "Property Name":=Properties."Property Name";
                end;
            end;
            trigger OnLookup()
            var
            begin
                Properties.Reset();
                Properties.SetRange("Landlord Code", Rec."Landlord Code");
                if Page.RunModal(68503, Properties) = ACTION::LookupOK then begin
                    Rec."Property Code":=Properties."Property Code";
                    Rec.Validate("Property Code");
                end;
            end;
        }
        field(4; "Property Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Landlord Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Landlords;

            trigger OnValidate()
            var
                LandLords: Record Landlords;
            begin
                if LandLords.Get("Landlord Code")then begin
                    "Landlord Name":=LandLords.Name;
                end;
            end;
        }
        field(6; "Landlord Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(7; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Property Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Apartment,Single-Family,Condominium,Town-House';
            OptionMembers = " ", Apartment, "Single-Family", Condominium, "Town-House";
        }
        field(9; "Floor Space (M2)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "No. of Rooms"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "No. of Bedrooms"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Floor No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Rent Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Deposit Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Water Deposit"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Electricity Deposit"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Other Deposits"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Expected Rent Date"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Late Payment Penalty %"; Decimal)
        {
            DataClassification = ToBeClassified;
            MaxValue = 100;
            MinValue = 0;
        }
        field(20; "General Description"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Unit No. Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Bill Water"; Boolean)
        {
            CalcFormula = Lookup(Properties."Bill Water" WHERE("Property Code"=FIELD("Property Code"), "Landlord Code"=FIELD("Landlord Code")));
            FieldClass = FlowField;
        }
        field(23; "Bill Electricity"; Boolean)
        {
            CalcFormula = Lookup(Properties."Bill Electricity" WHERE("Property Code"=FIELD("Property Code"), "Landlord Code"=FIELD("Landlord Code")));
            FieldClass = FlowField;
        }
        field(24; "Bill Other Amenities"; Boolean)
        {
            CalcFormula = Lookup(Properties."Bill Other Amenities" WHERE("Property Code"=FIELD("Property Code"), "Landlord Code"=FIELD("Landlord Code")));
            FieldClass = FlowField;
        }
    }
    keys
    {
        key(Key1; "Unit No.", "Property Code")
        {
        }
    }
    var Properties: Record Properties;
}
