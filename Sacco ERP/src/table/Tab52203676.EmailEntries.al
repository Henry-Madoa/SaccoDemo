table 52203676 "Email Entries"
{
    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; Recipient; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(3; Subject; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(4; Body; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Date to Send"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(6; Regards; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(7; CC; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(8; Sent; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Sender Name"; Text[230])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Sender Address"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Date Sent"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Time Sent"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Email Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ',PV,Budget,Imprest,Approval,Medical Balance Notice,Notification';
            OptionMembers = , PV, Budget, Imprest, Approval, "Medical Balance Notice", Notification;
        }
    }
    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }
}
