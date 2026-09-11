table 52203684 "Disposal Customers"
{
    fields
    {
        field(1; "Disposal No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Customer Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Customer E-Mail"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Customer Phone No"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Quoted Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(6; Selected; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Disposal No", "Customer Name")
        {
        }
    }
}
