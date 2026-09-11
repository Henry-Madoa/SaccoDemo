table 52204144 "Member Accounts Balances"
{
    LookupPageId = "Member Accounts Balances";
    DrillDownPageId = "Member Accounts Balances";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; "Member No."; Code[10])
        {
            TableRelation = Members;
        }
        field(3; "Product Code"; Code[20])
        {
            TableRelation = "Sacco Products";
            DataClassification = ToBeClassified;
        }
        field(4; "Account Name"; Text[100])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Sacco Products".Description where(Code=field("Product Code")));
        }
        field(5; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(6; Posted; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Already Posted"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Member Name"; Text[80])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Members."Full Name" where("No."=field("Member No.")));
        }
        field(9; "Posted Amount"; Decimal)
        {
            Editable = false;
        }
        field(10; "Junior Account Name"; Text[80])
        {
        }
    }
    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }
}
