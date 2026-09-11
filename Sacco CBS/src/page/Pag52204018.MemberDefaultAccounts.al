page 52204018 "Member Default Accounts"
{
    PageType = ListPart;
    SourceTable = "Member Default Accounts";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Product Code"; Rec."Product Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Product Description"; Rec."Product Description")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
