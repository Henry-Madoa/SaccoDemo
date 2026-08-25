table 52204102 "Mobile Member Ledger"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "Mobile Ledger";
    LookupPageId = "Mobile Ledger";

    fields
    {
        field(1; "Entry No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Document No"; Code[20])
        {
        }
        field(3; "Posting Date"; Date)
        {
        }
        field(4; "Member No"; Code[20])
        {
        }
        field(5; "Document Type"; Option)
        {
            OptionMembers = Activation,Blocking,Reactivation;
        }
        field(6; "User ID"; Code[100])
        {
        }
        field(7; "Posting Time"; Time)
        {
        }
    }
    keys
    {
        key(Key1; "Entry No")
        {
            Clustered = true;
        }
        key(key2; "Document No", "Member No", "Document Type")
        {
        }
    }
    var
        myInt: Integer;

    trigger OnInsert()
    begin
    end;

    trigger OnModify()
    begin
    end;

    trigger OnDelete()
    begin
    end;

    trigger OnRename()
    begin
    end;
}
