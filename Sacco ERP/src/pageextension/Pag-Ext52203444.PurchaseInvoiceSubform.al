pageextension 52203444 "Purchase Invoice Subform" extends "Purch. Invoice Subform"
{
    layout
    {
        // Add changes to page layout here
        modify("Tax Area Code")
        {
            Visible = false;
        }
        modify("Tax Group Code")
        {
            Visible = false;
        }
        modify("VAT Prod. Posting Group")
        {
            Visible = true;
        }
        addafter(ShortcutDimCode8)
        {
            field("Budget Available"; Rec."Budget Available")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
            }
        }
        modify(Description)
        {
            Editable = false;
            Visible = false;
        }
        modify("Line Amount")
        {
            Editable = false;
            Visible = false;
        }
        addafter("Line Discount %")
        {
            field("&Line Discount Amount"; Rec."Line Discount Amount")
            {
                ApplicationArea = All;
            }
        }
    }
}
