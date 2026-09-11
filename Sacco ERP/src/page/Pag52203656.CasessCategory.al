page 52203656 "Casess Category"
{
    PageType = List;
    SourceTable = "Cases Category";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Category Code"; Rec."Category Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Category Desription"; Rec."Category Desription")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}
