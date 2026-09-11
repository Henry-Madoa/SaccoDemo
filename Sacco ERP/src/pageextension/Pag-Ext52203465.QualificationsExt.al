pageextension 52203465 "Qualifications Ext" extends Qualifications
{
    layout
    {
        // Add changes to page layout here
        addbefore(Code)
        {
            field("Qualification Type"; Rec."Qualification Type")
            {
                ApplicationArea = Basic, Suite;
            }
        }
        addafter(Description)
        {
            field(Type; Rec.Type)
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
