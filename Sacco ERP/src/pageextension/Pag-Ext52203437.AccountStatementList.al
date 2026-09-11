pageextension 52203437 "Account Statement List" extends "Bank Account Statement List"
{
    actions
    {
        // Add changes to page actions here
        addafter(Print)
        {
            action("Unreconciling Report")
            {
                ApplicationArea = Basic, Suite;
                Ellipsis = true;
                Image = Print;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                Scope = Repeater;
                ToolTip = 'Prepare to print the document. A report request window for the document opens where you can specify what to include on the print-out.';

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
