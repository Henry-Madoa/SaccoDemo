table 52204077 "Economic Sectors"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "Economic Sectors";
    LookupPageId = "Economic Sectors";

    fields
    {
        field(1; "Sector Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Sector Name"; Text[100])
        {
        }
        field(3; "Created By"; Code[50])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(4; "Created On"; DateTime)
        {
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Sector Code")
        {
            Clustered = true;
        }
        key(key2; "Sector Name")
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Sector Code", "Sector Name")
        {
        }
    }
}
