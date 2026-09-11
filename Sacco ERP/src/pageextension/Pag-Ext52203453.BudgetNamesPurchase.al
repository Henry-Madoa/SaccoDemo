pageextension 52203453 "Budget Names Purchase" extends "Budget Names Purchase"
{
    actions
    {
        // Add changes to page actions here
        addafter(EditBudget)
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
