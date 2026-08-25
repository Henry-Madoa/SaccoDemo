table 52204041 "Member View Logs"
{
    Caption = 'Member View Logs';
    DataClassification = ToBeClassified;
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }
        field(2; "Member No."; Code[20])
        {
            Caption = 'Member No.';
            TableRelation = Members;
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                Members: Record Members;
            begin
                If Members.Get("Member No.") then
                    "Member Name" := Members.FullName;
            end;
        }
        field(3; "Member Name"; Text[80])
        {
            Editable = false;
            Caption = 'Member Name';
            DataClassification = CustomerContent;
        }
        field(4; Reason; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(5; "Viewed By"; Code[50])
        {
            Caption = 'Viewed By';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(6; "Viewed At"; DateTime)
        {
            Caption = 'Viewed At';
            DataClassification = SystemMetadata;
        }
        field(7; "Source Page"; Text[50])
        {
            Caption = 'Source Page';
            DataClassification = SystemMetadata;
        }
        field(8; "Session ID"; Integer)
        {
            Caption = 'Session ID';
            DataClassification = SystemMetadata;
        }
        field(9; "Client Type"; Text[30])
        {
            Caption = 'Client Type';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(ByMember; "Member No.", "Viewed At")
        {
        }
    }
}
