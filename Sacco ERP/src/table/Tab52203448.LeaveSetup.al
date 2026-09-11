table 52203448 "Leave Setup"
{
    fields
    {
        field(1; "P. Key"; Integer)
        {
        }
        field(2; "Leave Application Nos."; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(3; "Fin. Year Start"; Date)
        {
        }
        field(4; "Fin. Year End"; Date)
        {
        }
        field(5; "Base Calender"; Code[20])
        {
            TableRelation = "Leave Calendar";
        }
        field(6; "Adjustment Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(7; "Notify With SMS"; Boolean)
        {
        }
        field(8; "Web Client Path"; Text[250])
        {
            ExtendedDatatype = URL;
        }
        field(9; "Leave Journal Template"; Code[30])
        {
            TableRelation = "Leave Journal Template";
        }
        field(10; "Leave Journal Batch"; Code[30])
        {
            TableRelation = "Leave Journal Batch".Name WHERE("Journal Template Name"=FIELD("Leave Journal Template"));
        }
        field(11; "Leave Plan Nos."; Code[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(12; "Impending L.App. Not. Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Annual Leave. Bal For Comp."; Decimal)
        {
            DataClassification = ToBeClassified;
            Description = '//Annual Leave balance maximum balance that can deny someone compassionate leave';
        }
        field(14; "Leave Recall"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series".Code;
        }
        field(15; "Leave Allowance Entitlement"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Leave Reimbursement Nos."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
    }
    keys
    {
        key(Key1; "P. Key")
        {
        }
    }
}
