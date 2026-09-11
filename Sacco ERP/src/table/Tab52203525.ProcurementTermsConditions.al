table 52203525 "Procurement Terms & Conditions"
{
    fields
    {
        field(1; "No."; Code[10])
        {
        }
        field(2; "Document Type"; Option)
        {
            OptionCaption = 'Quote,Order,Invoice,Receipt';
            OptionMembers = Quote, "Order", Invoice, Receipt;
        }
        field(3; Description; Text[250])
        {
        }
        field(4; "Further Description"; Text[250])
        {
        }
    }
    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; "Document Type")
        {
        }
    }
}
