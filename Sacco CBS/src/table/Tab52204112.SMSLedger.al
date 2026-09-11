table 52204112 "SMS Ledger"
{
    LookupPageId = "SMS Ledger";
    DrillDownPageId = "SMS Ledger";
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Phone No"; Code[20])
        {
        }
        field(3; "SMS Message"; Text[250])
        {
        }
        field(4; "Created By"; Code[100])
        {
        }
        field(5; "Sent On"; DateTime)
        {
        }
        field(6; "SMS Source"; Code[20])
        {
        }
    }
    keys
    {
        key(Key1; "Entry No")
        {
            Clustered = true;
        }
        key(Key2; "SMS Source")
        {
        }
    }
}
