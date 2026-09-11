table 52204058 "Loan Security Mgmt Lines"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
        }
        field(2; "Line No"; Integer)
        {
        }
        field(3; "Security Type"; Enum "Security Type")
        {
        }
        field(4; "Security Code"; Code[20])
        {
        }
        field(5; "Security Name"; Text[100])
        {
        }
        field(6; "Loan No."; code[20])
        {
        }
        field(7; "Product Code"; Code[20])
        {
        }
        field(8; "Product Description"; Text[100])
        {
        }
        field(9; "Loan Principal"; Decimal)
        {
        }
        field(10; "Loan Balance"; Decimal)
        {
        }
        field(11; "Guaranteed Amount"; Decimal)
        {
        }
        field(12; "Intial Guaranteed"; Decimal)
        {
        }
        field(13; "Outstanding Guaranteed"; Decimal)
        {
        }
        field(14; Release; Boolean)
        {
        }
        field(15; Substitution; Boolean)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("Loan Security Mgmt Det. Lines" where("No." = field("No."), "Line No" = field("Line No")));
        }
    }
    keys
    {
        key(Key1; "No.", "Line No")
        {
            Clustered = true;
        }
    }
}
