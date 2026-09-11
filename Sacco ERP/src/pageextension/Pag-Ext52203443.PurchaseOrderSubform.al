pageextension 52203443 "Purchase Order Subform" extends "Purchase Order Subform"
{
    layout
    {
        // Add changes to page layout here
        modify("Location Code")
        {
            Editable = ((Rec.Type = Rec.Type::Item) or (Rec.Type = Rec.Type::"Fixed Asset"));
        }
        modify("VAT Prod. Posting Group")
        {
            Visible = true;
        }
        modify("Bin Code")
        {
            Visible = false;
        }
        modify("Reserved Quantity")
        {
            Visible = false;
        }
        modify("Qty. to Assign")
        {
            Visible = false;
        }
        modify("Qty. Assigned")
        {
            Visible = false;
        }
        modify("Promised Receipt Date")
        {
            Visible = false;
        }
        modify("Planned Receipt Date")
        {
            Visible = false;
        }
        modify("Expected Receipt Date")
        {
            Visible = false;
        }
        modify("Over-Receipt Code")
        {
            Visible = false;
        }
        modify("Over-Receipt Quantity")
        {
            Visible = false;
        }
        modify("Tax Area Code")
        {
            Visible = false;
        }
        modify("Appl.-to Item Entry")
        {
            Visible = false;
        }
        modify("Item Charge Qty. to Handle")
        {
            Visible = false;
        }
        modify("Direct Unit Cost")
        {
            Caption = 'Direct Unit Cost';

            trigger OnAfterValidate()
            begin
                Rec."Direct Unit Cost" := Round(Rec."Direct Unit Cost", 0.01);
            end;
        }
        addafter("Item Charge Qty. to Handle")
        {
            field("&Line Discount %"; Rec."Line Discount %")
            {
                ApplicationArea = All;
            }
            field("&Line Discount Amount"; Rec."Line Discount Amount")
            {
                ApplicationArea = All;
            }
        }
        addafter(ShortcutDimCode6)
        {
            field("FA Posting Type"; Rec."FA Posting Type")
            {
                ApplicationArea = Basic, Suite;
            }
        }
        addafter(ShortcutDimCode8)
        {
            field("Procurement Plan No."; Rec."Procurement Plan No.")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
            }
            field("Budget Available"; Rec."Budget Available")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
            }
        }
    }
}
