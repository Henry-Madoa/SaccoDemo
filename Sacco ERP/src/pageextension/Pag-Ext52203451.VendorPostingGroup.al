pageextension 52203451 "Vendor Posting Group" extends "Vendor Posting Groups"
{
    layout
    {
        // Add changes to page layout here
        addafter(Description)
        {
            field("Account Type"; Rec."Account Type")
            {
                ApplicationArea = Basic, Suite;
                ShowMandatory = true;
            }
        }
    }
}
