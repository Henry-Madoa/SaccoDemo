table 52204008 "Sacco Lookup Values"
{
    Caption = 'Lookup Values';
    LookupPageId = "Sacco Lookup Values";
    DrillDownPageId = "Sacco Lookup Values";

    fields
    {
        field(1; Type;Enum "Sacco Lookup Values")
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; Code; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; Description; Text[250])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; Type, Code)
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; Code, Description)
        {
        }
        fieldgroup(Brick; Code, Description)
        {
        }
    }
}
