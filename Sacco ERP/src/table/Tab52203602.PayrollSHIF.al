table 52203602 "Payroll SHIF"
{
    fields
    {
        field(1; "Tier Code"; Code[10])
        {
            SQLDataType = Integer;
        }
        field(2; "SHIF Tier"; Decimal)
        {
        }
        field(3; Amount; Decimal)
        {
        }
        field(4; "Lower Limit"; Decimal)
        {
        }
        field(5; "Upper Limit"; Decimal)
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
