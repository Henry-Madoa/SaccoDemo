page 52203612 "Budget User Roles"
{
    PageType = Card;
    SourceTable = "Budget Users";
    Caption = 'User Budget Roles';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(UserName; Rec.UserName)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Full Name"; Rec."Full Name")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part(Control; "User Budget Roles")
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "User ID"=field(UserName);
            }
        }
    }
}
