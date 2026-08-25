table 52204033 "Defaulter Notice Lines"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            Editable = false;
        }
        field(2; "Loan No"; Code[20])
        {
            Editable = false;
        }
        field(3; "Member No"; Code[20])
        {
            Editable = false;
        }
        field(4; "Member Name"; Text[100])
        {
            Editable = false;
        }
        field(5; "Product Code"; Code[20])
        {
            Editable = false;
        }
        field(6; "Product Description"; Text[100])
        {
            Editable = false;
        }
        field(7; "Total Arrears"; Decimal)
        {
            Editable = false;
        }
        field(8; "Defaulted Days"; Integer)
        {
            Editable = false;
        }
        field(9; "Defaulted Installments"; Integer)
        {
            Editable = false;
        }
        field(10; "Notice Type"; Option)
        {
            OptionMembers = "1st","2nd","3rd";
        }
        field(11; Notified; Boolean)
        {
            Editable = false;
        }
        field(12; "E-Mail"; Text[100])
        {
            Editable = false;
        }
        field(13; "Self Guarantee"; Boolean)
        {
            Editable = false;
        }
        field(14; "Skip Reason"; Text[100])
        {
            trigger OnValidate()
            begin
                if "Skip Reason" <> '' then
                    Skip := true
                else
                    Skip := false;
            end;
        }
        field(15; Skip; Boolean)
        {
            Editable = false;
        }
        field(16; "Loan Balance"; Decimal)
        {
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "No.", "Loan No")
        {
            Clustered = true;
        }
    }
}
