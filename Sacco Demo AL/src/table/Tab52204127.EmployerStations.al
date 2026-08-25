table 52204127 "Employer Stations"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Employer Stations";
    DrillDownPageId = "Employer Stations";

    fields
    {
        field(1; "Employer Code"; Code[20])
        {
        }
        field(2; Code; Code[20])
        {
        }
        field(3; Name; Text[100])
        {
        }
    }
    keys
    {
        key(Key1; "Employer Code", Code)
        {
            Clustered = true;
        }
        key(key2; Code, Name)
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; Code, Name)
        {
        }
    }
}
