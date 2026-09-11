page 52203968 "Tenant Bill Schedule Lines"
{
    AutoSplitKey = true;
    PageType = ListPart;
    SourceTable = "Tenant Bill Schedule Lines";
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Cost Type"; Rec."Cost Type")
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Description"; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Amount"; Rec.Amount)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
    }
}
