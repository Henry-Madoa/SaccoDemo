table 52204143 "B2B Transactions"
{
    LookupPageId = "B2B Transactions";
    DrillDownPageId = "B2B Transactions";

    fields
    {
        field(1; "Entry No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Source Code"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Transaction Refrence"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Transaction Date"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Total Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(6; Currency; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Document Refrence"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Bank Code"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Branch Code"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Payment Date"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Payment Refrence Code"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Payment Code"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Payment Mode"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Payment Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Account Number"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Account Name"; Text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Institution Code"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Institution Name"; Text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(19; Processed; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Additional Info"; Text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(21; Comments; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(22; Archived; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(23; Status; Option)
        {
            OptionMembers = , Completed, Incomplete;
        }
    }
    keys
    {
        key(Key1; "Entry No")
        {
            Clustered = true;
        }
    }
}
