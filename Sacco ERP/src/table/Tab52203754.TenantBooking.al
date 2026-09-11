table 52203754 "Tenant Booking"
{
    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; Name; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(3; Address; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Phone No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "E-Mail"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(6; Occupation; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Company Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Company Address"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Property Booked"; Code[30])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Properties.Get("Property Booked")then begin
                    Rec."Property Name":=Properties."Property Name";
                    Rec."Landlord Code":=Properties."Landlord Code";
                    Rec."Landlord Name":=Properties."Landlord Name";
                end;
            end;
            trigger OnLookup()
            var
            begin
                Properties.Reset();
                if Page.RunModal(68503, Properties) = ACTION::LookupOK then begin
                    Rec."Property Booked":=Properties."Property Code";
                    Rec."Property Name":=Properties."Property Name";
                    Rec."Landlord Code":=Properties."Landlord Code";
                    Rec."Landlord Name":=Properties."Landlord Name";
                    Rec.Validate("Property Booked");
                end;
            end;
        }
        field(10; "Property Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(11; "Landlord Code"; Code[30])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(12; "Landlord Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(13; Status; Option)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            OptionCaption = 'New,Pending Approval,Approved,Rejected';
            OptionMembers = New, "Pending Approval", Approved, Rejected;
        }
        field(14; "Created By"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Created Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(16; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Employment Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Self-Employed,Casual,Contract,Permanent';
            OptionMembers = " ", "Self-Employed", Casual, Contract, Permanent;
        }
        field(18; "Property Type"; Option)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            OptionCaption = ' ,Apartment,Single-Family,Condominium,Town-House';
            OptionMembers = " ", Apartment, "Single-Family", Condominium, "Town-House";
        }
        field(19; "Floor Space (M2)"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(20; "No. of Rooms"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(21; "No. of Bedrooms"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(22; "Floor No."; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(23; "Rent Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(24; "Deposit Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(25; "Water Deposit"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(26; "Electricity Deposit"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(27; "Other Deposits"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(28; "Expected Rent Date"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(29; "Late Payment Penalty %"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            MaxValue = 100;
            MinValue = 0;
        }
        field(30; "Tenancy Status"; Option)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            OptionCaption = 'Inactive,Booked,Active,Vacated';
            OptionMembers = Inactive, Booked, Active, Vacated;
        }
        field(31; "Tenancy Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(32; "Unit No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Property Units"."Unit No." WHERE("Property Code"=FIELD("Property Booked"), "Landlord Code"=FIELD("Landlord Code"));

            trigger OnValidate()
            begin
                if PropertyUnits.Get("Unit No.")then begin
                    Rec."Property Type":=PropertyUnits."Property Type";
                    Rec."No. of Rooms":=PropertyUnits."No. of Rooms";
                    Rec."No. of Bedrooms":=PropertyUnits."No. of Bedrooms";
                    Rec."Deposit Amount":=PropertyUnits."Deposit Amount";
                    Rec."Rent Amount":=PropertyUnits."Rent Amount";
                    Rec."Water Deposit":=PropertyUnits."Water Deposit";
                    Rec."Electricity Deposit":=PropertyUnits."Electricity Deposit";
                    Rec."Other Deposits":=PropertyUnits."Other Deposits";
                    Rec."Floor Space (M2)":=PropertyUnits."Floor Space (M2)";
                    Rec."Floor No.":=PropertyUnits."Floor No.";
                    Rec."Expected Rent Date":=PropertyUnits."Expected Rent Date";
                    Rec."Late Payment Penalty %":=PropertyUnits."Late Payment Penalty %";
                end;
            end;
        }
        field(33; "Customer No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(34; "Bill Water"; Boolean)
        {
            CalcFormula = Lookup(Properties."Bill Water" WHERE("Property Code"=FIELD("Property Booked"), "Landlord Code"=FIELD("Landlord Code")));
            FieldClass = FlowField;
        }
        field(35; "Bill Electricity"; Boolean)
        {
            CalcFormula = Lookup(Properties."Bill Electricity" WHERE("Property Code"=FIELD("Property Booked"), "Landlord Code"=FIELD("Landlord Code")));
            FieldClass = FlowField;
        }
        field(36; "Bill Other Amenities"; Boolean)
        {
            CalcFormula = Lookup(Properties."Bill Other Amenities" WHERE("Property Code"=FIELD("Property Booked"), "Landlord Code"=FIELD("Landlord Code")));
            FieldClass = FlowField;
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
            AssetManagementSetup.Get;
            AssetManagementSetup.TestField("Tenants Booking Nos");
            NoSeriesManagement.InitSeries(AssetManagementSetup."Tenants Booking Nos", xRec."No.", 0D, "No.", "No. Series");
        end;
    end;
    var AssetManagementSetup: Record "Asset Management Setup";
    NoSeriesManagement: Codeunit NoSeriesManagement;
    PropertyUnits: Record "Property Units";
    Properties: Record Properties;
}
