table 52203535 "Vendor Rating"
{
    DataClassification = CustomerContent;
    LookupPageId = "Vendor Rating Setup";
    DrillDownPageId = "Vendor Rating Setup";

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(2; Description; text[50])
        {
            DataClassification = CustomerContent;
        }
        field(3; factor; Decimal)
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; Code, factor)
        {
            Clustered = true;
        }
    }
}
