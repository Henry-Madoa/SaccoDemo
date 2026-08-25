table 52204128 "Employer Departments"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Employer Departments";
    DrillDownPageId = "Employer Departments";

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
