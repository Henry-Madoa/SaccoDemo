table 52204038 "Collateral Linked Loans"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "Collateral Linked Loans";
    LookupPageId = "Collateral Linked Loans";

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Loan No."; Code[20])
        {
        }
        field(3; "Product Code"; Code[20])
        {
        }
        field(4; "Product Details"; text[150])
        {
        }
        field(5; "Current Balance"; Decimal)
        {
        }
        Field(6; "Member No"; Code[20])
        {
        }
        field(7; "Member Name"; Text[150])
        {
        }
    }
    keys
    {
        key(PK; "No.", "Loan No.")
        {
            Clustered = true;
        }
    }
}
