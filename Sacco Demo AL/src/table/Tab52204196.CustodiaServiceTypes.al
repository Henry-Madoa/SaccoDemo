table 52204196 "Custodia Service Types"
{
    DrillDownPageID = "Custodial Service Types";
    LookupPageID = "Custodial Service Types";

    fields
    {
        field(1; "Service Type"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Service Description"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Charge Frequency"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(5; Charges; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Income Account"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No." WHERE("Direct Posting"=CONST(true));
        }
        field(7; "Grace Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Service Type")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Service Type", "Service Description")
        {
        }
    }
}
