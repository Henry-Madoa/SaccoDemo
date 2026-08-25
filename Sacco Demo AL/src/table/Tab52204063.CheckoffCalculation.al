table 52204063 "Checkoff Calculation"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "Checkoff Calculations";
    LookupPageId = "Checkoff Calculations";

    fields
    {
        field(1; "Document No"; Code[20])
        {
        }
        field(2; "Member No"; Code[20])
        {
            Editable = false;
            TableRelation = Members;
        }
        field(3; "Check No"; Code[20])
        {
            Editable = false;
        }
        field(4; "Entry No"; Integer)
        {
            Editable = false;
        }
        field(5; "Entry Type"; Enum "Checkoff Entries Types")
        {
            Editable = false;
        }
        field(6; "Account No"; Code[20])
        {
            Editable = false;
            TableRelation = Vendor;
        }
        field(7; Amount; Decimal)
        {
        }
        field(8; "Amount Base"; Decimal)
        {
            Editable = false;
        }
        field(9; "Loan No"; Code[20])
        {
            Editable = false;
        }
        field(10; "Account Name"; Text[100])
        {
            Editable = false;
        }
        field(11; Blocked; Enum "Vendor Blocked")
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor.Blocked where("No." = field("Account No")));
            Caption = 'Blocked';
            Editable = false;
        }
        field(12; "Pay Period"; Date)
        {
            Editable = false;
        }
        field(13; Posted; Boolean)
        {
            Editable = false;
        }
        field(14; UnMatched; Boolean)
        {
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Document No", "Member No", "Check No", "Entry No")
        {
            Clustered = true;
        }
    }
}
