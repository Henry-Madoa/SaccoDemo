pageextension 52203471 "Payment Methods CBS Ext." extends "Payment Methods"
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
