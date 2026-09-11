table 52203681 "Fixed Deposit Schedule"
{
    DataCaptionFields = "Entry No.", "No.", Description, Amount;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Entry Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Interest Due,Payment Due,Principle Due';
            OptionMembers = "Interest Due", "Payment Due", "Principle Due";
        }
        field(4; Description; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(5; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Posting Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Investment No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Outstanding Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(9; "Actual Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Witholding Tax"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Actual Posting Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(12; Posted; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Posted By"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Posted On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Posted At"; Time)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }
}
