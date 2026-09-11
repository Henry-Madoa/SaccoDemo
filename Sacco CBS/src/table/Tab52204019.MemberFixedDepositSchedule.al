table 52204019 "Member Fixed Deposit Schedule"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Member Fixed Deposit Schedule";
    DrillDownPageId = "Member Fixed Deposit Schedule";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "No."; Code[20])
        {
        }
        field(3; "Posting Date"; Date)
        {
        }
        field(4; Description; Text[50])
        {
        }
        field(5; Amount; Decimal)
        {
        }
        field(6; Transferred; Boolean)
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
    trigger OnDelete()
    begin
        Rec.Testfield(Transferred, false);
    end;
}
