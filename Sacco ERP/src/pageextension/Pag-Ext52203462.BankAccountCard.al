pageextension 52203462 "Bank Account Card" extends "Bank Account Card"
{
    layout
    {
        // Add changes to page layout here   
        addbefore("Bank Branch No.")
        {
            field("Bank_Code"; Rec.Bank_Code)
            {
                ApplicationArea = Basic, Suite;
            }
        }
        addafter(Posting)
        {
            group(Administration)
            {
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Tag Code"; Rec."Tag Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Tag Filter"; Rec."Tag Filter")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Custodial Payment Account"; Rec."Custodial Payment Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Minimum Float"; Rec."Minimum Float")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field("Petty Cash Holder"; Rec."Petty Cash Holder")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec."Account Type" = Rec."Account Type"::Cash;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec."Account Type" = Rec."Account Type"::Cash;
                }
            }
        }
    }
}
