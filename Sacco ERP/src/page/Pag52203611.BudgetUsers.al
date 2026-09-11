page 52203611 "Budget Users"
{
    PageType = List;
    Caption = 'Users Budget Roles';
    CardPageId = "Budget User Roles";
    Editable = false;
    ModifyAllowed = false;
    SourceTable = "Budget Users";

    layout
    {
        area(Content)
        {
            repeater(General)
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
        }
    }
}
