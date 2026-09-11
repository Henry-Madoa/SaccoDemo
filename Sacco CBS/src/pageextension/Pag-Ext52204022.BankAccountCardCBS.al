pageextension 52204022 "Bank Account Card CBS" extends "Bank Account Card"
{
    actions
    {
        addbefore("Detail Trial Balance")
        {
            action("Cash Book")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Cash Book';
                Image = "Report";

                trigger OnAction()
                begin
                    Rec.Reset();
                    Rec.SetRange("No.", Rec."No.");
                    if Rec.FindFirst then Report.Run(Report::"Cash Book", true, false, Rec);
                end;
            }
        }
    }
}
