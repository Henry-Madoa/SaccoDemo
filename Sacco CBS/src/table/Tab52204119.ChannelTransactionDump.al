table 52204119 "Channel Transaction Dump"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No"; Integer)
        {
        }
        field(2; "Document No"; Code[20])
        {
        }
        field(3; "Credit Member"; Code[20])
        {
        }
        field(4; "Credit Account"; Code[20])
        {
        }
        field(5; "Debit Member"; Code[20])
        {
        }
        field(6; "Debit Account"; Code[20])
        {
        }
        field(7; Amount; Decimal)
        {
        }
        field(8; "Posting Type"; Option)
        {
            OptionMembers = Credit, Debit;
        }
        field(9; "Transaction Type"; Code[20])
        {
        }
        field(10; "Transaction Type Name"; Text[150])
        {
        }
        field(11; "Credit Member Name"; Text[250])
        {
        }
        field(12; "Debit Member Name"; Text[250])
        {
        }
        field(13; "Posting Date"; Date)
        {
        }
        field(14; "MPESA Code"; Code[20])
        {
        }
    }
    keys
    {
        key(Key1; "Document No")
        {
            Clustered = true;
        }
    }
}
