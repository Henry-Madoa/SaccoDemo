table 52204021 "Transaction Charges"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Transaction Charges";
    DrillDownPageId = "Transaction Charges";

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Description; Text[100])
        {
        }
        field(3; "Posting Transaction Type"; Enum "Sacco Transaction Type")
        {
        }
        field(4; "Control Account"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Bank Account";
        }
    }
    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }
}
