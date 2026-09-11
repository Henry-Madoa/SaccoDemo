table 52203480 "Title"
{
    DrillDownPageID = Titles;
    LookupPageID = Titles;

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }
        field(3; Visible; Boolean)
        {
            Caption = 'Visible';
            DataClassification = ToBeClassified;
        }
        field(4; Gender;Enum "Employee Gender")
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; Code)
        {
        }
    }
}
