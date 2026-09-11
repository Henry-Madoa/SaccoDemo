pageextension 52203461 "Posted Purchase Invoice" extends "Posted Purchase Invoice"
{
    actions
    {
        // Add changes to page actions here
        addafter("Update Document")
        {
            action("Create Request For Payment")
            {
                ApplicationArea = Basic, Suite;
                Image = CreateSKU;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Enabled = not Rec."Payment Requested";

                trigger OnAction()
                begin
                    Paymentmgmt.InvoicePaymentRequest(Rec);
                end;
            }
        }
    }
    var
        Paymentmgmt: Codeunit "Payment Management";
}
