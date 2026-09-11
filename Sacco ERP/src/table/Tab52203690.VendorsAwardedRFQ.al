table 52203690 "Vendors Awarded RFQ"
{
    fields
    {
        field(1; "RFQ No."; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Vendor Awarded."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "RFQ No.", "Vendor Awarded.")
        {
        }
    }
}
