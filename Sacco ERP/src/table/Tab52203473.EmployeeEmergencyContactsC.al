table 52203473 "Employee Emergency Contacts C"
{
    fields
    {
        field(1; "Line No"; Integer)
        {
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
        field(2; "Employee No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee;
        }
        field(3; "Full Name"; Text[70])
        {
            DataClassification = ToBeClassified;
        }
        field(4; Relationship; Code[40])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Phone No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Email Address"; Text[70])
        {
            DataClassification = ToBeClassified;
        }
        field(70000; "Change No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(70001; "Action"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Retain,Remove,New Addition';
            OptionMembers = Retain, Remove, "New Addition";
        }
    }
    keys
    {
        key(Key1; "Line No", "Employee No.", "Change No")
        {
        }
    }
}
