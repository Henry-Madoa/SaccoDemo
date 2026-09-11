pageextension 52204020 "Vendor Posting Group Card" extends "Vendor Posting Group Card"
{
    layout
    {
        addafter("Payables Account")
        {
            field("Interest Accrual Account"; Rec."Interest Accrual Account")
            {
                ApplicationArea = Basic, Suite;
                ShowMandatory = true;
            }
        }
    }
}
