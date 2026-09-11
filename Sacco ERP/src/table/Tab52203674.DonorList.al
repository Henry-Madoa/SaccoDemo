table 52203674 "Donor List"
{
    DrillDownPageID = "Grant List";
    LookupPageID = "Grant List";

    fields
    {
        field(1; "Donor Code"; Code[50])
        {
        }
        field(2; "Donor Name"; Text[100])
        {
        }
        field(3; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Active,Inactive';
            OptionMembers = Active, Inactive;
        }
        field(4; "Grant Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Grant End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Grant Activity"; Code[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Grant Activities";
        }
        field(10; "Grant Type"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Grant Accountant"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Donor Code")
        {
        }
    }
}
