table 52203713 "Contract Extension Entries"
{
    fields
    {
        field(1; "Contract No"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Initial End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Extension Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "New End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Line No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Extension No"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Contract No", "Line No")
        {
        }
    }
    fieldgroups
    {
    }
}
