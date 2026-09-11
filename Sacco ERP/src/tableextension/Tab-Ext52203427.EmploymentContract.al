tableextension 52203427 "Employment Contract" extends "Employment Contract"
{
    fields
    {
        // Add changes to table fields here
        field(4; "Notice Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Contract Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Long Term,Short Term';
            OptionMembers = "Long Term","Short Term";
        }
        field(6; "Contract Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Leave Allowance"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(8; Gratuity; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(9; Medical; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Probation period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
    }
}
