pageextension 52203434 "Bank Account List" extends "Bank Account List"
{
    layout
    {
        // Add changes to page layout here   
        addafter(Contact)
        {
            field(Balance; Rec.Balance)
            {
                ApplicationArea = Basic, Suite;
            }
            field("Balance (LCY)"; Rec."Balance (LCY)")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
