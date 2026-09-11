pageextension 52203448 "Fixed Asset List" extends "Fixed Asset List"
{
    layout
    {
        // Add changes to page layout here
        addafter("FA Location Code")
        {
            field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
            {
                ApplicationArea = Basic, Suite;
            }
        }
        addbefore(Acquired)
        {
            field("Asset Tag"; Rec."Asset Tag")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
