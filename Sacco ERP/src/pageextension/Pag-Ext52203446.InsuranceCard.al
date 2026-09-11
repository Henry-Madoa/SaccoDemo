pageextension 52203446 "Insurance Card" extends "Insurance Card"
{
    layout
    {
        modify("Effective Date")
        {
            ShowCaption = true;
        }
        modify("Expiration Date")
        {
            Editable = false;
        } // Add changes to page layout here
        addafter("Effective Date")
        {
            field("Insurance Tenure"; Rec."Insurance Tenure")
            {
                ApplicationArea = Basic, Suite;
                ShowMandatory = true;
                ToolTip = 'No. of insurance tenure in month.';
            }
        }
    }
}
