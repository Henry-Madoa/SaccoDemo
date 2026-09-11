table 52204101 "Mobile Members"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Member No"; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Full Name"; Text[250])
        {
        }
        field(4; "FOSA Account"; Code[20])
        {
        }
        field(5; "Phone No"; Code[20])
        {
        }
        field(6; "ID No"; Code[20])
        {
        }
        field(7; "Activated On"; DateTime)
        {
        }
        field(8; "Activated By"; Code[50])
        {
            TableRelation = "User Setup";
        }
        field(9; "Last Reactivation Date"; Date)
        {
            FieldClass = FlowField;
            CalcFormula = max("Mobile Member Ledger"."Posting Date" where("Member No" = field("Member No"), "Document Type" = const(Reactivation)));
            Editable = false;
        }
        field(10; "Member Status"; Option)
        {
            OptionMembers = Active,Blocked,Held;
        }
        field(11; "Mobile Ledger"; Integer)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("Mobile Member Ledger" where("Member No" = field("Member No")));
        }
        field(12; "Mobile Transacting No"; Code[20])
        {
        }
    }
    keys
    {
        key(Key1; "Member No")
        {
            Clustered = true;
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
