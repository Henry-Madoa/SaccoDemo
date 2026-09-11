table 52203746 "Motor Vehicle Ledger"
{
    fields
    {
        field(1; "Entry No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Posting Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Transaction Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Fuel,Insurance,Maintenance';
            OptionMembers = Fuel, Insurance, Maintenance;
        }
        field(4; "Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Posting Description"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(6; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Amount (LCY)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Vehicle REG. No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Entry No")
        {
        }
    }
}
