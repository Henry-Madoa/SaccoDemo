table 52204075 "Standing Order Types"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Standing Order Types";
    DrillDownPageId = "Standing Order Types";

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Description; Text[100])
        {
        }
        field(3; "Standing Order Class";Enum "STO Types")
        {
        }
        field(4; "Default Account"; Code[20])
        {
            TableRelation = Vendor where("Account Type"=const(EFT));
        }
        field(5; "Charge Code"; Code[20])
        {
            TableRelation = "Transaction Charges";
        }
        field(6; Priority; Integer)
        {
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
