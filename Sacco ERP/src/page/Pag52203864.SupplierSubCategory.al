page 52203864 "Supplier Sub-Category"
{
    ApplicationArea = All;
    PageType = List;
    SourceTable = "Supplier Sub-Category";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Category Code"; Rec."Category Code")
                {
                    ApplicationArea = All;
                }
                field("Sub-Category Code"; Rec."Sub-Category Code")
                {
                    ApplicationArea = All;
                }
                field("Sub-Category Description"; Rec."Sub-Category Description")
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
