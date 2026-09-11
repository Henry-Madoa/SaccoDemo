tableextension 52203425 "VAT Prod Posting GRP CBS Ext." extends "VAT Product Posting Group"
{
    fields
    {
        // Add changes to table fields here
        field(52204000; Type; Option)
        {
            OptionMembers = " ", VAT, WHT, Allowance;
        }
    }
}
