table 52204025 "Collateral Types"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Collateral Types";
    DrillDownPageId = "Collateral Types";

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Description; Text[50])
        {
        }
        field(3; Category; Option)
        {
            OptionMembers = " ",Vehicle,"Real Estate";
        }
        Field(4; "Value Multiplier"; Decimal)
        {
        }
        field(5; Active; Boolean)
        {
            trigger OnValidate()
            begin
                Rec.Testfield("Value Multiplier");
            end;
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
