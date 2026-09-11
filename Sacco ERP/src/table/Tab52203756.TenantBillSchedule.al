table 52203756 "Tenant Bill Schedule"
{
    fields
    {
        field(1; "Schedule No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Schedule Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Tenant No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Customer."No.";

            trigger OnValidate()
            begin
                if Customer.Get(Rec."Tenant No.")then begin
                    Rec."Tenant Name":=Customer.Name;
                    Rec."Tenant Address":=Customer.Address;
                    Rec."Tenant Phone No.":=Customer."Phone No.";
                    Rec."Tenant E-Mail":=Customer."E-Mail";
                end;
            end;
        }
        field(4; "Tenant Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Tenant Address"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Tenant Phone No."; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Landlord No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Landlord Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Property Code"; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Properties.Get("Property Code")then begin
                    Rec."Property Name":=Properties."Property Name";
                    Rec."Landlord No.":=Properties."Landlord Code";
                    Rec."Landlord Name":=Properties."Landlord Name";
                end;
            end;
        }
        field(10; "Property Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Tenant E-Mail"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Schedule Status"; Option)
        {
            CalcFormula = Lookup("Billing Schedule".Status WHERE("No."=FIELD("Schedule No."), "Schedule Date"=FIELD("Schedule Date")));
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'Open,Generated,Closed';
            OptionMembers = Open, Generated, Closed;
        }
    }
    keys
    {
        key(Key1; "Schedule No.", "Schedule Date", "Tenant No.", "Property Code")
        {
        }
    }
    var Customer: Record Customer;
    Properties: Record Properties;
}
