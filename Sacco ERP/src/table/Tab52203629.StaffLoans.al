table 52203629 "Staff Loans"
{
    DrillDownPageID = "Staff Loan List";
    LookupPageID = "Staff Loan List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Loan Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Maximum Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Repayment Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(5; Instalments; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(6; Gratuity; boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Salary in Advance"; boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Salary Advance"; boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Code")
        {
        }
    }
}
