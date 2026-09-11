table 52203442 "Leave Calendar Lines"
{
    fields
    {
        field(1; "Code"; Code[10])
        {
        }
        field(2; Day; Text[40])
        {
            Editable = false;
        }
        field(3; Date; Date)
        {
            Editable = false;
        }
        field(4; "Non Working"; Boolean)
        {
        }
        field(5; Reason; Text[40])
        {
        }
    }
    keys
    {
        key(Key1; "Code", Date)
        {
        }
    }
}
