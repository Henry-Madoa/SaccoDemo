pageextension 52203429 "Grounds for Termination" extends "Grounds for Termination"
{
    layout
    {
        // Add changes to page layout here
        addafter(Description)
        {
            field(Type; Rec.Type)
            {
                ApplicationArea = Basic, Suite;
            }
            field("Pay Gratuity"; Rec."Pay Gratuity")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
