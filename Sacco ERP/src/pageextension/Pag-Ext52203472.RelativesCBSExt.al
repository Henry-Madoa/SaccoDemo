pageextension 52203472 "Relatives CBS Ext." extends Relatives
{
    layout
    {
        // Add changes to page layout here
        addafter(Description)
        {
            field("Exempt Age Limit"; Rec."Exempt Age Limit")
            {
                ApplicationArea = Basic, Suite;
            }
            field("For Dependant"; Rec."For Dependant")
            {
                ApplicationArea = Basic, Suite;
            }
            field(Minor; Rec.Minor)
            {
                ApplicationArea = Basic, Suite;
            }
            field("Is Spouse"; Rec."Is Spouse")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
