page 52204201 "Mobile Responses"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Mobile Responses";
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
                field("Request ID"; Rec."Request ID")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Transaction Code"; Rec."Transaction Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Response Code"; Rec."Response Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Response Message"; Rec."Response Message")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created At"; Rec."Created At")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
