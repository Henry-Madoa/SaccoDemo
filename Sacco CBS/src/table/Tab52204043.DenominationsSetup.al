table 52204043 "Denominations Setup"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Denominations Setup";
    DrillDownPageId = "Denominations Setup";

    fields
    {
        field(1; Code; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Description; Text[50])
        {
        }
        field(3; Value; Decimal)
        {
        }
    }
    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
        key(Key2; Value)
        {
        }
    }
}
