pageextension 52204019 "Vendor Posting Groups" extends "Vendor Posting Groups"
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
