table 52204129 "Account Instructions"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "Account Instructions";
    LookupPageId = "Account Instructions";

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; Description; Text[250])
        {
        }
    }
    keys
    {
        key(PK; Code, Description)
        {
            Clustered = true;
        }
        key(Key2; Description)
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; Description)
        {
        }
    }
}
