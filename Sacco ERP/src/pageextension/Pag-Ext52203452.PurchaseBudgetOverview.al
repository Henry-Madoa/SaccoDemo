pageextension 52203452 "Purchase Budget Overview" extends "Purchase Budget Overview"
{
    actions
    {
        // Add changes to page actions here
        addbefore("Export to Excel")
        {
            action(Print)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                Image = Print;
                RunObject = report "Detailed Procurement Plan";
            }
        }
    }
}
