pageextension 52203441 "Maintenance Registration" extends "Maintenance Registration"
{
    layout
    {
        // Add changes to page layout here
        addafter("Service Agent Phone No.")
        {
            field("Next Service Date"; Rec."Next Service Date")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
        }
    }
}
