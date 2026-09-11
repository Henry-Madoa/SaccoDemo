pageextension 52203447 "Purchase Order List" extends "Purchase Order List"
{
    layout
    {
        // Add changes to page layout here
        addafter("Amount Including VAT")
        {
            field("Last Date Modified"; Rec."Last Date Modified")
            {
                Editable = false;
            }
        }
    }
}
