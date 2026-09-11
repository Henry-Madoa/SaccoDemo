table 52203759 "Tenant Exit"
{
    Caption = 'Tenant Exit';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = ToBeClassified;
        }
        field(2; "Tenant No."; Code[20])
        {
            Caption = 'Tenant No.';
            DataClassification = ToBeClassified;
        }
        field(3; "Tenant Name"; Text[100])
        {
            Caption = 'Tenant Name';
            DataClassification = ToBeClassified;
        }
        field(4; "Property No."; Code[20])
        {
            Caption = 'Property No.';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }
}
