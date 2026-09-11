table 52204012 "Member Designation"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Type;Enum "Member Category Types")
        {
        }
        Field(3; Name; Text[50])
        {
        }
        field(4; Description; Text[250])
        {
        }
    }
    keys
    {
        key(PK; Code, Type)
        {
            Clustered = true;
        }
        key(Key2; Type, Code)
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
