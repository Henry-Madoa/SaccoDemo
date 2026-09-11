table 52204118 "E-Loan Application"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "E-Loans";
    LookupPageId = "E-Loans";

    fields
    {
        field(1; "Loan No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Member No"; Code[20])
        {
        }
        field(3; "Member Name"; Text[150])
        {
        }
        field(4; "Product Code"; Code[20])
        {
        }
        field(5; "Product Name"; Text[100])
        {
        }
        field(6; "Applied Amount"; Decimal)
        {
        }
        field(7; "Application Date"; Date)
        {
        }
        field(8; "Posted"; Boolean)
        {
        }
        field(9; "Payment Ref. Code"; Code[20])
        {
        }
    }
    keys
    {
        key(Key1; "Loan No")
        {
            Clustered = true;
        }
    }
}
