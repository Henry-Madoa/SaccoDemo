table 52204204 "CBS Event Notifications"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No"; Integer)
        {
        }
        field(2; "Account No."; Code[20])
        {
        }
        field(3; Amount; Decimal)
        {
        }
        field(4; "Booked Balance"; Decimal)
        {
        }
        field(5; "Cleared Balance"; Decimal)
        {
        }
        field(6; Currency; Code[20])
        {
        }
        field(7; "Cust. Memo Line1"; Code[50])
        {
        }
        field(8; "Cust. Memo Line2"; code[50])
        {
        }
        field(9; "Cust. Memo Line3"; Code[50])
        {
        }
        field(10; "Event Type"; Code[20])
        {
        }
        field(11; "Exchange Rate"; Decimal)
        {
        }
        field(12; Narration; Text[150])
        {
        }
        field(13; "Value Date"; Date)
        {
        }
        field(14; "Posting Date"; Date)
        {
        }
        field(15; "Payment Ref."; Code[50])
        {
        }
        field(16; "Transaction Date"; DateTime)
        {
        }
        field(17; "Transaction Id"; Code[20])
        {
        }
        field(18; "Transaction Type"; Code[20])
        {
        }
        field(19; "Created By"; Code[100])
        {
        }
        field(20; "Created On"; DateTime)
        {
        }
        field(21; "Posted On"; DateTime)
        {
        }
        field(22; Posted; Boolean)
        {
        }
    }
    keys
    {
        key(Key1; "Entry No")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        // Add changes to field groups here
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
