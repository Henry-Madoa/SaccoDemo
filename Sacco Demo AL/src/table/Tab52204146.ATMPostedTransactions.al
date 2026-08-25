table 52204146 "ATM Posted Transactions"
{
    LookupPageId = "ATM Transactions";
    DrillDownPageId = "ATM Transactions";
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
        }
        field(2; "Document No."; Text[250])
        {
        }
        field(3; "Reference No"; Text[250])
        {
        }
        field(4; "Posting Date"; Date)
        {
        }
        field(5; "Log Time"; DateTime)
        {
        }
        field(6; "Account No"; Code[20])
        {
        }
        field(7; "Description"; Text[200])
        {
        }
        field(8; "Amount"; Decimal)
        {
        }
        field(9; "Posting Description"; Text[50])
        {
        }
        field(10; "Posted"; Boolean)
        {
        }
        field(11; "Posting Time"; DateTime)
        {
        }
        field(12; "Unit ID"; Code[10])
        {
        }
        field(13; "Transaction Type"; Text[30])
        {
        }
        field(14; "Trans Time"; Text[50])
        {
        }
        field(15; "Transaction Time"; Time)
        {
        }
        field(16; "Transaction Date"; Date)
        {
        }
        field(17; "Source"; Option)
        {
            OptionMembers = "COOP","M-PESA","ATM","TIETO";
        }
        field(18; "Reversed"; Boolean)
        {
        }
        field(19; "Reversed Posted"; Boolean)
        {
        }
        field(20; "Reversal Trace ID"; Code[20])
        {
        }
        field(21; "Transaction Description"; Text[100])
        {
        }
        field(22; "Withdrawal Location"; Text[150])
        {
        }
        field(23; "Trace ID"; Code[20])
        {
        }
        field(24; "Transaction Type Charges"; Enum "ATM Transaction Type Charges")
        {
        }
        field(25; "ATM Card No"; Code[20])
        {
        }
        field(26; "Customer Names"; Text[250])
        {
        }
        field(27; "Process Code"; Code[20])
        {
        }
        field(28; "Is Coop Bank"; Boolean)
        {
        }
        field(29; "POS Vendor"; Option)
        {
            optionMembers = "ATM Lobby","Agent Banking","Coop Branch","Sacco POS";
        }
        field(30; "Card Acceptor Terminal ID"; Code[50])
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
    trigger OnInsert()
    begin
        "Log Time" := CurrentDateTime;
    end;
}
