table 52203512 "Rules & Regulations"
{
    DrillDownPageID = "Rules & Regulations";
    LookupPageID = "Rules & Regulations";

    fields
    {
        field(1; "Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Date; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Rules & Regulations"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Document Link"; Text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(5; Remarks; Text[200])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(6; "Language Code (Default)"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(7; Attachement; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = No, Yes;
        }
    }
    keys
    {
        key(Key1; "Code")
        {
        }
    }
}
