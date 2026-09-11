table 52204083 "Uncleared Funds"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Held Amounts";
    DrillDownPageId = "Held Amounts";

    fields
    {
        field(1; "Entry No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Member No"; Code[20])
        {
            trigger OnValidate()
            begin
                if Member.Get("Member No") then "Member Name" := Member.FullName;
            end;
        }
        field(3; "Member Name"; text[100])
        {
            Editable = false;
        }
        field(4; "Document No"; Code[20])
        {
        }
        field(5; "Amount"; decimal)
        {
        }
        field(6; Remarks; Text[500])
        {
        }
        field(7; "Created By"; Code[100])
        {
        }
        field(8; "Created On"; DateTime)
        {
        }
        field(9; "Account No"; Code[20])
        {
        }
        field(10; Cleared; Boolean)
        {
        }
        field(11; "Cleared On"; DateTime)
        {
            Editable = false;
        }
        field(12; "Cleared By"; Code[200])
        {
            Editable = false;
        }
        field(13; "Money Laundary Check"; Boolean)
        {
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Entry No")
        {
            Clustered = true;
        }
    }
    var
        UnclearedEffect: Record "Uncleared Funds";
        Member: Record Members;

    procedure GetLastEntryNo(): Integer
    begin
        UnclearedEffect.Reset();
        UnclearedEffect.SetAscending("Entry No", false);
        if UnclearedEffect.FindFirst then exit(UnclearedEffect."Entry No");
    end;
}
