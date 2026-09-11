table 52203728 "Tender Mandatory Requirements"
{
    DataCaptionFields = "Mandatory Code", "Requirement Description";
    DrillDownPageID = "Tender Mandatory Requirements";
    LookupPageID = "Tender Mandatory Requirements";

    fields
    {
        field(1; "Mandatory Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Requirement Description"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Mandatory Code")
        {
        }
    }
}
