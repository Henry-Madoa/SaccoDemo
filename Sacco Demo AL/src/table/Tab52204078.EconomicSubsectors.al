table 52204078 "Economic Subsectors"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "Economic Subsectors";
    LookupPageId = "Economic Subsectors";

    fields
    {
        field(1; "Sector Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Sub Sector Code"; Code[20])
        {
        }
        field(3; "Sub Sector Name"; Text[100])
        {
        }
    }
    keys
    {
        key(Key1; "Sector Code", "Sub Sector Code")
        {
            Clustered = true;
        }
        key(key2; "Sub Sector Name")
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Sub Sector Code", "Sub Sector Name")
        {
        }
    }
}
