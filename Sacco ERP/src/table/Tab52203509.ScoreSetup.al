table 52203509 "Score Setup"
{
    fields
    {
        field(1; "Score ID"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(2; Score; Text[30])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Score ID")
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; Score, "Score ID")
        {
        }
        fieldgroup(Brick; Score, "Score ID")
        {
        }
    }
}
