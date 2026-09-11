page 52203765 "Investment Posting Groups"
{
    CardPageID = "Investment Posting Group";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Investment Posting Group";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec.Group)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Debit Account No."; Rec."Debit Account No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Credit Account No."; Rec."Credit Account No.")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
