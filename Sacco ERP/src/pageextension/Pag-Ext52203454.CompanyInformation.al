pageextension 52203454 "Company Information" extends "Company Information"
{
    layout
    {
        // Add changes to page layout here
        addafter(General)
        {
            group("Pension Details")
            {
                field("Pension No."; Rec."Pension No.")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
        addlast(General)
        {
            field("Demo Company"; Rec."Demo Company")
            {
                ApplicationArea = Basic, Suite;
                Editable = true;
            }
        }
    }
}
