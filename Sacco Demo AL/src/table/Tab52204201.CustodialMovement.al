table 52204201 "Custodial Movement"
{
    fields
    {
        field(1; "Entry No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Transaction No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Posting Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Entry Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Check-In", "Check-Out", Viewing;
        }
        field(5; Description; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Created By"; Code[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "User Setup";
        }
        field(7; "Created On"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(8; "Collected By"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Expected Return Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Collected By Phone No"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Collected By ID  No"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Entry No")
        {
            Clustered = true;
        }
    }
}
