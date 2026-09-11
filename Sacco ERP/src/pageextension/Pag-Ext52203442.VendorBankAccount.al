pageextension 52203442 "Vendor Bank Account" extends "Vendor Bank Account Card"
{
    layout
    {
        // Add changes to page layout here 
        addafter("SWIFT Code")
        {
            field("Bank Sort Code"; Rec."Bank Sort Code")
            {
                ApplicationArea = Basic, Suite;
                ShowMandatory = true;
                Numeric = true;
            }
        }
    }
}
