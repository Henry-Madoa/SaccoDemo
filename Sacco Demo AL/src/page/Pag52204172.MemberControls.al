page 52204172 "Member Controls"
{
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = Members;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Guarantee Blocked"; Rec."Guarantee Blocked")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part("Mobile Loan Block"; "Channel Loan Block")
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "Member No"=field("No.");
            }
        }
        area(FactBoxes)
        {
            part(Member; "Member Statistics")
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "No."=field("No.");
            }
        }
    }
}
