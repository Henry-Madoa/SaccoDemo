page 52204176 "Mobile Ledger"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Mobile Member Ledger";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No"; Rec."Entry No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Document No"; Rec."Document No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member No"; Rec."Member No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Posting Time"; Rec."Posting Time")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
