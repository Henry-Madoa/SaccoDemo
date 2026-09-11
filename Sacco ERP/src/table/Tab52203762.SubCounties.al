table 52203762 "Sub Counties"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "Sub Counties";
    LookupPageId = "Sub Counties";

    fields
    {
        field(1; "County Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        Field(2; "Sub County Code"; Code[20])
        {
            Caption = 'Code';
        }
        field(3; "Sub County Name"; Text[50])
        {
            Caption = 'Name';
        }
    }
    keys
    {
        key(PK; "County Code", "Sub County Code")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Sub County Code", "Sub County Name")
        {
        }
    }
}
