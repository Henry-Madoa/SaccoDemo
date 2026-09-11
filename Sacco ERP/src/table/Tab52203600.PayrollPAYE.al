table 52203600 "Payroll PAYE"
{
    fields
    {
        field(1; "Tier Code"; Code[10])
        {
        }
        field(2; "PAYE Tier"; Decimal)
        {
        }
        field(3; Rate; Decimal)
        {
        }
        field(4; "Tax Code"; Code[20])
        {
        }
    }
    keys
    {
        key(Key1; "Tier Code")
        {
        }
    }
}
