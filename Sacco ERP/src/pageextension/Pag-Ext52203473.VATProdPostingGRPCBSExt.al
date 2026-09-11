pageextension 52203473 "VAT Prod Posting GRP CBS Ext." extends "VAT Product Posting Groups"
{
    layout
    {
        // Add changes to page layout here
        addafter(Description)
        {
            field(Type; Rec.Type)
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
