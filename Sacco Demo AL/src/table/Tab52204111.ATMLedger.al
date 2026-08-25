table 52204111 "ATM Ledger"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Entry Type"; Option)
        {
            OptionMembers = Activation, "CBS Blocking", "Mobile Blocking", Unblocking;
        }
        field(3; "Requested On"; DateTime)
        {
        }
        field(4; Status; Option)
        {
            OptionMembers = Success, Fail;
        }
        field(5; "User ID"; Code[50])
        {
            TableRelation = "User Setup";
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
