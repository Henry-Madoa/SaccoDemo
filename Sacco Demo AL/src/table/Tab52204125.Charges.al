table 52204125 "Charges"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = Charges;
    LookupPageId = Charges;

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Description; text[50])
        {
        }
    }
    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
}
