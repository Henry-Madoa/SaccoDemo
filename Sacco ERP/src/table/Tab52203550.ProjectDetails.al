table 52203550 "Project Details"
{
    DrillDownPageID = "Project Details";
    LookupPageID = "Project Details";

    fields
    {
        field(1; "Donor Code"; Code[20])
        {
        }
        field(2; "Donor Description"; Text[50])
        {
        }
        field(3; "Project Name"; Text[50])
        {
        }
        field(4; Funder; Code[10])
        {
        }
        field(5; Amount; Decimal)
        {
        }
        field(6; Duration; Text[30])
        {
        }
        field(7; Status; Option)
        {
            OptionCaption = 'Active,Closed';
            OptionMembers = Active, Closed;
        }
        field(8; "Approval Date"; Date)
        {
        }
        field(9; Currency; Code[10])
        {
            TableRelation = Currency;
        }
        field(10; "Approved Amount"; Decimal)
        {
        }
        field(11; "Approval/Withdrawal"; Decimal)
        {
        }
        field(12; "Contract Date"; Date)
        {
        }
        field(13; "Contract Amount"; Decimal)
        {
        }
        field(14; "Expected Amount (Transfers)"; Decimal)
        {
        }
        field(15; "Actual Amount (Transfers)"; Decimal)
        {
        }
    }
    keys
    {
        key(Key1; "Donor Code")
        {
        }
    }
}
