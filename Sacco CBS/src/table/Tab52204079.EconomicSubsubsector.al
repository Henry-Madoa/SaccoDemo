table 52204079 "Economic Sub-subsector"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "Economic Sub-Subsectors";
    LookupPageId = "Economic Sub-Subsectors";

    fields
    {
        field(1; "Sector Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Sub Sector Code"; Code[20])
        {
        }
        field(3; "Sub-Subsector Code"; Code[20])
        {
        }
        field(4; "Sub-Subsector Description"; Text[100])
        {
        }
    }
    keys
    {
        key(Key1; "Sector Code", "Sub Sector Code", "Sub-Subsector Code")
        {
            Clustered = true;
        }
        key(key2; "Sub-Subsector Description")
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Sub-Subsector Code", "Sub-Subsector Description")
        {
        }
    }
}
