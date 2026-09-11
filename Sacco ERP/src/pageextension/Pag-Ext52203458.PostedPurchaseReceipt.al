pageextension 52203458 "Posted Purchase Receipt" extends "Posted Purchase Receipt"
{
    actions
    {
        // Add changes to page actions 
        addafter("&Print")
        {
            action(GRN)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Print;

                trigger OnAction()
                begin
                    Rec.Reset();
                    Rec.SetRange("No.", Rec."No.");
                    Report.Run(50207, true, false, Rec);
                end;
            }
        }
        modify("&Print")
        {
            Visible = false;
        }
    }
}
