page 52204192 "SMS Ledger"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "SMS Ledger";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    SourceTableView = sorting("Entry No") order(descending);

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("SMS Message"; Rec."SMS Message")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Phone No"; Rec."Phone No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Sent On"; Rec."Sent On")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
