table 52203511 "Committees"
{
    fields
    {
        field(1; "Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(2; Description; Text[200])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(3; Comments; Text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(4; Interview; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Code")
        {
        }
    }
}
