page 52203928 "Motor Vehicle Ledger Entries"
{
    ApplicationArea = All;
    AutoSplitKey = true;
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';
    SourceTable = "Motor Vehicle Ledger";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No"; Rec."Entry No")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = All;
                }
                field("Vehicle REG. No"; Rec."Vehicle REG. No")
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("Posting Description"; Rec."Posting Description")
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
    }
}
