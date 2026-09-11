table 52204013 "Doc. Attachments Checklist"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Source Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Application Area"; Enum "Sacco Lookup Values")
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Sacco Lookup Values".Code where(Type = field("Application Area"));

            trigger OnValidate()
            begin
                if SaccoLookupValues.Get("Application Area", "Document No.") then Description := SaccoLookupValues.Description;
            end;
        }
        field(4; Description; Text[250])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5; Mandatory; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(6; Provided; Boolean)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Provided then begin
                    "Received By" := UserId;
                    "Received On" := WorkDate;
                end
                else begin
                    "Received By" := '';
                    "Received On" := 0D;
                end;
            end;
        }
        field(7; "Received On"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(8; "Received By"; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Source Code", "Document No.")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Document No.", Description)
        {
        }
        fieldgroup(Brick; "Document No.", Description)
        {
        }
    }
    var
        ProductFactory: Record "Sacco Products";
        SaccoLookupValues: Record "Sacco Lookup Values";
}
