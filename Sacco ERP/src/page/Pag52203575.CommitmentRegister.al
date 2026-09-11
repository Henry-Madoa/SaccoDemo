page 52203575 "Commitment Register"
{
    Editable = false;
    PageType = List;
    SourceTable = "Commitment Register";

    layout
    {
        area(content)
        {
            repeater(Control11)
            {
                ShowCaption = false;

                field("Entry No"; Rec."Entry No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Commitment Date"; Rec."Commitment Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Budget Line"; Rec."Budget Line")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Commitment Type"; Rec."Commitment Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Budget Year"; Rec."Budget Year")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
