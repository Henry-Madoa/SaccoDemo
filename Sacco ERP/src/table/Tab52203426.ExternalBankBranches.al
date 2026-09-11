table 52203426 "External Bank Branches"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Bank Code"; Code[20])
        {
        }
        field(2; "Branch Code"; Code[20])
        {
        }
        field(3; "Branch Name"; Text[100])
        {
        }
    }
    keys
    {
        key(Key1; "Bank Code", "Branch Code")
        {
            Clustered = true;
        }
        key(Key2; "Branch Code", "Branch Name")
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Branch Code", "Branch Name")
        {
        }
    }
}
