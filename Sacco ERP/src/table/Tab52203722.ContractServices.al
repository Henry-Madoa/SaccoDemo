table 52203722 "Contract Services"
{
    DrillDownPageID = "Contract Services";
    LookupPageID = "Contract Services";

    fields
    {
        field(1; Service; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "G/L Account"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Account Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Line No"; Integer)
        {
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Line No")
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; Service)
        {
        }
    }
}
