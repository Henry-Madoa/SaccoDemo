pageextension 52203427 "Dimension Values" extends "Dimension Value List"
{
    layout
    {
        // Add changes to page layout here
        addafter(Control1)
        {
            field("Global Dimension No."; Rec."Global Dimension No.")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
