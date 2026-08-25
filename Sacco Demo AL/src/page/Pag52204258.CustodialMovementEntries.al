page 52204258 "Custodial Movement Entries"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "Custodial Movement";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Collected By"; Rec."Collected By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Expected Return Date"; Rec."Expected Return Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Collected By Phone No"; Rec."Collected By Phone No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Collected By ID  No"; Rec."Collected By ID  No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
