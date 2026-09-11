pageextension 52204003 "Company Information CBS" extends "Company Information"
{
    layout
    {
        addafter(Picture)
        {
            field("Company Watermark"; Rec."Company Watermark")
            {
                ApplicationArea = Basic, Suite;
            }
            field(Signature; Rec.Signature)
            {
                ApplicationArea = Basic, Suite;
            }
        }
        addafter("Bank Account No.")
        {
            field("Paybill No."; Rec."Paybill No.")
            {
                ApplicationArea = Basic, Suite;
                ShowMandatory = true;
            }
        }
    }
}
