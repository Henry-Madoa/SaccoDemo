pageextension 52203431 "Customer Card" extends "Customer Card"
{
    layout
    {
        // Add changes to page layout here
        addlast(Invoicing)
        {
            field(Rent; Rec.Rent)
            {
                ApplicationArea = Basic, Suite;
            }
        }
        addbefore(Payments)
        {
            part("Customer Charges"; "Customer Charges")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Customer No." = field("No.");
                Visible = Rec."Customer Posting Group" = 'TENANT';
            }
        }
    }
    actions
    {
        // Add changes to page actions here
        addlast("Prices and Discounts")
        {
            action("Customer &Charges")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedIsBig = true;
                Image = SuggestFinancialCharge;
                PromotedCategory = Category7;
                RunObject = page "Customer Charges";
                RunPageLink = "Customer No." = field("No.");
                Visible = Rec."Customer Posting Group" = 'TENANT';
            }
        }
    }
}
