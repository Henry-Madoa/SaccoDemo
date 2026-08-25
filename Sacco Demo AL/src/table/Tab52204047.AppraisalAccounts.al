table 52204047 "Appraisal Accounts"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Loan No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Account Type"; Option)
        {
            OptionMembers = "Member Account", Multiplier, Loan;
        }
        field(3; "Account No"; Code[20])
        {
        }
        field(4; "Account Description"; Text[150])
        {
            Editable = false;
        }
        field(5; Balance; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = -sum("Detailed Vendor Ledg. Entry".Amount where("Vendor No."=field("Account No")));
            Editable = false;
        }
        field(6; "Mulltipled Value"; Decimal)
        {
        }
    }
    keys
    {
        key(Key1; "Loan No", "Account Type", "Account No")
        {
            Clustered = true;
        }
    }
}
