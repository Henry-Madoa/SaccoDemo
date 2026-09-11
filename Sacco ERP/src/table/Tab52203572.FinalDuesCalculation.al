table 52203572 "Final Dues Calculation"
{
    fields
    {
        field(1; "Employee No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Exit No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Line No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(4; Description; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Amount To Pay"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Include in Payment"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Days Balance"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(8; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(9; Remarks; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(10; Type; Option)
        {
            Editable = false;
            OptionMembers = " ", "Leave Encashment", Gratuity, "Notice Penalty", "Notice Income", "Uncleared Items";
        }
    }
    keys
    {
        key(Key1; "Employee No.", "Line No", "Exit No")
        {
        }
    }
}
