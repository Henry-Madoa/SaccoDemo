pageextension 52203432 "Sales Invoice" extends "Sales Invoice"
{
    actions
    {
        // Add changes to page actions here
        addlast("P&osting")
        {
            action("&Print")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Report;

                trigger OnAction()
                begin
                    Rec.Reset();
                    Rec.SetRange("No.", Rec."No.");
                    Rec.SetRange("Sell-to Customer No.", Rec."Sell-to Customer No.");
                    Report.Run(Report::"Sale - Invoice", true, false, Rec);
                end;
            }
        }
    }
}
