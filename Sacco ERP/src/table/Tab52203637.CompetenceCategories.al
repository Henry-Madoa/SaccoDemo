table 52203637 "Competence Categories"
{
    fields
    {
        field(1; "Line No"; Integer)
        {
            AutoIncrement = true;
        }
        field(2; Category; Text[100])
        {
        }
        field(3; "Maximum Weigth"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Line No")
        {
        }
    }
}
