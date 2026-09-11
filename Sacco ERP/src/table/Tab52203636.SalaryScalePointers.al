table 52203636 "Salary Scale Pointers"
{
    fields
    {
        field(1; Scale; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Pointer; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Basic Pay"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(4; Sequence; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; Scale, Pointer)
        {
        }
        key(Key2; Sequence)
        {
        }
    }
}
