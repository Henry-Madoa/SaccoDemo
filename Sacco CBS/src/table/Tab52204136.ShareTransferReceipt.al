table 52204136 "Share Transfer Receipt"
{
    fields
    {
        field(1; "Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Refrence No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(3; Description; Text[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(4; "Original Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5; "Remaining Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(6; "Allocated Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;

            trigger OnValidate()
            begin
                if "Allocated Amount" > "Remaining Amount" then Error('You Can Only Allocate Upto %1', "Remaining Amount");
            end;
        }
        field(7; "Account No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Document No.", "Refrence No.")
        {
            Clustered = true;
        }
    }
}
