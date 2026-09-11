table 52203594 "Employee Referees"
{
    fields
    {
        field(1; "Employee No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "First Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Middle Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Last Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(5; Instituition; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(6; Position; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(7; Email; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Phone No."; Code[15])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Employee No", "First Name", "Middle Name", "Last Name")
        {
        }
    }
}
