pageextension 52204018 "Payroll Transaction Code" extends "Payroll Transaction Code Card"
{
    layout
    {
        addafter("Vendor Posting Groups")
        {
            field("Posting Type"; Rec."Posting Type")
            {
                ApplicationArea = Basic, Suite;
                ShowMandatory = true;
            }
            field("Loan Product"; Rec."Loan Product")
            {
                ApplicationArea = Basic, Suite;
                ShowMandatory = true;
            }
        }
    }
}
