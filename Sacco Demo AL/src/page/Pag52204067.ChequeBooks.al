page 52204067 "Cheque Books"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Cheque Books";
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Serial No"; Rec."Serial No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member No"; Rec."Member No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account No"; Rec."Account No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Application No."; Rec."Application No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("No of Leafs"; Rec."No of Leafs")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Drawn; Rec.Drawn)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
        area(Factboxes)
        {
            part("Member Statistics"; "Member Statistics")
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "No."=field("Member No");
            }
        }
    }
}
