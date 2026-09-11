page 52203621 "Commitment Entries"
{
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "Commitment Entries";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Commitment No"; Rec."Commitment No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Commitment Date"; Rec."Commitment Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Commitment Type"; Rec."Commitment Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Committed Amount"; Rec."Committed Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Entry No"; Rec."Entry No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 1"; Rec."Global Dimension 1")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 2"; Rec."Global Dimension 2")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
