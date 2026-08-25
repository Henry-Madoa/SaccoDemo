page 52204189 "Job Execution Entries"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Job Execution Entries";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    SourceTableView = sorting("Entry No")order(descending);

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
                field("Document No"; Rec."Document No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Run Date"; Rec."Run Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member No"; Rec."Member No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Credit Account"; Rec."Credit Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Task Type"; Rec."Task Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("SASA Amount"; Rec."SASA Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Investment Amount"; Rec."Investment Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Deposits Amount"; Rec."Deposits Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Transactions Count"; Rec."Transactions Count")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
