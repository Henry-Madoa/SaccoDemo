table 52203632 "Score Cards"
{
    fields
    {
        field(1; Rating; Code[10])
        {
        }
        field(2; Description; Text[30])
        {
        }
        field(3; "Score %"; Decimal)
        {
            trigger OnValidate()
            begin
                if "Score %" > 100 then Error('% Cannt be More than 100');
            end;
        }
    }
    keys
    {
        key(Key1; Rating)
        {
        }
    }
}
