page 52204199 "Mobile Transactions Dump"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Channel Transaction Dump";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No"; Rec."Entry No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("MPESA Code"; Rec."MPESA Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Document No"; Rec."Document No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Credit Member"; Rec."Credit Member")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Credit Member Name"; Rec."Credit Member Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Credit Account"; Rec."Credit Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Debit Member"; Rec."Debit Member")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Debit Member Name"; Rec."Debit Member Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Debit Account"; Rec."Debit Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Posting Type"; Rec."Posting Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Transaction Type Name"; Rec."Transaction Type Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
