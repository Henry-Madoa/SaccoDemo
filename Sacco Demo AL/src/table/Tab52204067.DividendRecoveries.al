table 52204067 "Dividend Recoveries"
{
    DrillDownPageID = "Dividend Recoveries";
    LookupPageID = "Dividend Recoveries";

    fields
    {
        field(1; "Dividend Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Entry Type"; Enum "Dividend Recovery Types")
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Recovery Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(4; Description; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Member No"; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                Member: Record Members;
            begin
                if Member.Get("Member No") then "Member Name" := Member.FullName;
            end;
        }
        field(6; "Member Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(7; "Account No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Loan No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Product Posting Type"; Enum "Product Posting Type")
        {
            DataClassification = ToBeClassified;
        }
        field(10; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(11; Priority; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Dividend Code", "Entry Type", "Recovery Code", "Member No", "Account No.")
        {
            Clustered = true;
        }
        key(Key2; Priority)
        {
        }
    }
}
