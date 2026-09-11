pageextension 52203436 "Bank Account Statement" extends "Bank Account Statement"
{
    actions
    {
        // Add changes to page actions here
        addafter(Print)
        {
            action("Unreconciling Report")
            {
                ApplicationArea = Basic, Suite;
                Image = PrintDocument;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    BankAccReconciliation.Reset;
                    BankAccReconciliation.SetRange("Bank Account No.", Rec."Bank Account No.");
                    BankAccReconciliation.SetRange("Statement No.", Rec."Statement No.");
                    if BankAccReconciliation.FindFirst then REPORT.Run(Report::"Bank Rec-Unreconciling Entries", true, false, BankAccReconciliation);
                end;
            }
        }
    }
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
}
