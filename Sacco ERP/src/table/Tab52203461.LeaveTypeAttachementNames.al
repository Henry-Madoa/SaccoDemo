table 52203461 "Leave Type Attachement Names"
{
    DrillDownPageID = "Leave Type Attachement Names";
    LookupPageID = "Leave Type Attachement Names";

    fields
    {
        field(1; "Leave Code"; Code[100])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Attachement Name"; Code[100])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Attachement Description"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Leave Code", "Attachement Name")
        {
        }
    }
}
