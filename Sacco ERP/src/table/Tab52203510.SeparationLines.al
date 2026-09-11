table 52203510 "Separation Lines"
{
    fields
    {
        field(1; "Employee No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Item; Code[20])
        {
        }
        field(3; "Item Description"; Text[80])
        {
            DataClassification = ToBeClassified;
        }
        field(4; Cleared; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Cleared Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(6; Department; Option)
        {
            OptionMembers = " ", HR, IT, Finance;
        }
        field(7; Remarks; Text[80])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Employee No", Item)
        {
        }
    }
}
