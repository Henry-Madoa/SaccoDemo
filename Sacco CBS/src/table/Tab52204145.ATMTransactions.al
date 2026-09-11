table 52204145 "ATM Transactions"
{
    LookupPageId = "ATM Transactions";
    DrillDownPageId = "ATM Transactions";
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
        }
        field(2; "Document No."; Code[20])
        {
        }
        field(3; "Reference No"; Code[250])
        {
        }
        field(4; "Transaction Type"; Code[20])
        {
        }
        field(5; "Transaction Name"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Channel Transaction Setup".Description where(Code = field("Transaction Type")));
            Editable = false;
        }
        field(6; "Posting Type"; Option)
        {
            OptionMembers = Debit,Credit,Reversal;
        }
        field(7; "Card No"; Code[20])
        {
        }
        field(8; "Account No"; Code[20])
        {
        }
        field(9; "Member No"; Code[20])
        {
            trigger OnValidate()
            var
                Member: Record Members;
            begin
                If Member.Get("Member No") then "Member Name" := Member.FullName;
            end;
        }
        field(10; "Member Name"; Text[80])
        {
        }
        field(15; "Amount"; Decimal)
        {
        }
        // field(11; "Posting Description"; Text[50])
        // {
        // }
        field(12; Location; Text[1000])
        {
        }
        field(13; "Device Type"; Text[250])
        {
        }
        field(16; "Posting Date"; Date)
        {
        }
        field(17; "Posted"; Boolean)
        {
        }
        field(18; "Posting Time"; DateTime)
        {
        }
        field(19; "Transaction Time"; Time)
        {
        }
        field(20; "Transaction Date"; Date)
        {
        }
        field(21; Reversal; Boolean)
        {
        }
        field(22; "Reversed Posted"; Boolean)
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
}
