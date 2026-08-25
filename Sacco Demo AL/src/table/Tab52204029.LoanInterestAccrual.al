table 52204029 "Loan Interest Accrual"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "Interest Accruals";
    LookupPageId = "Interest Accruals";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Loan No."; code[20])
        {
        }
        field(3; "Entry Date"; Date)
        {
        }
        field(4; "Entry Type"; Option)
        {
            OptionMembers = "Interest Accrual", "Penalty Accrual";
        }
        field(5; Description; Text[50])
        {
        }
        field(6; "Member No."; Code[20])
        {
        }
        field(7; "Member Name"; Text[150])
        {
        }
        field(8; "Created By"; code[50])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(9; "Created On"; DateTime)
        {
            Editable = false;
        }
        field(10; Open; Boolean)
        {
        }
        field(11; Amount; Decimal)
        {
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
