table 52203607 "Training Calender"
{
    fields
    {
        field(1; "Calender Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Current Period"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(5; Closed; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(6; "Opened by"; Code[70])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(7; "Opened On"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(8; "Closed On"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(9; "Closed By"; Code[70])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Calender Code")
        {
        }
    }
}
